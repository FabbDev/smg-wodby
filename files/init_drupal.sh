#!/usr/bin/env bash
# Overrides https://github.com/wodby/drupal-php/blob/master/7/bin/init_drupal

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

settings_php="${DRUPAL_SITE_DIR}/settings.php"
sites_php="${DRUPAL_ROOT}/sites/sites.php"

mkdir -p "${DRUPAL_SITE_DIR}"
chmod 755 "${DRUPAL_SITE_DIR}" || true

# Include wodby.settings.php and settings.docker.php
if [[ ! -f "${settings_php}" ]]; then
    echo -e "<?php\n\n" > "${settings_php}"
fi

if [[ $( grep -ic "settings.docker.php" "${settings_php}" ) -eq 0 ]]; then
    chmod 644 "${settings_php}"
    cat <<'EOS' >> "$settings_php"

// Added automatically by smg-docker
if (getenv('ENVIRONMENT') === 'docker') {
  require_once getenv('CONF_DIR') . '/wodby.settings.php';
  require_once $app_root . '/' . $site_path . '/settings.docker.php';
}
EOS
fi

# Include wodby.sites.php for Drupal 7 and 8.
if [[ "${DRUPAL_SITE}" != "default" ]]; then
    if [[ "${DRUPAL_VERSION}" == "8" || "${DRUPAL_VERSION}" == "7" ]]; then
        if [[ ! -f "${sites_php}" ]]; then
            echo -e "<?php\n\n" > "${sites_php}"
        fi

        if [[ $( grep -ic "wodby.sites.php" "${sites_php}" ) -eq 0 ]]; then
            echo -e "${disclaimer}" >> "${sites_php}"
            echo -e "include '${CONF_DIR}/wodby.sites.php';" >> "${sites_php}"
        fi
    fi
fi

# Set up symlink for files dir.
files_link "${DRUPAL_SITE_DIR}/files"
