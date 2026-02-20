#!/bin/bash

# Bash Library - Blue-Green Deployment Module
# Version: 1.0.0
# Description: Provides blue-green deployment functions for Docker + Traefik environments
# Requires: docker (local or remote), Traefik with Docker provider

# Function: lib_bluegreen_detect_active_color
# Description: Detects which color (blue/green) is currently receiving traffic.
#              Looks for a running container with traefik.enable=true and matching deploy.service label.
# Usage: lib_bluegreen_detect_active_color <service_name> [ssh_target]
# Parameters:
#   $1 - Service name (value of deploy.service label)
#   $2 - SSH target for remote detection (optional, local if omitted)
# Returns: 0 on success, outputs "blue" or "green" to stdout (defaults to "blue" on first deployment)
lib_bluegreen_detect_active_color() {
	local service_name="$1"
	local ssh_target="${2:-}"
	local detect_cmd
	detect_cmd="docker ps --filter 'label=traefik.enable=true' --filter 'label=deploy.service=${service_name}' --format '{{.Label \"deploy.color\"}}' | head -1"

	local active_color
	if [[ -n "$ssh_target" ]]; then
		# shellcheck disable=SC2029 # Intentional client-side expansion
		active_color=$(ssh "$ssh_target" "$detect_cmd" 2>/dev/null || true)
	else
		active_color=$(bash -c "$detect_cmd" 2>/dev/null || true)
	fi

	echo "${active_color:-blue}"
}

# Function: lib_bluegreen_inactive_color
# Description: Returns the opposite color (blue↔green)
# Usage: lib_bluegreen_inactive_color <active_color>
# Parameters:
#   $1 - Current active color ("blue" or "green")
# Returns: 0 on success, outputs the opposite color to stdout
lib_bluegreen_inactive_color() {
	local active_color="$1"
	if [[ "$active_color" == "blue" ]]; then
		echo "green"
	else
		echo "blue"
	fi
}

# Function: lib_bluegreen_switch_traffic
# Description: Switches Traefik traffic to the target color by stopping the old color container.
#              The new color container must already be running with traefik.enable=true.
# Usage: lib_bluegreen_switch_traffic <service_name> <target_color> [ssh_target]
# Parameters:
#   $1 - Service name
#   $2 - Target color to switch traffic to
#   $3 - SSH target for remote execution (optional)
# Returns: 0 on success
lib_bluegreen_switch_traffic() {
	local service_name="$1"
	local target_color="$2"
	local ssh_target="${3:-}"
	local old_color
	old_color=$(lib_bluegreen_inactive_color "$target_color")

	local switch_cmd="docker stop ${service_name}_${old_color} 2>/dev/null || true"

	lib_log_info "Switching ${service_name}: ${old_color} -> ${target_color}"

	if [[ -n "$ssh_target" ]]; then
		# shellcheck disable=SC2029 # Intentional client-side expansion
		ssh "$ssh_target" "$switch_cmd"
	else
		bash -c "$switch_cmd"
	fi

	lib_log_success "Traffic now on ${service_name}_${target_color}"
}

# Function: lib_bluegreen_rollback
# Description: Rolls back deployment by starting the previous color and stopping the failed one
# Usage: lib_bluegreen_rollback <service_name> <failed_color> [ssh_target]
# Parameters:
#   $1 - Service name
#   $2 - Color that failed (will be stopped)
#   $3 - SSH target for remote execution (optional)
# Returns: 0 on success
lib_bluegreen_rollback() {
	local service_name="$1"
	local failed_color="$2"
	local ssh_target="${3:-}"
	local rollback_color
	rollback_color=$(lib_bluegreen_inactive_color "$failed_color")

	lib_log_header_starting "ROLLBACK: reverting ${service_name} from ${failed_color} to ${rollback_color}"

	local start_cmd="docker start ${service_name}_${rollback_color} 2>/dev/null || true"
	local stop_cmd="docker stop ${service_name}_${failed_color} 2>/dev/null || true"

	if [[ -n "$ssh_target" ]]; then
		# shellcheck disable=SC2029 # Intentional client-side expansion
		ssh "$ssh_target" "$start_cmd && $stop_cmd"
	else
		bash -c "$start_cmd && $stop_cmd"
	fi

	lib_log_header_done "ROLLBACK: ${service_name} reverted to ${rollback_color}"
}
