#!/usr/bin/perl

use lib '/home/lacuna/server/lib';
use Redis;
use Log::Log4perl;

use Lacuna::Config;
use Lacuna::Redis;
use Lacuna::Queue;
use Lacuna::DB;
use Lacuna::SDB;

use Lacuna::App::MQWorker;

Log::Log4perl->init('/home/lacuna/server/etc/log4perl.conf');

my $app = Lacuna::App::MQWorker->new_with_command();

$app->run;
