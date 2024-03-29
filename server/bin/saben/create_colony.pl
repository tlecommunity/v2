use 5.010;
use strict;
use lib '/home/lacuna/server/lib';
use Lacuna::DB;
use Lacuna;
use Lacuna::Util qw(randint format_date);
use Getopt::Long;
use List::MoreUtils qw(uniq);
$|=1;
our $quiet;
our $target;
GetOptions(
    'quiet'         => \$quiet,
    'target-player=s'        => \$target,
);

die 'You need to specify a target player.' unless $target;


out('Started');
my $start = time;

out('Loading DB');
our $db = Lacuna->db;
my $empires = $db->resultset('Empire');


out('getting empires...');
my $saben = $empires->find(-1);
my $lec = $empires->find(1);
my $target_player = $empires->find($target);
die 'Could not find target player.' unless defined $target_player;


out('Finding colony...');
my $body = $db->resultset('Map::Body')->search(
    { zone => $target_player->home_planet->zone, empire_id => undef, size => { between => [30,35]}}
    )->first;
die 'Could not find a colony to occupy.' unless defined $body;
say $body->name;

out('Clearing unneeded structures...');
foreach my $building (@{$body->building_cache}) {
    $building->delete;
}

out('Colonizing '.$body->name);
$body->found_colony($saben);


out('Setting target...');
$db->resultset('SabenTarget')->new({
    saben_colony_id     => $body->id,
    target_empire_id    => $target_player->id,
})->insert;

my $max_level = $target_player->university_level;
my $half_level = int( ($max_level + 1) / 2 );
my $one_third_level = int( ($max_level + 1) / 3 );
my $two_thirds_level = $one_third_level * 2;
my $quarter_level = int( ($max_level + 1) / 4 );

out('Placing structures on '.$body->name);
my @plans = (
    ['Lacuna::DB::Result::Building::Permanent::Ravine',$quarter_level, -2, 2],
    ['Lacuna::DB::Result::Building::Intelligence', $max_level, -1, 2],
    ['Lacuna::DB::Result::Building::Security', $two_thirds_level, 0, 2],
    ['Lacuna::DB::Result::Building::Espionage', $max_level, 1, 2],
    ['Lacuna::DB::Result::Building::Permanent::CitadelOfKnope',$one_third_level, 2, 2],

    ['Lacuna::DB::Result::Building::Permanent::OracleOfAnid',1, -2, 1],
    ['Lacuna::DB::Result::Building::Shipyard',2, -1, 1],
    ['Lacuna::DB::Result::Building::EntertainmentDistrict',$two_thirds_level, 0, 1],
    ['Lacuna::DB::Result::Building::Permanent::Volcano',$half_level, 1, 1],
    ['Lacuna::DB::Result::Building::Waste::Sequestration',10, 2, 1],

    ['Lacuna::DB::Result::Building::MunitionsLab',5, -2, 0],
    ['Lacuna::DB::Result::Building::SpacePort',$two_thirds_level, -1, 0],
    # PCC 0,0
    ['Lacuna::DB::Result::Building::Permanent::NaturalSpring',$half_level, 1, 0],
    ['Lacuna::DB::Result::Building::Permanent::InterDimensionalRift',$half_level, 2, 0],

    ['Lacuna::DB::Result::Building::Observatory',1, -2, -1],
    ['Lacuna::DB::Result::Building::Shipyard',2, -1, -1],
    ['Lacuna::DB::Result::Building::Trade',10, 0, -1],
    ['Lacuna::DB::Result::Building::Permanent::GeoThermalVent',$half_level, 1, -1],
    ['Lacuna::DB::Result::Building::Permanent::MalcudField',$one_third_level, 2, -1],

    ['Lacuna::DB::Result::Building::Permanent::LibraryOfJith',1, -2, -2],
    ['Lacuna::DB::Result::Building::SpacePort',$two_thirds_level, -1, -2],
    ['Lacuna::DB::Result::Building::Permanent::CrashedShipSite',$one_third_level, 0, -2],
    ['Lacuna::DB::Result::Building::Permanent::AlgaePond',$half_level, 1, -2],
    ['Lacuna::DB::Result::Building::Food::Syrup',$two_thirds_level, 2, -2],
);
$buildings = $db->resultset('Building');
foreach my $plan (@plans) {
    my $building = $buildings->new({
        class   => $plan->[0],
        level   => $plan->[1] - 1,
        x       => $plan->[2],
        y       => $plan->[3],
        body_id => $body->id,
        body    => $body,
    });
    say $building->name;
    $body->build_building($building);
    $building->finish_upgrade;
}


my $finish = time;
out('Finished');
out((($finish - $start)/60)." minutes have elapsed");




###############
## SUBROUTINES
###############




sub out {
    my $message = shift;
    unless ($quiet) {
        say format_date(DateTime->now), " ", $message;
    }
}
