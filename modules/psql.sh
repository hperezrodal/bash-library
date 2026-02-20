#!/bin/bash

# Bash Library - PostgreSQL Module
# Version: 1.0.0
# Description: Provides PostgreSQL client operations via Docker

# Function: lib_psql
# Description: Opens an interactive PostgreSQL session via Docker container.
#              Uses host networking for tunnel compatibility.
# Usage: lib_psql <host> <port> <db_name> <username> <password>
# Parameters:
#   $1 - Database host
#   $2 - Database port
#   $3 - Database name
#   $4 - Username
#   $5 - Password
# Returns: docker run exit code
lib_psql() {
	local db_host="$1"
	local db_port="$2"
	local db_name="$3"
	local db_username="$4"
	local db_password="$5"

	lib_log_info "Connecting to PostgreSQL: ${db_host}:${db_port}/${db_name} as ${db_username}"

	docker run -it --rm \
		--network="host" \
		-e "DB_PASSWORD=$db_password" \
		-e "DB_NAME=$db_name" \
		-e "DB_USERNAME=$db_username" \
		-e "DB_HOST=$db_host" \
		-e "DB_PORT=$db_port" \
		-v "$(pwd):/shared" \
		postgres \
		sh -c "PGPASSWORD='${db_password}' psql -h '${db_host}' -p '${db_port}' -d '${db_name}' -U '${db_username}'"
}

# Function: lib_psql_exec
# Description: Executes a SQL query via Docker and writes output to a file in /shared
# Usage: lib_psql_exec <host> <port> <db_name> <username> <password> <sql> <output_file>
# Parameters:
#   $1 - Database host
#   $2 - Database port
#   $3 - Database name
#   $4 - Username
#   $5 - Password
#   $6 - SQL query to execute
#   $7 - Output file name (written to /shared/ inside container, maps to pwd)
# Returns: docker run exit code
lib_psql_exec() {
	local db_host="$1"
	local db_port="$2"
	local db_name="$3"
	local db_username="$4"
	local db_password="$5"
	local sql="$6"
	local output="$7"

	lib_log_info "Executing SQL on ${db_host}:${db_port}/${db_name} -> ${output}"

	docker run -it --rm \
		--network="host" \
		-e "DB_PASS=$db_password" \
		-e "DB_NAME=$db_name" \
		-e "DB_USER=$db_username" \
		-e "DB_HOST=$db_host" \
		-e "DB_PORT=$db_port" \
		-v "$(pwd):/shared" \
		postgres \
		sh -c "PGPASSWORD='${db_password}' psql -h '${db_host}' -p '${db_port}' -d '${db_name}' -U '${db_username}' -c \"$sql\" >> /shared/$output"
}
