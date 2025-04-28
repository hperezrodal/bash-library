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
    echo "${old_password}" > "${old_password_file}"
    echo "${new_password}" > "${new_password_file}"

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