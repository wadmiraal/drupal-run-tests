#!/bin/bash

# Run Drupal tests without installing Drupal!
#
# This small utility runs Drupal tests inside a docker container. The Docker
# image used is wadmiraal/drupal, which comes pre-packaged with a fully
# installed Drupal site, and Simpletest pre-installed.

print_help() {
  echo -e "Usage:"
  echo -e "  $0 [-h] [-l] [-v] [-s] [-c <version>] [-n <runners>] [--module <workdir>] [--dependencies <depdir>] [--vendor <vendordir>] [--libraries <libdir>] --class <testclass>"
  echo -e "  $0 [-h] [-l] [-v] [-s] [-c <version>] [-n <runners>] [--module <workdir>] [--dependencies <depdir>] [--vendor <vendordir>] [--libraries <libdir>] --group <groupname>"
  echo -e "  $0 [-h] [-l] [-v] [-s] [-c <version>] [-n <runners>] [--module <workdir>] [--dependencies <depdir>] [--vendor <vendordir>] [--libraries <libdir>] [--composer-install] --all"
  echo -e ""
  echo -e "Options:"
  echo -e " -h, --help\t\tDisplay this help."
  echo -e " -l, --list\t\tList available tests (passes --list to scripts/run-tests.sh)."
  echo -e " -v, --verbose\t\tVerbose output (passes --verbose to scripts/run-tests.sh)."
  echo -e " -s, --sudo\t\tUse sudo to communicate with the docker daemon."
  echo -e " -c, --core\t\tThe version of Drupal core to use (e.g.: 7, 7.52, 8, 8.2.0)."
  echo -e " -n, --concurrency\tNumber of test runners to launch in parallel (passes --concurrency to scripts/run-tests.sh)."
  echo -e " --module\t\tThe working directory where the module code is located. Defaults to the current directory."
  echo -e " --dependencies\t\tIf depending on other modules, this is where to find them."
  echo -e " --vendor\t\tOnly for Drupal 7. If using the Composer Manager module, this is the location of the vendor directory. It will be mounted as sites/all/vendor."
  echo -e " --composer-install\tOnly for Drupal 8. Runs 'composer drupal-rebuild && composer install' before running the tests."
  echo -e " --libraries\t\tMount a libraries directory. It will be mounted as sites/all/libraries for Drupal 7, and libraries for Drupal 8."
  echo -e " --all\t\t\tRun all tests (passes --all to scripts/run-tests.sh)."
  echo -e " --class\t\tThe test class to run (passes --class to scripts/run-tests.sh)."
  echo -e " --group\t\tThe test group to run (passed as an argument to scripts/run-tests.sh)."
  echo -e ""
  echo -e "Example:"
  echo -e "  $0 -v -c 7.52 --module /path/to/module --dependencies /path/to/deps --vendor /path/to/vendor --group Node"
}

# Prepare our arguments and options.
COMMAND_ARGS=''
CORE=7
DOCKER='docker'
MOUNT_OPTIONS=''
WORK_DIR=`pwd`
CAN_RUN=1
PARSED_OPTIONS=$(getopt -n "$0" -o hlvsc:n:a --long "help,list,verbose,sudo,core:,concurrency:,all,module:,dependencies:,vendor:,libraries:,class:,group:,composer-install"  -- "$@")

# Bad arguments, something has gone wrong with the getopt command.
if [ $? -ne 0 ];
then
  print_help
  exit 1
fi

# A little magic, necessary when using getopt.
eval set -- "$PARSED_OPTIONS"

while true; do
  case "$1" in
    -h|--help)
      print_help
      exit
      ;;
    -l|--list)
      CAN_RUN=0
      COMMAND_ARGS="$COMMAND_ARGS --list"
      shift
      # A list command terminates immediately the option parsing, as Drupal's
      # run-tests.sh script will ignore other options anyway.
      break
      ;;
    -c|--core)
      CORE=$2
      shift 2
      ;;
    -s|--sudo)
      DOCKER="sudo $DOCKER"
      shift
      ;;
    -a|--all)
      CAN_RUN=0
      COMMAND_ARGS="$COMMAND_ARGS --all"
      shift
      ;;
    --group)
      CAN_RUN=0
      GROUP=$2
      shift 2
      ;;
    --class)
      CAN_RUN=0
      COMMAND_ARGS="$COMMAND_ARGS --class $2"
      shift 2
      ;;
    -v|--verbose)
      COMMAND_ARGS="$COMMAND_ARGS --verbose"
      shift
      ;;
    --composer-install)
      RUN_COMPOSER_INSTALL=1
      shift
      ;;
    -n|--concurrency)
      COMMAND_ARGS="$COMMAND_ARGS --concurrency $2"
      shift 2
      ;;
    --dependencies)
      MOUNT_OPTIONS="$MOUNT_OPTIONS -v $2:/var/www/sites/all/modules/__dependencies__"
      shift 2
      ;;
    --vendor)
      MOUNT_OPTIONS="$MOUNT_OPTIONS -v $2:/var/www/sites/all/vendor"
      shift 2
      ;;
    --libraries)
      # The location is different based on core version. Handle this later,
      # after we handled the core option.
      MOUNT_LIBRARIES=$2
      shift 2
      ;;
    --module)
      WORK_DIR=$2
      shift 2
      ;;
    --)
      shift
      break
      ;;
  esac
done

# We need at least a group or a class name, or the --all flag.
if (($CAN_RUN > 0)); then
  print_help
  exit 1
fi

# If a group was given, add it as the last argument.
if [[ ! -z $GROUP ]]; then
  COMMAND_ARGS="$COMMAND_ARGS $GROUP"
fi

# Do we have to mount the libraries folder? If so, check the core version, as
# the location is different.
if [[ ! -z $MOUNT_LIBRARIES ]]; then
  if [[ $CORE == 7* ]]; then
    MOUNT_OPTIONS="$MOUNT_OPTIONS -v $MOUNT_LIBRARIES:/var/www/sites/all/libraries"
  else
    MOUNT_OPTIONS="$MOUNT_OPTIONS -v $MOUNT_LIBRARIES:/var/www/libraries"
  fi
fi

# Prepare Docker options and commands.
CONTAINER_NAME="local_wadmiraal_drupal_test_runner_$RANDOM"
if [[ $CORE == 7* ]]; then
  MOUNT_OPTIONS="-v $WORK_DIR:/var/www/sites/all/modules/__to_test__ $MOUNT_OPTIONS"
  TEST_SCRIPT='php /var/www/scripts/run-tests.sh'
else
  MOUNT_OPTIONS="-v $WORK_DIR:/var/www/modules/__to_test__ $MOUNT_OPTIONS"
  TEST_SCRIPT='php /var/www/core/scripts/run-tests.sh'
fi

EXIT_CODE=0
echo "Starting new test runner with Drupal $CORE..."
$DOCKER run -d --name $CONTAINER_NAME $MOUNT_OPTIONS wadmiraal/drupal:$CORE >> /dev/null

RUNNING=$($DOCKER ps | grep $CONTAINER_NAME)
if [[ -z $RUNNING ]]; then
  echo -e "\e[31mCouldn't start a test runner! Aborting.\e[0m"
  EXIT_CODE=1
else
  echo -e "\e[32mStarted test runner.\e[0m"

  # Give services (like MySQL) time to start.
  sleep 3

  # If in context of Drupal 8, we might need to update Composer dependencies.
  # See https://www.drupal.org/node/2405811 for more information.
  if [[ ! -z $RUN_COMPOSER_INSTALL && $CORE == 8* ]]; then
    echo -e "\e[32mUpdating Composer dependencies...\e[0m"
    $DOCKER exec $CONTAINER_NAME bash -c 'drush --root=/var/www/ dl composer_manager'
    $DOCKER exec $CONTAINER_NAME bash -c 'cd /var/www && php modules/composer_manager/scripts/init.php'
    $DOCKER exec $CONTAINER_NAME bash -c 'cd /var/www && composer drupal-rebuild && composer update --prefer-source'
  fi

  # Clear the registry, so we get all tests classes.
  $DOCKER exec $CONTAINER_NAME bash -c 'drush --root=/var/www cc all >> /dev/null 2>&1'
  echo "Cleared the class registry."

  echo "Run tests..."
  $DOCKER exec $CONTAINER_NAME bash -c "$TEST_SCRIPT $COMMAND_ARGS"

  # Assign the exit code based on the test run.
  EXIT_CODE=$?

  echo "Removing test runner..."
  $DOCKER stop $CONTAINER_NAME >> /dev/null
  $DOCKER rm $CONTAINER_NAME >> /dev/null

  if (($EXIT_CODE > 0)); then
    echo -e "\e[31mFinished tests. Some tests failed!\e[0m"
  else
    echo -e "\e[32mFinished tests. All systems green.\e[0m"
  fi
fi

exit $EXIT_CODE


