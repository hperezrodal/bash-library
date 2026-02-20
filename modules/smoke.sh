#!/bin/bash

# Bash Library - Smoke Test Module
# Version: 1.0.0
# Description: Provides HTTP health check functions with retry logic
# Environment variables:
#   SMOKE_TIMEOUT - Default timeout in seconds (default: 30)
#   SMOKE_RETRIES - Default number of retries (default: 6)

# Function: lib_smoke_test
# Description: Tests an HTTP health endpoint with retries. Expects a 2xx response.
# Usage: lib_smoke_test <url> [timeout_seconds] [max_retries]
# Parameters:
#   $1 - URL to test
#   $2 - Timeout in seconds (optional, default: SMOKE_TIMEOUT or 30)
#   $3 - Max retries (optional, default: SMOKE_RETRIES or 6)
# Returns: 0 if healthy (2xx), 1 if all retries failed
lib_smoke_test() {
	local url="$1"
	local timeout="${2:-${SMOKE_TIMEOUT:-30}}"
	local retries="${3:-${SMOKE_RETRIES:-6}}"
	local interval=$((timeout / retries))

	lib_log_info "Smoke test: ${url} (timeout=${timeout}s, retries=${retries}, interval=${interval}s)"

	for i in $(seq 1 "$retries"); do
		local http_code
		http_code=$(curl -s -o /dev/null -w '%{http_code}' --connect-timeout 5 "$url" 2>/dev/null || echo "000")

		if [[ "$http_code" =~ ^2[0-9][0-9]$ ]]; then
			lib_log_success "Attempt ${i}/${retries}: HTTP ${http_code} — PASS"
			return 0
		fi

		lib_log_warn "Attempt ${i}/${retries}: HTTP ${http_code} — waiting ${interval}s..."
		sleep "$interval"
	done

	lib_log_error "SMOKE TEST FAILED: ${url} did not return 2xx after ${timeout}s"
	return 1
}

# Function: lib_smoke_test_remote
# Description: Tests a health endpoint on a remote host via SSH + docker exec
# Usage: lib_smoke_test_remote <ssh_target> <container_name> <port> [health_path] [timeout] [retries]
# Parameters:
#   $1 - SSH target host
#   $2 - Docker container name
#   $3 - Port inside the container
#   $4 - Health endpoint path (optional, default: /health)
#   $5 - Timeout in seconds (optional)
#   $6 - Max retries (optional)
# Returns: 0 if healthy, 1 if all retries failed
lib_smoke_test_remote() {
	local ssh_target="$1"
	local container_name="$2"
	local port="$3"
	local health_path="${4:-/health}"
	local timeout="${5:-${SMOKE_TIMEOUT:-30}}"
	local retries="${6:-${SMOKE_RETRIES:-6}}"
	local interval=$((timeout / retries))

	lib_log_info "Smoke test (remote): ${container_name}:${port}${health_path} via ${ssh_target}"

	for i in $(seq 1 "$retries"); do
		local result
		# shellcheck disable=SC2029 # Intentional client-side expansion
		result=$(ssh "$ssh_target" \
			"docker exec ${container_name} wget -qO- --timeout=5 http://localhost:${port}${health_path} 2>/dev/null && echo OK || echo FAIL" \
			2>/dev/null)

		if [[ "$result" == *"OK"* ]]; then
			lib_log_success "Attempt ${i}/${retries}: PASS"
			return 0
		fi

		lib_log_warn "Attempt ${i}/${retries}: FAIL — waiting ${interval}s..."
		sleep "$interval"
	done

	lib_log_error "SMOKE TEST FAILED: ${container_name} not healthy after ${timeout}s"
	return 1
}

# Function: lib_smoke_test_local
# Description: Tests a health endpoint in a local Docker container via docker exec
# Usage: lib_smoke_test_local <container_name> <port> [health_path] [timeout] [retries]
# Parameters:
#   $1 - Docker container name
#   $2 - Port inside the container
#   $3 - Health endpoint path (optional, default: /health)
#   $4 - Timeout in seconds (optional)
#   $5 - Max retries (optional)
# Returns: 0 if healthy, 1 if all retries failed
lib_smoke_test_local() {
	local container_name="$1"
	local port="$2"
	local health_path="${3:-/health}"
	local timeout="${4:-${SMOKE_TIMEOUT:-30}}"
	local retries="${5:-${SMOKE_RETRIES:-6}}"
	local interval=$((timeout / retries))

	lib_log_info "Smoke test (local): ${container_name}:${port}${health_path}"

	for i in $(seq 1 "$retries"); do
		if docker exec "$container_name" \
			wget -qO- --timeout=5 "http://localhost:${port}${health_path}" 2>/dev/null; then
			lib_log_success "Attempt ${i}/${retries}: PASS"
			return 0
		fi

		lib_log_warn "Attempt ${i}/${retries}: FAIL — waiting ${interval}s..."
		sleep "$interval"
	done

	lib_log_error "SMOKE TEST FAILED: ${container_name} not healthy after ${timeout}s"
	return 1
}
