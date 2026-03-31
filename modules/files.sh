#!/bin/bash

# Bash Library - File Operations Module
# Version: 1.1.0
# Description: Provides file and directory copy operations (local and remote)

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

# Function: lib_file_transfer_remote
# Description: Transfers a file to a remote host via rsync over SSH.
#              Provides integrity verification (block-level checksums),
#              resumability (--partial), and progress reporting.
#              On subsequent transfers of the same file, only changed blocks
#              are sent (rsync delta transfer).
# Usage: lib_file_transfer_remote <source> <host> <destination> [--ssh-key <path>] [--ssh-opts <opts>]
# Parameters:
#   $1 - Local file path (required)
#   $2 - Remote host as user@host (required)
#   $3 - Remote destination path (required)
#   --ssh-key  - SSH private key path (optional)
#   --ssh-opts - Additional SSH options (optional, e.g. "-o ConnectTimeout=10")
# Returns: 0 on success, 1 on error
lib_file_transfer_remote() {
	local source="$1"
	local host="$2"
	local destination="$3"
	shift 3

	local ssh_key=""
	local ssh_extra_opts=""

	while [[ $# -gt 0 ]]; do
		case "$1" in
			--ssh-key)
				ssh_key="$2"
				shift 2
				;;
			--ssh-opts)
				ssh_extra_opts="$2"
				shift 2
				;;
			*)
				break
				;;
		esac
	done

	lib_validate_params "lib_file_transfer_remote" \
		"source" "$source" \
		"host" "$host" \
		"destination" "$destination" || return 1

	if [[ ! -f "$source" ]]; then
		lib_log_error "lib_file_transfer_remote: source file not found: $source"
		return 1
	fi

	# Build SSH command for rsync
	local ssh_cmd="ssh -o StrictHostKeyChecking=no"
	if [[ -n "$ssh_key" ]]; then
		ssh_cmd+=" -i ${ssh_key}"
	fi
	if [[ -n "$ssh_extra_opts" ]]; then
		ssh_cmd+=" ${ssh_extra_opts}"
	fi

	local file_size
	file_size=$(du -h "$source" | cut -f1)
	lib_log_info "Transferring ${source} (${file_size}) → ${host}:${destination}"

	if ! rsync --partial --checksum --progress \
		-e "$ssh_cmd" \
		"$source" "${host}:${destination}"; then
		lib_log_error "lib_file_transfer_remote: transfer failed"
		return 1
	fi

	lib_log_success "Transfer complete: ${host}:${destination}"
}

# Function: lib_file_transfer_remote_pull
# Description: Pulls a file from a remote host via rsync over SSH.
#              Same guarantees as lib_file_transfer_remote (integrity, resumability).
# Usage: lib_file_transfer_remote_pull <host> <remote_path> <local_destination> [--ssh-key <path>] [--ssh-opts <opts>]
# Parameters:
#   $1 - Remote host as user@host (required)
#   $2 - Remote file path (required)
#   $3 - Local destination path (required)
#   --ssh-key  - SSH private key path (optional)
#   --ssh-opts - Additional SSH options (optional)
# Returns: 0 on success, 1 on error
lib_file_transfer_remote_pull() {
	local host="$1"
	local remote_path="$2"
	local destination="$3"
	shift 3

	local ssh_key=""
	local ssh_extra_opts=""

	while [[ $# -gt 0 ]]; do
		case "$1" in
			--ssh-key)
				ssh_key="$2"
				shift 2
				;;
			--ssh-opts)
				ssh_extra_opts="$2"
				shift 2
				;;
			*)
				break
				;;
		esac
	done

	lib_validate_params "lib_file_transfer_remote_pull" \
		"host" "$host" \
		"remote_path" "$remote_path" \
		"destination" "$destination" || return 1

	local ssh_cmd="ssh -o StrictHostKeyChecking=no"
	if [[ -n "$ssh_key" ]]; then
		ssh_cmd+=" -i ${ssh_key}"
	fi
	if [[ -n "$ssh_extra_opts" ]]; then
		ssh_cmd+=" ${ssh_extra_opts}"
	fi

	lib_log_info "Pulling ${host}:${remote_path} → ${destination}"

	# Ensure local directory exists
	local dest_dir
	dest_dir=$(dirname "$destination")
	mkdir -p "$dest_dir"

	if ! rsync --partial --checksum --progress \
		-e "$ssh_cmd" \
		"${host}:${remote_path}" "$destination"; then
		lib_log_error "lib_file_transfer_remote_pull: transfer failed"
		return 1
	fi

	lib_log_success "Pull complete: ${destination}"
}
