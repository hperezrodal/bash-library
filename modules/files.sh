#!/bin/bash

# Bash Library - File Operations Module
# Version: 1.0.0
# Description: Provides file and directory copy operations

# Function: lib_copy_with_patterns
# Description: Copies files matching glob patterns from source to destination.
#              Preserves directory structure relative to source.
# Usage: lib_copy_with_patterns "/src/path" "/dst/path" "*.txt" "*.json"
# Parameters:
#   $1 - Source directory path
#   $2 - Destination directory path
#   $@ - Glob patterns to match
# Returns: 0 on success, 1 on error
lib_copy_with_patterns() {
	local source_path="$1"
	local destination_path="$2"
	shift 2
	local patterns=("$@")

	if [[ -z "$source_path" || -z "$destination_path" ]]; then
		lib_log_error "lib_copy_with_patterns: source and destination paths are required"
		return 1
	fi

	if [[ ! -d "$source_path" ]]; then
		lib_log_error "lib_copy_with_patterns: source path does not exist: $source_path"
		return 1
	fi

	if [[ ! -d "$destination_path" ]]; then
		lib_log_info "Creating destination: $destination_path"
		mkdir -p "$destination_path"
	fi

	for pattern in "${patterns[@]}"; do
		lib_log_info "Copying files matching pattern: $pattern"
		find "$source_path" -type f -name "$pattern" -exec cp --parents {} "$destination_path" \;
	done

	lib_log_info "Copy operation completed"
}

# Function: lib_copy_recursively
# Description: Recursively copies all files and directories from source to destination using rsync
# Usage: lib_copy_recursively "/src/path" "/dst/path"
# Parameters:
#   $1 - Source directory path
#   $2 - Destination directory path
# Returns: 0 on success, 1 on error
lib_copy_recursively() {
	local source_path="$1"
	local destination_path="$2"

	if [[ -z "$source_path" || -z "$destination_path" ]]; then
		lib_log_error "lib_copy_recursively: source and destination paths are required"
		return 1
	fi

	if [[ ! -d "$source_path" ]]; then
		lib_log_error "lib_copy_recursively: source path does not exist: $source_path"
		return 1
	fi

	if [[ ! -d "$destination_path" ]]; then
		lib_log_info "Creating destination: $destination_path"
		mkdir -p "$destination_path"
	fi

	lib_log_info "Copying all files from $source_path to $destination_path"
	rsync -a "$source_path/" "$destination_path/"

	lib_log_info "Copy operation completed"
}
