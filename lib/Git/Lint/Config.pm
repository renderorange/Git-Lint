package Git::Lint::Config;

use strict;
use warnings;

use Module::Loader;
use List::MoreUtils ();
use Git::Lint::Command;

our $VERSION = '0.007';

sub new {
    my $class = shift;
    my $self  = { profiles => undef };

    # all check modules are added to the default profile
    my $loader        = Module::Loader->new;
    my $namespace     = 'Git::Lint::Check::Commit';
    my @commit_checks = List::MoreUtils::apply {s/$namespace\:\://g} $loader->find_modules( $namespace, { max_depth => 1 } );

    if (@commit_checks) {
        $self->{profiles}{commit}{default} = \@commit_checks;
    }

    $namespace = 'Git::Lint::Check::Message';
    my @message_checks = List::MoreUtils::apply {s/$namespace\:\://g} $loader->find_modules( $namespace, { max_depth => 1 } );

    if (@message_checks) {
        $self->{profiles}{message}{default} = \@message_checks;
    }

    bless $self, $class;

    my $user_config = $self->user_config();

    # user defined profiles override internally defined profiles
    foreach my $cat ( keys %{$user_config} ) {
        foreach my $check ( keys %{ $user_config->{$cat} } ) {
            foreach my $profile ( keys %{ $user_config->{$cat}{$check} } ) {
                $self->{$cat}{$check}{$profile} = $user_config->{$cat}{$check}{$profile};
            }
        }
    }

    return $self;
}

sub user_config {
    my $self = shift;

    my @git_config_cmd = (qw{ git config --get-regexp ^lint });

    my ( $stdout, $stderr, $exit ) = Git::Lint::Command::run( \@git_config_cmd );

    # if there is no user config, the git config command above will return 1
    # but without stderr.
    die "git-lint: $stderr\n" if $exit && $stderr;

    my %parsed_config = ();
    foreach my $line ( split( /\n/, $stdout ) ) {
        next unless $line =~ /^lint\.(\w+).(\w+).(\w+)\s+(.+)$/;
        my ( $cat, $check, $profile, $value ) = ( $1, $2, $3, $4 );

        my @values = List::MoreUtils::apply {s/^\s+|\s+$//g} split( /,/, $value );
        push @{ $parsed_config{$cat}{$check}{$profile} }, @values;
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

The C<profiles> key by default contains one profile per C<check> mode, C<default>, which contains all check modules for that mode.

The C<default> profile can be overridden through C<git config>.

To set the default profile for the commit check mode to only run the C<Whitespace> check:

 [lint "profiles.commit"]
     default = Whitespace

Or set the default profile for the commit check mode to C<Whitespace> and the fictional check, C<Flipdoozler>:

 [lint "profiles.commit"]
     default = Whitespace, Flipdoozler

=back

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
