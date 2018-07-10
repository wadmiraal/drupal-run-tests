<?php

/**
 * @file
 * Contains \Drupal\module_d8\Tests\ModuleD8Test.
 */

namespace Drupal\module_d8\Tests;

use Drupal\simpletest\WebTestBase;

/**
 * @group Other
 */
class ModuleD8Test extends WebTestBase {

  public static $modules = array('module_d8');

  public function testIt() {
    $this->assertTrue(module_d8_return_true(), "Module was correctly found and loaded.");
    $this->assertTrue(dep_d8_return_true(), "Dependency was correctly found and loaded.");
    $this->assertTrue(file_exists('libraries/mounted_file.txt'), "Libraries were correctly mounted.");
  }
}
