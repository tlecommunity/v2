package Lacuna;

use strict;
use Module::Find qw(useall);
use Lacuna::DB;
use Lacuna::SDB;
use Lacuna::Redis;
use Config::JSON;

useall __PACKAGE__;

our $VERSION = 3.0923;

my $config = Config::JSON->new('/home/lacuna/server/etc/lacuna.conf');
my $cache = Lacuna::Cache->new(servers => $config->get('memcached'));
my $queue = Lacuna::Queue->instance;

sub version {
    return $VERSION;
}

sub config {
    return $config;
}

sub db {
    #return $db;
    Lacuna::SDB->instance->db;
}

sub cache {
    return $cache;
}

sub queue {

    return $queue;
}

1;
