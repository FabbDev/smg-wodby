#!/usr/bin/env bash

# See https://stackoverflow.com/a/918931
IFS=':' read -ra cores <<< "$SOLR_CORES"
for core in "${cores[@]}"; do
  precreate-core "$core"
done

exec solr -f
