#!/usr/bin/env bash

#
# Generates some HTML to add to the readme, in case we add new views
#

set -euo pipefail
export LC_ALL=en_US.UTF-8

DB="$(pwd)/$1"

duckdb -list -noheader "$DB" "SELECT '<dt><code>' || view_name || '.csv</code></dt>' || chr(10) ||  '<dd>' || comment || '</dd>' FROM duckdb_views() WHERE NOT internal ORDER BY view_name"
