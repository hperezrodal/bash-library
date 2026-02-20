#!/usr/bin/env bash

# ansible.sh - Ansible-related functions
# Version: 1.0.0
# Description: Module for interacting with Ansible

# Function: lib_ansible_vault_decrypt
# Description: Decrypts an Ansible vault file using the provided password
# Usage: lib_ansible_vault_decrypt <vault_file> [vault_password]
# Parameters:
#   vault_file: Path to the vault file to decrypt
#   vault_password: (Optional) Vault password. If not provided, uses ANSIBLE_VAULT_PASSWORD env var
# Returns: 0 on success, 1 on error
# Example: lib_ansible_vault_decrypt "group_vars/all/vault.yml"
# Example with password: lib_ansible_vault_decrypt "group_vars/all/vault.yml" "mysecretpassword"
lib_ansible_vault_decrypt() {
	local vault_file="${1}"
	local vault_password="${2:-${ANSIBLE_VAULT_PASSWORD}}"

	# Validate required parameters
	if [[ -z "${vault_file}" ]]; then
		echo "Error: Missing required parameter: vault_file"
		echo "Usage: lib_ansible_vault_decrypt <vault_file> [vault_password]"
		return 1
	fi

	if [[ -z "${vault_password}" ]]; then
		echo "Error: Vault password not provided and ANSIBLE_VAULT_PASSWORD environment variable is not set"
		return 1
	fi

	# Check if ansible-vault command exists
	if ! command -v ansible-vault >/dev/null 2>&1; then
		echo "Error: ansible-vault command not found"
		return 1
	fi

	# Check if vault file exists
	if [[ ! -f "${vault_file}" ]]; then
		echo "Error: Vault file not found: ${vault_file}"
		return 1
	fi

	# Decrypt the vault file
	ansible-vault decrypt "${vault_file}" --vault-password-file=<(echo "${vault_password}")
	return $?
}

# Function: lib_ansible_vault_encrypt
# Description: Encrypts a file using Ansible vault
# Usage: lib_ansible_vault_encrypt <file> [vault_password]
# Parameters:
#   file: Path to the file to encrypt
#   vault_password: (Optional) Vault password. If not provided, uses ANSIBLE_VAULT_PASSWORD env var
# Returns: 0 on success, 1 on error
# Example: lib_ansible_vault_encrypt "group_vars/all/vault.yml"
# Example with password: lib_ansible_vault_encrypt "group_vars/all/vault.yml" "mysecretpassword"
lib_ansible_vault_encrypt() {
	local file="${1}"
	local vault_password="${2:-${ANSIBLE_VAULT_PASSWORD}}"

	# Validate required parameters
	if [[ -z "${file}" ]]; then
		echo "Error: Missing required parameter: file"
		echo "Usage: lib_ansible_vault_encrypt <file> [vault_password]"
		return 1
	fi

	if [[ -z "${vault_password}" ]]; then
		echo "Error: Vault password not provided and ANSIBLE_VAULT_PASSWORD environment variable is not set"
		return 1
	fi

	# Check if ansible-vault command exists
	if ! command -v ansible-vault >/dev/null 2>&1; then
		echo "Error: ansible-vault command not found"
		return 1
	fi

	# Check if file exists
	if [[ ! -f "${file}" ]]; then
		echo "Error: File not found: ${file}"
		return 1
	fi

	# Encrypt the file
	ansible-vault encrypt "${file}" --vault-password-file=<(echo "${vault_password}")
	return $?
}

# Function: lib_ansible_vault_view
# Description: Views the contents of an encrypted Ansible vault file
# Usage: lib_ansible_vault_view <vault_file> [vault_password]
# Parameters:
#   vault_file: Path to the vault file to view
#   vault_password: (Optional) Vault password. If not provided, uses ANSIBLE_VAULT_PASSWORD env var
# Returns: 0 on success, 1 on error
# Example: lib_ansible_vault_view "group_vars/all/vault.yml"
# Example with password: lib_ansible_vault_view "group_vars/all/vault.yml" "mysecretpassword"
lib_ansible_vault_view() {
	local vault_file="${1}"
	local vault_password="${2:-${ANSIBLE_VAULT_PASSWORD}}"

	# Validate required parameters
	if [[ -z "${vault_file}" ]]; then
		echo "Error: Missing required parameter: vault_file"
		echo "Usage: lib_ansible_vault_view <vault_file> [vault_password]"
		return 1
	fi

	if [[ -z "${vault_password}" ]]; then
		echo "Error: Vault password not provided and ANSIBLE_VAULT_PASSWORD environment variable is not set"
		return 1
	fi

	# Check if ansible-vault command exists
	if ! command -v ansible-vault >/dev/null 2>&1; then
		echo "Error: ansible-vault command not found"
		return 1
	fi

	# Check if vault file exists
	if [[ ! -f "${vault_file}" ]]; then
		echo "Error: Vault file not found: ${vault_file}"
		return 1
	fi

	# View the vault file contents
	ansible-vault view "${vault_file}" --vault-password-file=<(echo "${vault_password}") | cat
	return $?
}

# Function: lib_ansible_vault_edit
# Description: Edits an encrypted Ansible vault file using vim
# Usage: lib_ansible_vault_edit <vault_file> [vault_password]
# Parameters:
#   vault_file: Path to the vault file to edit
#   vault_password: (Optional) Vault password. If not provided, uses ANSIBLE_VAULT_PASSWORD env var
# Returns: 0 on success, 1 on error
# Example: lib_ansible_vault_edit "group_vars/all/vault.yml"
# Example with password: lib_ansible_vault_edit "group_vars/all/vault.yml" "mysecretpassword"
lib_ansible_vault_edit() {
	local vault_file="${1}"
	local vault_password="${2:-${ANSIBLE_VAULT_PASSWORD}}"

	# Validate required parameters
	if [[ -z "${vault_file}" ]]; then
		echo "Error: Missing required parameter: vault_file"
		echo "Usage: lib_ansible_vault_edit <vault_file> [vault_password]"
		return 1
	fi

	if [[ -z "${vault_password}" ]]; then
		echo "Error: Vault password not provided and ANSIBLE_VAULT_PASSWORD environment variable is not set"
		return 1
	fi

	# Check if ansible-vault command exists
	if ! command -v ansible-vault >/dev/null 2>&1; then
		echo "Error: ansible-vault command not found"
		return 1
	fi

	# Check if vault file exists
	if [[ ! -f "${vault_file}" ]]; then
		echo "Error: Vault file not found: ${vault_file}"
		return 1
	fi

	# Set vim as the editor if EDITOR is not set
	if [[ -z "${EDITOR}" ]]; then
		export EDITOR=vim
	fi

	# Edit the vault file
	ansible-vault edit "${vault_file}" --vault-password-file=<(echo "${vault_password}")
	return $?
}

# Function: lib_ansible_vault_change_password
# Description: Changes the password of an encrypted Ansible vault file
# Usage: lib_ansible_vault_change_password <vault_file> <old_password> <new_password>
# Parameters:
#   vault_file: Path to the vault file to change password
#   old_password: Current vault password
#   new_password: New vault password to set
# Returns: 0 on success, 1 on error
# Example: lib_ansible_vault_change_password "group_vars/all/vault.yml" "oldpass" "newpass"
lib_ansible_vault_change_password() {
	local vault_file="${1}"
	local old_password="${2}"
	local new_password="${3}"

	# Validate required parameters
	if [[ -z "${vault_file}" || -z "${old_password}" || -z "${new_password}" ]]; then
		echo "Error: Missing required parameters"
		echo "Usage: lib_ansible_vault_change_password <vault_file> <old_password> <new_password>"
		return 1
	fi

	# Check if ansible-vault command exists
	if ! command -v ansible-vault >/dev/null 2>&1; then
		echo "Error: ansible-vault command not found"
		return 1
	fi

	# Check if vault file exists
	if [[ ! -f "${vault_file}" ]]; then
		echo "Error: Vault file not found: ${vault_file}"
		return 1
	fi

	# Create temporary files for passwords
	local old_password_file
	local new_password_file
	old_password_file=$(mktemp)
	new_password_file=$(mktemp)

	# Write passwords to temporary files
	echo "${old_password}" >"${old_password_file}"
	echo "${new_password}" >"${new_password_file}"

	# Change the vault password
	ansible-vault rekey "${vault_file}" \
		--vault-password-file="${old_password_file}" \
		--new-vault-password-file="${new_password_file}"

	# Store the return code
	local return_code=$?

	# Clean up temporary files
	rm -f "${old_password_file}" "${new_password_file}"

	return ${return_code}
}

# ============================================================================
# Playbook Execution Functions
# ============================================================================

# Function: lib_ansible_check_syntax
# Description: Checks the syntax of an Ansible playbook
# Usage: lib_ansible_check_syntax <playbook_path>
# Parameters:
#   $1 - Full path to the playbook YAML file
# Returns: ansible-playbook exit code
lib_ansible_check_syntax() {
	local playbook="$1"

	if [[ -z "$playbook" ]]; then
		lib_log_error "lib_ansible_check_syntax: playbook path is required"
		return 1
	fi

	lib_log_info "Checking syntax for playbook: $playbook"
	ansible-playbook --syntax-check "$playbook"
}

# Function: lib_ansible_run_playbook
# Description: Runs an Ansible playbook with optional inventory and extra variables
# Usage: lib_ansible_run_playbook <playbook_path> [inventory] [extra_vars]
# Parameters:
#   $1 - Full path to the playbook YAML file
#   $2 - Inventory path (optional, default: ANSIBLE_INVENTORY env var or ./inventory)
#   $3 - Extra variables string (optional)
# Returns: ansible-playbook exit code
lib_ansible_run_playbook() {
	local playbook="$1"
	local inventory="${2:-${ANSIBLE_INVENTORY:-./inventory}}"
	local extra_vars="${3:-}"

	if [[ -z "$playbook" ]]; then
		lib_log_error "lib_ansible_run_playbook: playbook path is required"
		return 1
	fi

	lib_log_info "Running playbook: $playbook"

	if [[ -n "$extra_vars" ]]; then
		ansible-playbook -i "$inventory" "$playbook" --extra-vars "$extra_vars"
	else
		ansible-playbook -i "$inventory" "$playbook"
	fi
}

# Function: lib_ansible_check_hosts
# Description: Pings all hosts in the specified inventory
# Usage: lib_ansible_check_hosts [inventory]
# Parameters:
#   $1 - Inventory path (optional, default: ANSIBLE_INVENTORY env var or ./inventory)
# Returns: ansible exit code
lib_ansible_check_hosts() {
	local inventory="${1:-${ANSIBLE_INVENTORY:-./inventory}}"

	lib_log_info "Checking status of hosts in inventory: $inventory"
	ansible -i "$inventory" all -m ping
}

# Function: lib_ansible_list_roles
# Description: Lists available Ansible roles in the specified directory
# Usage: lib_ansible_list_roles [roles_dir]
# Parameters:
#   $1 - Roles directory (optional, default: ./roles)
# Returns: 0 on success
lib_ansible_list_roles() {
	local roles_dir="${1:-./roles}"

	lib_log_info "Listing Ansible roles in: $roles_dir"
	ls -1 "$roles_dir"
}

# Function: lib_ansible_validate_inventory
# Description: Validates an Ansible inventory by listing its contents
# Usage: lib_ansible_validate_inventory [inventory]
# Parameters:
#   $1 - Inventory path (optional, default: ANSIBLE_INVENTORY env var or ./inventory)
# Returns: ansible-inventory exit code
lib_ansible_validate_inventory() {
	local inventory="${1:-${ANSIBLE_INVENTORY:-./inventory}}"

	lib_log_info "Validating inventory: $inventory"
	ansible-inventory -i "$inventory" --list
}

# Function: lib_ansible_dry_run
# Description: Performs a dry-run (check mode) of an Ansible playbook
# Usage: lib_ansible_dry_run <playbook_path> [inventory]
# Parameters:
#   $1 - Full path to the playbook YAML file
#   $2 - Inventory path (optional, default: ANSIBLE_INVENTORY env var or ./inventory)
# Returns: ansible-playbook exit code
lib_ansible_dry_run() {
	local playbook="$1"
	local inventory="${2:-${ANSIBLE_INVENTORY:-./inventory}}"

	if [[ -z "$playbook" ]]; then
		lib_log_error "lib_ansible_dry_run: playbook path is required"
		return 1
	fi

	lib_log_info "Performing a dry-run for playbook: $playbook"
	ansible-playbook -i "$inventory" "$playbook" --check
}

# Function: lib_ansible_get_facts
# Description: Fetches facts from a specific host using the setup module
# Usage: lib_ansible_get_facts <host> [inventory]
# Parameters:
#   $1 - Host or group name
#   $2 - Inventory path (optional, default: ANSIBLE_INVENTORY env var or ./inventory)
# Returns: ansible exit code
lib_ansible_get_facts() {
	local host="$1"
	local inventory="${2:-${ANSIBLE_INVENTORY:-./inventory}}"

	if [[ -z "$host" ]]; then
		lib_log_error "lib_ansible_get_facts: host is required"
		return 1
	fi

	lib_log_info "Fetching facts for host: $host"
	ansible -i "$inventory" "$host" -m setup
}
