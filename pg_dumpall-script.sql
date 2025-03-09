


#!/bin/bash

# Set PostgreSQL connection variables
pg_user="db2dba"
pg_password="Smhnn@123"
pg_port="4554"

# Perform pg_dumpall without prompting for password
PGPASSWORD=$pg_password pg_dumpall -U $pg_user -p $pg_port -h 171.2.73.45 > /backup/m2p274/full_backup05022024/backup_all.sql

# Clear the password variable to minimize exposure
unset pg_password

echo "Backup completed successfully."
