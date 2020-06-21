package Git::Lint::Test;

use strict;
use warnings;

use parent 'Test::More';

our $VERSION = '0.001';

sub import {
    my $class = shift;
    my %args  = @_;

    if ( $args{tests} ) {
        $class->builder->plan( tests => $args{tests} )
            unless $args{tests} eq 'no_declare';
    }
    elsif ( $args{skip_all} ) {
        $class->builder->plan( skip_all => $args{skip_all} );
    }

    Test::More->export_to_level(1);

    return;
}

sub override_capture_tiny {
    my %args = (
        stdout => '',
        stderr => '',
        exit   => 0,
        @_,
    );

    require Capture::Tiny;

    no warnings 'redefine', 'prototype';
    *Capture::Tiny::capture = sub {
        return ( $args{stdout}, $args{stderr}, $args{exit} );
    };
}

1;

__END__

=pod

=head1 NAME

Git::Lint::Test - testing module for Git::Lint

=head1 SYNOPSIS

 use Git::Lint::Test;

 ok($got eq $expected, $test_name);

=head1 DESCRIPTION

C<Git::Lint::Test> sets up the testing environment and modules needed for tests.

Methods from C<Test::More> are exported and available for the tests.

=head1 SUBROUTINES

=over

=item override_capture_tiny

Overrides and sets the output of C<Capture::Tiny::capture>.

ARGS are C<stdout>, C<stderr>, and C<exit>.

 Git::Lint::Test::override_capture_tiny(
     stdout => "fake return\n", stderr => '', exit => 0
 );

If undefined, C<stdout> and C<stderr> default to empty string. C<exit> defaults to 0.

=back

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
