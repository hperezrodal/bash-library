#!/bin/bash

# Entry point for the Bash library
# Supports both system-wide install (BASH_LIBRARY_PATH) and submodule usage (dirname)

# Path resolution: prefer BASH_LIBRARY_PATH if set, otherwise resolve from script location
LIB_DIR="${BASH_LIBRARY_PATH:+${BASH_LIBRARY_PATH}/modules}"
LIB_DIR="${LIB_DIR:-$(dirname "${BASH_SOURCE[0]}")/modules}"

# Source each module
# shellcheck disable=SC1091
source "$LIB_DIR/datetime.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/logging.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/validate_params.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/files.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/git.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/docker.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/aws.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/kubernetes.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/ansible.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/eth_rpc.sh"
