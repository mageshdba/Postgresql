#!/bin/bash

# PostgreSQL connection details
HOST="127.0.0.1"
HNAME="hostname"
PORT="5665"
PSQL_USER="bkpadmin"
PSQL_PASSWORD="1w%<VO5Jx@L3"

# Report file path
REPORT_FILE="/backup/Reports/report_file.txt"

# Export password to be used by psql command
export PGPASSWORD=$PSQL_PASSWORD

# Execute the query to check replication status and capture the output
RESULT=$(psql -h $HOST --port $PORT -U $PSQL_USER -d postgres -t -c "
SELECT
  pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn() AS synced
" | tr -d '[:space:]')

# Check if replication is synced
if [[ "$RESULT" == "t" ]]; then
  # Replication is good, write to report file
  echo "Replication is good 👍" > $REPORT_FILE
  echo "Replication is synced at $(date)" >> $REPORT_FILE
else
  # Replication is not synced, calculate the delay
  DELAY=$(psql -h $HOST --port $PORT -U $PSQL_USER -d postgres -t -c "
  SELECT EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp()))::int AS replication_delay;
  " | tr -d '[:space:]')

  # Send an email with the delay information
  echo "${HNAME} - PG Replication error: Replication delay is $DELAY seconds" | mail -s "PG Replication error on ${HNAME}" -r "backup@m2pfintech.com" database.engineering@m2pfintech.com

  # Also write the delay to the report file for tracking
  echo "Replication delay is $DELAY seconds as of $(date)" > $REPORT_FILE
fi

# Unset the password after execution for security
unset PGPASSWORD
