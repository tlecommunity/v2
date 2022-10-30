
use 5.010;
use strict;
use lib '/home/lacuna/server/lib';
use Lacuna::DB;
use Lacuna;

out('Loading DB...');

our $db = Lacuna->db;
our $schedules = $db->resultset('Schedule')->search();

while (my $schedule = $schedules->next) {
  $schedule->queue_for_delivery();
}

sub out {
  say shift;
}
