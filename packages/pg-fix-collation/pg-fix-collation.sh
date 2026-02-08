#!/usr/bin/env bash

set -euox pipefail

echo "Fixing PostgreSQL collation mismatches"

DATABASES=$(
	psql \
		--no-align \
		--tuples-only \
		--command "
      SELECT datname
      FROM pg_database
      WHERE datallowconn
        AND datname NOT IN ('template0');
    "
)

for database in ${DATABASES}; do
	echo "Processing database: ${database}"
	psql --dbname "$database" --command "ALTER DATABASE \"$database\" REFRESH COLLATION VERSION;"
	psql --dbname "$database" --command "REINDEX DATABASE \"$database\";"
done

echo "All databases processed successfully."
