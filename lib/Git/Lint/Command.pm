package Git::Lint::Command;

use strict;
use warnings;

use Capture::Tiny;

our $VERSION = '0.001';

sub run {
    my $command = shift;

    my ( $stdout, $stderr, $exit ) = Capture::Tiny::capture {
        system( @{$command} );
    };

    if ($exit) {
        chomp($stderr);
        die "git-lint: $stderr\n";
    }

    return $stdout;
}

1;
