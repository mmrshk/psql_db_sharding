#!/bin/bash
set -e

# Set PostgreSQL configurations for logical replication
echo "host replication all 0.0.0.0/0 trust" >> ${PGDATA}/pg_hba.conf

# Writing configuration settings to postgresql.conf
cat >> ${PGDATA}/postgresql.conf <<EOF
shared_preload_libraries = 'citus, pg_stat_statements'
listen_addresses = '*'
logging_collector = on
log_directory = '/var/log/postgresql'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_statement = 'all'
log_duration = on
log_min_duration_statement = 0
EOF