#!/usr/bin/env bash

# Example script demonstrating the use of Kubernetes pod connection function
# This script shows how to connect to pods in different namespaces and containers

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

# Example 1: Connect to first pod in backend namespace
echo "Connecting to first pod in backend namespace..."
if ! lib_k8s_connect_to_pod "backend"; then
    echo "Failed to connect to pod in backend namespace"
    exit 1
fi

# Example 2: Connect to specific container in backend namespace
echo "Connecting to nginx container in backend namespace..."
if ! lib_k8s_connect_to_pod "backend" "nginx"; then
    echo "Failed to connect to nginx container"
    exit 1
fi

# Example 3: Connect to first pod in default namespace
echo "Connecting to first pod in default namespace..."
if ! lib_k8s_connect_to_pod "default"; then
    echo "Failed to connect to pod in default namespace"
    exit 1
fi

# Example 4: Connect to specific container in production namespace
echo "Connecting to postgres container in production namespace..."
if ! lib_k8s_connect_to_pod "production" "postgres"; then
    echo "Failed to connect to postgres container"
    exit 1
fi

echo "All connection attempts completed" 