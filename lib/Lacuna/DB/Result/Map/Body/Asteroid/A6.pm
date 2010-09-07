package Lacuna::DB::Result::Map::Body::Asteroid::A6;

use Moose;
no warnings qw(uninitialized);
extends 'Lacuna::DB::Result::Map::Body::Asteroid';

use constant image => 'a6';

use constant galena => 5790;
use constant kerogen => 40;
use constant water => 13;


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
