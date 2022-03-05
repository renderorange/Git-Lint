package Git::Lint::Check::Message::SummaryEndingPeriod;

use strict;
use warnings;

use parent 'Git::Lint::Check::Message';

our $VERSION = '0.013';

my $check_name        = 'summary ending period';
my $check_description = 'summary must not end with a period';

sub check {
    my $self  = shift;
    my $input = shift;

    my $match = sub {
        my $lines_arref = shift;
        my $summary     = shift @{$lines_arref};
        return 1 if $summary =~ /\.$/;
        return;
    };

    return $self->parse(
        input => $input,
        match => $match,
        check => $check_name . ' (' . $check_description . ')',
    );
}

1;

__END__

=pod

=head1 NAME

Git::Lint::Check::Message::SummaryEndingPeriod - check for no summary ending period

=head1 SYNOPSIS

 my $plugin = Git::Lint::Check::Message::SummaryEndingPeriod->new();

 my $input = $plugin->message( file => $filepath );
 my @lines = @{$input};
 my @issues = $plugin->check( \@lines );

=head1 DESCRIPTION

C<Git::Lint::Check::Message::SummaryEndingPeriod> is a C<Git::Lint::Check::Message> module which checks git commit message input to ensure the summary line doesn't end with a period.

=head1 METHODS

=over

=item check

=back

=cut
