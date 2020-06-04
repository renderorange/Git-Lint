package Git::Lint::Check;

use strict;
use warnings;

our $VERSION = '0.001';

sub new {
    my $class = shift;
    my $self  = {};

    bless $self, $class;

    return $self;
}

1;
