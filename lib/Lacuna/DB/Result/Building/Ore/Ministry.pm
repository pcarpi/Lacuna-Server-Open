package Lacuna::DB::Result::Building::Ore::Ministry;

use Moose;
extends 'Lacuna::DB::Result::Building::Ore';
use Lacuna::Constants qw(ORE_TYPES);

sub platforms {
    my $self = shift;
    return Lacuna->db->resultset('Lacuna::DB::Result::MiningPlatforms')->search({ planet_id => $self->body_id });
}

sub ships {
    my $self = shift;
    return Lacuna->db->resultset('Lacuna::DB::Result::Ships')->search({ body_id => $self->body_id, task => 'Mining' });
}

sub max_platforms {
    my $self = shift;
    return int(($self->level + 1) / 2);
}

sub add_ship {
    my ($self, $ship) = @_;
    $ship->task('Mining');
    $ship->update;
    $self->recalc_ore_production;
    return $self;
}

sub send_ship_home {
    my ($self, $asteroid, $ship) = @_;
    $ship->send(
        target      => $asteroid,
        direction   => 'in',
        task        => 'Travelling',
    );
    $self->recalc_ore_production;
    return $self;
}

sub can_add_platform {
    my ($self) = @_;
    if ($self->platforms->count >= $self->max_platforms) {
        confess [1009, 'You already have the maximum number of platforms allowed at this Ministry level.'];
    }
    return 1;
}

sub add_platform {
    my ($self, $asteroid) = @_;
    Lacuna->db->resultset('Lacuna::DB::Result::MiningPlatforms')->new({
        planet_id   => $self->body_id,
        planet      => $self->body,
        asteroid_id => $asteroid->id,
        asteroid    => $asteroid,
    })->insert;
    $self->recalc_ore_production;
    return $self;
}

sub remove_platform {
    my ($self, $platform) = @_;
    if ($self->platforms->count == 1) {
        my $ships = $self->ships;
        while (my $ship = $ships->next) {
            $self->send_ship_home($platform->asteroid, $ship);
        }
    }
    $platform->delete;
    $self->recalc_ore_production;
    return $self;
}

sub recalc_ore_production {
    my $self = shift;
    my $body = $self->body;
    
    # get ships
    my $ship_speed = 0;
    my $ship_capacity = 0;
    my $ship_count = 0;
    my $ships = $self->ships;
    while (my $ship = $ships->next) {
        $ship_count++;
        $ship_capacity += $ship->hold_size;
        $ship_speed += $ship->speed;
    }
    my $average_ship_speed = $ship_speed / $ship_count;
    
    # platforms
    my $platform_count              = $self->platforms->count;
    my $cargo_space_per_platform    = $ship_capacity / $platform_count;
    my $platforms                   = $self->platforms;
    my $production_hour             = 70 * $self->production_hour * $self->mining_production_bonus;
    while (my $platform = $platforms->next) {
        my $asteroid                    = $platform->asteroid;
        my $trips_per_hour              = ($body->calculate_distance_to_target($asteroid) / $average_ship_speed) * 2; 
        my $max_cargo_hauled_per_hour   = $trips_per_hour * $cargo_space_per_platform;
        my $cargo_hauled_per_hour       = ($production_hour > $max_cargo_hauled_per_hour) ? $max_cargo_hauled_per_hour : $production_hour;
        foreach my $ore (ORE_TYPES) {
            my $hour_method = $ore.'_hour';
            $platform->$hour_method(sprintf('%.0f', $asteroid->$ore * $cargo_hauled_per_hour / 10_000));
        }
        $platform->percent_ship_capacity(sprintf('%.0f', $cargo_hauled_per_hour / $max_cargo_hauled_per_hour * 100));
        $platform->percent_platform_capacity(sprintf('%.0f', $cargo_hauled_per_hour / $production_hour * 100));
        $platform->update;
    }
    
    # tell body to recalc at next tick
    $body->needs_recalc(1);
    $body->update;
    return $self;
}

before delete => sub {
    my ($self) = @_;
    $self->ships->update({task=>'Docked'});
    $self->platforms->delete_all;
    $self->body->needs_recalc(1);
    $self->body->update;
};

after finish_upgrade => sub {
    my ($self) = @_;
    $self->recalc_ore_production;
};

use constant controller_class => 'Lacuna::RPC::Building::MiningMinistry';

use constant university_prereq => 8;

use constant max_instances_per_planet => 1;

use constant image => 'miningministry';

use constant name => 'Mining Ministry';

use constant food_to_build => 137;

use constant energy_to_build => 139;

use constant ore_to_build => 137;

use constant water_to_build => 137;

use constant waste_to_build => 70;

use constant time_to_build => 150;

use constant food_consumption => 11;

use constant energy_consumption => 56;

use constant ore_consumption => 8;

use constant water_consumption => 13;

use constant waste_production => 1;


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
