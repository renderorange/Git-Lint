package Git::Lint::Check::Message::Summary;

use strict;
use warnings;

use parent 'Git::Lint::Check::Message';

our $VERSION = '0.004';

my $check_name = 'summary length';

use constant SUMMARY_LENGTH => 50;

sub check {
    my $self  = shift;
    my $input = shift;

    my $match = sub {
        my $lines_arref = shift;
        my $summary     = shift @{$lines_arref};
        return 1 if length $summary > SUMMARY_LENGTH;
        return;
    };

    return $self->parse(
        input => $input,
        match => $match,
        check => $check_name,
    );
}

1;

__END__

=pod

=head1 NAME

Git::Lint::Check::Message::Summary - check for line ending whitespace

=head1 SYNOPSIS

 my $plugin = Git::Lint::Check::Message::Summary->new();

 my $input = $plugin->message();
 my @lines = @{$input};
 my @issues = $plugin->check( \@lines );

=head1 DESCRIPTION

C<Git::Lint::Check::Message::Summary> is a C<Git::Lint::Check::Message> module which checks git commit message input to ensure the summary is 50 characters or less.

This module defines the subref that matches the violation.

=head1 METHODS

=over

=item check

Method that defines the check subref and passes it to C<Git::Lint::Check::Message>'s parse method.

=back

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
