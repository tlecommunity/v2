package Lacuna::SDB;

use MooseX::Singleton;
use namespace::autoclean;

has db => (
    is          => 'rw',
    required    => 1,
    isa         => 'Lacuna::DB',
    #handles     => [qw(resultset)],
    default     => sub {
        my $config = Lacuna->config;
        my $db = Lacuna::DB->connect(
                         $config->get('db/dsn'),
                         $config->get('db/username'),
                         $config->get('db/password'),
                         {
                             mysql_enable_utf8 => 1,
                             AutoCommit        => 1,
                         }
                        );

    }
);

__PACKAGE__->meta->make_immutable;
