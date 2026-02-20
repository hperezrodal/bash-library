#!/bin/bash

# Bash Library - Parameter Validation Module
# Version: 1.0.0
# Description: Provides parameter validation for bash functions

# Function: lib_validate_params
# Description: Validates that required parameters are not empty.
#              Accepts paired arguments: name1 value1 name2 value2 ...
# Usage: lib_validate_params "function_name" "Param1" "$param1" "Param2" "$param2"
# Returns: 0 if all params are valid, 1 if any param is empty
lib_validate_params() {
	local function_name="$1"
	shift

	local param_name
	local param_value

	while [[ "$#" -gt 1 ]]; do
		param_name="$1"
		param_value="$2"
		shift 2

		if [[ -z "$param_value" ]]; then
			lib_log_error "$function_name: required parameter '$param_name' is empty"
			return 1
		fi
	done
}
