package Git::Lint::Check::Commit;

use strict;
use warnings;

use parent 'Git::Lint::Check';

use Git::Lint::Command;

our $VERSION = '0.001';

sub diff {
    my $self = shift;

    my @git_head_cmd = (qw{ git rev-parse --verify HEAD });

    my $against;
    my $head = Git::Lint::Command::run( \@git_head_cmd );

    if ($head) {
        $against = 'HEAD';
    }
    else {
        # Initial commit: diff against an empty tree object
        $against = '4b825dc642cb6eb9a060e54bf8d69288fbee4904';
    }

    my @git_diff_index_cmd = ( qw{ git diff-index -p -M --cached }, $against );

    my $diff = Git::Lint::Command::run( \@git_diff_index_cmd );

    unless ($diff) {
        exit 0;
    }

    return [ split( /\n/, $diff ) ];
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

    my @issues;
    my $filename;
    my $lineno;

    foreach ( @{ $args->{input} } ) {
        if (m|^diff --git a/(.*) b/\1$|) {
            $filename = $1;
            next;
        }

        if (/^@@ -\S+ \+(\d+)/) {
            $lineno = $1 - 1;
            next;
        }

        if (/^ /) {
            $lineno++;
            next;
        }

        if (s/^\+//) {
            $lineno++;
            chomp;

            if ( $args->{match}->($_) ) {
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
