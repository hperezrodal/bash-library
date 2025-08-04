#!/usr/bin/env bash

# kubernetes.sh - Kubernetes-related functions
# Version: 1.0.0
# Description: Module for interacting with Kubernetes clusters

# Function: lib_k8s_run_sql_client
# Description: Runs a SQL client pod in Kubernetes to interact with a SQL Server database
# Usage: lib_k8s_run_sql_client <host> <user> <password> <database> [script]
# Parameters:
#   host: SQL Server hostname or service name
#   user: SQL Server username
#   password: SQL Server password
#   database: Target database name
#   script: (Optional) SQL script file to execute
# Returns: 0 on success, 1 on error
# Example: lib_k8s_run_sql_client "sql-server" "sa" "password123" "mydb"
# Example with script: lib_k8s_run_sql_client "sql-server" "sa" "password123" "mydb" "script.sql"
lib_k8s_run_sql_client() {
	local host="${1}"
	local user="${2}"
	local password="${3}"
	local database="${4}"
	local script="${5:-}"

	# Validate required parameters
	if [[ -z "${host}" || -z "${user}" || -z "${password}" || -z "${database}" ]]; then
		echo "Error: Missing required parameters"
		echo "Usage: lib_k8s_run_sql_client <host> <user> <password> <database> [script]"
		return 1
	fi

	# Base command
	local cmd="/opt/mssql-tools/bin/sqlcmd -S \$HOST -U \$USER -d \$DB"

	# If script is provided, add it to the command
	if [[ -n "${script}" ]]; then
		cmd="${cmd} -i \$SCRIPT"
	fi

	# Run the SQL client pod
	local pod_name="sql-client-$(date +%Y%m%d%H%M%S)"
	kubectl run "${pod_name}" --rm -i -t \
		--image=mcr.microsoft.com/mssql-tools:latest \
		--restart=Never \
		--env="HOST=${host}" \
		--env="USER=${user}" \
		--env="SQLCMDPASSWORD=${password}" \
		--env="DB=${database}" \
		${script:+--env="SCRIPT=${script}"} \
		-- bash -c "${cmd}"
}

# Function: lib_k8s_connect_to_pod
# Description: Connects to a pod in a Kubernetes namespace, with optional container name
# Usage: lib_k8s_connect_to_pod <namespace> [container_name]
# Parameters:
#   namespace: Kubernetes namespace where the pod is located
#   container_name: (Optional) Name of the container to connect to within the pod
# Returns: 0 on success, 1 on error
# Examples:
#   # Connect to the first pod in the backend namespace
#   lib_k8s_connect_to_pod backend
#
#   # Connect to a specific container in the first pod
#   lib_k8s_connect_to_pod backend nginx
#
#   # Connect to a pod in the default namespace
#   lib_k8s_connect_to_pod default
#
#   # Connect to a specific container in the default namespace
#   lib_k8s_connect_to_pod default redis
#
#   # Connect to a pod in a custom namespace
#   lib_k8s_connect_to_pod production
#
#   # Connect to a specific container in a custom namespace
#   lib_k8s_connect_to_pod production postgres
lib_k8s_connect_to_pod() {
	local namespace="${1}"
	local container_name="${2:-}"

	# Validate required parameters
	if [[ -z "${namespace}" ]]; then
		echo "Error: Namespace is required"
		echo "Usage: lib_k8s_connect_to_pod <namespace> [container_name]"
		return 1
	fi

	# Get the first pod name in the namespace
	local pod_name
	pod_name=$(kubectl get pods -n "${namespace}" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

	if [[ -z "${pod_name}" ]]; then
		echo "Error: No pods found in namespace ${namespace}"
		return 1
	fi

	# Build the kubectl exec command
	local cmd="kubectl exec -it -n ${namespace} ${pod_name}"

	# Add container name if provided
	if [[ -n "${container_name}" ]]; then
		cmd="${cmd} -c ${container_name}"
	fi

	# Add shell command
	cmd="${cmd} -- sh"

	# Execute the command
	eval "${cmd}"
}

# Function: lib_k8s_view_pod_logs
# Description: Views logs for pods matching specified criteria
# Usage: lib_k8s_view_pod_logs <namespace> [label_selector] [container_name]
# Parameters:
#   namespace: Kubernetes namespace where the pods are located
#   label_selector: (Optional) Label selector to filter pods (e.g., "app=backend")
#   container_name: (Optional) Name of the container to get logs from
# Returns: 0 on success, 1 on error
# Examples:
#   # View logs for all pods in backend namespace
#   lib_k8s_view_pod_logs backend
#
#   # View logs for pods with label app=backend in backend namespace
#   lib_k8s_view_pod_logs backend "app=backend"
#
#   # View logs for specific container in pods with label app=backend
#   lib_k8s_view_pod_logs backend "app=backend" "nginx"
#
#   # View logs for pods in default namespace
#   lib_k8s_view_pod_logs default
#
#   # View logs for pods with multiple labels
#   lib_k8s_view_pod_logs production "app=api,env=prod"
lib_k8s_view_pod_logs() {
	local namespace="${1}"
	local label_selector="${2:-}"
	local container_name="${3:-}"

	# Validate required parameters
	if [[ -z "${namespace}" ]]; then
		echo "Error: Namespace is required"
		echo "Usage: lib_k8s_view_pod_logs <namespace> [label_selector] [container_name]"
		return 1
	fi

	# Build the kubectl logs command
	local cmd="kubectl logs -f -n ${namespace}"

	# Add label selector if provided
	if [[ -n "${label_selector}" ]]; then
		cmd="${cmd} -l ${label_selector}"
	fi

	# Add container name if provided
	if [[ -n "${container_name}" ]]; then
		cmd="${cmd} -c ${container_name}"
	fi

	# Execute the command
	eval "${cmd}"
}

# Function: lib_k8s_rollout_restart
# Description: Restarts a deployment in a specified namespace
# Usage: lib_k8s_rollout_restart <namespace> <deployment_name>
# Parameters:
#   namespace: Kubernetes namespace where the deployment is located
#   deployment_name: Name of the deployment to restart
# Returns: 0 on success, 1 on error
# Examples:
#   # Restart deployment in argocd namespace
#   lib_k8s_rollout_restart argocd argocd-server
#
#   # Restart deployment in backend namespace
#   lib_k8s_rollout_restart backend api
#
#   # Restart deployment in default namespace
#   lib_k8s_rollout_restart default nginx
lib_k8s_rollout_restart() {
	local namespace="${1}"
	local deployment_name="${2}"

	# Validate required parameters
	if [[ -z "${namespace}" || -z "${deployment_name}" ]]; then
		echo "Error: Namespace and deployment name are required"
		echo "Usage: lib_k8s_rollout_restart <namespace> <deployment_name>"
		return 1
	fi

	# Check if deployment exists
	if ! kubectl get deployment "${deployment_name}" -n "${namespace}" >/dev/null 2>&1; then
		echo "Error: Deployment ${deployment_name} not found in namespace ${namespace}"
		return 1
	fi

	# Execute the rollout restart command
	echo "Restarting deployment ${deployment_name} in namespace ${namespace}..."
	if ! kubectl rollout restart deployment "${deployment_name}" -n "${namespace}"; then
		echo "Error: Failed to restart deployment ${deployment_name}"
		return 1
	fi

	# Wait for rollout to complete
	echo "Waiting for rollout to complete..."
	if ! kubectl rollout status deployment "${deployment_name}" -n "${namespace}"; then
		echo "Error: Rollout failed for deployment ${deployment_name}"
		return 1
	fi

	echo "Deployment ${deployment_name} successfully restarted"
}

# Function: lib_k8s_describe_deployment
# Description: Gets detailed information about a deployment
# Usage: lib_k8s_describe_deployment <namespace> <deployment_name>
# Parameters:
#   namespace: Kubernetes namespace where the deployment is located
#   deployment_name: Name of the deployment to describe
# Returns: 0 on success, 1 on error
# Examples:
#   # Get details of deployment in data-capture namespace
#   lib_k8s_describe_deployment data-capture data-capture
#
#   # Get details of deployment in backend namespace
#   lib_k8s_describe_deployment backend api
#
#   # Get details of deployment in default namespace
#   lib_k8s_describe_deployment default nginx
lib_k8s_describe_deployment() {
	local namespace="${1}"
	local deployment_name="${2}"

	# Validate required parameters
	if [[ -z "${namespace}" || -z "${deployment_name}" ]]; then
		echo "Error: Namespace and deployment name are required"
		echo "Usage: lib_k8s_describe_deployment <namespace> <deployment_name>"
		return 1
	fi

	# Check if deployment exists
	if ! kubectl get deployment "${deployment_name}" -n "${namespace}" >/dev/null 2>&1; then
		echo "Error: Deployment ${deployment_name} not found in namespace ${namespace}"
		return 1
	fi

	# Execute the describe command
	echo "Getting details for deployment ${deployment_name} in namespace ${namespace}..."
	if ! kubectl describe deployment "${deployment_name}" -n "${namespace}"; then
		echo "Error: Failed to get details for deployment ${deployment_name}"
		return 1
	fi
}

# Function: lib_k8s_connect_to_postgres
# Description: Runs a PostgreSQL client pod in Kubernetes to interact with a PostgreSQL database
# Usage: lib_k8s_connect_to_postgres <host> <user> <password> <database> [port]
# Parameters:
#   host: PostgreSQL server hostname or service name
#   user: PostgreSQL username
#   password: PostgreSQL password
#   database: Target database name
#   port: (Optional) PostgreSQL server port (default: 5432)
# Returns: 0 on success, 1 on error
# Example: lib_k8s_connect_to_postgres "postgres-db" "user" "password123" "mydb"
# Example with port: lib_k8s_connect_to_postgres "postgres-db" "user" "password123" "mydb" 5433
lib_k8s_connect_to_postgres() {
	local host="${1}"
	local user="${2}"
	local password="${3}"
	local database="${4}"
	local port="${5:-5432}"

	# Validate required parameters
	if [[ -z "${host}" || -z "${user}" || -z "${password}" || -z "${database}" ]]; then
		echo "Error: Missing required parameters"
		echo "Usage: lib_k8s_connect_to_postgres <host> <user> <password> <database> [port]"
		return 1
	fi

	# Command to run psql
	local cmd="psql postgresql://\${PGUSER}:\${PGPASSWORD}@\${PGHOST}:\${PGPORT}/\${PGDATABASE}"

	# Run the PostgreSQL client pod
	local pod_name="postgres-client-$(date +%Y%m%d%H%M%S)"
	kubectl run "${pod_name}" --rm -i -t \
		--image=postgres:latest \
		--restart=Never \
		--env="PGHOST=${host}" \
		--env="PGUSER=${user}" \
		--env="PGPASSWORD=${password}" \
		--env="PGDATABASE=${database}" \
		--env="PGPORT=${port}" \
		-- bash -c "${cmd}"
}
