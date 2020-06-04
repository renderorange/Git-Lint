package Git::Lint::Check::Commit::UnresolvedConflict;

use strict;
use warnings;

use parent 'Git::Lint::Check::Commit';

our $VERSION = '0.001';

my $check_name = 'unresolved conflict';

sub check {
    my $self  = shift;
    my $input = shift;

    my $match = sub {
        my $line = shift;
        return 1 if $line =~ /^(?:[<>=]){7}$/;
        return;
    };

    return $self->parse(
        input => $input,
        match => $match,
        check => $check_name
    );
}

1;
