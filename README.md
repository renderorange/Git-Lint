# Git-Lint

Pluggable lint framework for git, written in Perl.

## SYNOPSIS

```
git-lint [--check commit] [--check message <message_file>]
         [--profile <name>]
         [--version] [--help]
```

## DESCRIPTION

`git-lint` is a program to lint git commits.

## OPTIONS

### --check

Run either check mode commit or message.

If check type is message, `git-lint` expects the file path of the commit message to check as an unnamed option.

### --profile

Run a specific profile of check modules.

Defaults to the `default` profile.

### --version

Print the version.

### --help

Print the help menu.

## CONFIGURATION

Configuration is done through `git config` files `~/.gitconfig` or `/repo/.git/config`.

Only one profile, `default`, is defined internally. `default` contains all check modules by default.

The `default` profile can be overridden through `git config`.

To set the default profile to only run the `Whitespace` check:

```
[lint "profiles.commit"]
    default = Whitespace
```

Or set the default profile to `Whitespace` and the fictional check, `Flipdoozler`:

```
[lint "profiles.commit"]
    default = Whitespace, Flipdoozler
```

Additional profiles can be added with a new name and list of checks to run.

```
[lint "profiles.commit"]
    default = Whitespace, Flipdoozler
    hardcore = Other, Module, Names
```

The new profile can then be run with `git-lint --profile hardcore`.

## INSTALLATION

To enable as a `pre-commit` hook, create a symlink to the `pre-commit.example` script named `pre-commit` in the `.git/hooks` directory of the repo you want to check.

```
ln -s ~/git/Git-Lint/bin/pre-commit.example pre-commit
```

To automate running other profiles, a new `pre-commit` script can be created and linked to the `pre-commit` hook in the repo you want to check.

```
~/git/Git-Lint/bin $ cat pre-commit.hardcore
#!/bin/bash

perl ~/git/Git-Lint/bin/git-lint --profile hardcore
```

To enable as a `commit-msg` hook, create a symlink to the `commit-msg.example` script named `commit-msg` in the `.git/hooks` directory of the repo you want to check.

```
ln -s ~/git/Git-Lint/bin/commit-msg.example commit-msg
```

## COPYRIGHT AND LICENSE

Copyright (c) 2022 Blaine Motsinger under the MIT license.

## AUTHOR

Blaine Motsinger <blaine@renderorange.com>
