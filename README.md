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

# ENABLING CHECKS FOR REPOS

To enable as a `pre-commit` hook, copy the `pre-commit` script from the `example/hooks` directory into the `.git/hooks` directory of the repo you want to check.

Once copied, update the path and options to match your path and preferred profile.

To enable as a `commit-msg` hook, copy the `commit-msg` script from the `example/hooks` directory into the `.git/hooks` directory of the repo you want to check.

# KNOWN CAVEATS

Since the default commit check profile runs all commit checks by default, an unchanged default profile will not allow the user to add a commit since they'll get a warning for either indent tabs or indent spaces.  To work around this, create a new profile, or override the default profile, to use the one being used for the project.

    [lint "profiles.commit"]
        default = Whitespace, IndentSpaces

Both the IndentTabs and IndentSpaces commit checks overlap with the MixedIndentTabsSpaces check.  A user may find two warnings given if mixed indent tabs and spaces are found; one for the tab (or space) indent and one for the mixed indent tab (or space).

# COPYRIGHT AND LICENSE

Copyright (c) 2022 Blaine Motsinger under the MIT license.

# AUTHOR

Blaine Motsinger `blaine@renderorange.com`
