#!/usr/bin/env bash

#
# Generates some HTML to add to the readme, in case we add new views
#

set -euo pipefail
export LC_ALL=en_US.UTF-8

DIR="$(dirname "$(realpath "$0")")"
DB="$(pwd)/$1"


tables=()
for csv in "$DIR"/../data/t_*.csv; do
  csv=$(realpath "$csv")
  table=$(basename "$csv" '.csv')
  tables+=("${table#t_}")
done;

echo """
### Static / artisanal maintained data

Those files are manually maintained and contain static information:

<dl>
$(duckdb -list -noheader "$DB"  "SELECT '<dt><code><a href=\"data/t_' || table_name || '.csv\">t_' || table_name || '.csv</a></code></dt>' || chr(10) ||  '<dd>' || comment || '</dd>' FROM duckdb_tables() WHERE table_name IN ($(printf "'%s'," "${tables[@]}")) ORDER BY table_name")
</dl>

### Version and support matrices

Those files are generated via \`export_database.sh\` and contain the following information:

<dl>
$(duckdb -list -noheader "$DB" "SELECT '<dt><code><a href=\"data/' || view_name || '.csv\">' || view_name || '.csv</a></code></dt>' || chr(10) ||  '<dd>' || comment || '</dd>' FROM duckdb_views() WHERE NOT internal ORDER BY view_name")
</dl>
"""
