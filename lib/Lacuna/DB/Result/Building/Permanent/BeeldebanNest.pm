package Lacuna::DB::Result::Building::Permanent::BeeldebanNest;

use Moose;
no warnings qw(uninitialized);
extends 'Lacuna::DB::Result::Building::Permanent';

use constant controller_class => 'Lacuna::RPC::Building::BeeldebanNest';

sub can_build {
    my ($self, $body) = @_;
    if ($body->get_plan(__PACKAGE__, 1)) {
        return 1;  
    }
    confess [1013,"You can't build a Beeldeban Nest. It forms naturally."];
}

sub can_upgrade {
    confess [1013, "You can't upgrade a Beeldeban Nest. It forms naturally."];
}

use constant image => 'beeldebannest';

sub image_level {
    my ($self) = @_;
    return $self->image.'1';
}

after finish_upgrade => sub {
    my $self = shift;
    $self->body->add_news(30, sprintf('A boy was nearly killed today when he and his sister wandered into a wild Beeldeban nest on %s today.', $self->body->name));
};

use constant name => 'Beeldeban Nest';
use constant min_orbit => 5;
use constant max_orbit => 6;
use constant time_to_build => 0;
use constant max_instances_per_planet => 1;
use constant beetle_production => 4000;


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);