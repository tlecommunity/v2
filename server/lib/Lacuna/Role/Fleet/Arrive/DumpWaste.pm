package Lacuna::Role::Fleet::Arrive::DumpWaste;

use strict;
use Moose::Role;

after handle_arrival_procedures => sub {
    my ($self) = @_;

    # we're coming home
    return if ($self->direction eq 'in');

    # we're dumping on a star, nothing to do but go home
    if ($self->foreign_star_id) {
        $self->payload({ resources => { waste => 0 } });
        $self->update;
        return;
    }

    # dump it!
    my $body_attacked = $self->foreign_body;
    # If a scow crashes into an unclaimed planet, does anyone hear?
    unless ($body_attacked->empire) {
        $self->delete;
        confess [-1];
    }
    my $payload = $self->payload;
    my $waste_dumped = 0;
    if (defined($payload->{resources})) {
        $waste_dumped = $payload->{resources}{waste} if defined($payload->{resources}{waste});
    }
    $body_attacked->add_waste($waste_dumped);
    $body_attacked->update;

    unless ($self->body->empire->skip_attack_messages) {
        $self->body->empire->send_predefined_message(
            tags        => ['Attack','Alert'],
            filename    => 'our_scow_hit.txt',
            params      => [$body_attacked->x, $body_attacked->y, $body_attacked->name, $self->hold_size],
        );
    }

    unless ($body_attacked->empire->skip_attack_messages) {
        $body_attacked->empire->send_predefined_message(
            tags        => ['Attack','Alert'],
            filename    => 'hit_by_scow.txt',
            params      => [$self->body->empire_id, $self->body->empire->name, $body_attacked->id, $body_attacked->name, $self->hold_size],
        );
    }

    $body_attacked->add_news(30, sprintf('%s is so polluted that waste seems to be falling from the sky.', $body_attacked->name));

    my $logs = Lacuna->db->resultset('Log::Battles');
    $logs->new({
        date_stamp => DateTime->now,
        attacking_empire_id     => $self->body->empire_id,
        attacking_empire_name   => $self->body->empire->name,
        attacking_body_id       => $self->body_id,
        attacking_body_name     => $self->body->name,
        attacking_unit_name     => $self->name,
        attacking_type          => $self->type_formatted,
        defending_empire_id     => $body_attacked->empire_id,
        defending_empire_name   => $body_attacked->empire->name,
        defending_body_id       => $body_attacked->id,
        defending_body_name     => $body_attacked->name,
        defending_unit_name     => '',
        defending_type          => '',
        attacked_empire_id      => $body_attacked->empire_id,
        attacked_empire_name    => $body_attacked->empire->name,
        attacked_body_id        => $body_attacked->id,
        attacked_body_name      => $body_attacked->name,
        victory_to              => 'attacker',
    })->insert;

    # all pow
    $self->delete;
    confess [-1];
};

after send => sub {
    my $self = shift;
    my $waste_sent;
    if ($self->body->waste_stored < $self->hold_size) {
        $waste_sent = $self->body->waste_stored > 0 ? $self->body->waste_stored : 0;
    }
    else {
        $waste_sent = $self->hold_size;
    }
    $self->body->spend_waste($waste_sent)->update;
    $self->payload({ resources => { waste => $waste_sent } });
    $self->update;
};

after can_send_to_target => sub {
    my ($self, $target) = @_;
    confess [1013, 'Can only be sent to inhabited planets.'] if ($target->isa('Lacuna::DB::Result::Map::Body::Planet') && !$target->empire_id);
    confess [1011, 'You have no waste to transport.' ] unless ($self->body->waste_stored > 0);
#    confess [1011, 'You do not have enough waste to fill this scow. You need '.$self->hold_size.' waste to launch.'] unless ($self->body->waste_stored > $self->hold_size);
};

1;
