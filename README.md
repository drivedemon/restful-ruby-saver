# README

# Setup (Mac)

## Summary

- Prerequisites
- Install rbenv + ruby-build
- Install docker + docker-compose
- Install this repo's Ruby version

## Prerequisites

- [Homebrew](https://brew.sh/)
- [Node.js](https://nodejs.org/en/download/)

## Install rbenv + ruby-build

`rbenv` enables you to switch between different versions of Ruby. There are
several ways to tell it which Ruby to use, but the one we care most about is
that it reads the `.ruby-version` file in the local directory. For more
information see the [rbenv Github page](https://github.com/rbenv/rbenv).

To install on mac:

### (1) Install rbenv.

`$ brew install rbenv`

Note that this also installs `ruby-build`, so you'll be ready to
install other Ruby versions out of the box.

### (2) Set up rbenv in your shell.

`$ rbenv init`

### (3) Close your Terminal window and open a new one so your changes take effect.

### (4) Verify that rbenv is properly set up

Use this
[rbenv-doctor](https://github.com/rbenv/rbenv-installer/blob/master/bin/rbenv-doctor)
script:

```
$ curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash
Checking for `rbenv' in PATH: /usr/local/bin/rbenv
Checking for rbenv shims in PATH: OK
Checking `rbenv install' support: /usr/local/bin/rbenv-install (ruby-build 20170523)
Counting installed Ruby versions: none
  There aren't any Ruby versions installed under `~/.rbenv/versions'.
  You can install Ruby versions like so: rbenv install 2.2.4
Checking RubyGems settings: OK
Auditing installed plugins: OK
```

### (5) Install Ruby Version(s)

That's it! Installing rbenv includes ruby-build, so now you're ready to
[install some other Ruby versions](#installing-ruby-versions) using `rbenv
install`.

## Install docker + docker-compose

We'll use docker to manage our external service dependencies in development,
as well as to build our application for production.

First, [install Docker Desktop on Mac](https://docs.docker.com/docker-for-mac/install/).

Be aware that if you have an old version of Docker Machine installed, Docker
Desktop leaves all your machines alone. See the instructions for an expanded
explanation.

Docker Desktop already includes `docker-compose`, so you're done!

## Install this repo's Ruby version

Check the `.ruby-version` file in this repo (it's `2.7.1` as of this writing).
You should install the correct version of ruby with:

```
$ rbenv install 2.7.1
```

## Summary

- Start service dependencies (`docker-compose up -d`)
- Install Ruby libraries (`bundle install`)
  - The `pg` gem may require you to install PostgreSQL libraries (`brew install postgresql`)
- Install JavaScript libraries (`yarn install`)
- Initialize database (`bundle exec rails db:setup`)
- Start Rails (`bundle exec rails server`)
- Start webpack-dev-server, optional (`bin/webpack-dev-server`)

Because we've installed all gems into a local folder, you'll need to prefix
all related commands with `bundle exec`. You can save some typing by adding
a shell alias to your `.zshrc`:

```
alias be='bundle exec'
```
