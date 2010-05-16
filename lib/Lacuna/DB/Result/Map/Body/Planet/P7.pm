package Lacuna::DB::Result::Map::Body::Planet::P7;

use Moose;
extends 'Lacuna::DB::Result::Map::Body::Planet';

use constant image => 'p7';
use constant surface => 'surface-e';

use constant water => 5700;

# resource concentrations

use constant chalcopyrite => 2800;

use constant bauxite => 2700;

use constant goethite => 2400;

use constant gypsum => 2100;



no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
