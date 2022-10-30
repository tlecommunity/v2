use strict;
use warnings;
use Test::Most;
use Log::Log4perl;

use lib "lib";
use lib "t/lib";

use Redis;
use Lacuna::Config;
use Lacuna::Queue;
use Lacuna::Redis;
use Lacuna::DB;
use Lacuna::SDB;

use Test::Class::Moose::Load 't/tests';
use Test::Class::Moose::Runner;


#--- Initialize singleton objects
#
# Connect to the Redis Docker image
#
my $redis = Redis->new(server => "redis:6379");
Lacuna::Redis->initialize({
    redis => $redis,
});

Lacuna::Config->initialize;

# Connect to the beanstalk Docker image
#
Lacuna::Queue->initialize({
    server      => "beanstalkd:11300",
    ttr         => 120,
    debug       => 0,
});

Log::Log4perl->init('/home/lacuna/server/etc/log4perl.conf');

my $db = Lacuna::DB->connect(
    'DBI:SQLite:/home/lacuna/server/log/test.db',
);
$db->deploy({ add_drop_table => 1 });

Lacuna::SDB->initialize({
    db => $db,
});

my $runner = Test::Class::Moose::Runner->new(statistics => 1, test_classes => \@ARGV);
$runner->runtests;
1;
