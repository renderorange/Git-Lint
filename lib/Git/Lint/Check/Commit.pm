package Git::Lint::Check::Commit;

use strict;
use warnings;

use parent 'Git::Lint::Check';

use Git::Lint::Command;

our $VERSION = '0.001';

sub diff {
    my $self = shift;

    my $diff_arref = $self->_diff_index( $self->_against );

    unless ($diff_arref) {
        exit 0;
    }

    return $diff_arref;
}

sub _against {
    my $self = shift;

    my @git_head_cmd = (qw{ git show-ref --head });

    my $against;
    my ( $stdout, $stderr, $exit ) = Git::Lint::Command::run( \@git_head_cmd );

    # show-ref --head returns 1 if there are no prior commits, but doesn't
    # return a message to stderr.  since we need to halt for other errors and
    # can't rely on the error code alone, checking for stderr seems like the
    # least worst way to detect if we encountered any other errors.
    # checking the error string for 'fatal: Needed a single revision' was
    # the previous way we were checking for initial commit, but seemed more
    # brittle over the long term to check for a specific error string.
    if ( $exit && $stderr ) {
        die "git-lint: $stderr\n";
    }

    if ($stdout) {
        $against = 'HEAD';
    }
    else {
        # Initial commit: diff against an empty tree object
        $against = '4b825dc642cb6eb9a060e54bf8d69288fbee4904';
    }

    return $against;
}

sub _diff_index {
    my $self    = shift;
    my $against = shift;

    my @git_diff_index_cmd = ( qw{ git diff-index -p -M --cached }, $against );

    my ( $stdout, $stderr, $exit ) = Git::Lint::Command::run( \@git_diff_index_cmd );

    die "git-lint: $stderr\n" if $exit;

    return [ split( /\n/, $stdout ) ];
}

sub report {
    my $self = shift;
    my $args = {
        filename => undef,
        check    => undef,
        lineno   => undef,
        @_,
    };

    foreach ( keys %{$args} ) {
        die "$_ is a required argument"
            unless defined $args->{$_};
    }

    my $message = '* ' . $args->{check} . ' (line ' . $args->{lineno} . ')';

    return { filename => $args->{filename}, message => $message };
}

sub parse {
    my $self = shift;
    my $args = {
        input => undef,
        match => undef,
        check => undef,
        @_,
    };

    foreach ( keys %{$args} ) {
        die "$_ is a required argument"
            unless defined $args->{$_};
    }

    die 'match argument must be a code ref'
        unless ref $args->{match} eq 'CODE';

    my @issues;
    my $filename;
    my $lineno;

    foreach my $line ( @{ $args->{input} } ) {
        if ( $line =~ m|^diff --git a/(.*) b/\1$| ) {
            $filename = $1;
            next;
        }

        if ( $line =~ /^@@ -\S+ \+(\d+)/ ) {
            $lineno = $1 - 1;
            next;
        }

        if ( $line =~ /^ / ) {
            $lineno++;
            next;
        }

        if ( $line =~ /^--- / || $line =~ /^\+\+\+ / ) {
            $lineno++;
            next;
        }

        if ( $line =~ s/^\+// ) {
            $lineno++;
            chomp $line;

            if ( $args->{match}->($line) ) {
                push @issues,
                    $self->report(
                    filename => $filename,
                    check    => $args->{check},
                    lineno   => $lineno,
                    );
            }
        }
    }

    return @issues;
}

1;

__END__

=pod

=head1 NAME

Git::Lint::Check::Commit - parent module for Commit check modules

=head1 SYNOPSIS

 use Git::Lint::Check::Commit;

 my $plugin = Git::Lint::Check::Commit->new();
 my $input  = $plugin->diff();

=head1 DESCRIPTION

C<Git::Lint::Check::Commit> is the parent module for Commit check modules.

It contains methods which Commit check modules use for their check process and is not meant to be run outside of the context of child check modules.

=head1 METHODS

=over

=item diff

Returns the diff of the commits to check.

=item report

Formats the returned line violation into the expected format.

=item parse

Parses the diff input for violations using the match subref check.

=back

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
