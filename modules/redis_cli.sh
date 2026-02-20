#!/bin/bash

# Bash Library - Redis Module
# Version: 1.0.0
# Description: Provides Redis CLI client via Docker

# Function: lib_redis_cli
# Description: Opens an interactive Redis CLI session via Docker container.
#              Uses host networking for tunnel compatibility.
# Usage: lib_redis_cli <host> <port> [name] [username] [password]
# Parameters:
#   $1 - Redis host
#   $2 - Redis port
#   $3 - Redis database name (optional)
#   $4 - Username (optional)
#   $5 - Password (optional)
# Returns: docker run exit code
lib_redis_cli() {
	local redis_host="$1"
	local redis_port="$2"
	local redis_name="${3:-}"
	local redis_username="${4:-}"
	local redis_password="${5:-}"

	lib_log_info "Connecting to Redis: ${redis_host}:${redis_port}"

	docker run -it --rm \
		--network="host" \
		-e "REDIS_PASSWORD=$redis_password" \
		-e "REDIS_NAME=$redis_name" \
		-e "REDIS_USERNAME=$redis_username" \
		-e "REDIS_HOST=$redis_host" \
		-e "REDIS_PORT=$redis_port" \
		-v "$(pwd):/shared" \
		redis \
		sh -c "redis-cli -u redis://${redis_password}@${redis_host}:${redis_port}"
}
