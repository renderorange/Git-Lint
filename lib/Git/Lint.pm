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

sub run {
    my $self = shift;
    my $opt  = shift;

    my @issues;
    foreach my $check ( @{ $self->{_config}{profiles}{ $opt->{profile} } } ) {
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
