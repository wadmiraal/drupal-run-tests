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

Installation
------------

    wget https://raw.githubusercontent.com/wadmiraal/drupal-run-tests/master/drupal-run-tests.sh
    chmod +x drupal-run-tests.ch
    sudo mv drupal-run-tests.sh /usr/local/bin/

Usage
-----

### --module

By default, `drupal-run-tests.sh` will mount the current directory you are in. So if you are in the root of your module, you don't have to use the `--module` option. Otherwise, point the runner to your module code by providing the full path, like `--module /full/path/to/my/module/`.

### --dependencies

If your module depends on other modules, you can mount them as well using the `--dependencies` option. You can only specify a single dependency directory, so if you depend on multiple modules, put them all inside a single directory, and mount that one. For example: `--dependencies /path/to/modules/`.

### --libraries

If depending on a specific library, or using the Libraries API module, point this option to the location of your downloaded libraries. For example: `--libraries /path/to/downloaded/libraries/`.

### --vendor

If using Composer Manager, you can point this option to the location of your vendor directory. For example: `--vendor /path/to/vendor/`.

### -c, --core

Specify which version of Drupal core to use. Check [available tags](https://hub.docker.com/r/wadmiraal/drupal/tags/) for wadmiraal/drupal for more information.

### --class

Which test class to run. Can only give a single class (this is a limitation of Drupal's test script).

### --group

Run all tests inside a group. For example, `--group Node` will run all tests for the node module.

### -a, --all

Runs all available tests, Drupal core and module dependencies included.

### -n, --concurrency

How many runners to use. Defaults to 1.

### -v, --verbose

Runs in verbose mode, which makes the Drupal test script output individual assertion results, as well as stack traces in case of failures.

### -l, --list

Will pass `--list` to the Drupal test script, which lists all available tests.

### -h, --help

Print help.