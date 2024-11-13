#!/usr/bin/env bash

#
# Exports all views into markdown files
#

set -euo pipefail
export LC_ALL=en_US.UTF-8

DB="$(pwd)/$1"
TARGET="$(pwd)/$2"

for view in $(\
  duckdb "$DB" -noheader -csv -s "SELECT view_name FROM duckdb_views() WHERE NOT internal"\
); do
  duckdb "$DB" -markdown "FROM $view" > "$TARGET/$view.md"
done
