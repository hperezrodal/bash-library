#!/bin/bash

# Bash Library - Deployment State Module
# Version: 1.0.0
# Description: Records and queries deployment history
# Format: TIMESTAMP|ENV|APP|COMPONENT|COLOR|TAG|COMMIT
# Environment variables:
#   STATE_DIR - Directory for state files (default: $PWD/state)

# Function: lib_state_record_deployment
# Description: Records a deployment entry to the state log file
# Usage: lib_state_record_deployment <env> <app> <component> <color> <tag> <commit>
# Parameters:
#   $1 - Environment (e.g., dev, staging, prod)
#   $2 - Application name
#   $3 - Component name
#   $4 - Deployment color (blue/green/standard)
#   $5 - Image tag
#   $6 - Git commit hash
# Returns: 0 on success
lib_state_record_deployment() {
	local env="$1" app="$2" component="$3" color="$4" tag="$5" commit="$6"
	local state_dir="${STATE_DIR:-${PWD}/state}"
	local state_file="${state_dir}/deployments.log"
	mkdir -p "${state_dir}"

	local timestamp
	timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

	echo "${timestamp}|${env}|${app}|${component}|${color}|${tag}|${commit}" >>"$state_file"
	lib_log_info "State recorded: ${app}/${component}@${tag} -> ${env} (${color})"
}

# Function: lib_state_last_deployment
# Description: Returns the last deployment record for a specific component
# Usage: lib_state_last_deployment <env> <app> <component>
# Parameters:
#   $1 - Environment
#   $2 - Application name
#   $3 - Component name
# Returns: 0 on success, outputs the last matching record to stdout
lib_state_last_deployment() {
	local env="$1" app="$2" component="$3"
	local state_dir="${STATE_DIR:-${PWD}/state}"
	local state_file="${state_dir}/deployments.log"

	if [[ -f "$state_file" ]]; then
		grep "|${env}|${app}|${component}|" "$state_file" | tail -1
	fi
}

# Function: lib_state_list_deployments
# Description: Lists recent deployments for an environment
# Usage: lib_state_list_deployments <env> [count]
# Parameters:
#   $1 - Environment
#   $2 - Number of entries to show (optional, default: 10)
# Returns: 0 on success, outputs matching records to stdout
lib_state_list_deployments() {
	local env="$1"
	local count="${2:-10}"
	local state_dir="${STATE_DIR:-${PWD}/state}"
	local state_file="${state_dir}/deployments.log"

	if [[ -f "$state_file" ]]; then
		grep "|${env}|" "$state_file" | tail -"$count"
	fi
}
