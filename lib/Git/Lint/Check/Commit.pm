package Git::Lint::Check::Commit;

use strict;
use warnings;

use parent 'Git::Lint::Check';

use Try::Tiny;
use Git::Repository ();

our $VERSION = '0.001';

sub diff {
    my $self = shift;

    my @git_head_cmd = (qw{ rev-parse --verify HEAD });

    my $against;
    my $head = try {
        return Git::Repository->run(@git_head_cmd);
    }
    catch {
        chomp( my $exception = $_ );
        die "gitlint: $exception\n";
    };

    if ($head) {
        $against = 'HEAD';
    }
    else {
        # Initial commit: diff against an empty tree object
        $against = '4b825dc642cb6eb9a060e54bf8d69288fbee4904';
    }

    my @git_diff_index_cmd = ( qw{ diff-index -p -M --cached }, $against );

    my @diff = try {
        return Git::Repository->run(@git_diff_index_cmd);
    }
    catch {
        chomp( my $exception = $_ );
        die "gitlint: $exception\n";
    };

    unless (@diff) {
        exit 0;
    }

    return \@diff;
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
