#!/usr/bin/env bash

#
# Copies all views as CSV files into a target directory. Existing files will be overwritten.
#

set -euo pipefail
export LC_ALL=en_US.UTF-8

DB="$(pwd)/$1"
TARGET="$(pwd)/$2"

for view in $(\
  duckdb "$DB" -noheader -csv -s "SELECT view_name FROM duckdb_views() WHERE NOT internal"\
); do
  duckdb "$DB" "COPY $view TO '$TARGET/$view.csv'"
done
