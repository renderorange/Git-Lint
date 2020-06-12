package Git::Lint::Config;

use strict;
use warnings;

use Module::Loader;
use List::MoreUtils ();
use Capture::Tiny;

our $VERSION = '0.001';

sub new {
    my $class = shift;

    # all check modules are added to the default profile
    my $loader    = Module::Loader->new;
    my $namespace = 'Git::Lint::Check::Commit';
    my @checks    = List::MoreUtils::apply {s/$namespace\:\://g} $loader->find_modules( $namespace, { max_depth => 1 } );

    my $self = { profiles => { default => \@checks } };

    bless $self, $class;

    my $user_config = $self->user_config();

    # user defined profiles override default profiles
    foreach my $cat ( keys %{$user_config} ) {
        foreach my $key ( keys %{ $user_config->{$cat} } ) {
            $self->{$cat}{$key} = $user_config->{$cat}{$key};
        }
    }

    return $self;
}

sub user_config {
    my $self = shift;

    my @git_config_cmd = (qw{ git config --get-regexp ^lint });

    my ($stdout, $stderr, $exit) = Capture::Tiny::capture {
        system(@git_config_cmd);
    };

    if ($exit) {
        chomp($stderr);
        die "git-lint: $stderr\n";
    }

    my %parsed_config = ();
    foreach my $line ( split( /\n/, $stdout ) ) {
        next unless $line =~ /^lint\.(\w+).(\w+)\s+(.+)$/;
        my ( $cat, $key, $value ) = ( $1, $2, $3 );

        my @values = List::MoreUtils::apply {s/^\s+|\s+$//g} split( /,/, $value );
        push @{ $parsed_config{$cat}{$key} }, @values;
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

=head1 CONSTRUCTOR

=over

=item new

Returns a reference to a new C<Git::Lint::Config> object.

=back

=head1 METHODS

=over

=item user_config

Reads, parses, and returns the user config settings from C<git config>.

=back

=head1 CONFIGURATION

Configuration is done through C<git config> files (F<~/.gitconfig> or F</repo/.git/config>).

The C<Git::Lint::Config> object will contain the following keys:

=over

=item profiles

The C<profiles> key by default contains one profile, C<default>, which contains all check modules.

The C<default> profile can be overridden through C<git config>.

To set the default profile to only run the C<Whitespace> check:

 [lint "profiles"]
     default = Whitespace

Or set the default profile to C<Whitespace> and the fictional check, C<Flipdoozler>:

 [lint "profiles"]
     default = Whitespace, Flipdoozler

=back

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
