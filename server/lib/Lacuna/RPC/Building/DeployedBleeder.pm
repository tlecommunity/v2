package Lacuna::RPC::Building::DeployedBleeder;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'Lacuna::RPC::Building';

sub app_url {
    return '/deployedbleeder';
}

sub model_class {
    return 'Lacuna::DB::Result::Building::DeployedBleeder';
}

around demolish => sub {
    my ($orig, $self, %args) = @_;
    my $session  = $self->get_session({session_id => $args{session_id}, building_id => $args{building_id} });
    $session->check_captcha;
    return $orig->($self, (%args));
};

no Moose;
__PACKAGE__->meta->make_immutable;
