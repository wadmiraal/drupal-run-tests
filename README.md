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

By default, `drupal-run-tests.sh` will mount the current directory you are in. So if you are in the root of your module, you don't have to use the `--module` option. Otherwise, point the runner to your module code by providing the full path, like `--module /full/path/to/my/module/`.

If your module depends on other modules, you can mount them as well using the `--dependencies` option. You can only specify a single dependency directory, so if you depend on multiple modules, put them all inside a single directory, and mount that one. For example: `--dependencies /path/to/modules`.
