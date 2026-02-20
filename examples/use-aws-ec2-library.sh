#!/bin/bash

# Example script using aws-ec2 functions as a sourced library
# This script demonstrates how to use the AWS EC2 functions directly

# Set AWS credentials (if needed)
#export AWS_PROFILE="my-profile"
export AWS_REGION="us-east-1"

# Source the bash library
LIB_DIR="/path/to/bash-library"

# shellcheck disable=SC1091
source "$LIB_DIR/lib-loader.sh"

# Example instance ID (replace with your actual instance ID)
INSTANCE_ID="i-1234567890abcdef0"

# Example 1: Check instance status
echo "Checking instance status..."
if ! STATUS=$(lib_aws_ec2_get_instance_status "$INSTANCE_ID"); then
	lib_log_error "Failed to get instance status"
	exit 1
fi
lib_log_info "Instance status: $STATUS"

# Example 2: Start instance if stopped
if [ "$STATUS" = "stopped" ]; then
	lib_log_info "Starting instance..."
	if ! lib_aws_ec2_start_instance "$INSTANCE_ID"; then
		lib_log_error "Failed to start instance"
		exit 1
	fi

	# Wait for instance to be running
	lib_log_info "Waiting for instance to be running..."
	sleep 30
	if ! NEW_STATUS=$(lib_aws_ec2_get_instance_status "$INSTANCE_ID"); then
		lib_log_error "Failed to get updated status"
		exit 1
	fi
	lib_log_info "New instance status: $NEW_STATUS"
fi

# Example 3: Stop instance if running
if [ "$STATUS" = "running" ]; then
	lib_log_info "Stopping instance..."
	if ! lib_aws_ec2_stop_instance "$INSTANCE_ID"; then
		lib_log_error "Failed to stop instance"
		exit 1
	fi
fi

# Example 4: Using in a function
function manage_instance() {
	local instance_id="$1"
	local desired_state="$2"

	lib_log_info "Managing instance $instance_id to state: $desired_state"

	# Get current status
	if ! current_status=$(lib_aws_ec2_get_instance_status "$instance_id"); then
		lib_log_error "Failed to get status for instance $instance_id"
		return 1
	fi

	lib_log_info "Current status: $current_status"

	case "$desired_state" in
	"running")
		if [ "$current_status" = "stopped" ]; then
			lib_log_info "Starting instance..."
			if ! lib_aws_ec2_start_instance "$instance_id"; then
				lib_log_error "Failed to start instance"
				return 1
			fi
		elif [ "$current_status" = "running" ]; then
			lib_log_info "Instance is already running"
		else
			lib_log_error "Cannot start instance in state: $current_status"
			return 1
		fi
		;;
	"stopped")
		if [ "$current_status" = "running" ]; then
			lib_log_info "Stopping instance..."
			if ! lib_aws_ec2_stop_instance "$instance_id"; then
				lib_log_error "Failed to stop instance"
				return 1
			fi
		elif [ "$current_status" = "stopped" ]; then
			lib_log_info "Instance is already stopped"
		else
			lib_log_error "Cannot stop instance in state: $current_status"
			return 1
		fi
		;;
	*)
		lib_log_error "Invalid desired state: $desired_state"
		return 1
		;;
	esac

	lib_log_info "Instance management completed successfully"
	return 0
}

# Example 5: Using the function
if ! manage_instance "$INSTANCE_ID" "running"; then
	exit 1
fi

# Example 6: Batch operations on multiple instances
function batch_instance_operation() {
	local operation="$1"
	shift
	local instances=("$@")

	lib_log_info "Performing batch $operation operation on ${#instances[@]} instances"

	for instance in "${instances[@]}"; do
		lib_log_info "Processing instance: $instance"

		case "$operation" in
		"start")
			if ! lib_aws_ec2_start_instance "$instance"; then
				lib_log_error "Failed to start $instance"
				continue
			fi
			;;
		"stop")
			if ! lib_aws_ec2_stop_instance "$instance"; then
				lib_log_error "Failed to stop $instance"
				continue
			fi
			;;
		"status")
			if ! status=$(lib_aws_ec2_get_instance_status "$instance"); then
				lib_log_error "Failed to get status for $instance"
				continue
			fi
			lib_log_info "Instance $instance status: $status"
			;;
		*)
			lib_log_error "Invalid operation: $operation"
			return 1
			;;
		esac
	done

	lib_log_info "Batch operation completed"
	return 0
}

# Example instances
INSTANCES=("i-1234567890abcdef0" "i-0987654321fedcba0")

# Get status of all instances
if ! batch_instance_operation "status" "${INSTANCES[@]}"; then
	exit 1
fi

# Example 7: Error handling with logging
function safe_ec2_operation() {
	local operation="$1"
	local instance_id="$2"

	lib_log_info "Performing $operation on instance: $instance_id"

	case "$operation" in
	"start")
		if ! lib_aws_ec2_start_instance "$instance_id"; then
			lib_log_error "Failed to start instance"
			return 1
		fi
		;;
	"stop")
		if ! lib_aws_ec2_stop_instance "$instance_id"; then
			lib_log_error "Failed to stop instance"
			return 1
		fi
		;;
	"status")
		if ! lib_aws_ec2_get_instance_status "$instance_id"; then
			lib_log_error "Failed to get instance status"
			return 1
		fi
		;;
	*)
		lib_log_error "Invalid operation: $operation"
		return 1
		;;
	esac

	lib_log_info "Operation completed successfully"
	return 0
}

# Use the safe operation function
if ! safe_ec2_operation "status" "$INSTANCE_ID"; then
	exit 1
fi
