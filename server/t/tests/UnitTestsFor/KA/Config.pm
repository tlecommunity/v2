package UnitTestsFor::Lacuna::Config;

use lib "lib";

use Test::Class::Moose;
use File::Temp qw(tempfile);
use Data::Dumper;

use Lacuna::Config;

sub test_construction_foo {
    my ($self) = @_;

    my $config = Lacuna::Config->instance;

    isa_ok($config, 'Lacuna::Config');

    is($config->get('test/foo'), 'bar', "Can get from config");
}

1;
