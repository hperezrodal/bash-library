#!/bin/bash

# Bash Library - AWS Module
# Version: 1.0.0
# Description: Provides AWS-related functions for bash scripts

# Function: lib_aws_get_secret
# Description: Retrieves secrets from AWS Secrets Manager
# Usage: lib_aws_get_secret "secret-name"
# Returns: 0 on success, outputs secret JSON to stdout
#          1 on error, outputs error message to stderr
# Environment Variables:
#     AWS_PROFILE (optional) - AWS profile to use
#     AWS_REGION (optional) - AWS region to use
lib_aws_get_secret() {
	local secret_name="$1"
	local aws_profile="${AWS_PROFILE:-}"
	local aws_region="${AWS_REGION:-}"
	local aws_cmd="aws secretsmanager get-secret-value"

	# Add profile if specified
	if [ -n "$aws_profile" ]; then
		aws_cmd="$aws_cmd --profile $aws_profile"
	fi

	# Add region if specified
	if [ -n "$aws_region" ]; then
		aws_cmd="$aws_cmd --region $aws_region"
	fi

	# Get the secret value
	if ! SECRET_JSON=$($aws_cmd \
		--secret-id "$secret_name" \
		--query SecretString \
		--output text 2>&1); then
		lib_log_error "Failed to fetch secret '$secret_name' from AWS Secrets Manager: $SECRET_JSON"
		return 1
	fi

	# Output the secret JSON
	echo "$SECRET_JSON"
	return 0
}

# Function: lib_aws_get_secret_value
# Description: Retrieves a specific value from an AWS Secrets Manager secret
# Usage: lib_aws_get_secret_value "secret-name" "key-name"
# Returns: 0 on success, outputs secret value to stdout
#          1 on error, outputs error message to stderr
lib_aws_get_secret_value() {
	local secret_name="$1"
	local key_name="$2"
	local secret_json

	# Get the secret JSON
	if ! secret_json=$(lib_aws_get_secret "$secret_name"); then
		return 1
	fi

	# Extract the specific value
	if ! value=$(echo "$secret_json" | jq -r ".$key_name"); then
		lib_log_error "Failed to extract value for key '$key_name' from secret JSON"
		return 1
	fi

	echo "$value"
	return 0
}

# Function: lib_aws_check_credentials
# Description: Verifies AWS credentials are properly configured
# Usage: lib_aws_check_credentials
# Returns: 0 if credentials are valid
#          1 if credentials are invalid or not configured
# Environment Variables:
#     AWS_PROFILE (optional) - AWS profile to use
#     AWS_ACCESS_KEY_ID (optional) - AWS access key ID
#     AWS_SECRET_ACCESS_KEY (optional) - AWS secret access key
#     AWS_REGION (optional) - AWS region
lib_aws_check_credentials() {
	local aws_profile="${AWS_PROFILE:-}"
	local aws_cmd="aws sts get-caller-identity"

	# Check if AWS_PROFILE is set
	if [ -n "$aws_profile" ]; then
		aws_cmd="$aws_cmd --profile $aws_profile"
	else
		# Check for required environment variables if AWS_PROFILE is not set
		if [ -z "${AWS_ACCESS_KEY_ID:-}" ] || [ -z "${AWS_SECRET_ACCESS_KEY:-}" ]; then
			lib_log_error "AWS credentials are not properly configured. Either set AWS_PROFILE or AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
			return 1
		fi
	fi

	if ! $aws_cmd >/dev/null 2>&1; then
		lib_log_error "AWS credentials are not properly configured"
		return 1
	fi

	return 0
}

# Function: lib_aws_ec2_start_instance
# Description: Starts an EC2 instance
# Usage: lib_aws_ec2_start_instance "instance-id"
# Returns: 0 on success
#          1 on error, outputs error message to stderr
# Environment Variables:
#     AWS_PROFILE (optional) - AWS profile to use
#     AWS_ACCESS_KEY_ID (optional) - AWS access key ID
#     AWS_SECRET_ACCESS_KEY (optional) - AWS secret access key
#     AWS_REGION (optional) - AWS region to use
lib_aws_ec2_start_instance() {
	local instance_id="$1"
	local aws_profile="${AWS_PROFILE:-}"
	local aws_region="${AWS_REGION:-}"
	local aws_cmd="aws ec2 start-instances"

	# Validate input
	if [ -z "$instance_id" ]; then
		lib_log_error "Instance ID is required"
		return 1
	fi

	# Check credentials first
	if ! lib_aws_check_credentials; then
		return 1
	fi

	# Add profile if specified
	if [ -n "$aws_profile" ]; then
		aws_cmd="$aws_cmd --profile $aws_profile"
	fi

	# Add region if specified
	if [ -n "$aws_region" ]; then
		aws_cmd="$aws_cmd --region $aws_region"
	fi

	# Start the instance
	if ! $aws_cmd --instance-ids "$instance_id" >/dev/null 2>&1; then
		lib_log_error "Failed to start EC2 instance '$instance_id'"
		return 1
	fi

	lib_log_info "Successfully started EC2 instance '$instance_id'"
	return 0
}

# Function: lib_aws_ec2_stop_instance
# Description: Stops an EC2 instance
# Usage: lib_aws_ec2_stop_instance "instance-id"
# Returns: 0 on success
#          1 on error, outputs error message to stderr
# Environment Variables:
#     AWS_PROFILE (optional) - AWS profile to use
#     AWS_ACCESS_KEY_ID (optional) - AWS access key ID
#     AWS_SECRET_ACCESS_KEY (optional) - AWS secret access key
#     AWS_REGION (optional) - AWS region to use
lib_aws_ec2_stop_instance() {
	local instance_id="$1"
	local aws_profile="${AWS_PROFILE:-}"
	local aws_region="${AWS_REGION:-}"
	local aws_cmd="aws ec2 stop-instances"

	# Validate input
	if [ -z "$instance_id" ]; then
		lib_log_error "Instance ID is required"
		return 1
	fi

	# Check credentials first
	if ! lib_aws_check_credentials; then
		return 1
	fi

	# Add profile if specified
	if [ -n "$aws_profile" ]; then
		aws_cmd="$aws_cmd --profile $aws_profile"
	fi

	# Add region if specified
	if [ -n "$aws_region" ]; then
		aws_cmd="$aws_cmd --region $aws_region"
	fi

	# Stop the instance
	if ! $aws_cmd --instance-ids "$instance_id" >/dev/null 2>&1; then
		lib_log_error "Failed to stop EC2 instance '$instance_id'"
		return 1
	fi

	lib_log_info "Successfully stopped EC2 instance '$instance_id'"
	return 0
}

# Function: lib_aws_ec2_get_instance_status
# Description: Gets the current status of an EC2 instance
# Usage: lib_aws_ec2_get_instance_status "instance-id"
# Returns: 0 on success, outputs status to stdout
#          1 on error, outputs error message to stderr
# Environment Variables:
#     AWS_PROFILE (optional) - AWS profile to use
#     AWS_ACCESS_KEY_ID (optional) - AWS access key ID
#     AWS_SECRET_ACCESS_KEY (optional) - AWS secret access key
#     AWS_REGION (optional) - AWS region to use
lib_aws_ec2_get_instance_status() {
	local instance_id="$1"
	local aws_profile="${AWS_PROFILE:-}"
	local aws_region="${AWS_REGION:-}"
	local aws_cmd="aws ec2 describe-instances"

	# Validate input
	if [ -z "$instance_id" ]; then
		lib_log_error "Instance ID is required"
		return 1
	fi

	# Check credentials first
	if ! lib_aws_check_credentials; then
		return 1
	fi

	# Add profile if specified
	if [ -n "$aws_profile" ]; then
		aws_cmd="$aws_cmd --profile $aws_profile"
	fi

	# Add region if specified
	if [ -n "$aws_region" ]; then
		aws_cmd="$aws_cmd --region $aws_region"
	fi

	# Get instance status
	if ! status=$($aws_cmd \
		--instance-ids "$instance_id" \
		--query 'Reservations[0].Instances[0].State.Name' \
		--output text 2>&1); then
		lib_log_error "Failed to get status for EC2 instance '$instance_id': $status"
		return 1
	fi

	# Check if instance exists
	if [ "$status" = "None" ]; then
		lib_log_error "EC2 instance '$instance_id' not found"
		return 1
	fi

	echo "$status"
	return 0
}
