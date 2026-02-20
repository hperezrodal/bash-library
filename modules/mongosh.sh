#!/bin/bash

# Bash Library - MongoDB Module
# Version: 1.0.0
# Description: Provides MongoDB shell client via Docker

# Function: lib_mongosh
# Description: Opens an interactive MongoDB shell session via Docker container.
#              Uses host networking for tunnel compatibility.
# Usage: lib_mongosh <host> <port> <db_name> [username] [password]
# Parameters:
#   $1 - Database host
#   $2 - Database port
#   $3 - Database name
#   $4 - Username (optional)
#   $5 - Password (optional)
# Returns: docker run exit code
lib_mongosh() {
	local db_host="$1"
	local db_port="$2"
	local db_name="$3"
	local db_username="${4:-}"
	local db_password="${5:-}"

	lib_log_info "Connecting to MongoDB: ${db_host}:${db_port}/${db_name}"

	docker run -it --rm \
		--network="host" \
		-e "DB_PASS=$db_password" \
		-e "DB_NAME=$db_name" \
		-e "DB_USER=$db_username" \
		-e "DB_HOST=$db_host" \
		-e "DB_PORT=$db_port" \
		-v "$(pwd):/shared" \
		mongo \
		sh -c "mongosh mongodb://${db_host}:${db_port}/${db_name}"
}
