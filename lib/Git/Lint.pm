package Git::Lint;

use strict;
use warnings;

use Git::Lint::Config;
use Try::Tiny;
use Module::Loader;

our $VERSION = '0.001';

sub new {
    my $class = shift;
    my $self  = {
        issues    => {},
        '_loader' => Module::Loader->new(),
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
        unless exists $self->config->{profiles}{ $opt->{profile} };

    my @issues;
    foreach my $check ( @{ $self->config->{profiles}{ $opt->{profile} } } ) {
        my $class = 'Git::Lint::Check::Commit::' . $check;
        try {
            $self->{_loader}->load($class);
        }
        catch {
            my $exception = $_;
            die "git-lint: $exception\n";
        };
        my $plugin = $class->new();

        # ensure the plugins don't manipulate the original input
        my $input = $class->diff();
        my @lines = @{$input};
        push @issues, $plugin->check( \@lines );
    }

    foreach my $issue (@issues) {
        push @{ $self->{issues}{ $issue->{filename} } }, $issue->{message};
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

=head1 CONFIGURATION

Configuration is done through C<git config> files (F<~/.gitconfig> or F</repo/.git/config>).

Only one profile, C<default>, is defined internally. C<default> contains all check modules by default.

The C<default> profile can be overridden through C<git config>.

To set the default profile to only run the C<Whitespace> check:

 [lint "profiles"]
     default = Whitespace

Or set the default profile to C<Whitespace> and the fictional check, C<Flipdoozler>:

 [lint "profiles"]
     default = Whitespace, Flipdoozler

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
