#!/bin/bash

# Entry point for the Bash library

# Source all the modules from the `modules/` directory
LIB_DIR="$BASH_LIBRARY_PATH/modules"

# Source each module
# shellcheck disable=SC1091
source "$LIB_DIR/logging.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/aws.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/kubernetes.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/ansible.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/eth_rpc.sh"
