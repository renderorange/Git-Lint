package Git::Lint::Check::Commit::Whitespace;

use strict;
use warnings;

use parent 'Git::Lint::Check::Commit';

our $VERSION = '0.001';

my $check_name = 'trailing whitespace';

sub check {
    my $self  = shift;
    my $input = shift;

    my $match = sub {
        my $line = shift;
        return 1 if $line =~ /\s$/;
        return;
    };

    return $self->parse(
        input => $input,
        match => $match,
        check => $check_name
    );
}

1;
