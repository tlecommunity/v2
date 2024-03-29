package Lacuna::RPC::Building::Embassy;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'Lacuna::RPC::Building';
use Lacuna::Constants qw(FOOD_TYPES ORE_TYPES);
use Guard qw(guard);

sub app_url {
    return '/embassy';
}

around 'view' => sub {
    my ($orig, $self, %args) = @_;
    my $session  = $self->get_session({session_id => $args{session_id}, building_id => $args{building_id}, skip_offline => 1 });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $out = $orig->($self, (%args));
    my $alliance = eval{$building->alliance};
    if (defined $alliance) {
        $out->{alliance_status} = $alliance->get_status;
    }
    return $out;
};

sub model_class {
    return 'Lacuna::DB::Result::Building::Embassy';
}

sub assign_alliance_leader {
    my ($self, $session_id, $building_id, $empire_id, $message) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    unless ($empire_id) {
        confess [1002, 'You must specify which empire you want to take over leadership.'];
    }
    my $new_leader = Lacuna->db->resultset('Empire')->find($empire_id);
    unless (defined $new_leader) {
        confess [1002, 'The empire you specified to take over as leader does not exist.'];
    }
    $building->assign_alliance_leader($new_leader);
    return {
        status          => $self->format_status($session, $building->body),
        alliance        => $building->alliance->get_status,
    };
}

sub create_alliance {
    my ($self, $session_id, $building_id, $name) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $alliance = $building->create_alliance($name);
    return {
        status          => $self->format_status($session, $building->body),
        alliance        => $alliance->get_status,
    };
}

sub get_alliance_status {
    my ($self, $session_id, $building_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    return {
        status          => $self->format_status($session, $building->body),
        alliance        => $building->get_alliance_status,
    };
}

sub dissolve_alliance {
    my ($self, $session_id, $building_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    $building->dissolve_alliance;
    $empire->discard_changes;
    return {
        status          => $self->format_status($session, $building->body),
    };
}

sub leave_alliance {
    my ($self, $session_id, $building_id, $message) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    $building->leave_alliance($message);
    return {
        status          => $self->format_status($session, $building->body),
    };
}

sub expel_member {
    my ($self, $session_id, $building_id, $member_id, $message) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $member = Lacuna->db->resultset('Empire')->find($member_id);
    $building->expel_member($member, $message);
    return $self->get_alliance_status($empire, $building);
}

sub accept_invite {
    my ($self, $session_id, $building_id, $invite_id, $message) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    if ($empire->current_session->is_sitter) {
        confess [1015, 'Sitters cannot join alliances.'];
    }
    $empire->current_session->check_captcha;
    unless ($invite_id) {
        confess [1002, 'You must specify an invite id.'];
    }
    my $invite = Lacuna->db->resultset('AllianceInvite')->find($invite_id);
    unless (defined $invite) {
        confess [1002, 'Invitation not found.'];
    }
    my $cache = Lacuna->cache;
    if ($cache->get('join_alliance_lock', $empire->id)) {
        confess [1010, 'You cannot join an alliance more than once in a 24 hour period. Please wait 24 hours and try again.'];
    }
    $building->accept_invite($invite, $message);
    $cache->set('join_alliance_lock', $empire->id, 1, 60 * 60 * 24);
    return $self->get_alliance_status($empire, $building);
}

sub reject_invite {
    my ($self, $session_id, $building_id, $invite_id, $message) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    unless ($invite_id) {
        confess [1002, 'You must specify an invite id.'];
    }
    my $invite = Lacuna->db->resultset('AllianceInvite')->find($invite_id);
    unless (defined $invite) {
        confess [1002, 'Invitation not found.'];
    }
    $building->reject_invite($invite, $message);
    return {
        status          => $self->format_status($session, $building->body),
    };
}

sub withdraw_invite {
    my ($self, $session_id, $building_id, $invite_id, $message) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    unless ($invite_id) {
        confess [1002, 'You must specify an invite id.'];
    }
    my $invite = Lacuna->db->resultset('AllianceInvite')->find($invite_id);
    unless (defined $invite) {
        confess [1002, 'Invitation not found.'];
    }
    $building->withdraw_invite($invite, $message);
    return {
        status          => $self->format_status($session, $building->body),
    };
}

sub send_invite {
    my ($self, $session_id, $building_id, $empire_id, $message) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    unless ($empire_id) {
        confess [1002, 'You must specify which empire you want to invite.'];
    }
    my $invitee = Lacuna->db->resultset('Empire')->find($empire_id);
    unless (defined $invitee) {
        confess [1002, 'The empire you specified to invite does not exist.'];
    }
    $building->send_invite($invitee, $message);
    return {
        status          => $self->format_status($session, $building->body),
    };
}

sub get_pending_invites {
    my ($self, $session_id, $building_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    return {
        invites         => $building->get_pending_invites,
        status          => $self->format_status($session, $building->body),
    };
}

sub get_my_invites {
    my ($self, $session_id, $building_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    return {
        invites         => $building->get_my_invites,
        status          => $self->format_status($session, $building->body),
    };
}


sub update_alliance {
    my ($self, $session_id, $building_id, $params) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $alliance = $building->update_alliance($params);
    return {
        alliance        => $alliance->get_status,
        status          => $self->format_status($session, $building->body),
    };
}

sub view_stash {
    my ($self, $session_id, $building_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $body = $building->body;
    my %stored;
    foreach my $resource ('water','energy',FOOD_TYPES,ORE_TYPES) {
        $stored{$resource} = $body->get_stored($resource);
    }
    return {
        stash           => $building->alliance->stash || {},
        status          => $self->format_status($session, $body),
        max_exchange_size   => $building->max_exchange_size,
        exchanges_remaining_today   => $building->exchanges_remaining_today,
        stored          => \%stored,
    };
}

sub donate_to_stash {
    my ($self, $session_id, $building_id, $donation) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    $building->alliance->donate($building->body, $donation);
    return $self->view_stash($session, $building);
}

sub exchange_with_stash {
    my ($self, $session_id, $building_id, $donation, $request) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    $building->exchange_with_stash($donation, $request);
    return $self->view_stash($session, $building);
}

sub view_propositions {
    my ($self, $session_id, $building_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my @out;
    my $propositions = $building->propositions->search({ status => 'Pending'});
    while (my $proposition = $propositions->next) {
        $proposition->check_status;
        push @out, $proposition->get_status($empire);
    }
    return {
        status          => $self->format_status($session, $building->body),
        propositions    => \@out,
    };
}

sub cast_vote {
    my ($self, $session_id, $building_id, $proposition_id, $vote) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $cache = Lacuna->cache;
    my $lock = 'vote_lock_'.$empire->id;
    if ($cache->get($lock, $proposition_id)) {
        confess [1013, 'You already have a vote in process for this proposition.'];
    }
    $cache->set($lock,$proposition_id,1,5);
    my $guard = guard {$cache->delete($lock,$proposition_id);};
    my $proposition = Lacuna->db->resultset('Proposition')->find($proposition_id);
    unless (defined $proposition) {
        confess [1002, 'Proposition not found.'];
    }
    if ($proposition->station->alliance_id != $empire->alliance_id) {
        confess [1003, q[You cannot vote for another alliance's propositions!]];
    }

    $proposition->cast_vote($empire, $vote);
    return {
        status      => $self->format_status($session, $building->body),
        proposition => $proposition->get_status($empire),
    };
}

__PACKAGE__->register_rpc_method_names(qw(
                                       exchange_with_stash
                                       view_stash
                                       donate_to_stash

                                       expel_member
                                       update_alliance
                                       get_pending_invites
                                       get_my_invites
                                       assign_alliance_leader
                                       create_alliance
                                       dissolve_alliance
                                       send_invite
                                       accept_invite
                                       withdraw_invite
                                       reject_invite
                                       leave_alliance
                                       get_alliance_status

                                       view_propositions
                                       cast_vote
                                       ));


no Moose;
__PACKAGE__->meta->make_immutable;
