#!/bin/bash

set -e

PG_PORT_5432_TCP_ADDR=${PG_PORT_5432_TCP_ADDR:-}
PG_PORT_5432_TCP_PORT=${PG_PORT_5432_TCP_PORT:-}
PG_ENV_POSTGRESQL_USER=${PG_ENV_POSTGRESQL_USER:-}
PG_ENV_POSTGRESQL_PASS=${PG_ENV_POSTGRESQL_PASS:-}
PG_ENV_POSTGRESQL_MAX_CLIENT_CONN=${PG_ENV_POSTGRESQL_MAX_CLIENT_CONN:-}
PG_ENV_POSTGRESQL_DEFAULT_POOL_SIZE=${PG_ENV_POSTGRESQL_DEFAULT_POOL_SIZE:-}
PG_ENV_POSTGRESQL_SERVER_IDLE_TIMEOUT=${PG_ENV_POSTGRESQL_SERVER_IDLE_TIMEOUT:-}
PG_POOL_MODE=${PG_POOL_MODE:-session}
PG_LOG_VERBOSE=${PG_LOG_VERBOSE:-0}
PG_SSL_MODE=${PG_SSL_MODE:-}
PG_SSL_ROOT_CERT=${PG_SSL_ROOT_CERT:-}

rm -rf /tmp/pgbouncer/*

mkdir -p /tmp/pgbouncer/etc
mkdir -p /tmp/pgbouncer/run

if [ ! -f /tmp/pgbouncer/etc/pgbconf.ini ]
then
cat << EOF > /tmp/pgbouncer/etc/pgbconf.ini
[databases]
* = host=${PG_PORT_5432_TCP_ADDR} port=${PG_PORT_5432_TCP_PORT}
[pgbouncer]
logfile = /dev/null
pidfile = /tmp/pgbouncer/run/pgbouncer.pid
;listen_addr = *
listen_addr = 0.0.0.0
listen_port = 6432
unix_socket_dir = /tmp/pgbouncer/run
;auth_type = any
auth_type = trust
auth_file = /tmp/pgbouncer/etc/userlist.txt
pool_mode = ${PG_POOL_MODE}
server_reset_query = DISCARD ALL
max_client_conn = ${PG_ENV_POSTGRESQL_MAX_CLIENT_CONN}
default_pool_size = ${PG_ENV_POSTGRESQL_DEFAULT_POOL_SIZE}
ignore_startup_parameters = extra_float_digits
server_idle_timeout = ${PG_ENV_POSTGRESQL_SERVER_IDLE_TIMEOUT}
verbose = ${PG_LOG_VERBOSE}
log_connections = 0
log_disconnections = 0
EOF
fi

if [ ! -z "${PG_STATUS_USER}" ]
then
    echo "stats_users = ${PG_STATUS_USER}" >> /tmp/pgbouncer/etc/pgbconf.ini
fi

if [ ! -z "${PG_SSL_MODE}" ]
then
    echo "server_tls_sslmode = ${PG_SSL_MODE}" >> /tmp/pgbouncer/etc/pgbconf.ini
fi

if [ ! -z "${PG_SSL_ROOT_CERT}" ]
then
    echo "server_tls_ca_file = ${PG_SSL_ROOT_CERT}" >> /tmp/pgbouncer/etc/pgbconf.ini
fi


if [ ! -s /tmp/pgbouncer/etc/userlist.txt ]
then
        echo '"'"${PG_ENV_POSTGRESQL_USER}"'" "'"${PG_ENV_POSTGRESQL_PASS}"'"'  > /tmp/pgbouncer/etc/userlist.txt
fi

chown -R postgres:postgres /tmp/pgbouncer
#chown root:postgres /var/log/postgresql
#chmod 1775 /var/log/postgresql
chmod 640 /tmp/pgbouncer/etc/userlist.txt

/usr/sbin/pgbouncer -u postgres /tmp/pgbouncer/etc/pgbconf.ini
