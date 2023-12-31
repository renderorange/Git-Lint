use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";

use Git::Lint::Test;
use Test::Exception;

my $class = 'Git::Lint::Config';
use_ok( $class );

NO_USER_CONFIG: {
    note( 'no user config' );

    Git::Lint::Test::override(
        package => 'Capture::Tiny',
        name    => 'capture',
        subref  => sub { return ( '', '', 1 ) },
    );

    my $object = bless {}, $class;
    dies_ok( sub { $object->user_config() }, 'dies if no user config is defined' );
    like( $@, qr/configuration setup is required\. see the documentation for instructions\./, 'exception string matches expected' );
}

GIT_CONFIG_ERROR: {
    note( 'git config error' );

    Git::Lint::Test::override(
        package => 'Capture::Tiny',
        name    => 'capture',
        subref  => sub { return ( '', 'git config error', 1 ) },
    );

    my $object = bless {}, $class;
    dies_ok( sub { $object->user_config() }, 'dies if error was returned from git config command' );
    like( $@, qr/git config error/, 'exception string matches expected' );
}

done_testing;
