package Lacuna::DB::Result::Building;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'Lacuna::DB::Result';
use Lacuna::Constants ':all';
use List::Util qw(shuffle min);
use List::MoreUtils qw(first_index);

use Lacuna::Util qw(format_date);
use Lacuna::SDB;
use Lacuna::Cache;

__PACKAGE__->load_components('DynamicSubclass');
__PACKAGE__->table('building');
__PACKAGE__->add_columns(
    date_created    => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    body_id         => { data_type => 'int', size => 11, is_nullable => 0 },
    x               => { data_type => 'int', size => 11, default_value => 0 },
    y               => { data_type => 'int', size => 11, default_value => 0 },
    level           => { data_type => 'int', size => 11, default_value => 0 },
    class           => { data_type => 'varchar', size => 255, is_nullable => 0 },
    upgrade_started => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    upgrade_ends    => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    is_upgrading    => { data_type => 'bit', default_value => 0 },
    work_started    => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    work_ends       => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    is_working      => { data_type => 'bit', default_value => 0 },
    work            => { data_type => 'mediumblob', is_nullable => 1, 'serializer_class' => 'JSON' },
    efficiency      => { data_type => 'int', default_value => 100, is_nullable => 0 },
    last_check      => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },

);

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;
    $sqlt_table->add_index(name => 'idx_x_y', fields => ['x','y']);
    $sqlt_table->add_index(name => 'idx_class', fields => ['class']);
    $sqlt_table->add_index(name => 'idx_is_upgrading', fields => ['is_upgrading']);
    $sqlt_table->add_index(name => 'idx_is_working', fields => ['is_working']);
}

__PACKAGE__->belongs_to('body', 'Lacuna::DB::Result::Map::Body', 'body_id');


sub controller_class {
    confess "you need to override me";
}

use constant max_instances_per_planet => 50;

use constant university_prereq => 0;

sub build_tags {
    return ();
}

use constant min_orbit => 1;

use constant max_orbit => 8;

use constant building_prereq => {};

use constant name => 'Building';

sub sortable_name {
    '50'.shift->name
}

sub image {
    confess 'override me';
}

sub image_level {
    my ($self, $level) = @_;
    $level ||= $self->level;
    $level = ($level > 9) ? 9 : $level;
    return $self->image.$level;
}

sub produces_food_items { [] };

use constant prod_rate              => GROWTH;
use constant consume_rate           => CONSUME;
use constant cost_rate              => INFLATION;
use constant waste_consume_rate     => WASTE;
use constant waste_prod_rate        => WASTE;
use constant happy_prod_rate        => HAPPY;
use constant happy_consume_rate     => HAPPY;
use constant time_inflation         => TINFLATE;

use constant time_to_build          => 60;

use constant build_with_halls       => 0;
use constant subsidizable           => 1;

use constant energy_to_build        => 0;
use constant food_to_build          => 0;
use constant ore_to_build           => 0;
use constant water_to_build         => 0;
use constant waste_to_build         => 0;

use constant happiness_consumption  => 0;
use constant energy_consumption     => 0;
use constant water_consumption      => 0;
use constant waste_consumption      => 0;
use constant food_consumption       => 0;
use constant ore_consumption        => 0;

use constant happiness_production   => 0;
use constant energy_production      => 0;
use constant water_production       => 0;
use constant waste_production       => 0;
use constant beetle_production      => 0;
use constant shake_production       => 0;
use constant burger_production      => 0;
use constant fungus_production      => 0;
use constant syrup_production       => 0;
use constant algae_production       => 0;
use constant meal_production        => 0;
use constant milk_production        => 0;
use constant pancake_production     => 0;
use constant pie_production         => 0;
use constant chip_production        => 0;
use constant soup_production        => 0;
use constant bread_production       => 0;
use constant wheat_production       => 0;
use constant cider_production       => 0;
use constant corn_production        => 0;
use constant root_production        => 0;
use constant bean_production        => 0;
use constant cheese_production      => 0;
use constant apple_production       => 0;
use constant lapis_production       => 0;
use constant potato_production      => 0;
use constant ore_production         => 0;

use constant water_storage          => 0;
use constant energy_storage         => 0;
use constant food_storage           => 0;
use constant ore_storage            => 0;
use constant waste_storage          => 0;

use constant can_really_be_built    => 1;

# BASE FORMULAS

has effective_level => (
    is => 'rw',
    lazy => 1,
    builder => '_build_effective_level',
    clearer => 'clear_effective_level',
);

sub _build_effective_level
{
    my $self = shift;
    my $uni_prod   = ($self->body->empire) ? $self->body->empire->university_level : 1;
    my $real_level = $self->level;
    # take whichever one is lower.
    my $eff_level  = min($uni_prod + 1, $real_level);

    # room for objects/boosts/whatever to override this.

    $eff_level;
}

has effective_efficiency => (
    is => 'rw',
    lazy => 1,
    builder => '_build_effective_efficiency',
    clearer => 'clear_effective_efficiency',
);

sub _build_effective_efficiency {
    my $self = shift;
    $self->efficiency; # with rare exceptions
}

sub production_hour {
    my $self = shift;
    return 0 unless  $self->effective_level;
    my $prod_level = $self->effective_level;
    my $production = ($self->prod_rate ** (  $prod_level - 1));
    $production = ($production * $self->effective_efficiency) / 100;
    return $production;
}

sub current_level_cost {
    my $self = shift;

    return ($self->cost_rate ** ($self->level -1));
}

sub upgrade_cost {
    my ($self, $level) = @_;
    $level ||= $self->level;
    return ($self->cost_rate ** $level);
}

sub consumption_hour {
    my $self = shift;
    return 0 unless  $self->effective_level;
    my $consume_level = $self->effective_level;
    my $consumption = ($self->consume_rate ** (  $consume_level - 1));
    $consumption = ($consumption * $self->effective_efficiency) / 100;
    return $consumption;
}

sub happy_production_hour {
    my $self = shift;
    return 0 unless  $self->effective_level;
    my $prod_level = $self->effective_level;
    my $production = ($self->happy_prod_rate ** (  $prod_level - 1));
    $production = ($production * $self->effective_efficiency) / 100;
    return $production;
}

sub happy_consumption_hour {
    my $self = shift;
    return 0 unless  $self->effective_level;
    my $consume_level = $self->effective_level;
    my $consumption = ($self->happy_consume_rate ** (  $consume_level - 1));
    $consumption = ($consumption * $self->effective_efficiency) / 100;
    return $consumption;
}

sub waste_production_hour {
    my $self = shift;
    return 0 unless  $self->effective_level;
    my $wprod_level = $self->effective_level;
    my $wproduction = ($self->waste_prod_rate ** (  $wprod_level - 1));
    $wproduction = $self->waste_production * ($wproduction * $self->effective_efficiency) / 100;
    return sprintf('%.0f',$wproduction);
}

sub waste_consumption_bonus {
    my ($self) = @_;
    my $empire = $self->body->empire;
    return 1 unless defined $empire;
    my $gg_bonus = ($self->body->get_type eq 'gas giant') ? 50 : 0;
    return (100 + $gg_bonus + $empire->effective_environmental_affinity * 5) / 100;
}

sub waste_consumption_hour {
    my $self = shift;
    return 0 unless  $self->effective_level;
    my $wprod_level = $self->effective_level;
    my $wproduction = ($self->waste_consume_rate ** (  $wprod_level - 1));
    $wproduction = $self->waste_consumption_bonus * $self->waste_consumption * ($wproduction * $self->effective_efficiency) / 100;
    return sprintf('%.0f',$wproduction);
}


# PRODUCTION

sub farming_production_bonus {
    my ($self) = @_;
    my $empire = $self->body->empire;
    return 1 unless defined $empire;
    my $boost = (time < $empire->food_boost->epoch) ? 25 : 0;
    return (100 + $boost + $empire->effective_farming_affinity * 4) / 100;
}

sub manufacturing_production_bonus {
    my ($self) = @_;
    my $empire = $self->body->empire;
    return 1 unless defined $empire;
    return (100 + $empire->effective_manufacturing_affinity * 4) / 100;
}

sub lapis_production_hour {
    my ($self) = @_;
    my $base = $self->lapis_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->farming_production_bonus);
}

sub potato_production_hour {
    my ($self) = @_;
    my $base = $self->potato_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->farming_production_bonus);
}

sub bean_production_hour {
    my ($self) = @_;
    my $base = $self->bean_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->farming_production_bonus);
}

sub cheese_production_hour {
    my ($self) = @_;
    my $base = $self->cheese_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->manufacturing_production_bonus);
}

sub apple_production_hour {
    my ($self) = @_;
    my $base = $self->apple_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->farming_production_bonus);
}

sub root_production_hour {
    my ($self) = @_;
    my $base = $self->root_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->farming_production_bonus);
}

sub corn_production_hour {
    my ($self) = @_;
    my $base = $self->corn_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->farming_production_bonus);
}

sub cider_production_hour {
    my ($self) = @_;
    my $base = $self->cider_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->manufacturing_production_bonus);
}

sub wheat_production_hour {
    my ($self) = @_;
    my $base = $self->wheat_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->farming_production_bonus);
}

sub bread_production_hour {
    my ($self) = @_;
    my $base = $self->bread_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->manufacturing_production_bonus);
}

sub soup_production_hour {
    my ($self) = @_;
    my $base = $self->soup_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->manufacturing_production_bonus);
}

sub chip_production_hour {
    my ($self) = @_;
    my $base = $self->chip_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->manufacturing_production_bonus);
}

sub pie_production_hour {
    my ($self) = @_;
    my $base = $self->pie_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->manufacturing_production_bonus);
}

sub pancake_production_hour {
    my ($self) = @_;
    my $base = $self->pancake_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->manufacturing_production_bonus);
}

sub milk_production_hour {
    my ($self) = @_;
    my $base = $self->milk_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->farming_production_bonus);
}

sub meal_production_hour {
    my ($self) = @_;
    my $base = $self->meal_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->manufacturing_production_bonus);
}

sub algae_production_hour {
    my ($self) = @_;
    my $base = $self->algae_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->farming_production_bonus);
}

sub syrup_production_hour {
    my ($self) = @_;
    my $base = $self->syrup_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->manufacturing_production_bonus);
}

sub fungus_production_hour {
    my ($self) = @_;
    my $base = $self->fungus_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->farming_production_bonus);
}

sub burger_production_hour {
    my ($self) = @_;
    my $base = $self->burger_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->manufacturing_production_bonus);
}

sub shake_production_hour {
    my ($self) = @_;
    my $base = $self->shake_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->manufacturing_production_bonus);
}

sub beetle_production_hour {
    my ($self) = @_;
    my $base = $self->beetle_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->farming_production_bonus);
}

sub food_production_hour {
    my ($self) = @_;
    my $tally = 0;
    foreach my $food (FOOD_TYPES) {
        my $method = $food."_production_hour";
        $tally += $self->$method;
    }
    return $tally;
}

sub food_consumption_hour {
    my ($self) = @_;
    return sprintf('%.0f',$self->food_consumption * $self->consumption_hour);
}

sub food_hour {
    my ($self) = @_;
    return sprintf('%.0f',$self->food_production_hour - $self->food_consumption_hour);
}

sub building_reduction_bonus {
    my ($self) = @_;
    my $empire = $self->body->empire;
    return 1 unless defined $empire;
    return (time < $empire->building_boost->epoch) ? 0.75 : 1;
}

sub energy_production_bonus {
    my ($self) = @_;
    my $empire = $self->body->empire;
    return 1 unless defined $empire;
    my $boost = (time < $empire->energy_boost->epoch) ? 25 : 0;
    my $gg_bonus = ($self->body->get_type eq 'gas giant') ? 50 : 0;
    return (100 + $boost + $gg_bonus + $empire->effective_science_affinity * 4) / 100;
}

sub energy_production_hour {
    my ($self) = @_;
    my $base = $self->energy_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->energy_production_bonus);
}

sub energy_consumption_hour {
    my ($self) = @_;
    my $gg_perc = ($self->body->get_type eq 'gas giant') ? 75 : 100;
    my $consumption = ($gg_perc * $self->energy_consumption)/100;
    return sprintf('%.0f',$consumption * $self->consumption_hour);
}

sub energy_hour {
    my ($self) = @_;
    return sprintf('%.0f',$self->energy_production_hour - $self->energy_consumption_hour);
}

sub mining_production_bonus {
    my ($self) = @_;
    my $empire = $self->body->empire;
    return 1 unless defined $empire;
    my $refinery = $self->body->refinery;
    my $refinery_bonus = (defined $refinery) ? $refinery->effective_level * 5 : 0;
    my $boost = (time < $empire->ore_boost->epoch) ? 25 : 0;
    return (100 + $boost + $refinery_bonus + $empire->effective_mining_affinity * 4) / 100;
}

sub ore_production_hour {
    my ($self) = @_;
    my $base = $self->ore_production * $self->production_hour * ($self->body->total_ore_concentration / 10000);
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->mining_production_bonus);
}

sub ore_consumption_hour {
    my ($self) = @_;
    return sprintf('%.0f',$self->ore_consumption * $self->consumption_hour);
}

sub ore_hour {
    my ($self) = @_;
    return sprintf('%.0f',$self->ore_production_hour - $self->ore_consumption_hour);
}

sub water_production_bonus {
    my ($self) = @_;
    my $empire = $self->body->empire;
    return 1 unless defined $empire;
    my $boost = (time < $empire->water_boost->epoch) ? 25 : 0;
    my $gg_bonus = ($self->body->get_type eq 'gas giant') ? -25 : 0;
    return (100 + $boost + $gg_bonus + $empire->effective_environmental_affinity * 4) / 100;
}

sub water_production_hour {
    my ($self) = @_;
    my $base = $self->water_production * $self->production_hour;
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->water_production_bonus);
}

sub water_consumption_hour {
    my ($self) = @_;
    return sprintf('%.0f',$self->water_consumption * $self->consumption_hour);
}

sub water_hour {
    my ($self) = @_;
    return sprintf('%.0f',$self->water_production_hour - $self->water_consumption_hour);
}

sub waste_hour {
    my ($self) = @_;
    return sprintf('%.0f',$self->waste_production_hour - $self->waste_consumption_hour);
}

sub happiness_production_bonus {
    my ($self) = @_;
    my $empire = $self->body->empire;
    return 1 unless defined $empire;
    my $boost = (time < $empire->happiness_boost->epoch) ? 25 : 0;
    my $sboost = $self->body->propaganda_boost;
    my $max_b = $boost ? 75 : 50;
    if ($self->body->get_stored('happiness') > 0 and $sboost > $max_b) {
        $sboost = $max_b;
    }
    $boost += $sboost;
    my $capitol_bonus = 0;
    if (defined $self->body->capitol and $self->class !~ /Permanent|LCOT/) {
        my $capitol_level = $self->body->capitol->effective_level;
        $capitol_bonus = $capitol_level * 3;
    }
    return (100 + $capitol_bonus) * (100 + $boost) * (100 + $empire->effective_political_affinity * 10)/1000000;
}

sub happiness_production_hour {
    my ($self) = @_;
    my $base = $self->happiness_production * $self->happy_production_hour;
    return 0 unless $self->body->empire;
    return 0 if Lacuna::Cache->instance->get('sz_exceeded', $self->body->id);
    return 0 if $base == 0;
    return sprintf('%.0f', $base * $self->happiness_production_bonus);
}

sub happiness_consumption_hour {
    my ($self) = @_;
    return sprintf('%.0f',$self->happiness_consumption * $self->happy_consumption_hour);
}

sub happiness_hour {
    my ($self) = @_;
    return sprintf('%.0f',$self->happiness_production_hour - $self->happiness_consumption_hour);
}

# STORAGE

has storage_bonus => (
    is  => 'rw',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $empire = $self->body->empire;
        return 1 unless defined $empire;
        my $stockpile_bonus = 0;
        if (defined $self->body->stockpile and $self->class !~ /Permanent|LCOT/) {
            my $stock_level = $self->body->stockpile->effective_level;
            $stockpile_bonus = $stock_level * 3;
        }
        my $boost = (time < $empire->storage_boost->epoch) ? 25 : 0;
        return ((100 + $stockpile_bonus)/100) * ((100 + $boost) / 100);
    },
);

sub food_capacity {
    my ($self) = @_;
    my $base = $self->food_storage * $self->production_hour;
    return 0 if $base == 0;
    my $empire = $self->body->empire;
    return 1 unless defined $empire;
    return sprintf('%.0f', $base * ($self->storage_bonus + ($empire->effective_farming_affinity * 4 / 100) ));
}

sub energy_capacity {
    my ($self) = @_;
    my $base = $self->energy_storage * $self->production_hour;
    return 0 if $base == 0;
    my $empire = $self->body->empire;
    return 1 unless defined $empire;
    return sprintf('%.0f', $base * ($self->storage_bonus + ($empire->effective_science_affinity * 4 / 100) ));
}

sub ore_capacity {
    my ($self) = @_;
    my $base = $self->ore_storage * $self->production_hour;
    return 0 if $base == 0;
    my $empire = $self->body->empire;
    return 1 unless defined $empire;
    return sprintf('%.0f', $base * ($self->storage_bonus + ($empire->effective_mining_affinity * 4 / 100) ));
}

sub water_capacity {
    my ($self) = @_;
    my $base = $self->water_storage * $self->production_hour;
    return 0 if $base == 0;
    my $empire = $self->body->empire;
    return 1 unless defined $empire;
    return sprintf('%.0f', $base * ($self->storage_bonus + ($empire->effective_environmental_affinity * 4 / 100) ));
}

sub waste_capacity {
    my ($self) = @_;
    my $base = $self->waste_storage * $self->production_hour;
    return 0 if $base == 0;
    my $empire = $self->body->empire;
    return 1 unless defined $empire;
    my $gg_bonus = ($self->body->get_type eq 'gas giant') ? 50 : 0;
    return sprintf('%.0f', $base * ($self->storage_bonus + ($gg_bonus + $empire->effective_environmental_affinity * 4) / 100) );
}

# BUILD

before delete => sub {
    my ($self) = @_;

    # delete any scheduled work or upgrade jobs
    #
    $self->delete_schedule($self->id, '/building/finishWork');
    $self->delete_schedule($self->id, '/building/finishUpgrade');
};

sub has_special_resources {
    return 1;
}

sub can_build {
    my ($self, $body) = @_;

    # check body type
    $self->can_build_on;

    # check goldilox zone
    if ($body->orbit < $self->min_orbit || $body->orbit > $self->max_orbit) {
        confess [1013, "This building may only be built between orbits ".$self->min_orbit." and ".$self->max_orbit.".", [$self->min_orbit, $self->max_orbit]];
    }

    # check special resources
    $self->has_special_resources;

    unless ($body->get_plan($self->class, 1)) {
        # check university level
        if ($self->university_prereq > $body->empire->university_level) {
            confess [1013, "You need a level ".$self->university_prereq." University.",$self->university_prereq];
        }

        # check building prereqs
        my $prereqs = $self->building_prereq;
        foreach my $key (keys %{$prereqs}) {
            my $prereq_buildings = $body->prereq_buildings($key, $prereqs->{$key});
            if (@$prereq_buildings < 1) {
                confess [1013, "You need a level ".$prereqs->{$key}." ".$key->name.".",[$key->name, $prereqs->{$key}]];
            }
        }
    }

    return 1;
}

sub can_build_on {
    my $self = shift;
    if (!$self->body->isa('Lacuna::DB::Result::Map::Body::Planet') || $self->body->isa('Lacuna::DB::Result::Map::Body::Planet::Station')) {
        confess [1009, 'Can only be built on habitable planets and gas giants.'];
    }
    return 1;
}

sub finish_building {
    my $self = shift;
    # most buildings don't need to do anything here.
}

# DEMOLISH

sub can_demolish {
    my $self = shift;
    if ($self->is_working) {
        confess [1013, "You cannot demolish a building that is working."];
    }
    return 1;
}

sub demolish {
    my ($self, $theft) = @_;
    my $body = $self->body;

    if (!$theft) {
        $body->add_waste(sprintf('%.0f',$self->ore_to_build * $self->upgrade_cost));
        $body->spend_happiness(sprintf('%.0f',$self->food_to_build * $self->upgrade_cost));
    }

    # Remove the building from the cache
    $self->level(0);
    my $idx = first_index {$_->id == $self->id} @{$body->building_cache};
    if (defined $idx) {
        my @blist = @{$body->building_cache};
        my @buildings = splice @blist,$idx,1;
        $body->building_cache(\@blist);
    }
    $self->delete;
    $body->needs_recalc(1);
    $body->needs_surface_refresh(1);
    $body->update;
}


# UPGRADES

sub can_downgrade {
    my $self = shift;
    confess [1013, 'This building is currently upgrading.'] if $self->is_upgrading;
    return 1;
}

sub downgrade {
    my ($self, $theft) = @_;
    if ($self->level == 1) {
        $self->can_demolish;
        return $self->demolish($theft);
    }
    $self->level( $self->level - 1);
    $self->efficiency(100);
    $self->update;
    my $body = $self->body;
    if (!$theft) {
        $body->add_waste(sprintf('%.0f',$self->ore_to_build * $self->upgrade_cost));
        $body->spend_happiness(sprintf('%.0f',$self->food_to_build * $self->upgrade_cost));
    }
    $body->needs_recalc(1);
    $body->needs_surface_refresh(1);
    $body->update;
}

sub upgrade_status {
    my ($self) = @_;
    my $complete = $self->upgrade_ends;
    if ($self->is_upgrading) {
        return {
            seconds_remaining   => $complete->epoch - time,
            start               => format_date($self->upgrade_started),
            end                 => format_date($complete),
        };
    }
    else {
        return undef;
    }
}

sub has_met_upgrade_prereqs {
    my ($self) = @_;
#    if (!$self->isa('Lacuna::DB::Result::Building::University') && $self->level >= $self->body->empire->university_level + 1) {
    if ($self->level >= $self->body->empire->university_level + 1) {
        confess [1013, sprintf("You cannot upgrade a building past level %s (university level + 1).",$self->body->empire->university_level+1)];
    }
    return 1;
}

sub has_no_pending_build {
    my ($self) = @_;
    if ($self->is_upgrading) {
        # sometimes the upgrade gets stuck, and someone has to jiggle
        # the database.  Detect the situation and jiggle the database
        # immediately.
        if ($self->upgrade_ends < DateTime->now)
        {
            $self->finish_upgrade();
        }
        else
        {
            confess [1010, "You must complete the pending build first."];
        }
    }
    return 1;
}

sub is_not_max_level {
    my ($self) = @_;
    if ($self->level >= 30) {
        confess [1009, 'This building is already at its maximum level.'];
    }
    return 1;
}

sub can_upgrade {
    my ($self, $cost) = @_;
    if ($self->efficiency < 100) {
        confess [1010, 'You must repair this building before you can upgrade it.'];
    }
    $self->is_not_max_level;
    my $body = $self->body;
    $self->has_special_resources;
    $self->has_met_upgrade_prereqs;
    $body->has_resources_to_operate($self);
    $body->has_resources_to_build($self,$cost);
    $self->has_no_pending_build;
    $body->has_room_in_build_queue;
    return 1;
}

sub construction_cost_reduction_bonus {
    my $self = shift;
    my $empire = $self->body->empire;
    return 1 unless defined $empire;
    return (100 - $empire->effective_research_affinity * 5) / 100;
}

sub manufacturing_cost_reduction_bonus {
    my $self = shift;
    my $empire = $self->body->empire;
    return 1 unless defined $empire;
    return (100 - $empire->effective_manufacturing_affinity * 5) / 100;
}

sub time_cost_reduction_bonus {
    my ($self, $extra) = @_;
    $extra ||= 0;
    my $body = $self->body;
    my $empire = $body->empire;
    return 1 unless defined $empire;
    my $unhappy_workers = 0;
    my $base_cost_reduction = 100 - $extra - ($body->empire->effective_management_affinity * 5);
    if ( $base_cost_reduction < 1 ) {
        my $new_factor = (1 - $base_cost_reduction) / 30;
        $base_cost_reduction = 1 - $new_factor;
    }
    return $base_cost_reduction / 100;
}

sub cost_to_upgrade {
    my ($self) = @_;
    my $upgrade_cost = $self->upgrade_cost;
    my $upgrade_cost_reduction = $self->construction_cost_reduction_bonus;
    my $plan = $self->body->get_plan($self->class, $self->level + 1);
    my $build_with_halls = 0;
    my $time_with_plan   = 1;
    if ($self->build_with_halls) {
        if ($self->level > 0) {
            $build_with_halls = 1;
        }
    }
    if (defined $plan) {
        $upgrade_cost_reduction = 0;
        $build_with_halls = 0;
        $time_with_plan   = 0.75;
    }
    my $oversight_reduction = 1;
    if (defined $self->body->oversight) {
        my $om_level = $self->body->oversight->effective_level;
        $oversight_reduction = (100 - ($om_level * 3)) / 100;
    }
    my $time_inflator = ($self->level * 2) - 1;
    $time_inflator = 1 if ($time_inflator < 1);
    my $throttle = Lacuna->config->get('building_build_speed') || 6;
    my $min_time = Lacuna->config->get('building_min_time') || 15;
    my $time_cost = (( $self->level+1)/$throttle * $self->time_to_build * $time_inflator ** $self->time_inflation) *
                       $self->building_reduction_bonus * $self->time_cost_reduction_bonus *
                       $oversight_reduction * $time_with_plan;
    $time_cost = 5184000 if ($time_cost > 5184000); # 60 Days
    $time_cost *= $self->body->build_boost;
    $time_cost = $min_time if ($time_cost < $min_time);

    if ($build_with_halls) {
        return {
            halls   => $self->level + 1,
            time    => sprintf('%.0f',$time_cost),
        };
    }
    else {
        return {
            food    => int($self->food_to_build * $upgrade_cost * $upgrade_cost_reduction),
            energy  => int($self->energy_to_build * $upgrade_cost * $upgrade_cost_reduction),
            ore     => int($self->ore_to_build * $upgrade_cost * $upgrade_cost_reduction),
            water   => int($self->water_to_build * $upgrade_cost * $upgrade_cost_reduction),
            waste   => int($self->waste_to_build * $upgrade_cost * $upgrade_cost_reduction),
            time    => int($time_cost),
        };
    }
}

sub stats_after_upgrade {
    my ($self) = @_;
    my $current_level = $self->level;
    $self->level($current_level + 1);
    $self->clear_effective_level;
    my %stats;
    my @list = qw(food_hour food_capacity ore_hour ore_capacity water_hour water_capacity waste_hour waste_capacity energy_hour energy_capacity happiness_hour);
    foreach my $resource (@list) {
        $stats{$resource} = $self->$resource;
    }
    $self->level($current_level);
    $self->clear_effective_level;
    return \%stats;
}

sub lock_upgrade {
    my ($self, $x, $y) = @_;
    return Lacuna::Cache->instance->set('upgrade_contention_lock', $self->id, $self->level + 1, 15); # lock it
}

sub is_upgrade_locked {
    my ($self, $x, $y) = @_;
    return Lacuna::Cache->instance->get('upgrade_contention_lock', $self->id);
}

sub start_upgrade {
    my ($self, $cost, $in_parallel) = @_;
    my $body = $self->body;
    $cost ||= $self->cost_to_upgrade;

    # set time to build, plus what's in the queue
    my $now = DateTime->now;
    my $upgrade_ends = $in_parallel ? $now : $body->get_existing_build_queue_time;
    if ($upgrade_ends < $now) {
        $upgrade_ends = $now;
    }

    my $time_to_add = $body->isa('Lacuna::DB::Result::Map::Body::Planet::Station') ? 60 * 60 * 72 : $cost->{time};
    $upgrade_ends->add(seconds=>$time_to_add);
    # add to queue
    $self->update({
        is_upgrading    => 1,
        upgrade_started => DateTime->now,
        upgrade_ends    => $upgrade_ends,
    });

    $self->create_schedule($self->id, '/building/finishUpgrade', $upgrade_ends);

    return $self;
}

sub delete_schedule {
    my ($self, $id, $route) = @_;

    my $schedule_rs = Lacuna::SDB->db->resultset('Schedule')->search({
        route       => $route,
        db_id       => $id,
    });

    while (my $schedule = $schedule_rs->next) {
        $schedule->delete;
    }
}

sub create_schedule {
    my ($self, $id, $route, $delivery) = @_;

    my $schedule = Lacuna::SDB->db->resultset('Schedule')->create({
        queue       => 'bg_building',
        route       => $route,
        delivery    => $delivery,
        db_id       => $id,
        payload     => {
            route       => $route,
            content => {
                building_id     => $id,
            },
        },
    });
    return $schedule;
}

sub finish_upgrade {
    my ($self) = @_;

    $self->delete_schedule($self->id, '/building/finishUpgrade');

    if ($self->is_upgrading) {
        my $body = $self->body;
        my $empire = $body->empire;
        my $new_level = $self->level+1;

        if ($empire) {
            # 31 is the actual Max level for the Terra & Gas Platforms.
            if ($new_level >= 1 and $new_level <= 31) {
                $empire->add_medal('building'.$new_level);
            }
            elsif ($new_level > 31) {
                $empire->add_medal('buildingX');
            }
            my $type = $self->controller_class;
            $type =~ s/^Lacuna::RPC::Building::(\w+)$/$1/;
            $empire->add_medal($type);
            $self->finish_upgrade_news($new_level, $empire);
        }

        $self->reschedule_queue;
        $self->level($new_level);
        $self->clear_effective_level();
        $self->is_upgrading(0);
        $self->update;

        $body->needs_recalc(1);
        $body->needs_surface_refresh(1);
        $body->update;
    }

    Lacuna::Cache->instance->delete('upgrade_contention_lock', $self->id);

    return $self;
}

sub finish_upgrade_news
{
    my ($self, $new_level, $empire) = @_;
    if ($new_level % 5 == 0) {
        my %levels = (5=>'a quiet',10=>'an extravagant',15=>'a lavish',20=>'a magnificent',25=>'a historic',30=>'a magical');
        $self->body->add_news($new_level*4,"In %s ceremony, %s unveiled its newly augmented %s.", $levels{$new_level}, $empire->name, $self->name);
    }
}

# Cancel the upgrade of any any one build on the build queue
#
sub cancel_upgrade {
    my ($self) = @_;

    if ($self->is_upgrading) {
        $self->reschedule_queue;
        if ($self->level <= 1) {
            $self->delete;
        }
        else {
            $self->is_upgrading(0);
            $self->upgrade_ends(DateTime->now);
            $self->update;
        }
    }
    Lacuna::Cache->instance->delete('upgrade_contention_lock', $self->id);
    return $self;
}

sub reschedule_queue {
    my ($self) = @_;

    my $start_time  = DateTime->now;
    my $end_time;
    my @build_queue = @{$self->body->builds};
    my $build;
    BUILD:
    while ($build = shift @build_queue) {
        if ($build->id == $self->id) {
            $end_time   = $build->upgrade_ends;
            last BUILD;
        }
        # Start time of the next build is the end time of this one
        $start_time = $build->upgrade_ends;
    }
    if ($build) {
        # Remove this scheduled event
        my $duration = $end_time->epoch - $start_time->epoch;

        $self->delete_schedule($build->id, '/building/finishUpgrade');

        # Change the scheduled time for all subsequent builds (if any)
        while (my $build = shift @build_queue) {
            $self->delete_schedule($build->id, '/building/finishUpgrade');

            my $upgrade_ends = $build->upgrade_ends->subtract(seconds => $duration);
            $build->upgrade_ends($upgrade_ends);
            $build->update;

            $self->create_schedule($build->id, '/building/finishUpgrade', $upgrade_ends);
        }
    }
}

# WORK

sub work_ends_formatted {
    my $self = shift;
    return format_date($self->work_ends);
}

sub work_started_formatted {
    my $self = shift;
    return format_date($self->work_started);
}

sub work_seconds_remaining {
    my ($self) = @_;
    return 0 unless $self->is_working;
    my $seconds = $self->work_ends->epoch - time;
    return ($seconds > 0) ? $seconds : 0;
}


# Reschedule work to end at a different time
#
sub reschedule_work {
    my ($self, $new_work_ends) = @_;

    $self->is_working(1);
    $self->work_ends($new_work_ends);
    $self->update;

    $self->delete_schedule($self->id, '/building/finishWork');

    $self->create_schedule($self->id, '/building/finishWork', $new_work_ends);
    return $self;
}


sub start_work {
    my ($self, $work, $duration) = @_;
    my $now = DateTime->now;
    $self->is_working(1);
    $self->work_started($now);
    my $ends = DateTime->now->add(seconds => $duration);
    $self->work_ends($ends);
    $self->work($work);
    $self->update;

    # add to queue
    $self->create_schedule($self->id, '/building/finishWork', $self->work_ends);

    return $self;
}

sub finish_work {
    my ($self) = @_;

    $self->is_working(0);
    $self->work({});
    $self->update;

    $self->delete_schedule($self->id, '/building/finishWork');

    return $self;
}

sub last_check_formatted {
    my $self = shift;
    return format_date($self->last_check);
}

# EFFICIENCY / REPAIR

sub is_offline {
    my $self = shift;
    if ($self->effective_efficiency == 0) {
        confess [1013, $self->name.' is currently offline.'];
    }
}

sub get_repair_costs {
    my $self = shift;
    my $level_cost = $self->current_level_cost;
    my $damage = 100 - $self->efficiency;
    my $damage_cost = $level_cost * $damage / 100;
    return {
        ore     => sprintf('%.0f',$self->ore_to_build * $damage_cost),
        water   => sprintf('%.0f',$self->water_to_build * $damage_cost),
        food    => sprintf('%.0f',$self->food_to_build * $damage_cost),
        energy  => sprintf('%.0f',$self->energy_to_build * $damage_cost),
    };
}

sub can_repair {
    my ($self, $costs) = @_;
    $costs ||= $self->get_repair_costs;
    my $body = $self->body;
    my $damage = 100 - $self->efficiency;
    my $fix = $damage;
    if ($body->get_stored('food')-50 < $costs->{food} and $costs->{food} > 0) {
        my $teff = int(($body->get_stored('food')-50) * $damage / $costs->{food});
        $fix = $teff if ($teff < $fix);
    }
    if ($body->get_stored('water') < $costs->{water} and $costs->{water} > 0) {
        my $teff = int($body->get_stored('water') * $damage / $costs->{water});
        $fix = $teff if ($teff < $fix);
    }
    if ($body->get_stored('ore')-50 < $costs->{ore} and $costs->{ore} > 0) {
        my $teff = int(($body->get_stored('ore')-50) * $damage / $costs->{ore});
        $fix = $teff if ($teff < $fix);
    }
    if ($body->get_stored('energy') < $costs->{energy} and $costs->{energy} > 0) {
        my $teff = int($body->get_stored('energy') * $damage / $costs->{energy});
        $fix = $teff if ($teff < $fix);
    }
    if ($damage && $fix <= 0) {
        confess [1011, 'Not enough resources to do a partial repair.'];
    }
    return 1;
}

sub repair {
    my ($self, $costs) = @_;
    $costs ||= $self->get_repair_costs;
    my $body = $self->body;
    my $damage = 100 - $self->efficiency;
    if ($damage <= 0) {
        return 0;
    }
    my $fix = $damage;
    if ($body->get_stored('food')-50 < $costs->{food} and $costs->{food} > 0) {
        my $teff = int(($body->get_stored('food')-50) * $damage / $costs->{food});
        $fix = $teff if ($teff < $fix);
    }
    if ($body->get_stored('water') < $costs->{water} and $costs->{water} > 0) {
        my $teff = int($body->get_stored('water') * $damage / $costs->{water});
        $fix = $teff if ($teff < $fix);
    }
    if ($body->get_stored('ore')-50 < $costs->{ore} and $costs->{ore} > 0) {
        my $teff = int(($body->get_stored('ore')-50) * $damage / $costs->{ore});
        $fix = $teff if ($teff < $fix);
    }
    if ($body->get_stored('energy') < $costs->{energy} and $costs->{energy} > 0) {
        my $teff = int($body->get_stored('energy') * $damage / $costs->{energy});
        $fix = $teff if ($teff < $fix);
    }
    if ($fix <= 0) {
        return 0;
    }
    $costs->{food}   = int($fix*$costs->{food}/$damage);
    $costs->{water}  = int($fix*$costs->{water}/$damage);
    $costs->{ore}    = int($fix*$costs->{ore}/$damage);
    $costs->{energy} = int($fix*$costs->{energy}/$damage);
    my $n_eff = $self->efficiency + $fix;
    $self->efficiency($n_eff);
    $self->update;
    $body->spend_food($costs->{food}, 0);
    $body->spend_water($costs->{water});
    $body->spend_ore($costs->{ore});
    $body->spend_energy($costs->{energy});
    $body->needs_recalc(1);
    $body->update;
}

sub spend_efficiency {
    my ($self, $amount) = @_;
    my $efficiency = $self->efficiency;
    if ($amount < 1 || $efficiency == 0) {
        return $self;
    }
    $amount = ($amount > $efficiency) ? $efficiency : $amount;
    $self->efficiency( $efficiency - $amount );
    my $body = $self->body;
    $body->needs_recalc(1);
    $body->needs_surface_refresh(1);
    $body->update;
    return $self;
}

# POPULATION

has population => (
        is      => 'ro',
        lazy    => 1,
        builder => '_build_population',
        );

sub _build_population {
    my ($self) = @_;

    $self->effective_level * 10_000;
}

{
    # Because some buildings inherit from ::Permanent instead of inheriting
    # from ::Building directly, we end up with
    # Class::C3::Componentised::ensure_class_loaded getting confused as to
    # whether Permanent-derived modules are loaded or not.  However, since
    # they're going to be loaded anyway, this hack avoids the extra loading
    # that DynamicSubclass tries to do.
    # Alternatives: fix DS to defer loading until first use, "our @ISA;" in
    # Permanent (and any other intermediate class we create in the future).
    # This still seems to be the least-intrusive hack.
    local *ensure_class_loaded = sub {};
    __PACKAGE__->typecast_map(class => {
        'Lacuna::DB::Result::Building::CloakingLab' => 'Lacuna::DB::Result::Building::CloakingLab',
        'Lacuna::DB::Result::Building::MissionCommand' => 'Lacuna::DB::Result::Building::MissionCommand',
        'Lacuna::DB::Result::Building::MunitionsLab' => 'Lacuna::DB::Result::Building::MunitionsLab',
        'Lacuna::DB::Result::Building::LuxuryHousing' => 'Lacuna::DB::Result::Building::LuxuryHousing',
        'Lacuna::DB::Result::Building::PilotTraining' => 'Lacuna::DB::Result::Building::PilotTraining',
        'Lacuna::DB::Result::Building::Development' => 'Lacuna::DB::Result::Building::Development',
        'Lacuna::DB::Result::Building::Embassy' => 'Lacuna::DB::Result::Building::Embassy',
        'Lacuna::DB::Result::Building::EntertainmentDistrict' => 'Lacuna::DB::Result::Building::EntertainmentDistrict',
        'Lacuna::DB::Result::Building::Espionage' => 'Lacuna::DB::Result::Building::Espionage',
        'Lacuna::DB::Result::Building::GasGiantLab' => 'Lacuna::DB::Result::Building::GasGiantLab',
        'Lacuna::DB::Result::Building::Intelligence' => 'Lacuna::DB::Result::Building::Intelligence',
        'Lacuna::DB::Result::Building::IntelTraining' => 'Lacuna::DB::Result::Building::IntelTraining',
        'Lacuna::DB::Result::Building::MayhemTraining' => 'Lacuna::DB::Result::Building::MayhemTraining',
        'Lacuna::DB::Result::Building::PoliticsTraining' => 'Lacuna::DB::Result::Building::PoliticsTraining',
        'Lacuna::DB::Result::Building::TheftTraining' => 'Lacuna::DB::Result::Building::TheftTraining',
        'Lacuna::DB::Result::Building::Network19' => 'Lacuna::DB::Result::Building::Network19',
        'Lacuna::DB::Result::Building::Observatory' => 'Lacuna::DB::Result::Building::Observatory',
        'Lacuna::DB::Result::Building::Park' => 'Lacuna::DB::Result::Building::Park',
        'Lacuna::DB::Result::Building::PlanetaryCommand' => 'Lacuna::DB::Result::Building::PlanetaryCommand',
        'Lacuna::DB::Result::Building::Stockpile' => 'Lacuna::DB::Result::Building::Stockpile',
        'Lacuna::DB::Result::Building::Capitol' => 'Lacuna::DB::Result::Building::Capitol',
        'Lacuna::DB::Result::Building::Propulsion' => 'Lacuna::DB::Result::Building::Propulsion',
        'Lacuna::DB::Result::Building::Oversight' => 'Lacuna::DB::Result::Building::Oversight',
        'Lacuna::DB::Result::Building::Security' => 'Lacuna::DB::Result::Building::Security',
        'Lacuna::DB::Result::Building::Shipyard' => 'Lacuna::DB::Result::Building::Shipyard',
        'Lacuna::DB::Result::Building::SpacePort' => 'Lacuna::DB::Result::Building::SpacePort',
        'Lacuna::DB::Result::Building::TerraformingLab' => 'Lacuna::DB::Result::Building::TerraformingLab',
        'Lacuna::DB::Result::Building::Archaeology' => 'Lacuna::DB::Result::Building::Archaeology',
        'Lacuna::DB::Result::Building::GeneticsLab' => 'Lacuna::DB::Result::Building::GeneticsLab',
        'Lacuna::DB::Result::Building::Trade' => 'Lacuna::DB::Result::Building::Trade',
        'Lacuna::DB::Result::Building::Transporter' => 'Lacuna::DB::Result::Building::Transporter',
        'Lacuna::DB::Result::Building::University' => 'Lacuna::DB::Result::Building::University',
        'Lacuna::DB::Result::Building::Water::Production' => 'Lacuna::DB::Result::Building::Water::Production',
        'Lacuna::DB::Result::Building::Water::Purification' => 'Lacuna::DB::Result::Building::Water::Purification',
        'Lacuna::DB::Result::Building::Water::Reclamation' => 'Lacuna::DB::Result::Building::Water::Reclamation',
        'Lacuna::DB::Result::Building::Water::Storage' => 'Lacuna::DB::Result::Building::Water::Storage',
        'Lacuna::DB::Result::Building::Waste::Exchanger' => 'Lacuna::DB::Result::Building::Waste::Exchanger',
        'Lacuna::DB::Result::Building::Waste::Recycling' => 'Lacuna::DB::Result::Building::Waste::Recycling',
        'Lacuna::DB::Result::Building::Waste::Sequestration' => 'Lacuna::DB::Result::Building::Waste::Sequestration',
        'Lacuna::DB::Result::Building::Waste::Digester' => 'Lacuna::DB::Result::Building::Waste::Digester',
        'Lacuna::DB::Result::Building::Waste::Treatment' => 'Lacuna::DB::Result::Building::Waste::Treatment',
        'Lacuna::DB::Result::Building::Permanent::Crater' => 'Lacuna::DB::Result::Building::Permanent::Crater',
        'Lacuna::DB::Result::Building::Permanent::Volcano' => 'Lacuna::DB::Result::Building::Permanent::Volcano',
        'Lacuna::DB::Result::Building::Permanent::MassadsHenge' => 'Lacuna::DB::Result::Building::Permanent::MassadsHenge',
        'Lacuna::DB::Result::Building::Permanent::LibraryOfJith' => 'Lacuna::DB::Result::Building::Permanent::LibraryOfJith',
        'Lacuna::DB::Result::Building::Permanent::NaturalSpring' => 'Lacuna::DB::Result::Building::Permanent::NaturalSpring',
        'Lacuna::DB::Result::Building::Permanent::OracleOfAnid' => 'Lacuna::DB::Result::Building::Permanent::OracleOfAnid',
        'Lacuna::DB::Result::Building::Permanent::TempleOfTheDrajilites' => 'Lacuna::DB::Result::Building::Permanent::TempleOfTheDrajilites',
        'Lacuna::DB::Result::Building::Permanent::GeoThermalVent' => 'Lacuna::DB::Result::Building::Permanent::GeoThermalVent',
        'Lacuna::DB::Result::Building::Permanent::InterDimensionalRift' => 'Lacuna::DB::Result::Building::Permanent::InterDimensionalRift',
        'Lacuna::DB::Result::Building::Permanent::KalavianRuins' => 'Lacuna::DB::Result::Building::Permanent::KalavianRuins',
        'Lacuna::DB::Result::Building::Permanent::CrashedShipSite' => 'Lacuna::DB::Result::Building::Permanent::CrashedShipSite',
        'Lacuna::DB::Result::Building::Permanent::CitadelOfKnope' => 'Lacuna::DB::Result::Building::Permanent::CitadelOfKnope',
        'Lacuna::DB::Result::Building::Permanent::EssentiaVein' => 'Lacuna::DB::Result::Building::Permanent::EssentiaVein',
        'Lacuna::DB::Result::Building::Permanent::GasGiantPlatform' => 'Lacuna::DB::Result::Building::Permanent::GasGiantPlatform',
        'Lacuna::DB::Result::Building::Permanent::Lake' => 'Lacuna::DB::Result::Building::Permanent::Lake',
        'Lacuna::DB::Result::Building::Permanent::RockyOutcrop' => 'Lacuna::DB::Result::Building::Permanent::RockyOutcrop',
        'Lacuna::DB::Result::Building::Permanent::TerraformingPlatform' => 'Lacuna::DB::Result::Building::Permanent::TerraformingPlatform',
        'Lacuna::DB::Result::Building::Ore::Mine' => 'Lacuna::DB::Result::Building::Ore::Mine',
        'Lacuna::DB::Result::Building::Ore::Ministry' => 'Lacuna::DB::Result::Building::Ore::Ministry',
        'Lacuna::DB::Result::Building::Ore::Refinery' => 'Lacuna::DB::Result::Building::Ore::Refinery',
        'Lacuna::DB::Result::Building::Ore::Storage' => 'Lacuna::DB::Result::Building::Ore::Storage',
        'Lacuna::DB::Result::Building::Food::Reserve' => 'Lacuna::DB::Result::Building::Food::Reserve',
        'Lacuna::DB::Result::Building::Food::Bread' => 'Lacuna::DB::Result::Building::Food::Bread',
        'Lacuna::DB::Result::Building::Food::Burger' => 'Lacuna::DB::Result::Building::Food::Burger',
        'Lacuna::DB::Result::Building::Food::Cheese' => 'Lacuna::DB::Result::Building::Food::Cheese',
        'Lacuna::DB::Result::Building::Food::Chip' => 'Lacuna::DB::Result::Building::Food::Chip',
        'Lacuna::DB::Result::Building::Food::Cider' => 'Lacuna::DB::Result::Building::Food::Cider',
        'Lacuna::DB::Result::Building::Food::CornMeal' => 'Lacuna::DB::Result::Building::Food::CornMeal',
        'Lacuna::DB::Result::Building::Food::Pancake' => 'Lacuna::DB::Result::Building::Food::Pancake',
        'Lacuna::DB::Result::Building::Food::Pie' => 'Lacuna::DB::Result::Building::Food::Pie',
        'Lacuna::DB::Result::Building::Food::Shake' => 'Lacuna::DB::Result::Building::Food::Shake',
        'Lacuna::DB::Result::Building::Food::Soup' => 'Lacuna::DB::Result::Building::Food::Soup',
        'Lacuna::DB::Result::Building::Food::Syrup' => 'Lacuna::DB::Result::Building::Food::Syrup',
        'Lacuna::DB::Result::Building::Food::Algae' => 'Lacuna::DB::Result::Building::Food::Algae',
        'Lacuna::DB::Result::Building::Food::Apple' => 'Lacuna::DB::Result::Building::Food::Apple',
        'Lacuna::DB::Result::Building::Food::Beeldeban' => 'Lacuna::DB::Result::Building::Food::Beeldeban',
        'Lacuna::DB::Result::Building::Food::Bean' => 'Lacuna::DB::Result::Building::Food::Bean',
        'Lacuna::DB::Result::Building::Food::Corn' => 'Lacuna::DB::Result::Building::Food::Corn',
        'Lacuna::DB::Result::Building::Food::Dairy' => 'Lacuna::DB::Result::Building::Food::Dairy',
        'Lacuna::DB::Result::Building::Food::Lapis' => 'Lacuna::DB::Result::Building::Food::Lapis',
        'Lacuna::DB::Result::Building::Food::Malcud' => 'Lacuna::DB::Result::Building::Food::Malcud',
        'Lacuna::DB::Result::Building::Food::Potato' => 'Lacuna::DB::Result::Building::Food::Potato',
        'Lacuna::DB::Result::Building::Food::Root' => 'Lacuna::DB::Result::Building::Food::Root',
        'Lacuna::DB::Result::Building::Food::Wheat' => 'Lacuna::DB::Result::Building::Food::Wheat',
        'Lacuna::DB::Result::Building::Energy::Fission' => 'Lacuna::DB::Result::Building::Energy::Fission',
        'Lacuna::DB::Result::Building::Energy::Fusion' => 'Lacuna::DB::Result::Building::Energy::Fusion',
        'Lacuna::DB::Result::Building::Energy::Geo' => 'Lacuna::DB::Result::Building::Energy::Geo',
        'Lacuna::DB::Result::Building::Energy::Hydrocarbon' => 'Lacuna::DB::Result::Building::Energy::Hydrocarbon',
        'Lacuna::DB::Result::Building::Energy::Reserve' => 'Lacuna::DB::Result::Building::Energy::Reserve',
        'Lacuna::DB::Result::Building::Energy::Singularity' => 'Lacuna::DB::Result::Building::Energy::Singularity',
        'Lacuna::DB::Result::Building::Energy::Waste' => 'Lacuna::DB::Result::Building::Energy::Waste',
        'Lacuna::DB::Result::Building::Permanent::Grove' => 'Lacuna::DB::Result::Building::Permanent::Grove',
        'Lacuna::DB::Result::Building::Permanent::Sand' => 'Lacuna::DB::Result::Building::Permanent::Sand',
        'Lacuna::DB::Result::Building::Permanent::Lagoon' => 'Lacuna::DB::Result::Building::Permanent::Lagoon',
        'Lacuna::DB::Result::Building::Permanent::Beach1' => 'Lacuna::DB::Result::Building::Permanent::Beach1',
        'Lacuna::DB::Result::Building::Permanent::Beach2' => 'Lacuna::DB::Result::Building::Permanent::Beach2',
        'Lacuna::DB::Result::Building::Permanent::Beach3' => 'Lacuna::DB::Result::Building::Permanent::Beach3',
        'Lacuna::DB::Result::Building::Permanent::Beach4' => 'Lacuna::DB::Result::Building::Permanent::Beach4',
        'Lacuna::DB::Result::Building::Permanent::Beach5' => 'Lacuna::DB::Result::Building::Permanent::Beach5',
        'Lacuna::DB::Result::Building::Permanent::Beach6' => 'Lacuna::DB::Result::Building::Permanent::Beach6',
        'Lacuna::DB::Result::Building::Permanent::Beach7' => 'Lacuna::DB::Result::Building::Permanent::Beach7',
        'Lacuna::DB::Result::Building::Permanent::Beach8' => 'Lacuna::DB::Result::Building::Permanent::Beach8',
        'Lacuna::DB::Result::Building::Permanent::Beach9' => 'Lacuna::DB::Result::Building::Permanent::Beach9',
        'Lacuna::DB::Result::Building::Permanent::Beach10' => 'Lacuna::DB::Result::Building::Permanent::Beach10',
        'Lacuna::DB::Result::Building::Permanent::Beach11' => 'Lacuna::DB::Result::Building::Permanent::Beach11',
        'Lacuna::DB::Result::Building::Permanent::Beach12' => 'Lacuna::DB::Result::Building::Permanent::Beach12',
        'Lacuna::DB::Result::Building::Permanent::Beach13' => 'Lacuna::DB::Result::Building::Permanent::Beach13',
        'Lacuna::DB::Result::Building::Permanent::MalcudField' => 'Lacuna::DB::Result::Building::Permanent::MalcudField',
        'Lacuna::DB::Result::Building::Permanent::BeeldebanNest' => 'Lacuna::DB::Result::Building::Permanent::BeeldebanNest',
        'Lacuna::DB::Result::Building::Permanent::LapisForest' => 'Lacuna::DB::Result::Building::Permanent::LapisForest',
        'Lacuna::DB::Result::Building::Permanent::AlgaePond' => 'Lacuna::DB::Result::Building::Permanent::AlgaePond',
        'Lacuna::DB::Result::Building::Permanent::Ravine' => 'Lacuna::DB::Result::Building::Permanent::Ravine',
        'Lacuna::DB::Result::Building::Permanent::Fissure' => 'Lacuna::DB::Result::Building::Permanent::Fissure',
        'Lacuna::DB::Result::Building::Permanent::PantheonOfHagness' => 'Lacuna::DB::Result::Building::Permanent::PantheonOfHagness',
        'Lacuna::DB::Result::Building::SubspaceSupplyDepot' => 'Lacuna::DB::Result::Building::SubspaceSupplyDepot',
        'Lacuna::DB::Result::Building::ThemePark' => 'Lacuna::DB::Result::Building::ThemePark',
        'Lacuna::DB::Result::Building::DeployedBleeder' => 'Lacuna::DB::Result::Building::DeployedBleeder',
        'Lacuna::DB::Result::Building::Permanent::BlackHoleGenerator' => 'Lacuna::DB::Result::Building::Permanent::BlackHoleGenerator',
        'Lacuna::DB::Result::Building::Permanent::GratchsGauntlet' => 'Lacuna::DB::Result::Building::Permanent::GratchsGauntlet',
        'Lacuna::DB::Result::Building::Permanent::HallsOfVrbansk' => 'Lacuna::DB::Result::Building::Permanent::HallsOfVrbansk',
        'Lacuna::DB::Result::Building::Permanent::KasternsKeep' => 'Lacuna::DB::Result::Building::Permanent::KasternsKeep',
        'Lacuna::DB::Result::Building::Permanent::TheDillonForge' => 'Lacuna::DB::Result::Building::Permanent::TheDillonForge',
        'Lacuna::DB::Result::Building::Permanent::GreatBallOfJunk' => 'Lacuna::DB::Result::Building::Permanent::GreatBallOfJunk',
        'Lacuna::DB::Result::Building::Permanent::PyramidJunkSculpture' => 'Lacuna::DB::Result::Building::Permanent::PyramidJunkSculpture',
        'Lacuna::DB::Result::Building::Permanent::MetalJunkArches' => 'Lacuna::DB::Result::Building::Permanent::MetalJunkArches',
        'Lacuna::DB::Result::Building::Permanent::JunkHengeSculpture' => 'Lacuna::DB::Result::Building::Permanent::JunkHengeSculpture',
        'Lacuna::DB::Result::Building::Permanent::SpaceJunkPark' => 'Lacuna::DB::Result::Building::Permanent::SpaceJunkPark',
        'Lacuna::DB::Result::Building::Water::AtmosphericEvaporator' => 'Lacuna::DB::Result::Building::Water::AtmosphericEvaporator',
        'Lacuna::DB::Result::Building::SupplyPod' => 'Lacuna::DB::Result::Building::SupplyPod',
        'Lacuna::DB::Result::Building::SAW' => 'Lacuna::DB::Result::Building::SAW',
        'Lacuna::DB::Result::Building::DistributionCenter' => 'Lacuna::DB::Result::Building::DistributionCenter',
        'Lacuna::DB::Result::Building::SSLa' => 'Lacuna::DB::Result::Building::SSLa',
        'Lacuna::DB::Result::Building::SSLb' => 'Lacuna::DB::Result::Building::SSLb',
        'Lacuna::DB::Result::Building::SSLc' => 'Lacuna::DB::Result::Building::SSLc',
        'Lacuna::DB::Result::Building::SSLd' => 'Lacuna::DB::Result::Building::SSLd',
        'Lacuna::DB::Result::Building::Module::ArtMuseum' => 'Lacuna::DB::Result::Building::Module::ArtMuseum',
        'Lacuna::DB::Result::Building::Module::CulinaryInstitute' => 'Lacuna::DB::Result::Building::Module::CulinaryInstitute',
        'Lacuna::DB::Result::Building::Module::OperaHouse' => 'Lacuna::DB::Result::Building::Module::OperaHouse',
        'Lacuna::DB::Result::Building::Module::StationCommand' => 'Lacuna::DB::Result::Building::Module::StationCommand',
        'Lacuna::DB::Result::Building::Module::IBS' => 'Lacuna::DB::Result::Building::Module::IBS',
        'Lacuna::DB::Result::Building::Module::Warehouse' => 'Lacuna::DB::Result::Building::Module::Warehouse',
        'Lacuna::DB::Result::Building::Module::Parliament' => 'Lacuna::DB::Result::Building::Module::Parliament',
        'Lacuna::DB::Result::Building::Permanent::AmalgusMeadow' => 'Lacuna::DB::Result::Building::Permanent::AmalgusMeadow',
        'Lacuna::DB::Result::Building::Permanent::DentonBrambles' => 'Lacuna::DB::Result::Building::Permanent::DentonBrambles',
        'Lacuna::DB::Result::Building::MercenariesGuild' => 'Lacuna::DB::Result::Building::MercenariesGuild',
        'Lacuna::DB::Result::Building::Module::PoliceStation' => 'Lacuna::DB::Result::Building::Module::PoliceStation',
        'Lacuna::DB::Result::Building::LCOTa' => 'Lacuna::DB::Result::Building::LCOTa',
        'Lacuna::DB::Result::Building::LCOTb' => 'Lacuna::DB::Result::Building::LCOTb',
        'Lacuna::DB::Result::Building::LCOTc' => 'Lacuna::DB::Result::Building::LCOTc',
        'Lacuna::DB::Result::Building::LCOTd' => 'Lacuna::DB::Result::Building::LCOTd',
        'Lacuna::DB::Result::Building::LCOTe' => 'Lacuna::DB::Result::Building::LCOTe',
        'Lacuna::DB::Result::Building::LCOTf' => 'Lacuna::DB::Result::Building::LCOTf',
        'Lacuna::DB::Result::Building::LCOTg' => 'Lacuna::DB::Result::Building::LCOTg',
        'Lacuna::DB::Result::Building::LCOTh' => 'Lacuna::DB::Result::Building::LCOTh',
        'Lacuna::DB::Result::Building::LCOTi' => 'Lacuna::DB::Result::Building::LCOTi',
    });
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
