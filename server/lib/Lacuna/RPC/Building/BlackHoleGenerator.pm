package Lacuna::RPC::Building::BlackHoleGenerator;
use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'Lacuna::RPC::Building';
use List::Util qw(shuffle);
use Lacuna::Util qw(randint random_element commify);
use Lacuna::Constants qw(FOOD_TYPES ORE_TYPES);

use experimental 'smartmatch';

sub app_url {
    return '/blackholegenerator';
}

sub model_class {
    return 'Lacuna::DB::Result::Building::Permanent::BlackHoleGenerator';
}

around 'view' => sub {
    my ($orig, $self, %args) = @_;
    my $session  = $self->get_session({session_id => $args{session_id}, building_id => $args{building_id}, skip_offline => 1 });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $out = $orig->($self, (%args));
    my $body = $building->body;

    my $throw = 0; my $reason = '';
    ($throw, $reason) = check_bhg_neutralized($body, $empire);
    if ($throw > 0) {
        $out->{tasks} = [ {
            can          => 0,
            name         => 'Black Hole Generator Neutralized',
            types        => ['none'],
            reason       => $reason,
            occupied     => 0,
            min_level    => 0,
            range        => 0,
            recovery     => 0,
            waste_cost   => 0,
            base_fail    => 0,
            seconds_remaining => 0,
            side_chance  => 0,
            subsidy_mult => 1,
        } ];
    }
    elsif ($building->is_working) {
        $out->{tasks} = [ {
            seconds_remaining => $building->work_seconds_remaining,
            can               => 0,
        } ];
    }
    else {
        my @tasks = bhg_tasks($building);
        $out->{tasks} = \@tasks;
    }

    my @zones = Lacuna->db->resultset('Map::Star')->search(
        undef,
        { distinct => 1 }
    )->get_column('zone')->all;

    $out->{task_options} = {
        asteroid_types => [ 1 .. Lacuna::DB::Result::Map::Body->asteroid_types ],
        planet_types   => [ 1 .. Lacuna::DB::Result::Map::Body->planet_types ],
        zones          => [ sort @zones ],
    };
    return $out;
};

my @orbits = (
              undef,
              [ 1,  2], # 1
              [ 2,  1], # 2
              [ 2, -1], # 3
              [ 1, -2], # 4
              [-1, -2], # 5
              [-2, -1], # 6
              [-2,  1], # 7
              [-1,  2], # 8
             );
my %orbit_for; $orbit_for{$orbits[$_][0]}{$orbits[$_][1]} = $_ for 1..8;

sub find_target {
    my ($self, $empire, $target_params) = @_;
    unless (ref $target_params eq 'HASH') {
        confess [-32602,
            'The target parameter should be a hash reference. For example { "body_id" : 9999 }.'];
    }
    my $db = Lacuna->db;
    my $target;
    my $target_type;
    my $target_word = join(":", keys %$target_params);
    if ($target_word eq '') {
        confess [ -32602,
            'The target parameter should be a hash reference. For example { "body_id" : 9999 }.'];
    }
    if (exists $target_params->{body_id}) {
        $target_word = $target_params->{body_id};
        $target = $db->resultset('Map::Body')->find($target_params->{body_id});
        if (defined $target) {
            $target_type = $target->get_type;
        }
    }
    elsif (exists $target_params->{body_name}) {
        $target_word = $target_params->{body_name};
        $target = $db->resultset('Map::Body')
            ->search(
                { name => $target_params->{body_name} }
            )->first;
        if (defined $target) {
            $target_type = $target->get_type;
        }
    }
    elsif (exists $target_params->{x}) {
        $target_word = $target_params->{x}.":".$target_params->{y};
        $target = $db->resultset('Map::Body')
            ->search(
                { x => $target_params->{x}, y => $target_params->{y} }
            )->first;
        unless (defined $target) {
            $target = $db->resultset('Map::Star')
                ->search(
                    { x => $target_params->{x}, y => $target_params->{y} }
                )->first;
            $target_type = "star" if (defined $target);
        }
        else {
            $target_type = $target->get_type;
        }
        #Check for empty orbits.
        unless (defined $target) {
            my $star = $db->resultset('Map::Star')
                ->search(
                    {
                        x => { '>=' => ($target_params->{x} -2),
                               '<=' => ($target_params->{x} +2)
                              },
                        y => { '>=' => ($target_params->{y} -2),
                               '<=' => ($target_params->{y} +2)
                              }
                    }
                )->first;
            if (defined $star) {
                my $sx = $star->x; my $sy = $star->y;
                my $tx = $target_params->{x}; my $ty = $target_params->{y};
                my $orbit = $orbit_for{$tx-$sx}{$ty-$sy};
                if ($orbit) {
                    $target = {
                        id      => 0,
                        name    => "Empty Space",
                        orbit   => $orbit,
                        type    => 'empty',
                        x       => $tx,
                        y       => $ty,
                        zone    => $star->zone,
                        star    => $star,
                        star_id => $star->id,
                    };
                    $target_type = "empty";
                }
            }
        }
    }
    elsif (exists $target_params->{zone}) {
        my @zones = $db->resultset('Map::Star')->search(
                undef,
                { distinct => 1 }
            )->get_column('zone')->all;
        unless ($target_params->{zone} ~~ @zones) {
            confess [ 1002, 'Could not find '.$target_word.' zone.'];
        }
#New Method
        my @stations;
        my @stars;
        if ($empire->alliance_id) {
            @stations = $db->resultset('Map::Body')->search(
                {
                    'me.alliance_id' => $empire->alliance_id,
                },
                {
                    join  => 'laws',
                }
            )->get_column('id')->all;
        }
        if (@stations) {
            @stars  = $db->resultset('Map::Star')->search(
                {
                    'me.zone' => $target_params->{zone},
                    -or => [
                        { 'me.station_id' => { 'in' => \@stations } },
                        { 'me.station_id' => undef },
                    ],
                }
            )->get_column('id')->all;
        }
        else {
            @stars  = $db->resultset('Map::Star')->search(
                {
                    'me.zone' => $target_params->{zone},
                    'me.station_id' => undef,
                }
            )->get_column('id')->all;
        }
        my @bodies = shuffle $db->resultset('Map::Body')->search(
            {
                'me.zone'           => $target_params->{zone},
                'me.empire_id'      => undef,
                'me.class'          => { like => 'Lacuna::DB::Result::Map::Body::Planet::%' },
                'me.orbit'          => { between => [$empire->min_orbit, $empire->max_orbit] },
                'star.id' =>  { 'in' => \@stars } ,
            },
            {
                join  => 'star',
            }
        );
        if (@bodies > 0) {
            foreach my $candidate (@bodies) {
                next if ($candidate->get_buildings_of_class('Lacuna::DB::Result::Building::Permanent::Fissure'));
                $target = $candidate;
                last;
            }
        }
        if (defined $target) {
            $target_type = "zone";
        }
    }
    elsif (exists $target_params->{star_name} or exists $target_params->{star_id}) {
        my ($type,$value) = exists $target_params->{star_id} ?
            (id => $target_params->{star_id}) : (name => $target_params->{star_name});

        $target = $db->resultset('Map::Star')->find({$type => $value});
        $target_type = "star";
        $target_word =~ s/:?orbit:?//g;

        if ($target && $target_params->{orbit} && 1 <= $target_params->{orbit} && $target_params->{orbit} <= 8) {
            my $star = $target;
            my $orbit = int($target_params->{orbit});
            my ($x, $y) = ($star->x + $orbits[$orbit][0], $star->y + $orbits[$orbit][1]); #++);

            $target = $db->resultset('Map::Body')->find({ x => $x, y => $y });
            if ($target)
            {
                $target_type = $target->get_type;
            }
            else
            {
                $target = {
                    id      => 0,
                    name    => "Empty Space",
                    orbit   => $orbit,
                    type    => 'empty',
                    x       => $x,
                    y       => $y,
                    zone    => $star->zone,
                    star    => $star,
                    star_id => $star->id,
                };
                $target_type = "empty";
            }
        }
    }
    unless (defined $target) {
        confess [ 1002, 'Could not find '.$target_word.' target.'];
    }
    return $target, $target_type;
}

sub get_actions_for {
    my ($self, $session_id, $building_id, $target_params) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $body = $building->body;
    my ($target, $target_type) = $self->find_target($empire, $target_params);
    my @tasks = bhg_tasks($building);
    my @list;
    for my $task (@tasks) {
        my $chance;
        $chance = task_chance($building, $target, $target_type, $task);
        $task->{dist}    = $chance->{dist};
        $task->{range}   = $chance->{range};
        $task->{reason}  = $chance->{reason};
        $task->{success} = $chance->{success};
        $task->{throw}   = $chance->{throw};
        $task->{essentia_cost} = $chance->{essentia_cost};
        for my $mod ("waste_cost", "recovery", "side_chance") {
            if (defined($chance->{$mod})) {
                $task->{$mod} = $chance->{$mod};
            }
        }
        if ( 'Change Type' eq $task->{name} && $task->{success} > 0 ) {
            $task->{body_type} = $target_type;
        }
    }
    return {
        status => $self->format_status($session, $body),
        tasks  => \@tasks
    };
}

sub task_chance {
    my ($building, $target, $target_type, $task) = @_;

    my $dist; my $target_id;
    my $range = $task->{range};
    my $body = $building->body;
    my $return = {
        success   => 0,
        body_id   => 0,
        dist      => -1,
        range     => $range,
        throw     => 0,
        reason    => '',
    };
    ($return->{throw}, $return->{reason}) = check_bhg_neutralized($body, $body->empire);
    if ($return->{throw} > 0) {
        return $return;
    }
    ($return->{throw}, $return->{reason}) = check_bhg_neutralized($target, $body->empire);
    if ($return->{throw} > 0) {
        return $return;
    }
    if ($task->{name} eq 'Jump Zone' or
        $task->{name} eq 'Swap Places' or
        $task->{name} eq 'Move System') {
        ($return->{throw}, $return->{reason}) = check_starter_zone($body, $target, $task);
        if ($return->{throw} > 0) {
            return $return;
        }
        ($return->{throw}, $return->{reason}) = check_neutral_violation($body, $target, $task);
        if ($return->{throw} > 0) {
            return $return;
        }
        ($return->{throw}, $return->{reason}) = check_member_laws($body, $target, $task);
        if ($return->{throw} > 0) {
            return $return;
        }
    }
    unless ( grep { $target_type eq $_ } @{$task->{types}} ) {
        $return->{throw}   = 1009;
        $return->{reason}  = $task->{reason};
        return $return;
    }
    unless ($building->effective_level >= $task->{min_level}) {
        $return->{throw}  = 1013;
        $return->{reason} = sprintf(
            "You need a Level %d Black Hole Generator to do that",
            $task->{min_level}
        );
        return $return;
    }
    if ($task->{name} eq "Jump Zone") {
        my $szone = $body->zone;
        my $tzone = $target->zone;
        my ($sz_x, $sz_y) = $szone =~ m/(-?\d+)\|(-?\d+)/;
        my ($tz_x, $tz_y) = $tzone =~ m/(-?\d+)\|(-?\d+)/;
        $dist = sprintf "%0.2f", sqrt( ($sz_x - $tz_x)**2 + ($sz_y - $tz_y)**2);
        $target_id = $target->id;
    }
    elsif (ref $target eq 'HASH') {
        my $bx = $body->x;
        my $by = $body->y;
        $dist = sprintf "%0.2f", sqrt( ($target->{x} - $bx)**2 + ($target->{y} - $by)**2);
        $target_id = $target->{id};
    }
    else {
        $dist = sprintf "%0.2f", $body->calculate_distance_to_target($target)/100;
        $target_id = $target->id;
    }
    $return->{dist} = $dist;
    $return->{body_id} = $target_id;
    unless ($dist < $range) {
        $return->{throw}  = 1009;
        $return->{reason} = 'That target is too far away at '.$dist.
            ' with a range of '.$range.'.';
        return $return;
    }
    $return->{success} = (100 - $task->{base_fail}) - int( ($dist/$range) * (99-$task->{base_fail})+0.5);
    $return->{success} = 0 if $return->{success} < 1;

    my $bhg_param = Lacuna->config->get('bhg_param');
    if ($bhg_param) {
        $return->{waste_cost}  = $bhg_param->{waste_cost}  if ($bhg_param->{waste_cost});
        $return->{recovery}    = $bhg_param->{recovery}    if ($bhg_param->{recovery});
        $return->{side_chance} = $bhg_param->{side_chance} if ($bhg_param->{side_chance});
        $return->{success}     = $bhg_param->{success}     if ($bhg_param->{success});
    }
    unless ($building->body->get_stored('energy') >= $task->{waste_cost}) {
        $return->{throw}  = 1011;
        $return->{reason} = sprintf(
            "You need at least %s waste to run that function of the Black Hole Generator.",
            commify($task->{waste_cost})
        );
        $return->{success} = 0;
        return $return;
    }

    $return->{essentia_cost} = $return->{success} ? int($task->{subsidy_mult} * 2000 / $return->{success})/10 : 0;

    return $return;
}

sub check_bhg_neutralized {
    my ($check, $empire) = @_;
    my $tstar; my $tname;
    if (ref $check eq 'HASH') {
        $tstar = $check->{star};
        $tname = $check->{name};
    }
    else {
        if ($check->isa('Lacuna::DB::Result::Map::Star')) {
            $tstar = $check;
            $tname = $check->name;
        }
        else {
            $tstar = $check->star;
            $tname = $check->name;
        }
    }
    my $alliance_check = 0;
    if ($empire) {
        $alliance_check = $empire->alliance_id if ($empire->alliance_id);
    }
    my $sname = $tstar->name;
    my $throw; my $reason;
    if ($tstar->station_id) {
        if ($tstar->station->alliance_id == $alliance_check) {
            return 0, "";
        }
        if ($tstar->station->laws->search({type => 'BHGNeutralized'})->count) {
            my $passes = $tstar->station->laws->search({type => "BHGPassport"});
            while (my $pass = $passes->next) {
                return 0, "" if ($pass->scratch->{alliance_id} == $alliance_check);
            }
            my $ss_name = $tstar->station->name;
            $throw = 1009;
            $reason = sprintf("The star, %s is under BHG Neutralization from %s", $sname, $ss_name);
            return $throw, $reason;
        }
    }
    return 0, "";
}

sub check_member_laws {
    my ($body, $target, $task) = @_;
    my $throw; my $reason; my $tstar;
    my $btype;
    if (ref $target eq 'HASH') {
        $btype = $target->{type};
        $tstar = $target->{star};
    }
    else {
        if ($target->isa('Lacuna::DB::Result::Map::Star')) {
            $btype = 'star';
            $tstar = $target;
        }
        else {
            $btype = $target->get_type;
            $tstar = $target->star;
        }
    }
    if ($task->{name} eq "Jump Zone" or $task->{name} eq "Swap Places") {
        return 0, "" if $btype eq "star";
        my ($throw, $reason) = check_bentry($body, $tstar);
        return $throw, $reason if $throw;
        ($throw, $reason) = check_bentry($target, $body->star);
        return $throw, $reason if $throw;
    }
    elsif ($task->{name} eq "Move System") {
        my $bodies = Lacuna->db->resultset('Map::Body')->search({star_id => [ $body->star_id ]});
        my $throw; my $reason;
        while (my $cbody = $bodies->next) {
            ($throw, $reason) = check_bentry($cbody, $tstar);
            return $throw, $reason if $throw;
        }
        $bodies = Lacuna->db->resultset('Map::Body')->search({star_id => [ $tstar->id ]});
        while (my $tbody = $bodies->next) {
            ($throw, $reason) = check_bentry($tbody, $body->star);
            return $throw, $reason if $throw;
        }
    }
    return 0, "";
}

sub check_bentry {
    my ($body, $star) = @_;

    unless ($star->station_id) {
        return 0, "";
    }
    return 0, "" unless (Scalar::Util::blessed($body) && $body->empire);
    my $baid = $body->empire->alliance_id if ($body->empire);
    my $staid = $star->station->alliance_id;
    if ($baid and $baid == $staid) {
        return 0, "";
    }
    my $btype = $body->get_type;
    my $lawcheck;
    my $reason = '';
    if ($btype eq 'habitable planet' or $btype eq 'gas giant') {
      $lawcheck = "MembersOnlyColonization";
      $reason = 'Only '.$star->station->alliance->name.
                    ' members can bring planets into the jurisdiction of space station '.
                    $star->station->name.'.';
    }
    elsif ($btype eq 'space station') {
      $lawcheck = "MembersOnlyStations";
      $reason = 'Only '.$star->station->alliance->name.
                    ' members can bring stations into the jurisdiction of space station '.
                    $star->station->name.'.';
    }
    else {
        return 0, "";
    }
    if ($star->station->laws->search({type => $lawcheck})->count) {
        my $passes = $star->station->laws->search({type => "BHGPassport"});
        while (my $pass = $passes->next) {
            return 0, "" if ($pass->scratch->{alliance_id} == $baid);
        }
        return 1099, $reason;
    }
    return 0, "";
}

sub check_neutral_violation {
    my ($body, $target, $task) = @_;

    my $throw; my $reason;
    my $nz_param = Lacuna->config->get('neutral_area');
    return 0,"" unless $nz_param;
    return 0 if $body->in_neutral_area;
    my $target_in = 0;
    if (ref $target eq 'HASH') {
        my $tstar = $target->{star};
        $target_in = $tstar->in_neutral_area;
        $target = $tstar;
    }
    else {
        $target_in = $target->in_neutral_area;
    }
    my $body_in = $body->in_neutral_area;
    if (($body_in and $target_in) or (!($body_in) and !($target_in))) {
# Swap in happening fully inside or fully outside Neutral Area
        return 0;
    }
    my $test_body;
    if ($target_in) {
        $test_body = $body;
    }
    else {
        $test_body = $target;
    }

    my $dtf = Lacuna->db->storage->datetime_parser;
    my $now = DateTime->now;
    if ($task->{name} eq "Jump Zone" or $task->{name} eq "Swap Places") {
        if ( $test_body->neutral_entry > $now ) {
            $throw = 1009;
            $reason = sprintf("Colony %s can not enter the neutral area until %s.", $test_body->name, $dtf->format_datetime($test_body->neutral_entry));
            return $throw, $reason;
        }
    }
    elsif ($task->{name} eq "Move System") {
        my $bodies = Lacuna->db->resultset('Map::Body')->search({star_id => [ $test_body->star_id ]});
        my $fail = 0;
        while (my $obody = $bodies->next) {
            next unless (defined($obody->empire));
            if ( $obody->neutral_entry > $now ) {
                $throw = 1009;
                $reason = sprintf("Colony %s can not enter the neutral area until %s.", $obody->name, $dtf->format_datetime($obody->neutral_entry));
                $fail = 1;
            }
        }
        if ($fail) {
            return $throw, $reason;
        }
    }
    return 0;
}

sub check_starter_zone {
    my ($body, $target, $task) = @_;

    my $throw; my $reason;
    my $sz_param = Lacuna->config->get('starter_zone');
    return 0,"" unless $sz_param;
    return 0,"" unless $sz_param->{max_colonies};
    my $body_in = $body->in_starter_zone;
    my $target_in = 0;
    if (ref $target eq 'HASH') {
        my $tstar = $target->{star};
        $target_in = $tstar->in_starter_zone;
        $target = $tstar;
    }
    else {
        $target_in = $target->in_starter_zone;
    }

    if ($task->{name} eq "Move System") {
        if ($body_in or $target_in) {
            $throw = 1009;
            $reason = sprintf("Move System isn't allowed to & from starter zones.");
            return $throw, $reason;
        }
    }
    elsif ($task->{name} eq "Jump Zone") {
        if ($body_in) {
# If we start in a starter zone, we don't care where they go.
            return 0, "";
        }
        if ($target->isa('Lacuna::DB::Result::Map::Star')) {
            return 0, "";
        }
        if ($target_in) {
            my $sz_colonies = 0;
            my $planets = $body->empire->planets;
            while (my $planet = $planets->next) {
                $sz_colonies++ if $planet->in_starter_zone;
            }
            if ($sz_colonies >= $sz_param->{max_colonies}) {
                $throw = 1009;
                $reason = sprintf("You already have the maximum allowed colonies in starter zones.");
                return $throw, $reason;
            }
        }
    }
    elsif ($task->{name} eq "Swap Places") {
        if ($target->isa('Lacuna::DB::Result::Map::Star')) {
            return 0, "";
        }
        if ($body_in and !$target_in) {
            if (defined ($target->empire)) {
                if ($target->get_type eq 'space station') {
                    $throw = 1009;
                    $reason = sprintf("You can not move a space station into a starter zone.");
                    return $throw, $reason;
                }
                return 0,"" if (defined($body->empire) and $body->empire_id == $target->empire_id);
                my $sz_colonies = 0;
                my $planets = $target->empire->planets;
                while (my $planet = $planets->next) {
                    $sz_colonies++ if $planet->in_starter_zone;
                }
                if ($sz_colonies >= $sz_param->{max_colonies}) {
                    $throw = 1009;
                    $reason = sprintf("Target already have the maximum allowed colonies in starter zones.");
                    return $throw, $reason;
                }
            }
        }
        elsif (!$body_in and $target_in) {
            if (defined ($body->empire)) {
                return 0,"" if (defined($target->empire) and $body->empire_id == $target->empire_id);
                my $sz_colonies = 0;
                my $planets = $body->empire->planets;
                while (my $planet = $planets->next) {
                    $sz_colonies++ if $planet->in_starter_zone;
                }
                if ($sz_colonies >= $sz_param->{max_colonies}) {
                    $throw = 1009;
                    $reason = sprintf("You already have the maximum allowed colonies in starter zones.");
                    return $throw, $reason;
                }
            }
        }
    }
    return 0, "";
}

sub generate_singularity {
    my $self  = shift;
    my $args  = shift;

    if (ref($args) ne "HASH") {
        $args = {
            session_id    => $args,
            building_id   => shift,
            target        => shift,
            task_name     => shift,
            params        => shift,
        };
    }
    my $session  = $self->get_session({session_id => $args->{session_id}, building_id => $args->{building_id} });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $task_name = $args->{task_name};
    my $subsidize = $args->{subsidize};

    my $body                   = $building->body;
    my ($target, $target_type) = $self->find_target($empire, $args->{target});
    my $effect                 = {};

    my $return_stats = {};
    if ($building->is_working) {
        confess [1010, 'The Black Hole Generator is cooling down from the last use.'];
    }
    $building->start_work({}, 600)->update;
    unless (defined $target) {
        confess [1002, 'Could not locate target.'];
    }
    my @tasks = bhg_tasks($building);
    my ($task) = grep { $task_name eq $_->{name} } @tasks;
    unless ($task) {
        confess [1002, 'Could not find task: '.$task_name];
    }
    my $chance = task_chance($building, $target, $target_type, $task);
    if ($chance->{throw} > 0) {
        confess [ $chance->{throw}, $chance->{reason} ];
    }
    for my $mod ("waste_cost", "recovery", "side_chance") {
        if (defined($chance->{$mod})) {
            $task->{$mod} = $chance->{$mod};
        }
    }
    if ($subsidize) {
        if ($empire->essentia < $chance->{essentia_cost}) {
            confess [1011, "Not enough essentia."];
        }
        $chance->{success} = 100;
    }
    # Check Target Status
    my $btype;
    my $tempire;
    my $tstar;
    my $tid;
    # Handle Stars
    if (ref $target eq 'HASH') {
        $btype = $target->{type};
        $tstar = $target->{star};
        $tid   = $target->{id};
    }
    else {
        if ($target->isa('Lacuna::DB::Result::Map::Star')) {
            $btype = 'star';
            $tstar = $target;
        }
        else {
            $btype = $target->get_type;
            $tstar = $target->star;
            if (defined($target->empire)) {
                $tempire = $target->empire;
            }
        }
        $tid = $target->id;
    }
    unless ($body->get_stored('waste') >= $task->{waste_cost}) {
        confess [1011, 'You need at least '.$task->{waste_cost}.' waste to run that function of the Black Hole Generator.'];
    }
    unless ($task->{occupied}) {
        if ($btype eq 'asteroid') {
            my $platforms = Lacuna->db->resultset('MiningPlatform')
                ->search({asteroid_id => $target->id });
            my $count = 0;
            while (my $platform = $platforms->next) {
                $count++;
            }
            if ($count) {
                $body->add_news(75, 'Scientists revolt against %s for despicable practices.', $empire->name);
                $effect->{fail} = bhg_self_destruct($building);
                return {
                    status => $self->format_status($session, $body),
                    effect => $effect,
                };
            }
        }
        elsif (defined($tempire)) {
            $body->add_news(
                75,
                sprintf(
                    'Scientists revolt against %s for trying to turn %s into an asteroid.',
                    $empire->name, $target->name
                )
            );
            $effect->{fail} = bhg_self_destruct($building);
            return {
                status => $self->format_status($session, $body),
                effect => $effect,
            };
        }
    }
    if ( $task->{name} eq "Change Type" && defined ($tempire) ) {
        unless (
            ($body->empire->id == $tempire->id)
            or
            (   $body->empire->alliance_id
                && ($body->empire->alliance_id == $tempire->alliance_id)
            )
        ) {
            confess [1009, "You can not change type of a body if it is occupied by another alliance!"];
        }
        my $class = $target->class;
        my $ntype = $args->{params}->{newtype};
        if ($btype eq 'asteroid') {
            if ($class eq 'Lacuna::DB::Result::Map::Body::Asteroid::A'.$ntype) {
                confess [1013, "That body is already that type."];
            }
        }
        elsif ($btype eq 'habitable planet') {
            if ($class eq 'Lacuna::DB::Result::Map::Body::Planet::P'.$ntype) {
                confess [1013, "That body is already that type."];
            }
        }
        else {
            confess [1013, "We can't change the type of that body"];
        }
    }
    elsif ( $task->{name} eq "Swap Places" ) {
        my $confess = "";
        my $allowed = 0;
        if ($body->id == $tid) {
            $confess = "Pointless swapping with oneself.";
        }
        elsif (defined($tempire)) {
            $confess = "You can not attempt that action on a body if it is occupied by another alliance!";
            if ( ($body->empire->id == $tempire->id) or ( $body->empire->alliance_id
                  && ($body->empire->alliance_id == $tempire->alliance_id))) {
                $allowed = 1;
            }
        }
        else {
            if ($tstar->station_id) {
                if ($tstar->station->laws->search({type => 'MembersOnlyColonization'})->count) {
                    if ($tstar->station->alliance_id == $body->empire->alliance_id) {
                        $allowed = 1;
                    }
                    else {
                        $confess = 'Only '.$tstar->station->alliance->name.
                                   ' members can bring colonies into the jurisdiction of space station '.
                                   $tstar->station->name.'.';
                    }
                }
                else {
                    $allowed = 1;
                }
            }
            else {
                $allowed = 1;
            }
        }
        if ($body->get_buildings_of_class('Lacuna::DB::Result::Building::Permanent::Fissure')) {
            $confess = sprintf("%s can not be moved without tearing apart from the fissure on it.", $body->name);
            $allowed = 0;
        }
        elsif ($btype eq 'habitable planet' and $target->get_buildings_of_class('Lacuna::DB::Result::Building::Permanent::Fissure')) {
            $confess = sprintf("%s can not be moved without tearing apart from the fissure on it.", $target->name);
            $allowed = 0;
        }
        unless ($allowed) {
            confess [ 1010, $confess ];
        }
    }
    elsif ( $task->{name} eq 'Move System' ) {
        unless ($target->isa('Lacuna::DB::Result::Map::Star')) {
            confess [1009, "You can not attempt that action on non-stars!"];
        }
        if ($target->id == $body->star->id) {
            confess [1009, "You are already in that system"];
        }
# This is handled now by check_member_laws
#        if ($target->station_id) {
#            unless ($body->empire->alliance_id && $target->station->alliance_id == $body->empire->alliance_id) {
#                confess [1009, 'That star system is claimed by '.$tstar->station->alliance->name.'.'];
#            }
#        }
        # Let's check all planets in our system and target system
        qualify_moving_sys($building, $target);
#Need to add to qualify
    }
    elsif ( $task->{name} eq 'Jump Zone' ) {
        if ($body->get_buildings_of_class('Lacuna::DB::Result::Building::Permanent::Fissure')) {
            confess [1009, sprintf("%s can not be moved without tearing apart from the fissure on it.", $body->name) ];
        }
    }

    $body->spend_waste($task->{waste_cost})->update;
    my $work_ends = DateTime->now;
    $work_ends->add(seconds => $task->{recovery});
    $building->reschedule_work($work_ends);
    $building->update;
    # Passed basic checks
#Check for enemy spies.
    my $lock_down = Lacuna
                    ->db
                    ->resultset('Spy')
                    ->search(
                        { on_body_id  => $body->id,
                          empire_id => { '!=' => $body->empire_id },
                          task => 'Sabotage BHG'  },
                          { order_by => 'rand()' }
                            )->first;
    if (defined $lock_down) {
        my $power = $lock_down->mayhem_xp + $lock_down->offense;
        my $defense = 0;
        my $hq = $body->get_building_of_class('Lacuna::DB::Result::Building::Security');
        if (defined $hq) {
            $defense = $hq->effective_level * $hq->effective_efficiency;
        }
        my $breakthru = int(($power - $defense + $lock_down->luck)/100 + 0.5)+50;
        $breakthru = 5 if $breakthru < 5;
        $breakthru = 95 if $breakthru > 95;
        my $failure = 0;
        my $spy_cond;
#See if spy successfully blocks BHG.
        if (randint(0,99) < $breakthru) { # Success!
            $subsidize = 0;  # Turn off E cost
            $chance->{success} = 0;
            $failure = 1;
        }
        else {
            $breakthru = $breakthru/2;
        }
        my $caught = randint(0,99);
        if ($caught > $breakthru) {
            if (randint(0,2) == 0) {
                $spy_cond = "Killed";
            }
            else {
                $spy_cond = "Captured";
            }
        }
        elsif ($breakthru - $caught < 10) {
            my $rand = randint(0,4);
            if ($rand == 0) {
                $spy_cond = "Killed";
            }
            elsif ($rand < 3) {
                $spy_cond = "Captured";
            }
            else {
                $spy_cond = "Squeek";
            }
        }
        else {
            my $rand = randint(0,9);
            if ($rand == 0) {
                $spy_cond = "Killed";
            }
            elsif ($rand < 3) {
                $spy_cond = "Unconscious";
            }
            else {
                $spy_cond = "Escaped";
            }
        }
#Post news
#Send emails
        my $o_message;
        my $e_message;
        my $add_skill = 6;
        if ($failure == 1) {
            $add_skill = 10;
            $lock_down->offense_mission_successes($lock_down->offense_mission_successes + 1 );
            $body->add_news(100, 'Enemy agents prevented the Black Hole Generator on %s to be used!',
                            $body->name);
            if ($spy_cond eq "Killed") {
                $o_message = sprintf("We had a security breach with our BHG on %s, causing a misfire, we killed the enemy agent responsible.",
                                     $body->name);
                $e_message = sprintf("%s was successful on %s in preventing the BHG to be used, but was killed trying to escape.",
                                     $lock_down->name, $body->name);
            }
            elsif ($spy_cond eq "Captured") {
                $o_message = sprintf("We had a security breach with our BHG on %s, causing a misfire, but we caught %s before they could get away.",
                                     $body->name, $lock_down->name);
                $e_message = sprintf("%s was successful on %s in preventing the BHG to be used, but was captured.",
                                     $lock_down->name, $body->name);
            }
            elsif ($spy_cond eq "Squeek") {
                $o_message = sprintf("We had a security breach with our BHG on %s, causing a misfire, the agent responsible got away.",
                                     $body->name);
                $e_message = sprintf("%s was successful on %s in preventing the BHG to be used, but was spotted getting away.",
                                     $lock_down->name, $body->name);
            }
            elsif ($spy_cond eq "Escaped") {
                $o_message = sprintf("Our BHG on %s misfired today.  We suspect enemy action.",
                                     $body->name);
                $e_message = sprintf("%s was successful on %s in preventing the BHG to be used, %s suspects nothing.",
                                     $lock_down->name, $body->name, $body->empire->name);
            }
            elsif ($spy_cond eq "Unconscious") {
                $o_message = sprintf("Our BHG on %s misfired today causing many of our scientists to be sent to the hospital.",
                                     $body->name);
                $e_message = sprintf("%s was successful on %s in preventing the BHG to be used, but has not reported back. He may be in the hospital.",
                                     $lock_down->name, $body->name);
            }
        }
        else {
            if ($spy_cond eq "Killed") {
                $o_message = sprintf("Our security spotted an enemy agent before he could cause a problem on %s. He was shot trying to resist arrest.",
                                     $body->name);
                $e_message = sprintf("%s was killed trying to stop the BHG on %s.",
                                     $lock_down->name, $body->name);
            }
            elsif ($spy_cond eq "Captured") {
                $o_message = sprintf("Our security spotted an enemy agent before they could cause a problem on %s. They are currently under going interrogation.",
                                     $body->name);
                $e_message = sprintf("%s was captured trying to stop the BHG on %s.",
                                     $lock_down->name, $body->name);
            }
            elsif ($spy_cond eq "Squeek") {
                $o_message = sprintf("Our security spotted an enemy agent before they could cause a problem on %s. Regrettfully, they got away.",
                                     $body->name);
                $e_message = sprintf("%s was almost captured trying to stop the BHG on %s.",
                                     $lock_down->name, $body->name);
            }
            elsif ($spy_cond eq "Escaped") {
                $o_message = sprintf("We noticed an odd power fluctuation with our BHG on %s, but everything worked as expected.",
                                     $body->name);
                $e_message = sprintf("%s was almost captured trying to stop the BHG on %s.",
                                     $lock_down->name, $body->name);
            }
            elsif ($spy_cond eq "Unconscious") {
                $o_message = sprintf("We need to have a meeting about safety concerns at the BHG on %s. We found another unconsious worker there.",
                                     $body->name);
                $e_message = sprintf("%s was knocked out trying to sabotage the BHG on %s.",
                                     $lock_down->name, $body->name);
            }
        }
        $body->empire->send_predefined_message(
                tags        => ['Spies','Alert'],
                filename    => 'bhg_sabotage_us.txt',
                params      => [$o_message],
        );
        $lock_down->empire->send_predefined_message(
                tags        => ['Spies','Alert'],
                filename    => 'bhg_sabotage_them.txt',
                params      => [$e_message],
        );
        if ($spy_cond eq "Killed") {
            $lock_down->available_on(DateTime->now->add(years => 5));
            $lock_down->task('Killed In Action');
        }
        elsif ($spy_cond eq "Captured") {
            $lock_down->available_on(DateTime->now->add(days=>7));
            $lock_down->task('Captured');
            $lock_down->started_assignment(DateTime->now);
            $lock_down->times_captured( $lock_down->times_captured + 1 );
        }
        elsif ($spy_cond eq "Squeek" or $spy_cond eq "Escaped") {
        }
        elsif ($spy_cond eq "Unconscious") {
            $lock_down->available_on(DateTime->now->add(seconds => randint(120, 60 * 60 * 48)));
            $lock_down->task('Unconscious');
        }
        my $off_skill = $lock_down->mayhem_xp + $add_skill;
        $off_skill = 2600 if ($off_skill > 2600);
        $lock_down->mayhem_xp($off_skill);
        $lock_down->offense_mission_count( $lock_down->offense_mission_count + 1);
        $lock_down->update;
    }
###
    # Check for startup failure
    my $roll = randint(0,99);
    if ($roll >= $chance->{success}) {
        # Something went wrong with the start
        my $fail = randint(0,19);
        if ($fail == 0) {
            $return_stats = bhg_self_destruct($building);
            $body->add_news(
                75,
                sprintf('%s finds a decimal point out of place.', $empire->name)
            );
        }
        elsif ($fail <  6) {
            $return_stats = bhg_decor($building, $body, -1);
            $body->add_news(
                30,
                sprintf('%s is wracked with changes.', $body->name)
            );
        }
        elsif ($fail < 11) {
            $return_stats = bhg_resource($body, -1);
            $body->add_news(
                50,
                sprintf('%s opens up a wormhole near their storage area.', $body->name)
            );
        }
        elsif ($fail < 16) {
            $return_stats = bhg_size($building, $body, -1);
            $body->add_news(
                50,
                sprintf('%s deforms after an experiment goes wild.', $body->name)
            );
        }
        elsif ($fail < 19) {
            $return_stats = bhg_random_make($building);
            $body->add_news(
                50,
                sprintf('Scientists on %s are concerned when their singularity has a malfunction.', $body->name)
            );
        }
        else {
            $return_stats = bhg_random_type($building);
            $body->add_news(
                50,
                sprintf('Scientists on %s are concerned when their singularity has a malfunction.', $body->name)
            );
        }
        $return_stats->{perc} = $chance->{success};
        $return_stats->{roll} = $roll;
        $effect->{fail} = $return_stats;
    }
    else {
        # We have a working BHG!
        if ($task->{name} eq "Make Planet") {
            $return_stats = bhg_make_planet($building, $target);
            $body->add_news(
                50,
                sprintf('%s has expanded %s into a habitable world!', $empire->name, $target->name)
            );
        }
        elsif ($task->{name} eq "Make Asteroid") {
            $return_stats = bhg_make_asteroid($building, $target);
            $body->add_news(75, '%s has destroyed %s.', $empire->name, $target->name);
        }
        elsif ($task->{name} eq "Increase Size") {
            $return_stats = bhg_size($building, $target, 1);
            $body->add_news(50, '%s has expanded %s.', $empire->name, $target->name);
        }
        elsif ($task->{name} eq "Change Type") {
            $return_stats = bhg_change_type($target, $args->{params});
            $body->add_news(
                50,
                sprintf('The geology of %s has been extensively altered by powers unknown', $target->name)
            );
        }
        elsif ($task->{name} eq "Jump Zone") {
            $return_stats = bhg_swap($building->body, $target);
            $return_stats->{message}  = "Jumped Zone",
            my $tname;
            if (ref $target eq 'HASH') {
                $tname = $target->{name};
            }
            else {
                $tname = $target->name;
            }
            $body->add_news(50, '%s has switched places with %s!', $body->name, $tname);
        }
        elsif ($task->{name} eq "Swap Places") {
            $return_stats = bhg_swap($building->body, $target);
            my $tname;
            if (ref $target eq 'HASH') {
                $tname = $target->{name};
            }
            else {
                $tname = $target->name;
            }
            $body->add_news(50, '%s has switched places with %s!', $body->name, $tname);
        }
        elsif ($task->{name} eq "Move System") {
            $return_stats = bhg_move_system($building, $target);
            $body->add_news(
                50,
                sprintf(
                    'Astronomers are perplexed about the change of the orbiting bodies around %s.',
                    $target->name
                )
            );
        }
        else {
            confess [552, "Internal Error"];
        }
        $effect->{target} = $return_stats;
        #And now side effect time
        my $side = randint(0,99);
        if ($return_stats->{fissures}) {
            for my $count (1 .. $return_stats->{fissures}) {
                $return_stats = bhg_random_fissure($building);
                $effect->{side} = $return_stats;
            }
        }
        elsif ($task->{side_chance} > $side) {
            my $side_type = randint(0,99);
            if ($side_type < 5) {
                $return_stats = bhg_random_fissure($building);
            }
            elsif ($side_type < 25) {
                $return_stats = bhg_random_size($building);
            }
            elsif ($side_type < 40) {
                $return_stats = bhg_random_make($building);
            }
            elsif ($side_type < 50) {
                $return_stats = bhg_random_type($building);
            }
            elsif ($side_type < 75) {
                $return_stats = bhg_random_resource($building);
            }
            elsif ($side_type < 97) {
                $return_stats = bhg_random_decor($building);
            }
            else {
                $return_stats = bhg_resource($body, 0);
            }
            $effect->{side} = $return_stats;
        }
    }
    if ($subsidize) {
        $empire->spend_essentia({
            amount  => $chance->{essentia_cost},
            reason  => 'BHG perfection subsidy after the fact',
        });
        $empire->update;
    }

    return {
        status => $self->format_status($session, $body),
        effect => $effect,
    };
}

sub qualify_moving_sys {
    my ($building, $target_star) = @_;
    my $current_body = $building->body;
    my $current_star = $current_body->star;
    my $current_empire = $current_body->empire;
    my $ceid = $current_empire->id;
    my $caid = $current_empire->alliance_id;

    my $bodies = Lacuna->db->resultset('Map::Body')->search({star_id => [ $current_star->id, $target_star->id]});

    while (my $body = $bodies->next) {
        if (defined($body->empire)) {
            my $body_empire = $body->empire;
            unless ($body_empire->id == $ceid) {
                unless (
                    (defined($caid) and defined($body_empire->alliance_id))
                    and
                    ($caid == $body_empire->alliance_id)
                ) {
                    confess [1009, 'You can only move your own alliance member bodies.'];
                }
            }
        }
        if ($body->get_type ne 'asteroid' and $body->get_buildings_of_class('Lacuna::DB::Result::Building::Permanent::Fissure')) {
            confess [1009, 'You can not move a body with a fissure on it.'];
        }
    }
    return 1;
}

sub bhg_move_system {
    my ($building, $target_star) = @_;
    my $current_body = $building->body;
    my $current_star = $current_body->star;

    my $current_bodies = make_orbit_array($current_star);
    my $target_bodies  = make_orbit_array($target_star);

    my $return_stats = {};
    my @orbiting;
    my @recalcs;
    for my $orbit (1..8) {
        my $return;
        if ($current_bodies->[$orbit] and $target_bodies->[$orbit]) {
            $return = bhg_swap($current_bodies->[$orbit], $target_bodies->[$orbit]);
            push @recalcs, $current_bodies->[$orbit];
            push @recalcs, $target_bodies->[$orbit];
        }
        elsif ($current_bodies->[$orbit] and !($target_bodies->[$orbit])) {
            my $targeted = target_orbit($target_star, $orbit);
            $return = bhg_swap($current_bodies->[$orbit], $targeted);
            push @recalcs, $current_bodies->[$orbit];
        }
        elsif (!($current_bodies->[$orbit]) and $target_bodies->[$orbit]) {
            my $targeted = target_orbit($current_star, $orbit);
            $return = bhg_swap($target_bodies->[$orbit], $targeted);
            push @recalcs, $target_bodies->[$orbit];
        }
        else {
            $return = {
                id      => 0,
                message => "Swapped Places",
                name    => "Empty Orbit",
                orbit   => $orbit,
            };
        }
        push @orbiting, $return;
    }
    for my $bod (@recalcs) {
# We need to redo all the chains of the moved planets in one go.
        if ($bod->empire and $bod->get_type ne 'asteroid') {
            $bod->recalc_chains;
            recalc_incoming_supply($bod);
        }
    }
    return {
        id       => $target_star->id,
        message  => "Moved System",
        name     => $target_star->name,
        orbits   => \@orbiting,
        swapname => $current_star->name,
        swapid   => $current_star->id,
    };
}

sub target_orbit {
    my ($star, $orbit) = @_;

    my $x = $star->x;
    my $y = $star->y;
    my $offset = [
        [ $x    , $y     ],  # Not an orbit.
        [ $x + 1, $y + 2 ],  # 1
        [ $x + 2, $y + 1 ],  # 2
        [ $x + 2, $y - 1 ],  # 3
        [ $x + 1, $y - 2 ],  # 4
        [ $x - 1, $y - 2 ],  # 5
        [ $x - 2, $y - 1 ],  # 6
        [ $x - 2, $y + 1 ],  # 7
        [ $x - 1, $y + 2 ],  # 8
    ];
    my $target = {
        id      => 0,
        name    => "Empty Space",
        orbit   => $orbit,
        type    => 'empty',
        x       => $offset->[$orbit]->[0],
        y       => $offset->[$orbit]->[1],
        zone    => $star->zone,
        star    => $star,
        star_id => $star->id,
    };
    return $target;
}

sub make_orbit_array {
    my ($star) = @_;
    my $bodies = Lacuna->db->resultset('Map::Body')->search({star_id => $star->id});
    my @orbits;
    while (my $body = $bodies->next) {
        $orbits[$body->orbit] = $body;
    }
    return \@orbits;
}

sub bhg_swap {
    my ($body, $target) = @_;
    my $return;
    my $old_data = {
        x       => $body->x,
        y       => $body->y,
        zone    => $body->zone,
        star_id => $body->star_id,
        orbit   => $body->orbit,
    };
    my $new_data;
    if (ref $target eq 'HASH') {
        $new_data = {
            id      => $target->{id},
            name    => $target->{name},
            orbit   => $target->{orbit},
            star_id => $target->{star_id},
            type    => $target->{type},
            x       => $target->{x},
            y       => $target->{y},
            zone    => $target->{zone},
        };
    }
    else {
        $new_data = {
            id      => $target->id,
            name    => $target->name,
            orbit   => $target->orbit,
            star_id => $target->star_id,
            type    => $target->get_type,
            x       => $target->x,
            y       => $target->y,
            zone    => $target->zone,
        };
    }
    $body->update({
        needs_recalc => 1,
        x       => $new_data->{x},
        y       => $new_data->{y},
        zone    => $new_data->{zone},
        star_id => $new_data->{star_id},
        orbit   => $new_data->{orbit},
    });

    unless ($new_data->{type} eq "empty") {
        $target->update({
            needs_recalc => 1,
            x       => $old_data->{x},
            y       => $old_data->{y},
            zone    => $old_data->{zone},
            star_id => $old_data->{star_id},
            orbit   => $old_data->{orbit},
        });
        if ($new_data->{type} ne 'asteroid') {
            my $target_waste = Lacuna->db->resultset('WasteChain')
                ->search({ planet_id => $target->id });
            if ($target_waste->count > 0) {
                while (my $chain = $target_waste->next) {
                    $chain->update({
                        star_id => $old_data->{star_id}
                    });
                }
            }
            if ($new_data->{type} eq 'space station') {
                drop_stars_beyond_range($target);
            }
        }
        if (defined($target->empire)) {
            my $toracle = $body->get_building_of_class('Lacuna::DB::Result::Building::Permanent::OracleOfAnid');
            if ($toracle) {
                if ($toracle->is_working) {
                    my $work_ends = DateTime->now->add(seconds => 60 * 5);
                    $toracle->reschedule_work($work_ends);
                }
                else {
                    $toracle->start_work({}, 60 * 5);
                }
                $toracle->update;
            }
            my $mbody = Lacuna->db
                ->resultset('Map::Body')
                ->find($target->id);
            my $fbody = Lacuna->db
                ->resultset('Map::Body')
                ->find($body->id);
            my $mess = sprintf("{Starmap %s %s %s} is now at %s/%s in orbit %s around {Starmap %s %s %s}.",
                    $fbody->x, $fbody->y, $fbody->name,
                    $fbody->x, $fbody->y, $fbody->orbit,
                    $fbody->star->x, $fbody->star->y, $fbody->star->name);
            $target->empire->send_predefined_message(
                tags     => ['Alert'],
                filename => 'planet_moved.txt',
                params   => [
                    $mbody->x,
                    $mbody->y,
                    $mbody->name,
                    $mbody->x,
                    $mbody->y,
                    $mbody->orbit,
                    $mbody->star->x,
                    $mbody->star->y,
                    $mbody->star->name,
                    $mess,
                ],
            );
        }
    }
    if ($body->get_type ne 'asteroid') {
        my $waste_chain = Lacuna->db->resultset('WasteChain')
            ->search({ planet_id => $body->id });
        if ($waste_chain->count > 0) {
            while (my $chain = $waste_chain->next) {
                $chain->update({
                    star_id => $new_data->{star_id}
                });
            }
        }
        if ($body->get_type eq 'space station') {
            drop_stars_beyond_range($body);
        }
        my $boracle = $body->get_building_of_class('Lacuna::DB::Result::Building::Permanent::OracleOfAnid');
        if ($boracle) {
            if ($boracle->is_working) {
                my $work_ends = DateTime->now->add(seconds => 60 * 5);
                $boracle->reschedule_work($work_ends);
            }
            else {
                $boracle->start_work({}, 60 * 5);
            }
            $boracle->update;
        }
    }
    if (defined($body->empire)) {
        my $mbody = Lacuna->db
            ->resultset('Map::Body')
            ->find($body->id);
        my $mess;
        unless ($new_data->{type} eq "empty") {
            my $fbody = Lacuna->db
                ->resultset('Map::Body')
                ->find($target->id);
            $mess = sprintf("{Starmap %s %s %s} took our place at %s/%s in orbit %s around {Starmap %s %s %s}.",
                    $fbody->x, $fbody->y, $fbody->name,
                    $fbody->x, $fbody->y, $fbody->orbit,
                    $fbody->star->x, $fbody->star->y, $fbody->star->name);
        }
        else {
            my $star = Lacuna->db->
                       resultset('Map::Star')->find($old_data->{star_id});
            $mess = sprintf("There is now an empty orbit at %s/%s in orbit %s around {Starmap %s %s %s}",
                    $old_data->{x}, $old_data->{y}, $old_data->{orbit},
                    $star->x, $star->y, $star->name);
        }
        $body->empire->send_predefined_message(
            tags     => ['Alert'],
            filename => 'planet_moved.txt',
            params   => [
                    $mbody->x,
                    $mbody->y,
                    $mbody->name,
                    $mbody->x,
                    $mbody->y,
                    $mbody->orbit,
                    $mbody->star->x,
                    $mbody->star->y,
                    $mbody->star->name,
                    $mess,
            ],
        );
    }
    unless ($new_data->{type} eq "empty" or $new_data->{type} eq 'asteroid') {
        $target->recalc_chains; # Recalc all chains
        recalc_incoming_supply($target);
        $target->update({needs_recalc => 1});
    }
    if ($body->get_type ne 'asteroid') {
        $body->recalc_chains; # Recalc all chains
        recalc_incoming_supply($body);
        $body->update({needs_recalc => 1});
    }

    return {
        id       => $body->id,
        message  => "Swapped Places",
        name     => $body->name,
        orbit    => $new_data->{orbit},
        star_id  => $new_data->{star_id},
        swapname => $new_data->{name},
        swapid   => $new_data->{id},
    };
}

sub recalc_incoming_supply {
    my ($body) = @_;

    my $all_chains = $body->in_supply_chains;

    my %bids;
    while (my $chain = $all_chains->next) {
        my $bid = $chain->planet_id;
        next if defined($bids{$bid});
        $bids{$bid} = 1;
        my $sender = Lacuna->db
            ->resultset('Map::Body')
            ->find($bid);
        if (defined($sender->empire)) {
            $sender->recalc_chains; # Recalc all chains
        }
    }
}

sub drop_stars_beyond_range {
    my ($station) = @_;

    return 0 if ($station->get_type ne 'space station');
    $station->update_influence();
    return 1;
}

sub bhg_make_planet {
    my ($building, $body) = @_;
    my $class;
    my $size;
    my $old_class = $body->class;
    my $old_size  = $body->size;
    my $random = randint(0,99);
    if ($random < 5) {
        $class = 'Lacuna::DB::Result::Map::Body::Planet::GasGiant::G'.randint(1,Lacuna::DB::Result::Map::Body->gas_giant_types);
        $size  = randint(90, 121);
    }
    else {
        $class = 'Lacuna::DB::Result::Map::Body::Planet::P'.randint(1,Lacuna::DB::Result::Map::Body->planet_types);
        $size  = 30;
    }

    $body->update({
        class                     => $class,
        size                      => $size,
        needs_recalc              => 1,
        usable_as_starter_enabled => 0,
    });
    $body->sanitize;
    return {
        message   => "Made Planet",
        old_class => $old_class,
        class     => $class,
        old_size  => $old_size,
        size      => $size,
        id        => $body->id,
        name      => $body->name,
    };
}

sub bhg_make_asteroid {
    my ($building, $body) = @_;
    my $old_class = $body->class;
    my $old_size  = $body->size;
    my @fissures = $body->get_buildings_of_class('Lacuna::DB::Result::Building::Permanent::Fissure');
    my @to_demolish = @{$body->building_cache};
    $body->delete_buildings(\@to_demolish);
    my $new_size = int($building->effective_level/5);
    $new_size = 10 if $new_size > 10;
    $body->update({
        class                     => 'Lacuna::DB::Result::Map::Body::Asteroid::A'.randint(1,Lacuna::DB::Result::Map::Body->asteroid_types),
        size                      => $new_size,
        needs_recalc              => 1,
        usable_as_starter_enabled => 0,
        alliance_id => undef,
    });
    my $rstat =  {
        message   => "Made Asteroid",
        old_class => $old_class,
        class     => $body->class,
        old_size  => $old_size,
        size      => $new_size,
        id        => $body->id,
        name      => $body->name,
    };
    if (scalar @fissures) {
        $rstat->{fissures} = scalar @fissures;
    }
    return $rstat;
}

sub bhg_random_make {
    my ($building) = @_;
    my $body = $building->body;
    my $return;
    my $target = Lacuna->db->resultset('Map::Body')
        ->search(
            {zone => $body->zone, empire_id => undef, },
            { order_by => 'rand()' }
        )->first;
    my $btype = $target->get_type;
    my ($throw, $reason) = check_bhg_neutralized($target);
    if ($throw > 0) {
        $return = {
            message => "Side effect neutralized",
            id      => $target->id,
            name    => $target->name,
        };
    }
    elsif ($btype eq 'habitable planet' or $btype eq 'gas giant') {
        $body->add_news(75, '%s has been destroyed!', $target->name);
        $return = bhg_make_asteroid($building, $target);
    }
    elsif ($btype eq 'asteroid') {
        my $platforms = Lacuna->db->resultset('MiningPlatform')->
        search({asteroid_id => $target->id });
        unless ($platforms->next) {
            $body->add_news(50, 'A new planet has appeared where %s had been!', $target->name);
            $return = bhg_make_planet($building, $target);
        }
        else {
            $return = {
                message => "Aborted making planet",
                id      => $target->id,
                name    => $target->name,
            };
        }
    }
    return $return;
}

sub bhg_random_type {
    my ($building) = @_;
    my $body = $building->body;
    my $return;
    my $target = Lacuna->db->resultset('Map::Body')
        ->search(
            {zone => $body->zone, empire_id => undef, },
            { order_by => 'rand()' }
        )->first;
    my $btype = $target->get_type;
    my ($throw, $reason) = check_bhg_neutralized($target);
    if ($throw > 0) {
        $return = {
            message => "Side effect neutralized",
            id      => $target->id,
            name    => $target->name,
        };
    }
    elsif ($btype eq 'habitable planet') {
        my $params = { newtype => randint(1,Lacuna::DB::Result::Map::Body->planet_types) };
        $body->add_news(50, '%s has gone thru extensive changes.', $target->name);
        $return = bhg_change_type($target, $params);
    }
    elsif ($btype eq 'asteroid') {
        my $params = { newtype => randint(1,Lacuna::DB::Result::Map::Body->asteroid_types) };
        $body->add_news(50, '%s has gone thru extensive changes.', $target->name);
        $return = bhg_change_type($target, $params);
    }
    else {
        $return = {
            message => "Fizzle",
            id      => $target->id,
            name    => $target->name,
        };
    }
    return $return;
}

sub bhg_random_size {
    my ($building) = @_;
    my $body = $building->body;
    my $target = Lacuna->db->resultset('Map::Body')
        ->search(
            {zone => $body->zone, id => { '!=' => $body->id } },
            { order_by => 'rand()' }
        )->first;
    my $return;
    my $btype = $target->get_type;
    my ($throw, $reason) = check_bhg_neutralized($target);
    if ($throw > 0) {
        $return = {
            message => "Side effect neutralized",
            id      => $target->id,
            name    => $target->name,
        };
    }
    elsif ($btype eq 'habitable planet') {
        $body->add_news(50, '%s has deformed.', $target->name);
        $return = bhg_size($building, $target, 0);
    }
    elsif ($btype eq 'asteroid') {
        $body->add_news(50, '%s has deformed.', $target->name);
        $return = bhg_size($building, $target, 0);
    }
    else {
        $return = {
            message => "Fizzle",
            id      => $target->id,
            name    => $target->name,
        };
    }
    return $return;
}

sub bhg_random_resource {
    my ($building) = @_;
    my $body = $building->body;
    my $target = Lacuna->db->resultset('Map::Body')
        ->search(
            {zone => $body->zone, empire_id => { '!=' => undef} },
            { order_by => 'rand()' }
        )->first;
    my $return;
    my $btype = $target->get_type;
    my ($throw, $reason) = check_bhg_neutralized($target);
    if ($throw > 0) {
        $return = {
            message => "Side effect neutralized",
            id      => $target->id,
            name    => $target->name,
        };
    }
    elsif ($btype eq 'habitable planet' or $btype eq 'gas giant') {
        $body->add_news(50, 'A wormhole briefly appeared on %s.', $target->name);
        my $variance =  (randint(0,9) < 2) ? 1 : 0;
        $return = bhg_resource($target, $variance);
    }
    else {
        $return = {
            message => "No Resources Modified",
            id      => $target->id,
            name    => $target->name,
        };
    }
    return $return;
}

sub bhg_random_fissure {
    my ($building) = @_;
    my $body = $building->body;
    my $target = Lacuna->db->resultset('Map::Body')
    ->search(
            {
                zone      => $body->zone,
                empire_id => undef,
                class     => { like => 'Lacuna::DB::Result::Map::Body::Planet::P%' },
                usable_as_starter_enabled   => 0,
            },
            { order_by => 'rand()' }
        )->first;
    my $btype = $target->get_type;
    my $return = {
        id        => $target->id,
        name      => $target->name,
        type    => $btype,
    };
    my ($throw, $reason) = check_bhg_neutralized($target);
    if ($throw > 0) {
        $return = {
            message => "Side effect neutralized",
            id      => $target->id,
            name    => $target->name,
        };
    }
    elsif ($btype eq 'habitable planet') {
        my ($x, $y) = eval { $target->find_free_space};
        unless ($@) {
            my $level = randint(1,30);
            my $building = Lacuna->db->resultset('Building')->new({
                x            => $x,
                y            => $y,
                level        => $level,
                body_id      => $target->id,
                body         => $target,
                class        => 'Lacuna::DB::Result::Building::Permanent::Fissure',
            });
            $target->build_building($building, undef, 1);
            $body->add_news(50, 'Astronomers detect a gravitational anomoly on %s.', $target->name);
            $body->empire->add_medal('Fissure');
            $return->{message} = "Fissure formed";
            my $minus_x = 0 - $target->x;
            my $minus_y = 0 - $target->y;
            my $alert = Lacuna->db->resultset('Map::Body')->search({
                -and => [
                    {empire_id => { '!=' => 'Null' }}
                ],
            },{
                '+select' => [
                    { ceil => \"pow(pow(me.x + $minus_x,2) + pow(me.y + $minus_y,2), 0.5)", '-as' => 'distance' },
                ],
                '+as' => [
                    'distance',
                ],
                order_by    => 'distance',
            });
            my %already;
            my $max_alert = $level*5;
            $max_alert = 120 if ($max_alert > 120);
            $max_alert = 25 if ($max_alert < 25);
            my $number_to_alert = 0;
            while (my $to_alert = $alert->next) {
                last if ($number_to_alert++ > 25);
                my $distance = $to_alert->get_column('distance');
                last if ($distance > $max_alert);
                my $eid = $to_alert->empire_id;
                unless ($already{$eid} == 1) {
                    $already{$eid} = 1;
                    $to_alert->empire->send_predefined_message(
                        tags        => ['Fissure', 'Alert'],
                        filename    => 'fissure_alert_spawn.txt',
                        params      => [$target->x, $target->y, $target->name],
                    );
                }
            }
        }
        else {
            $return->{message} = "No warp";
        }
    }
    else {
        $return->{message} = "No warp";
    }
    return $return;
}

sub bhg_random_decor {
    my ($building) = @_;
    my $body = $building->body;
    my $target = Lacuna->db->resultset('Map::Body')
        ->search(
            {zone => $body->zone },
            { order_by => 'rand()' }
        )->first;
    my $btype = $target->get_type;
    my $return = {
        id        => $target->id,
        name      => $target->name,
    };
    my ($throw, $reason) = check_bhg_neutralized($target);
    if ($throw > 0) {
        $return = {
            message => "Side effect neutralized",
            id      => $target->id,
            name    => $target->name,
        };
    }
    elsif ($btype eq 'habitable planet') {
        if ($target->empire_id) {
            $body->add_news(75, 'The population of %s marvels at the new terrain.', $target->name);
        }
        else {
            $body->add_news(30, 'Astronomers claim that the surface of %s has changed.', $target->name);
        }
        my $variance =  (randint(0,9) < 2) ? 1 : 0;
        $return = bhg_decor($building, $target, $variance);
    }
    else {
        $return = {
            message => "No decorating",
            id      => $target->id,
            name    => $target->name,
            type    => $btype,
        };
    }
    return $return;
}

sub bhg_self_destruct {
    my ($building) = @_;
    my $body = $building->body;
    my $return = {
        id        => $body->id,
        name      => $body->name,
    };
    $body->set_stored('waste',0);

    # yes, ->level, not ->effective_level
    for (1..$building->level) {
        my ($placement) =
            sort {
                $b->efficiency <=> $a->efficiency ||
                rand() <=> rand()
            }
            grep {
                ($_->class ne 'Lacuna::DB::Result::Building::Permanent::Crater') and
                ($_->class ne 'Lacuna::DB::Result::Building::DeployedBleeder')
            } @{$body->building_cache};

        last unless defined($placement);
        my $amount = randint(10, 100);
        $placement->spend_efficiency($amount)->update;
    }
    $body->needs_surface_refresh(1);
    $body->needs_recalc(1);
    $body->update;
    $building->update({class=>'Lacuna::DB::Result::Building::Permanent::Fissure'});
    $body->empire->add_medal('Fissure');
    $return->{message} = "Black Hole Generator Destroyed";
    return $return;
}

sub bhg_decor {
    my ($building, $body, $variance) = @_;
    my @decor = qw(
        Lacuna::DB::Result::Building::Permanent::Crater
        Lacuna::DB::Result::Building::Permanent::Lake
        Lacuna::DB::Result::Building::Permanent::RockyOutcrop
        Lacuna::DB::Result::Building::Permanent::Grove
        Lacuna::DB::Result::Building::Permanent::Sand
        Lacuna::DB::Result::Building::Permanent::Lagoon
    );
    my $plant; my $max_level;
    if ($variance == -1) {
        $plant = randint(1, int($building->effective_level/10)+1);
        $max_level = 3;
    }
    elsif ($variance == 0) {
        $plant = randint(1, int($building->effective_level/5)+1);
        $max_level = int($building->level/5);
    }
    else {
        $plant = randint(1, int($building->effective_level/3)+1);
        $max_level = $building->effective_level;
    }
    $max_level = 30 if $max_level > 30;
    my $planted = 0;
    foreach my $cnt (1..$plant) {
        my ($x, $y) = eval { $body->find_free_space};
        unless ($@) {
            my $building = Lacuna->db->resultset('Building')->new({
                x       => $x,
                y       => $y,
                level   => randint(1, $max_level),
                body_id => $body->id,
                body    => $body,
                class   => random_element(\@decor),
            });
            $body->build_building($building, undef, 1);
            $planted++;
        }
        else {
            last;
        }
    }
    if ($planted) {
        $body->needs_surface_refresh(1);
        $body->needs_recalc(1);
        $body->update;
        if ($body->empire) {
            my $plural = ($planted > 1) ? "s" : "";
            $body->empire->send_predefined_message(
                tags     => ['Alert'],
                filename => 'new_decor.txt',
                params   => [$planted, $plural, $body->x, $body->y, $body->name],
            );
        }
        return {
            message => "$planted decor items placed",
            id      => $body->id,
            name    => $body->name,
        };
    }
    else {
        return {
            message => "Fizzle",
            id      => $body->id,
            name    => $body->name,
        };
    }
}

sub bhg_resource {
    my ($body, $variance) = @_;
    # If -1 deduct resources, if 0 randomize, if 1 add

    my $return = {
        variance  => $variance,
        id        => $body->id,
        name      => $body->name,
        message   => "Resource Shuffle",
    };
    # Waste always reacts oddly
    my $waste_msg;
    my $waste_rnd = randint(1,5);
    if ($waste_rnd > 3) {
        $body->set_stored('waste', $body->get_capacity('waste'));
        $return->{waste} = "Filled";
        $waste_msg = "filled our waste containers";
    }
    elsif ($waste_rnd < 3) {
        $body->set_stored('waste', 0);
        $return->{waste} = "Zero";
        $waste_msg = "emptied our waste containers";
    }
    else {
        $body->set_stored('waste', randint(0, $body->get_capacity('waste')));
        $return->{waste} = "Random";
        $waste_msg = "randomized our waste storage";
    }
    # Other resources
    my $resource_msg;
    if ($variance == 1) {
        $body->set_stored('water', randint($body->get_stored('water'), $body->get_capacity('water')));
        $body->set_stored('energy', randint($body->get_stored('energy'), $body->get_capacity('energy')));
        my $arr = rand_perc(scalar FOOD_TYPES);
        my $food_stored = 0;
        for my $type (FOOD_TYPES) {
            $food_stored += $body->get_stored($type);
        }
        my $food_room = $body->get_capacity('food') - $food_stored;
        for (0..(scalar FOOD_TYPES - 1)) {
            my $type = (FOOD_TYPES)[$_];
            $body->set_stored($type, randint(0, int($food_room * $arr->[$_]/100) ));
        }
        $arr = rand_perc(scalar ORE_TYPES);
        my $ore_stored = 0;
        for my $type (ORE_TYPES) {
            $ore_stored += $body->get_stored($type);
        }
        my $ore_room = $body->get_capacity('ore') - $ore_stored;
        for (0..(scalar ORE_TYPES - 1)) {
            my $type = (ORE_TYPES)[$_];
            $body->set_stored($type, randint(0, int($ore_room * $arr->[$_]/100) ));
        }
        $resource_msg = "added various resources";
    }
    elsif ($variance == -1) {
        $body->set_stored('water', randint(0, $body->get_stored('water')));
        $body->set_stored('energy', randint(0, $body->get_stored('energy')));
        foreach my $type (FOOD_TYPES, ORE_TYPES) {
            next unless $body->get_stored($type);
            $body->set_stored($type, randint(0, $body->get_stored($type)));
        }
        $resource_msg = "took away various resources";
    }
    else {
        $body->set_stored('water', randint(0, $body->get_capacity('water')));
        $body->set_stored('energy', randint(0, $body->get_capacity('energy')));
        my $arr = rand_perc(scalar FOOD_TYPES);
        for (0..(scalar FOOD_TYPES - 1)) {
            my $type = (FOOD_TYPES)[$_];
            $body->set_stored($type, randint(0, int($body->get_capacity('food') * $arr->[$_]/100) ));
        }
        $arr = rand_perc(scalar ORE_TYPES);
        for (0..(scalar ORE_TYPES - 1)) {
            my $type = (ORE_TYPES)[$_];
            $body->set_stored($type, randint(0, int($body->get_capacity('ore') * $arr->[$_]/100) ));
        }
        $resource_msg = "randomized our resources. We may need to do a full inventory";
    }
    $body->empire->send_predefined_message(
        tags     => ['Alert'],
        filename => 'wormhole.txt',
        params   => [$body->x, $body->y, $body->name, $waste_msg, $resource_msg],
    );
    $body->update({
        needs_recalc => 1,
    });
    return $return;
}

sub rand_perc {
    my ($num) = @_;

    my @arr;
    for (1..100) {
        $arr[randint(0,$num)]++;
    }
    return \@arr;
}

sub recalc_miners {
    my ($asteroid) = @_;

    my %mining_bodies = map { $_->planet_id => 1 }
                        Lacuna->db->resultset('MiningPlatform')->search({
                            asteroid_id => $asteroid->id})->all;
    for my $body_id (keys %mining_bodies) {
        my $body = Lacuna->db->resultset('Map::Body')->find($body_id);
        my $building = $body->get_building_of_class('Lacuna::DB::Result::Building::Ore::Ministry');
        $building->recalc_ore_production;
    }
}

sub bhg_change_type {
    my ($body, $params) = @_;
    my $class = $body->class;
    my $old_class = $class;
    my $btype = $body->get_type;
    if ($btype eq 'asteroid') {
        if ($params->{newtype} >= 1 and $params->{newtype} <= Lacuna::DB::Result::Map::Body->asteroid_types) {
            $class = 'Lacuna::DB::Result::Map::Body::Asteroid::A'.$params->{newtype};
        }
        else {
            confess [1013, "Trying to change to a forbidden type!"];
        }
    }
    elsif ($btype eq 'gas giant') {
        confess [1013, "We can't change the type of that body"];
    }
    elsif ($btype eq 'habitable planet') {
        if ($params->{newtype} >= 1 and $params->{newtype} <= Lacuna::DB::Result::Map::Body->planet_types) {
            $class = 'Lacuna::DB::Result::Map::Body::Planet::P'.$params->{newtype};
            $old_class =~ /::(P\d+)/;
            my $old_type = $1;
            $class =~ /::(P\d+)/;
            my $new_type = $1;
            if ($body->empire and $old_type ne $new_type) {
                $body->empire->send_predefined_message(
                    tags     => ['Alert'],
                    filename => 'changed_type.txt',
                    params   => [$body->x, $body->y, $body->name, $old_type, $new_type],
                );
            }
        }
        else {
            confess [1013, "Trying to change to a forbidden type!"];
        }
    }
    else {
        confess [1013, "We can't change the type of that body"];
    }
    if ($class eq $old_class) {
        return {
            message => "Fizzle",
            id      => $body->id,
            name    => $body->name,
        };
    }
    #  my $starter = (!$body->empire && $body->size >= 40 && $body->size <= 50) ? 1 : 0;
    my $starter = 0;
    $body->update({
        needs_recalc              => 1,
        class                     => $class,
        usable_as_starter_enabled => $starter,
    });
    if ($btype eq "asteroid") {
        recalc_miners($body);
    }
    return {
        message   => "Changed Type",
        old_class => $old_class,
        class     => $class,
        id        => $body->id,
        name      => $body->name,
    };
}

sub bhg_size {
    my ($building, $body, $variance) = @_;
    my $current_size = $body->size;
    my $old_size     = $current_size;
    my $btype = $body->get_type;
    if ($btype eq 'asteroid') {
        if ($variance == -1) {
            $current_size -= randint(1, int($building->effective_level/10)+1);
            $current_size = 1 if ($current_size < 1);
        }
        elsif ($variance == 1) {
            if ($current_size >= 10) {
                $current_size++ if (randint(0,99) < 25);
                $current_size = 20 if ($current_size > 20);
            }
            else {
                $current_size += int($building->effective_level/5);
                $current_size = 10 if ($current_size > 10);
            }
        }
        else {
            $current_size += randint(1,5) - 3;
            $current_size = 1 if ($current_size < 1);
            $current_size = 20 if ($current_size > 20);
        }
    }
    elsif ($btype eq 'gas giant') {
        confess [1013, "We can't change the sizes of that body"];
    }
    elsif ($btype eq 'habitable planet') {
        if ($variance == -1) {
            $current_size -= randint(1,$building->effective_level);
            $current_size = 30 if ($current_size < 30);
        }
        elsif ($variance == 1) {
            if ($current_size >= 70) {
                $current_size++ if (randint(0,99) < 25);
                $current_size = 75 if ($current_size > 75);
            }
            else {
                $current_size += $building->effective_level;
                $current_size = 70 if ($current_size > 70);
            }
        }
        else {
            $current_size += randint(1,5) - 3;
            $current_size = 30 if ($current_size < 30);
            $current_size = 75 if ($current_size > 75);
        }
        if ($old_size != $current_size && $body->empire) {
            $body->empire->send_predefined_message(
                tags     => ['Alert'],
                filename => 'changed_size.txt',
                params   => [$body->x, $body->y, $body->name, $old_size, $current_size],
            );
        }
    }
    else {
        confess [1013, "We can't change the sizes of that body"];
    }
    if ($old_size == $current_size) {
        return {
            message => "Fizzle",
            id      => $body->id,
            name    => $body->name,
        };
    }
    #  my $starter = (!$body->empire && $body->size >= 40 && $body->size <= 50) ? 1 : 0;
    my $starter = 0;
    $body->update({
        needs_recalc              => 1,
        size                      => $current_size,
        usable_as_starter_enabled => $starter,
    });
    return {
        message  => "Changed Size",
        old_size => $old_size,
        size     => $current_size,
        id       => $body->id,
        name     => $body->name,
        type     => $btype,
    };
}

sub bhg_tasks {
    my ($building) = @_;
    my $day_sec = 60 * 60 * 24;
    my $blevel = $building->effective_level == 0 ? 1 : $building->effective_level;
    my $map_size = Lacuna->config->get('map_size');
    my $max_dist = sprintf "%0.2f",
        sqrt(($map_size->{x}[0] - $map_size->{x}[1])**2 + ($map_size->{y}[0] - $map_size->{y}[1])**2);
    my $zone_dist = int($max_dist/250 - 0.5);
    $zone_dist = 1 if $zone_dist < 1;  # Would only happen if a game is setup less than 250 units across
    my @tasks = (
        {
            name         => 'Make Asteroid',
            types        => ['habitable planet', 'gas giant'],
            reason       => "You can only make an asteroid from a planet.",
            occupied     => 0,
            min_level    => 10,
            range        => 15 * $blevel,
            recovery     => int($day_sec * 90/$blevel),
            waste_cost   => 50_000_000,
            base_fail    => 40 - $building->effective_level, # 10% - 40%
            side_chance  => 25,
            subsidy_mult => .75,
        },
        {
            name         => 'Make Planet',
            types        => ['asteroid'],
            reason       => "You can only make a planet from an asteroid.",
            occupied     => 0,
            min_level    => 15,
            range        => 10 * $blevel,
            recovery     => int($day_sec * 90/$blevel),
            waste_cost   => 100_000_000,
            base_fail    => 40 - int(($blevel - 15) * (25/15)),
            side_chance  => 40,
            subsidy_mult => .75,
        },
        {
            name         => 'Increase Size',
            types        => ['habitable planet', 'asteroid'],
            reason       => "You can only increase the sizes of habitable planets and asteroids.",
            occupied     => 1,
            min_level    => 20,
            range        => 20 * $blevel,
            recovery     => int($day_sec * 120/$blevel),
            waste_cost   => 1_000_000_000,
            base_fail    => 40 - int( ($blevel - 20) * 2), # 20% - 40%
            side_chance  => 60,
            subsidy_mult => 1,
        },
        {
            name         => 'Change Type',
            types        => ['asteroid', 'habitable planet'],
            reason       => "You can only change the type of habitable planets and asteroids.",
            occupied     => 1,
            min_level    => 25,
            range        => 10 * $blevel,
            recovery     => int($day_sec * 180/$blevel),
            waste_cost   => 10_000_000_000,
            base_fail    => int(65 - $blevel), # 35% - %40
            side_chance  => 75,
            subsidy_mult => 1,
        },
        {
            name         => 'Swap Places',
            types        => ['asteroid', 'habitable planet', 'gas giant', 'space station', 'empty'],
            reason       => "Bodies and empty orbits as targets.",
            occupied     => 1,
            min_level    => 30,
            range        => 10 * $blevel,
            recovery     => int($day_sec * 240/$blevel),
            waste_cost   => 15_000_000_000,
            base_fail    => 40,
            side_chance  => 90,
            subsidy_mult => 1.25,
        },
        {
            name         => 'Jump Zone',
            types        => ['zone'],
            reason       => "Zones only.",
            occupied     => 0,
            min_level    => 15,
            range        => int($blevel * $zone_dist/30),
            recovery     => int($day_sec * 600/$blevel),
            waste_cost   => 15_000_000,
            base_fail    => int(50 - $blevel), # 20% - %45
            side_chance  => 95,
            subsidy_mult => 2,
        },
        {
            name         => 'Move System',
            types        => ['star'],
            reason       => "Target action by Star.",
            occupied     => 0,
            min_level    => 30,
            range        => 8 * $blevel,
            recovery     => int($day_sec * 1200/$blevel),
            waste_cost   => 30_000_000_000,
            base_fail    => 60,
            side_chance  => 95,
            subsidy_mult => 3,
        },
    );
    return @tasks;
}

sub subsidize_cooldown {
    my ($self, $session_id, $building_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;

    unless ($building->is_working) {
        confess [1010, "BHG is not in cooldown mode."];
    }

    unless ($empire->essentia >= 2) {
        confess [1011, "Not enough essentia."];
    }

    $building->finish_work->update;
    $empire->spend_essentia({
        amount  => 2,
        reason  => 'BHG cooldown subsidy after the fact',
    });
    $empire->update;

    return $self->view($session, $building);
}

__PACKAGE__->register_rpc_method_names(qw(generate_singularity get_actions_for subsidize_cooldown));

no Moose;
__PACKAGE__->meta->make_immutable;
