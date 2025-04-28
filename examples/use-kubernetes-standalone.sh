#!/usr/bin/env bash

# Example script demonstrating standalone use of Kubernetes SQL client
# This script shows how to use the SQL client functionality in Kubernetes

# Function: show_usage
# Description: Display script usage information
show_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --host         SQL Server hostname or service name (required)"
    echo "  -u, --user         SQL Server username (required)"
    echo "  -p, --password     SQL Server password (required)"
    echo "  -d, --database     Target database name (required)"
    echo "  -s, --script       SQL script file to execute (optional)"
    echo "  --help             Show this help message"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--host)
            SQL_HOST="$2"
            shift 2
            ;;
        -u|--user)
            SQL_USER="$2"
            shift 2
            ;;
        -p|--password)
            SQL_PASSWORD="$2"
            shift 2
            ;;
        -d|--database)
            SQL_DATABASE="$2"
            shift 2
            ;;
        -s|--script)
            SQL_SCRIPT="$2"
            shift 2
            ;;
        --help)
            show_usage
            ;;
        *)
            echo "Error: Unknown option: $1"
            show_usage
            ;;
    esac
done

# Validate required parameters
if [[ -z "${SQL_HOST}" || -z "${SQL_USER}" || -z "${SQL_PASSWORD}" || -z "${SQL_DATABASE}" ]]; then
    echo "Error: Missing required parameters"
    show_usage
fi

# Example 1: Interactive SQL session
echo "Starting interactive SQL session..."
if ! ./sql-client.sh "${SQL_HOST}" "${SQL_USER}" "${SQL_PASSWORD}" "${SQL_DATABASE}"; then
    echo "Failed to start interactive SQL session"
    exit 1
fi

# Example 2: Execute SQL script (if provided)
if [[ -n "${SQL_SCRIPT}" ]]; then
    echo "Executing SQL script: ${SQL_SCRIPT}"
    if ! ./sql-client.sh "${SQL_HOST}" "${SQL_USER}" "${SQL_PASSWORD}" "${SQL_DATABASE}" "${SQL_SCRIPT}"; then
        echo "Failed to execute SQL script"
        exit 1
    fi
fi

echo "All operations completed successfully" 