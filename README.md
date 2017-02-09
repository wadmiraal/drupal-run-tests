Local Drupal Testbot runner
===========================

`drupal-run-tests.sh` allows you to run tests just as you would with Drupal's built-in `scripts/run-tests.sh`, but without having to install a Drupal instance first, or even having to have the Drupal source code at hand at all.

Requirements
------------

* Docker
* Bash
* Sudo

Quick example
-------------

    drupal-run-tests.sh --core 7 --class MyTestClass --module /path/to/my/module/ --dependencies /path/to/dependencies

This will start a new instance of [wadmiraal/drupal](https://hub.docker.com/r/wadmiraal/drupal/), mount your module code inside it, and run the tests. Once finished, the container is completely removed, so your system isn't cluttered with old containers. You can specify which version of core you want to use: `7` or `8` will use the latest minor release of that branch, whereas `7.54` or `8.3.1` will run against that specific version.