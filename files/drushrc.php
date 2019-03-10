<?php

/**
 * @file
 * Drush settings.
 */

if (getenv('ENVIRONMENT') === 'docker' && getenv('PROJECT_BASE_URL')) {
  $options['uri'] = 'http://' . getenv('PROJECT_BASE_URL');
}
