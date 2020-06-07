package Git::Lint::Config;

use strict;
use warnings;

use Git::Repository ();
use Try::Tiny;
use List::MoreUtils ();

our $VERSION = '0.001';

sub new {
    my $class = shift;
    my $self  = { profiles => { default => [ 'Whitespace', 'UnresolvedConflict' ] } };

    bless $self, $class;

    my $user_config = $self->user_config();

    # load the user config into the object.
    # user defined config settings override default settings above.
    foreach my $cat ( keys %{$user_config} ) {
        foreach my $key ( keys %{ $user_config->{$cat} } ) {
            $self->{$cat}{$key} = $user_config->{$cat}{$key};
        }
    }

    return $self;
}

sub user_config {
    my $self = shift;

    my @git_config_cmd = (qw{ config --get-regexp ^lint });

    my $raw_config = try {
        return Git::Repository->run(@git_config_cmd);
    }
    catch {
        chomp( my $exception = $_ );
        die "git-lint: $exception\n";
    };

    my %parsed_config = ();
    foreach my $line ( split( /\n/, $raw_config ) ) {
        next unless $line =~ /^lint\.(\w+).(\w+)\s+(.+)$/;

        my @values = List::MoreUtils::apply {s/^\s+|\s+$//g} split( /,/, $3 );
        push @{ $parsed_config{$1}{$2} }, @values;
    }

    return \%parsed_config;
}

1;

__END__

=pod

=head1 NAME

Git::Lint::Config - configuration for C<Git::Lint>

=head1 SYNOPSIS

 use Git::Lint::Config;

 my $config   = Git::Lint::Config->new();
 my $profiles = $config->{profiles};

=head1 DESCRIPTION

C<Git::Lint::Config> defines and loads settings for C<Git::Lint>.

=head1 CONFIGURATION

Configuration is done through C<git config> files (F<~/.gitconfig> or F</repo/.git/config>).

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=head1 COPYRIGHT

=cut
