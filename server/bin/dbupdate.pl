#!/usr/bin/env perl

use App::DH;
use lib '/home/lacuna/server/lib';
use Lacuna;

{
    package Lacuna::DH;
    use Moose;
    extends 'App::DH';

    has '+schema' =>
        default => sub { 'Lacuna::DB' };
    has '+script_dir' =>
        default => sub { '/home/lacuna/server/var/upgrades' };

    # This doesn't work because it doesn't have the user/password
    #has '+connection_name' =>
    #    default => sub { Lacuna->config->get('db/dsn') };

    sub _build__schema {
        # we already load the connection, let's reuse it.
        Lacuna::SDB->db
    }

    __PACKAGE__->meta->make_immutable;
}

Lacuna::DH->new_with_options->run;
