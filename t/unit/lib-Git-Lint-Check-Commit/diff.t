use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";

use Git::Lint::Test;
use Test::Exception;

my $class = 'Git::Lint::Check::Commit';
use_ok( $class );

HAPPY_PATH: {
    note( 'happy path' );

    my $expected = "fake return\n";
    Git::Lint::Test::override_capture_tiny( stdout => $expected );

    my $plugin = $class->new();
    my $return = $plugin->diff();

    # command run cleans up newlines from the end of stdout, so just to
    # document functionality we're doing it here as well.
    chomp $expected;

    ok( ref $return eq 'ARRAY', 'return is an ARRAYREF' );
    is( $return->[0], $expected, 'return matches expected' );
}

GIT_HEAD_COMMAND: {
    note( 'git head command' );

    # this test exercises the specific failure logic to detect failure or success
    # when seeing if the repo is on initial commit.
    # if $exit and $stderr, the command failed.  if $exit and not $stderr, our
    # command was successful and the repo is on initial commit.
    my $error = "fake error\n";
    Git::Lint::Test::override_capture_tiny( stderr => $error, exit => 1 );

    my $plugin = $class->new();
    dies_ok( sub { $plugin->diff() }, 'dies if stderr and exit' );
    is( $@, 'git-lint: ' . $error, 'exception matches expected' );
}

done_testing;
