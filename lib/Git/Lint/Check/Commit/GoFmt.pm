package Git::Lint::Check::Commit::GoFmt;

use strict;
use warnings;

use parent 'Git::Lint::Check::Commit';

our $VERSION = '0.007';

my $check_name        = 'gofmt';
my $check_description = 'not formatted';

sub check {
    my $self  = shift;
    my $input = shift;

    my @files;
    foreach my $line ( @{$input} ) {
        my $filename = $self->get_filename($line);
        if ($filename) {
            next if $filename !~ /\.go$/;
            push @files, $filename;
        }
    }

    my @issues;
    foreach my $filename (@files) {
        my ( $stdout, $stderr, $exit ) = Git::Lint::Command::run( [ qw{gofmt -l}, $filename ] );
        die "gofmt: $stderr\n" if $exit;

        if ($stdout) {
            push @issues, { filename => $filename, message => "$check_name ($check_description)" };
        }
    }

    return @issues;
}

1;

__END__

=pod

=head1 NAME

Git::Lint::Check::Commit::GoFmt - check go files for formatting

=head1 SYNOPSIS

 my $plugin = Git::Lint::Check::Commit::GoFmt->new();

=head1 DESCRIPTION

C<Git::Lint::Check::Commit::GoFmt> is a C<Git::Lint::Check::Commit> module which checks go files for formatting.

=head1 METHODS

=over

=item check

Checks the filename for formatting using C<gofmt>.

=back

=cut
