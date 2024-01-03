# NAME

Git::Lint - lint git commits and messages

# SYNOPSIS

    use Git::Lint;

    my $lint = Git::Lint->new();
    $lint->run({ check => 'commit', profile => 'default' });
    $lint->run({ check => 'message', file => 'file_path', profile => 'default' });

    git-lint [--check commit] [--check message <message_file>]
             [--profile <name>]
             [--version] [--help]

# DESCRIPTION

`Git::Lint` is a pluggable framework for linting git commits and messages.

For the commandline interface to `Git::Lint`, see the documentation for [git-lint](https://metacpan.org/pod/git-lint).

For adding check modules, see the documentation for [Git::Lint::Check::Commit](https://metacpan.org/pod/Git%3A%3ALint%3A%3ACheck%3A%3ACommit) and [Git::Lint::Check::Message](https://metacpan.org/pod/Git%3A%3ALint%3A%3ACheck%3A%3AMessage).

# CONSTRUCTOR

- new

    Returns a reference to a new `Git::Lint` object.

# METHODS

- run

    Loads the check modules as defined by `profile`.

    `run` expects the following arguments:

    **profile**

    The name of a defined set of check modules to run.

    **check**

    Either `commit` or `message`.

    **file**

    If `check` is `message`, `file` is required.

- config

    Returns the [Git::Lint::Config](https://metacpan.org/pod/Git%3A%3ALint%3A%3AConfig) object created by `Git::Lint`.

# INSTALLATION

To install `Git::Lint`, download the latest release, then extract.

    tar xzvf Git-Lint-0.008.tar.gz
    cd Git-Lint-0.008

or clone the repo.

    git clone https://github.com/renderorange/Git-Lint.git
    cd Git-Lint

Generate the build and installation tooling.

    perl Makefile.PL

Then build, test, and install.

    make
    make test && make install

`Git::Lint` can also be installed using [cpanm](https://metacpan.org/pod/cpanm).

    cpanm Git::Lint

# CONFIGURATION

Configuration is done through `git config` files (`~/.gitconfig` or `/repo/.git/config`).

Only one profile, `default`, is defined internally. `default` contains all check modules by default.

The `default` profile can be overridden through `git config` files (`~/.gitconfig` or `/repo/.git/config`).

To set the default profile to only run the `Whitespace` commit check:

    [lint "profiles.commit"]
        default = Whitespace

Or set the default profile to `Whitespace` and the fictional commit check, `Flipdoozler`:

    [lint "profiles.commit"]
        default = Whitespace, Flipdoozler

Additional profiles can be added with a new name and list of checks to run.

    [lint "profiles.commit"]
        default = Whitespace, Flipdoozler
        hardcore = Other, Module, Names

Message check profiles can also be defined.

    [lint "profiles.message"]
        # override the default profile to only contain SummaryLength, SummaryEndingPeriod, and BlankLineAfterSummary
        default = SummaryLength, SummaryEndingPeriod, BlankLineAfterSummary
        # create a summary profile with specific modules
        summary = SummaryEndingPeriod, SummaryLength

An example configuration is provided in the `examples` directory of this project.

Configuration is required.  If no configuration exists, an error will be printed to STDERR, but the action allowed to complete.

    blaine@base ~/git/test (master *) $ git add test
    blaine@base ~/git/test (master +) $ git commit
    git-lint: [error] configuration setup is required. see the documentation for instructions.
    [master 894b6d0] test
     1 file changed, 1 insertion(+), 1 deletion(-)
    blaine@base ~/git/test (master) $

# ADDING NEW CHECK MODULES

`git-lint` can be configured to load check modules from a local directory using the `localdir` configuration setting.

To load modules from a local directory, add the lint `config` setting, with `localdir` key and directory location to the git config file.

    [lint "config"]
        localdir = /home/blaine/tmp/git-lint/lib

In this example, we're adding a new commit check, `Flipdoozler`.  Create the local directory and path for the new module.

    $ mkdir -p /home/blaine/tmp/git-lint/lib/Git/Lint/Check/Commit

Then add the new check module.

    $ vi /home/blaine/tmp/git-lint/lib/Git/Lint/Check/Commit/Flipdoozler.pm
    package Git::Lint::Check::Commit::Flipdoozler;
    ...

Update the commit check profile to use the new module.

    [lint "profiles.commit"]
        default = Whitespace, IndentTabs, MixedIndentTabsSpaces, Flipdoozler

`git-lint` will now warn for the check contained in Flipdoozler.

    blaine@base ~/git/test (master +) $ git commit
    git-lint: [commit] test - Flipdoozler (line 18)
    blaine@base ~/git/test (master +) $

# ENABLING CHECKS FOR REPOS

To enable as a `pre-commit` hook, copy the `pre-commit` script from the `example/hooks` directory into the `.git/hooks` directory of the repo you want to check.

Once copied, update the path and options to match your path and preferred profile.

To enable as a `commit-msg` hook, copy the `commit-msg` script from the `example/hooks` directory into the `.git/hooks` directory of the repo you want to check.

# COPYRIGHT AND LICENSE

Copyright (c) 2022 Blaine Motsinger under the MIT license.

# AUTHOR

Blaine Motsinger `blaine@renderorange.com`
