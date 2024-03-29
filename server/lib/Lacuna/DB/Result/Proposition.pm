package Lacuna::DB::Result::Proposition;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'Lacuna::DB::Result';
use Lacuna::Util qw(format_date);
use DateTime;

__PACKAGE__->load_components('DynamicSubclass');
__PACKAGE__->table('proposition');
__PACKAGE__->add_columns(
    name                    => { data_type => 'varchar', size => 30, is_nullable => 0 },
    station_id              => { data_type => 'int', size => 11, is_nullable => 0 },
    description             => { data_type => 'text', is_nullable => 1 },
    type                    => { data_type => 'varchar', size => 30, is_nullable => 0 },
    scratch                 => { data_type => 'mediumblob', is_nullable => 1, 'serializer_class' => 'JSON' },
    date_ends               => { data_type => 'datetime', is_nullable => 0 },
    proposed_by_id          => { data_type => 'int', size => 11, is_nullable => 0 },
    status                  => { data_type => 'varchar', size => 10, is_nullable => 0, default_value => 'Pending' },
);

__PACKAGE__->typecast_map(type => {
    AbandonStation          => 'Lacuna::DB::Result::Proposition::AbandonStation',
    BHGNeutralized          => 'Lacuna::DB::Result::Proposition::BHGNeutralized',
    BHGPassport             => 'Lacuna::DB::Result::Proposition::BHGPassport',
    BroadcastOnNetwork19    => 'Lacuna::DB::Result::Proposition::BroadcastOnNetwork19',
    DemolishModule          => 'Lacuna::DB::Result::Proposition::DemolishModule',
    DowngradeModule         => 'Lacuna::DB::Result::Proposition::DowngradeModule',
    EnactWrit               => 'Lacuna::DB::Result::Proposition::EnactWrit',
    ElectNewLeader          => 'Lacuna::DB::Result::Proposition::ElectNewLeader',
    EvictExcavator          => 'Lacuna::DB::Result::Proposition::EvictExcavator',
    EvictMiningPlatform     => 'Lacuna::DB::Result::Proposition::EvictMiningPlatform',
    ExpelMember             => 'Lacuna::DB::Result::Proposition::ExpelMember',
    FireBfg                 => 'Lacuna::DB::Result::Proposition::FireBfg',
    ForeignAid              => 'Lacuna::DB::Result::Proposition::ForeignAid',
    InductMember            => 'Lacuna::DB::Result::Proposition::InductMember',
    InstallModule           => 'Lacuna::DB::Result::Proposition::InstallModule',
    MembersOnlyColonization => 'Lacuna::DB::Result::Proposition::MembersOnlyColonization',
    MembersOnlyStations     => 'Lacuna::DB::Result::Proposition::MembersOnlyStations',
    MembersOnlyExcavation   => 'Lacuna::DB::Result::Proposition::MembersOnlyExcavation',
    MembersOnlyMiningRights => 'Lacuna::DB::Result::Proposition::MembersOnlyMiningRights',
    RenameAsteroid          => 'Lacuna::DB::Result::Proposition::RenameAsteroid',
    RenameStar              => 'Lacuna::DB::Result::Proposition::RenameStar',
    RenameStation           => 'Lacuna::DB::Result::Proposition::RenameStation',
    RenameUninhabited       => 'Lacuna::DB::Result::Proposition::RenameUninhabited',
    RepairModule            => 'Lacuna::DB::Result::Proposition::RepairModule',
    RepealLaw               => 'Lacuna::DB::Result::Proposition::RepealLaw',
    Taxation                => 'Lacuna::DB::Result::Proposition::Taxation',
    TransferStationOwnership=> 'Lacuna::DB::Result::Proposition::TransferStationOwnership',
    UpgradeModule           => 'Lacuna::DB::Result::Proposition::UpgradeModule',
});

__PACKAGE__->belongs_to('proposed_by', 'Lacuna::DB::Result::Empire', 'proposed_by_id');
__PACKAGE__->belongs_to('station', 'Lacuna::DB::Result::Map::Body', 'station_id');
__PACKAGE__->has_many('votes', 'Lacuna::DB::Result::Vote', 'proposition_id');

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;
    $sqlt_table->add_index(name => 'idx_status_date_ends', fields => ['status','date_ends']);
}

has votes_needed => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        int( ($self->station->alliance->members->count + 1) / 2);
    }
);

has votes_yes => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        $self->votes->search({vote => 1})->count;
    }
);

has votes_no => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        $self->votes->search({vote => 0})->count;
    }
);

sub cast_vote {
    my ($self, $empire, $vote) = @_;
    unless ($self->status eq 'Pending') {
        confess [1009, 'This proposition has already '.$self->status.'.'];
    }
    if ($self->votes->search({empire_id => $empire->id})->count) {
        confess [1010, 'You have already voted on this proposition.'];
    }
    Lacuna->db->resultset('Vote')->new({
        proposition_id  => $self->id,
        empire_id       => $empire->id,
        vote            => $vote,
    })->insert;
    $self->check_status;
}

before delete => sub {
    my $self = shift;
    $self->fail if $self->status eq 'Pending';
    $self->votes->delete_all;
};

sub check_status {
    my $self = shift;
    my $cache = Lacuna->cache;

    if ($self->status eq 'Pending') {
        # cache check as close as possible to cache set to reduce chance
        # (but not eliminate chance) of race condition
        if ($self->votes_yes >= $self->votes_needed) {
            return $self if $cache->get('proposition_recently_completed', $self->id);
            $cache->set('proposition_recently_completed', $self->id, 30);
            $self->pass;
        }
        elsif ($self->votes_no >= $self->votes_needed) {
            return $self if $cache->get('proposition_recently_completed', $self->id);
            $cache->set('proposition_recently_completed', $self->id, 30);
            $self->fail;
        }
        elsif ($self->date_ends->epoch < time()) {
            return $self if $cache->get('proposition_recently_completed', $self->id);
            $cache->set('proposition_recently_completed', $self->id, 30);
            $self->time_is_up;
        }
        $self->update;
    }
    return $self;
}

# allow some propositions to auto-fail by overriding this.
sub time_is_up
{
    my ($self) = @_;
    $self->pass;
}

sub pass {
    my $self = shift;
    $self->station->alliance->send_predefined_message(
        filename    => 'parliament_vote_passed.txt',
        tags        => ['Parliament','Correspondence'],
        params      => [
            $self->name,
            $self->name,
            $self->votes_yes,
            $self->votes_no,
            $self->description,
            $self->pass_extra_message,
        ],
    );
    $self->status('Passed');
    return $self;
}

has pass_extra_message => (
    is  => 'rw',
);

sub fail {
    my $self = shift;
    $self->station->alliance->send_predefined_message(
        filename    => 'parliament_vote_failed.txt',
        tags        => ['Parliament','Correspondence'],
        params      => [
            $self->name,
            $self->name,
            $self->votes_yes,
            $self->votes_no,
            $self->description,
            $self->fail_extra_message,
        ],
    );
    $self->status('Failed');
    return $self;
}

has fail_extra_message  => (
    is  => 'ro',
);

before insert => sub {
    my $self = shift;
    $self->date_ends( DateTime->now->add(hours => 72) );
};

after insert => sub {
    my $self = shift;
    $self->send_vote;
};

sub get_status {
    my ($self, $empire) = @_;
    my $out = {
        id          => $self->id,
        name        => $self->name,
        description => $self->description,
        votes_needed=> $self->votes_needed,
        votes_yes   => $self->votes_yes,
        votes_no    => $self->votes_no,
        status      => $self->status,
        date_ends   => $self->date_ends_formatted,
        station     => $self->station->name,
        station_id  => $self->station->id,
        proposed_by => {
            id      => $self->proposed_by->id,
            name    => $self->proposed_by->name,
        },
    };
    if (defined $empire) {
        my $vote = $self->votes->search({ empire_id => $empire->id})->first;
        if (defined $vote) {
            $out->{my_vote} = $vote->vote;
        }
    }
    return $out;
}

sub send_vote {
    my $self = shift;
    my $station = $self->station;
    my $parliament = $station->parliament;
    $station->alliance->send_predefined_message(
        filename    => 'parliament_vote.txt',
        tags        => ['Parliament','Correspondence'],
        from        => $self->proposed_by,
        params      => [
            $self->name,
            $self->name,
            $self->description,
            $station->id,
            $parliament->id,
            $self->id,
            $station->id,
            $parliament->id,
            $self->id,
        ],
    );
}

sub date_ends_formatted {
    my ($self) = @_;
    return format_date($self->date_ends);
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
