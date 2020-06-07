package Git::Lint;

use strict;
use warnings;

use Module::Loader;
use Git::Lint::Config;

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

    my @issues;
    foreach my $check ( $self->{_loader}->find_modules('Git::Lint::Check::Commit') ) {
        $self->{_loader}->load($check);
        my $plugin = $check->new();

        # ensure the plugins don't manipulate the original input
        my $input = $check->diff();
        my @lines = @{$input};
        push @issues, $plugin->check( \@lines );
    }

    foreach my $issue (@issues) {
        push @{ $self->{issues}{ $issue->{filename} } }, $issue->{message};
    }

    return;
}

1;
