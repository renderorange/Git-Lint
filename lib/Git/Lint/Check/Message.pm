package Git::Lint::Check::Message;

use strict;
use warnings;

use parent 'Git::Lint::Check';

use Git::Lint::Command;

our $VERSION = '0.003';

sub message {
    my $self = shift;
    my $args = {
        file => undef,
        @_,
    };

    my $lines_arref = [];
    open( my $message_fh, '<', $args->{file} )
        or die 'open: ' . $args->{file} . ': ' . $!;
    while ( my $line = <$message_fh> ) {
        chomp $line;
        push @{$lines_arref}, $line;
    }
    close($message_fh);

    unless ($lines_arref) {
        exit 0;
    }

    return $lines_arref;
}

sub report {
    my $self = shift;
    my $args = {
        check => undef,
        @_,
    };

    foreach ( keys %{$args} ) {
        die "$_ is a required argument"
            unless defined $args->{$_};
    }

    my $message = '* ' . $args->{check};

    return { message => $message };
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
    if ( $args->{match}->( $args->{input} ) ) {
        push @issues, $self->report( check => $args->{check}, );
    }

    return @issues;
}

1;

__END__

=pod

=head1 NAME

Git::Lint::Check::Message - parent module for Message check modules

=head1 SYNOPSIS

 use Git::Lint::Check::Message;

 my $plugin = Git::Lint::Check::Message->new();
 my $input  = $plugin->message();

=head1 DESCRIPTION

C<Git::Lint::Check::Message> is the parent module for Message check modules.

It contains methods which Message check modules use for their check process and is not meant to be run outside of the context of child check modules.

=head1 METHODS

=over

=item message

Reads and returns an array ref of the commit message input.

=item report

Formats the returned line violation into the expected format.

=item parse

Parses the commit message input for violations using the match subref check.

=back

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
