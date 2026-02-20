#!/bin/bash

# Bash Library - Datetime Module
# Version: 1.0.0
# Description: Provides timestamp utilities for bash scripts

# Function: lib_datetime_now
# Description: Returns a formatted timestamp (YYYY-MM-DD-HH.MM.SS)
# Usage: lib_datetime_now
# Returns: 0 on success, outputs formatted timestamp to stdout
lib_datetime_now() {
	date +%Y-%m-%d-%H.%M.%S
}
