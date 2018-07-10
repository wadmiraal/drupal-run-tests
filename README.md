Local Drupal Testbot runner
===========================

[![Build Status](https://travis-ci.org/wadmiraal/drupal-run-tests.svg?branch=master)](https://travis-ci.org/wadmiraal/drupal-run-tests)

`drupal-run-tests.sh` allows you to run tests just as you would with Drupal's built-in `scripts/run-tests.sh`, but without having to install a Drupal instance first, or even having to have the Drupal source code at hand at all.

Requirements
------------

* Docker
* Bash (or similar)
* Sudo

Quick example
-------------

    drupal-run-tests.sh --core 7 --class MyTestClass --module /path/to/my/module/ --dependencies /path/to/dependencies

This will start a new instance of [wadmiraal/drupal](https://hub.docker.com/r/wadmiraal/drupal/), mount your module code inside it, and run the tests. Once finished, the container is completely removed, so your system isn't cluttered with old containers. You can specify which version of core you want to use. For example, `7` or `8` will use the latest minor release of that branch, whereas `7.54` or `8.3.1` will run against that specific version.

Why use the CLI to run your tests
---------------------------------

Running Drupal tests using the web UI is slow, much slower than the tests actually run on the system. Running tests via the command line is much faster, because it skips a lot of overhead *and* can run tests in parallel. However, having to maintain a running Drupal system is impractical, especially for local development.

`drupal-run-tests.sh` solves these problems by leveraging Docker and the Drupal development image, `wadmiraal/drupal`. You don't have to worry about managing a local instance, clearing caches and code registries, etc. Just run the script, set an appropriate amount of runners and wait for the results.

Installation
------------

    wget https://raw.githubusercontent.com/wadmiraal/drupal-run-tests/master/drupal-run-tests.sh
    chmod +x drupal-run-tests.sh
    sudo mv drupal-run-tests.sh /usr/local/bin/

Options
-------

### `--module`

By default, `drupal-run-tests.sh` will mount the current directory you are in. So if you are in the root of your module, you don't have to use the `--module` option. Otherwise, point the runner to your module code by providing the full path, like `--module /full/path/to/my/module/`.

### `--dependencies`

If your module depends on other modules, you can mount them as well using the `--dependencies` option. You can only specify a single dependency directory, so if you depend on multiple modules, put them all inside a single directory, and mount that one. For example: `--dependencies /path/to/modules/`.

### `--libraries`

If depending on a specific library, or using the Libraries API module, point this option to the location of your downloaded libraries. This will be mounted inside Drupal 7 as `sites/all/libraries`, and Drupal 8 as `libraries`. For example: `--libraries /path/to/downloaded/libraries/`.

### `--vendor`

*Only for Drupal 7*. If using Composer Manager, you can point this option to the location of your vendor directory. This will be mounted inside Drupal as `sites/all/vendor`. For example: `--vendor /path/to/vendor/`.

### `--composer-install`

**DEPRECATED**

*Only for Drupal 8*. This will install the Composer `drupal-rebuild` extension, and call `composer drupal-rebuild && composer install` prior to running tests.

*Note: this is not the recommended way of installing Composer dependencies in Drupal 8, but is still the easiest way in our particular context.*

### `-c`, `--core`

Specify which version of Drupal core to use. Check [available tags](https://hub.docker.com/r/wadmiraal/drupal/tags/) for wadmiraal/drupal for more information. Defaults to the latest version of Drupal 7.

### `--class`

Which test class to run. Can only give a single class (this is a limitation of Drupal's test script). If using Drupal 8, don't forget this requires the complete namespace, and that you must double-escape backslashes. For example: `--class 'Drupal\\Tests\\node\\Kernel\\Views\\RevisionCreateTimestampTest'`

### `--group`

Run all tests inside a group. For example, `--group Node` will run all tests for the node module.

### `-a`, `--all`

Runs all available tests, Drupal core and module dependencies included.

### `-n`, `--concurrency`

How many runners to use. Defaults to 1.

### `-v`, `--verbose`

Runs in verbose mode, which makes the Drupal test script output individual assertion results, as well as stack traces in case of failures.

### `-l`, `--list`

Will pass `--list` to the Drupal test script, which lists all available tests.

### `-h`, `--help`

Print help.
