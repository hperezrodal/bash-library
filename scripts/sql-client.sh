#!/usr/bin/env bash

# Source the library
if [ -z "${BASH_LIBRARY_PATH:-}" ]; then
	echo "Error: BASH_LIBRARY_PATH is not set"
	exit 1
fi

if [ ! -f "$BASH_LIBRARY_PATH/lib-loader.sh" ]; then
	echo "Error: Library file not found at $BASH_LIBRARY_PATH/lib-loader.sh"
	exit 1
fi

# shellcheck source=/dev/null
source "$BASH_LIBRARY_PATH/lib-loader.sh"

# Check if kubectl is installed
if ! command -v kubectl &>/dev/null; then
	echo "Error: kubectl is not installed"
	exit 1
fi

# Check if we have the required parameters
if [[ $# -lt 4 ]]; then
	echo "Usage: $0 <host> <user> <password> <database>"
	echo "Example: $0 sql-server sa password123 mydb"
	exit 1
fi

# Run the SQL client
lib_k8s_run_sql_client "$1" "$2" "$3" "$4"
