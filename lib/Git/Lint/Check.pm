package Git::Lint::Check;

use strict;
use warnings;

our $VERSION = '0.004';

sub new {
    my $class = shift;
    my $self  = {};

    bless $self, $class;

    return $self;
}

1;

__END__

=pod

=head1 NAME

Git::Lint::Check - constructor for Git::Lint::Check modules

=head1 SYNOPSIS

 use Git::Lint::Check;

 my $check = Git::Lint::Check->new();

=head1 DESCRIPTION

C<Git::Lint::Check> provides a contructor for child modules.

This module is not meant to be initialized directly, but through child modules.

There isn't anything here anyway if you did.

=head1 CONSTRUCTOR

=over

=item new

Returns a reference to a new C<Git::Lint::Check> object.

=back

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
