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

__END__

=pod

=head1 NAME

Git::Lint::Command - run commands

=head1 SYNOPSIS

 use Git::Lint::Command;
 my $config_raw = Git::Lint::Command::run(\@git_config_cmd);

=head1 DESCRIPTION

C<Git::Lint::Command> runs commands and returns output.

=head1 SUBROUTINES

=over

=item run

Runs the passed command and returns the output.

=back

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
