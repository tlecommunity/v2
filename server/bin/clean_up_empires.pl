use 5.010;
use strict;
use feature "switch";
use lib '/home/lacuna/server/lib';
use Lacuna::DB;
use Lacuna;
use List::Util qw(shuffle);
use Lacuna::Util qw(randint format_date);
use Getopt::Long;
$|=1;
our $quiet;
GetOptions(
    'quiet'         => \$quiet,
);

out('Started Clean Up Empires');
my $start = DateTime->now;

out('Loading DB');
our $db = Lacuna->db;
our $dtf = $db->storage->datetime_parser;
my $empires = $db->resultset('Empire');


out('Deleting dead spies and retiring old spies.');
my $spies = $db->resultset('Spy');
$spies->search({task=>'Killed In Action'})->delete_all;
my $retiring_spies = $spies->search({ -or => { offense_mission_count => { '>=' => 150 }, defense_mission_count => { '>=' => 150 } }});
while (my $spy = $retiring_spies->next) {
    $spy->empire->send_predefined_message(
        tags        => ['Spies'],
        filename    => 'retiring.txt',
        params      => [$spy->format_from],
    );
    $spy->delete;
}


out('Deleting Expired Self Destruct Empires');
my $to_be_deleted = $empires->search({ self_destruct_date => { '<' => $dtf->format_datetime($start) }, self_destruct_active => 1});
my $delete_tally = 0;
my $active_duration = 0;
while (my $empire = $to_be_deleted->next) {
    out('Deleting empire '.$empire->name);
    $delete_tally++;
    $active_duration += $start->epoch - $empire->date_created->epoch;
    $empire->delete;
}

out('Deleting Half Created Empires');
my $old_half_created = $start->clone->subtract(hours => 2);
$to_be_deleted = $empires->search({ stage => 'new', date_created => { '<' => $dtf->format_datetime($old_half_created) }});
while (my $empire = $to_be_deleted->next) {
    out("$empire->name");
    $delete_tally++;
    $active_duration += $start->epoch - $empire->date_created->epoch;
    $empire->delete;
}

out('Enabling Self Destruct For Inactivity');
my $abandons_tally;
my $inactivity_time_out = Lacuna->config->get('self_destruct_after_inactive_days') || 20;
my $inactivity_time_out_formatted = $dtf->format_datetime(DateTime->now->subtract( days => $inactivity_time_out) );
my $inactives = $empires->search({
    last_login           => { '<' => $inactivity_time_out_formatted },
    self_destruct_active => 0,
    id                   => { '>' => 1},
    is_admin             => 0,
#    disable_self_destruct=> 0,
});
while (my $empire = $inactives->next) {
    # this checks if there were any sitters for this account that have not yet
    # expired, or that have expired in the last 20 days.  If so, then this
    # account isn't ready to be checked for reaping yet.
    my $recent_expires = $empire->sitterauths->
        search({ expiry => { '>' => $inactivity_time_out_formatted } })->count;
    next if $recent_expires;

    if ($empire->essentia >= 1) {
      unless (Lacuna->cache->get('empire_inactive',$empire->id)) {
        out('Preventing self-destruct by spending essentia.');
        $empire->spend_essentia({
            amount      => 1,
            reason      => 'prevent self-destruct',
        });
        $empire->update;
        Lacuna->cache->set('empire_inactive',$empire->id,1,60*60*24);
      }
    }
    else {
        out('Enabling self destruct on '.$empire->name);
        $empire->enable_self_destruct;
        $abandons_tally++;
    }
}

out('Updating Viral Log');
my $viral_log = $db->resultset('Log::Viral');
my $add_deletes = $viral_log->search({date_stamp => format_date($start,'%F')})->first;
unless (defined $add_deletes) {
    $add_deletes = $viral_log->new({date_stamp => format_date($start,'%F')})->insert;
}
$add_deletes->update({
    deletes         => $add_deletes->deletes + $delete_tally,
    abandons        => $add_deletes->abandons + $abandons_tally,
    active_duration => $add_deletes->active_duration + $active_duration,
    total_users     => $empires->count,
});
my $cache = Lacuna->cache;
my $create_date = format_date($start->clone->subtract(hours => 1),'%F');
my $add_creates = $viral_log->search({date_stamp => $create_date})->first;
unless (defined $add_deletes) {
    $add_creates = $viral_log->new({date_stamp => $create_date})->insert;
}
$add_creates->update({
    creates => $cache->get('empires_created', $create_date),
    accepts => $cache->get('friends_accepted', $create_date),
    invites => $cache->get('friends_invited', $create_date),
});



my $finish = time;
out('Finished');
out((($finish - $start->epoch)/60)." minutes have elapsed");


###############
## SUBROUTINES
###############

sub out {
    my $message = shift;
    unless ($quiet) {
        say format_date(DateTime->now), " ", $message;
    }
}
