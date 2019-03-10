#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

make init-drupal -f /usr/local/bin/actions.mk
