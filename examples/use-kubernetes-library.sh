#!/usr/bin/env bash

# Example script demonstrating the use of Kubernetes library functions
# This script shows how to use both SQL client and pod connection functionality in Kubernetes

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

# Example 1: Interactive SQL session
echo "Starting interactive SQL session..."
if ! lib_k8s_run_sql_client "sql-server" "sa" "password123" "mydb"; then
    echo "Failed to start interactive SQL session"
    exit 1
fi

# Example 2: Execute SQL script
echo "Executing SQL script..."
if ! lib_k8s_run_sql_client "sql-server" "sa" "password123" "mydb" "init-database.sql"; then
    echo "Failed to execute SQL script"
    exit 1
fi

# Example 3: Connect to first pod in backend namespace
echo "Connecting to first pod in backend namespace..."
if ! lib_k8s_connect_to_pod "backend"; then
    echo "Failed to connect to pod in backend namespace"
    exit 1
fi

# Example 4: Connect to specific container in backend namespace
echo "Connecting to nginx container in backend namespace..."
if ! lib_k8s_connect_to_pod "backend" "nginx"; then
    echo "Failed to connect to nginx container"
    exit 1
fi

echo "All operations completed successfully" 