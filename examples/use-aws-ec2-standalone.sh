#!/bin/bash

# Example script using aws-ec2.sh as a standalone command
# This script demonstrates how to manage EC2 instances using aws-ec2.sh

# Set AWS credentials (if needed)
export AWS_PROFILE="my-profile"
export AWS_REGION="us-east-1"

# Path to the aws-ec2.sh script
AWS_EC2_SCRIPT="/path/to/bash-library/scripts/aws-ec2.sh"

# Example instance ID (replace with your actual instance ID)
INSTANCE_ID="i-1234567890abcdef0"

# Example 1: Check instance status
echo "Checking instance status..."
if ! STATUS=$("$AWS_EC2_SCRIPT" status "$INSTANCE_ID"); then
	echo "Failed to get instance status"
	exit 1
fi
echo "Instance status: $STATUS"

# Example 2: Start instance if stopped
if [ "$STATUS" = "stopped" ]; then
	echo "Starting instance..."
	if ! "$AWS_EC2_SCRIPT" start "$INSTANCE_ID"; then
		echo "Failed to start instance"
		exit 1
	fi
	echo "Instance started successfully"

	# Wait for instance to be running
	echo "Waiting for instance to be running..."
	sleep 30
	if ! NEW_STATUS=$("$AWS_EC2_SCRIPT" status "$INSTANCE_ID"); then
		echo "Failed to get updated status"
		exit 1
	fi
	echo "New instance status: $NEW_STATUS"
fi

# Example 3: Stop instance if running
if [ "$STATUS" = "running" ]; then
	echo "Stopping instance..."
	if ! "$AWS_EC2_SCRIPT" stop "$INSTANCE_ID"; then
		echo "Failed to stop instance"
		exit 1
	fi
	echo "Instance stopped successfully"
fi

# Example 4: Using in a pipeline with other commands
echo "Using EC2 status in a pipeline..."
if ! "$AWS_EC2_SCRIPT" status "$INSTANCE_ID" | grep -q "running"; then
	echo "Instance is not running, starting it..."
	if ! "$AWS_EC2_SCRIPT" start "$INSTANCE_ID"; then
		echo "Failed to start instance"
		exit 1
	fi
else
	echo "Instance is already running"
fi

# Example 5: Batch operations on multiple instances
INSTANCES=("i-1234567890abcdef0" "i-0987654321fedcba0")

for instance in "${INSTANCES[@]}"; do
	echo "Processing instance: $instance"

	# Check status
	if ! instance_status=$("$AWS_EC2_SCRIPT" status "$instance"); then
		echo "Failed to get status for $instance"
		continue
	fi

	echo "Instance $instance status: $instance_status"

	# Start if stopped
	if [ "$instance_status" = "stopped" ]; then
		echo "Starting $instance..."
		if ! "$AWS_EC2_SCRIPT" start "$instance"; then
			echo "Failed to start $instance"
		else
			echo "Successfully started $instance"
		fi
	fi
done
