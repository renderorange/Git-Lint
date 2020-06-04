package Git::Lint::Check::Commit;

use strict;
use warnings;

use parent 'Git::Lint::Check';

our $VERSION = '0.001';

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
