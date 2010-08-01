package Lacuna::RPC::Building::Beach11;

use Moose;
extends 'Lacuna::RPC::Building';

sub app_url {
    return '/beach11';
}

sub model_class {
    return 'Lacuna::DB::Result::Building::Permanent::Beach11';
}

no Moose;
__PACKAGE__->meta->make_immutable;
