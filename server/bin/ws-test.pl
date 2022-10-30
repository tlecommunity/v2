#!/usr/bin/env perl

use strict;
use warnings;
#use v5.20;
use lib "../lib";

use Redis;

use Lacuna::WebSocket::User;
use Lacuna::Queue;
use Lacuna::Config;
use Lacuna::Redis;
use Lacuna::SDB;
use Lacuna::DB;
use Lacuna;

use Log::Log4perl;

my $config = Lacuna->config->get();
my $client_url = $config->{client_url};
my $condvar = AnyEvent->condvar;

Log::Log4perl->init('/home/lacuna/server/etc/log4perl.conf');

use AnyEvent;
use AnyEvent::Socket qw(tcp_server);
use AnyEvent::WebSocket::Server;
use AnyEvent::Beanstalk;

# beanstalk sender
my $timer = AE::timer 0, 10, sub {
    print STDERR "In 10 sec Timer!\n";

    my $queue = Lacuna::Queue->instance();

    $queue->publish({
        queue   => 'mq_worker',
        payload => {
            route   => '/starmap/getMapChunk',
            user_id => 1,
            content => {
                left    => 50,
                bottom  => -50,
            }
        },
    });
};

$condvar->recv;
print STDERR "WE SHOULD NEVER GET HERE\n";
