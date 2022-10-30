package Lacuna::MessageQueue::Starmap;

use Moose;
use Log::Log4perl;
use Data::Dumper;
use Text::Trim qw(trim);
use Email::Valid;
use Time::HiRes qw(gettimeofday);

use Lacuna::SDB;
use Lacuna::Queue;

sub log {
    my ($self) = @_;
    return Log::Log4perl->get_logger( "Lacuna::MessageQueue::Starmap" );
}

#--- Receive a getMapChunk request
#
sub bg_getMapChunk {
    my ($self, $context) = @_;

    $self->log->debug("BG - getStarMap: ".Dumper($context));

















}

1;
