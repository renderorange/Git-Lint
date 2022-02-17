package Git::Lint;

use strict;
use warnings;

use Git::Lint::Config;
use Try::Tiny;
use Module::Loader;

our $VERSION = '0.004';

sub new {
    my $class = shift;
    my $self  = {
        issues    => undef,
        '_config' => Git::Lint::Config->new(),
    };

    bless $self, $class;

    return $self;
}

sub config {
    my $self = shift;
    return $self->{_config};
}

sub run {
    my $self = shift;
    my $opt  = shift;

    die 'git-lint: profile ' . $opt->{profile} . ' was not found' . "\n"
        unless exists $self->config->{profiles}{ $opt->{check} }{ $opt->{profile} };

    my $check = lc $opt->{check};
    $check = ucfirst $check;

    my $loader = Module::Loader->new;

    my @issues;
    foreach my $module ( @{ $self->config->{profiles}{ $opt->{check} }{ $opt->{profile} } } ) {
        my $class = q{Git::Lint::Check::} . $check . q{::} . $module;
        try {
            $loader->load($class);
        }
        catch {
            my $exception = $_;
            die "git-lint: $exception\n";
        };
        my $plugin = $class->new();

        # TODO: this would be better to be named the same method
        my $input = ( $opt->{check} eq 'commit' ? $class->diff() : $class->message( file => $opt->{file} ) );

        # ensure the plugins don't manipulate the original input
        my @lines = @{$input};
        push @issues, $plugin->check( \@lines );
    }

    foreach my $issue (@issues) {
        if ( $opt->{check} eq 'commit' ) {
            push @{ $self->{issues}{ $issue->{filename} } }, $issue->{message};
        }
        else {
            push @{ $self->{issues} }, $issue->{message};
        }
    }

    return;
}

1;

__END__

=pod

=head1 NAME

Git::Lint - linter for git

=head1 SYNOPSIS

 use Git::Lint;

 my $lint = Git::Lint->new();
 $lint->run({ profile => 'default' });

=head1 DESCRIPTION

C<Git::Lint> is a pluggable lint framework for git, written in Perl.

=head1 CONSTRUCTOR

=over

=item new

Returns a reference to a new C<Git::Lint> object.

=back

=head1 METHODS

=over

=item run

Loads the check modules as defined by C<profile>.

C<run> accepts the following arguments:

B<profile>

The name of a defined set of check modules to run.

=item config

Returns the C<Git::Lint::Config> object created by C<Git::Lint>.

=back

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
