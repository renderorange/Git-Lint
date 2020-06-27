use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";

use Git::Lint::Test;
use Test::Deep;

my $class = 'Git::Lint::Config';
use_ok( $class );

HAPPY_PATH: {
    note( 'happy path' );

    # default config will contain
    # { profiles => { commit => { default => [ 'One', 'Two' ] } } }
    Git::Lint::Test::override(
        package => 'Module::Loader',
        name    => 'find_modules',
        subref  => sub {
                       return (
                           'Git::Lint::Check::Commit::One',
                           'Git::Lint::Check::Commit::Two',
                       )
        },
    );

    # user config will return nothing to parse
    Git::Lint::Test::override(
        package => 'Git::Lint::Config',
        name    => 'user_config',
        subref  => sub { return {} },
    );

    my $object = $class->new();
    my $expected = { profiles => { commit => { default => [ 'One', 'Two' ] } } };
    bless $expected, 'Git::Lint::Config';
    cmp_deeply( $object, $expected, 'default config contains default' );
}

USER_ADD: {
    note( 'user add' );

    # default config will contain
    # { profiles => { commit => { default => [ 'One', 'Two' ] } } }
    Git::Lint::Test::override(
        package => 'Module::Loader',
        name    => 'find_modules',
        subref  => sub {
                       return (
                           'Git::Lint::Check::Commit::One',
                           'Git::Lint::Check::Commit::Two',
                       )
        },
    );

    # user config will add but not override
    my $expected = { profiles => { commit => { default => [ 'One', 'Two' ], shoe => [ 'Gaze' ] } } };
    my $user_config = { profiles => { commit => { shoe => [ 'Gaze' ] } } };
    Git::Lint::Test::override(
        package => 'Git::Lint::Config',
        name    => 'user_config',
        subref  => sub { return $user_config },
    );

    my $object = $class->new();
    bless $expected, 'Git::Lint::Config';
    cmp_deeply( $object, $expected, 'default config contains default and user adds' );
}

USER_OVERRIDE_AND_ADD: {
    note( 'user override and add' );

    # default config will contain
    # { profiles => { commit => { default => [ 'One', 'Two' ] } } }
    Git::Lint::Test::override(
        package => 'Module::Loader',
        name    => 'find_modules',
        subref  => sub {
                       return (
                           'Git::Lint::Check::Commit::One',
                           'Git::Lint::Check::Commit::Two',
                       )
        },
    );

    # user config will override everything in default
    my $expected = { profiles => { commit => { default => [ 'Three' ], shoe => [ 'Gaze' ] } } };
    Git::Lint::Test::override(
        package => 'Git::Lint::Config',
        name    => 'user_config',
        subref  => sub { return $expected },
    );

    my $object = $class->new();
    bless $expected, 'Git::Lint::Config';
    cmp_deeply( $object, $expected, 'user config overrides default and adds' );
}

done_testing;
