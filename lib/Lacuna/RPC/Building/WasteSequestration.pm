package Lacuna::RPC::Building::WasteSequestration;

use Moose;
extends 'Lacuna::RPC::Building';

sub app_url {
    return '/wastesequestration';
}

sub model_class {
    return 'Lacuna::DB::Result::Building::Waste::Sequestration';
}

no Moose;
__PACKAGE__->meta->make_immutable;
