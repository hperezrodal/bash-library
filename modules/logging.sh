#!/bin/bash

# Bash Library - Logging Module
# Version: 1.0.0
# Description: Provides logging functions for bash scripts

# Log levels
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3
export LOG_LEVEL_DEBUG LOG_LEVEL_INFO LOG_LEVEL_WARN LOG_LEVEL_ERROR

# Default log level
LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

# Function: lib_log_header_starting
# Description: Logs the start of a process with a header
# Usage: lib_log_header_starting "Process Name"
# Returns: 0 on success
lib_log_header_starting() {
	if [ $# -ne 1 ]; then
		echo "Error: lib_log_header_starting requires exactly one argument" >&2
		return 1
	fi

	echo "============================================================================"
	echo "$1 starting..."
	echo "============================================================================"
	return 0
}

# Function: lib_log_header_done
# Description: Logs the completion of a process with a header
# Usage: lib_log_header_done "Process Name"
# Returns: 0 on success
lib_log_header_done() {
	if [ $# -ne 1 ]; then
		echo "Error: lib_log_header_done requires exactly one argument" >&2
		return 1
	fi

	echo "============================================================================"
	echo "done. ($1)"
	echo "============================================================================"
	return 0
}

# Function: lib_log_info
# Description: Logs an info message
# Usage: lib_log_info "Message"
# Returns: 0 on success
lib_log_info() {
	if [ $# -ne 1 ]; then
		echo "Error: lib_log_info requires exactly one argument" >&2
		return 1
	fi

	if [ "${LOG_LEVEL}" -le "${LOG_LEVEL_INFO}" ]; then
		echo "[INFO] $1"
	fi
	return 0
}

# Function: lib_log_warn
# Description: Logs a warning message to stderr
# Usage: lib_log_warn "Message"
# Returns: 0 on success
lib_log_warn() {
	if [ $# -ne 1 ]; then
		echo "Error: lib_log_warn requires exactly one argument" >&2
		return 1
	fi

	if [ "${LOG_LEVEL}" -le "${LOG_LEVEL_WARN}" ]; then
		echo "[WARN] $1" >&2
	fi
	return 0
}

# Function: lib_log_error
# Description: Logs an error message to stderr
# Usage: lib_log_error "Message"
# Returns: 0 on success
lib_log_error() {
	if [ $# -ne 1 ]; then
		echo "Error: lib_log_error requires exactly one argument" >&2
		return 1
	fi

	echo "[ERROR] $1" >&2
	return 0
}

# Function: lib_log_success
# Description: Logs a success message
# Usage: lib_log_success "Message"
# Returns: 0 on success
lib_log_success() {
	if [ $# -ne 1 ]; then
		echo "Error: lib_log_success requires exactly one argument" >&2
		return 1
	fi

	echo "[SUCCESS] $1"
	return 0
}
