#!/bin/bash

# Bash Library - Pipeline Module
# Version: 1.0.0
# Description: Provides CI/CD pipeline orchestration functions for build, setup, and deployment
# Environment variables:
#   DOCKER_REGISTRY, DOCKER_USERNAME, DOCKER_PASSWORD - Docker registry credentials
#   PRIVATE_KEY - SSH private key path for Ansible
#   ANSIBLE_VAULT_PASSWORD_FILE - Path to vault password file
#   BLUEGREEN - Set to "true" to enable blue-green deployment
#   GIT_COMMIT, IMAGE_TAG, BG_TARGET_COLOR - Deployment metadata

# Function: lib_pipeline_build_and_publish
# Description: Clones a repo, builds a Docker image, and pushes it to the registry.
#              Tags with branch.commit and latest.
# Usage: lib_pipeline_build_and_publish <repository> <git_url> <branch> [workdir] <myhome> [artifact]
# Parameters:
#   $1 - Repository name
#   $2 - Git URL
#   $3 - Branch name
#   $4 - Working directory (optional, default: /tmp)
#   $5 - Home directory to copy build context from
#   $6 - Artifact name (optional, defaults to repository name)
# Returns: 0 on success
lib_pipeline_build_and_publish() {
	lib_log_header_starting "$0"

	local repository="$1"
	local git_url="$2"
	local branch="$3"
	local workdir="${4:-/tmp}"
	local myhome="$5"
	local artifact="${6:-$repository}"

	lib_log_info "REPOSITORY=$repository"
	lib_log_info "GIT_URL=$git_url"
	lib_log_info "BRANCH=$branch"
	lib_log_info "WORKDIR=$workdir"
	lib_log_info "MYHOME=$myhome"
	lib_log_info "ARTIFACT=$artifact"

	local now
	now=$(lib_datetime_now)
	lib_log_info "NOW=$now"
	workdir="${workdir}/${repository}-${now}"

	# checkout
	lib_git_clone_repo "$git_url" "$workdir" || { lib_log_error "Failed to clone repository"; return 1; }
	cd "$workdir" || return 1
	lib_git_switch_branch "$branch" || { lib_log_error "Failed to switch to branch $branch"; return 1; }

	# prepare
	lib_copy_recursively "$myhome" "$workdir"

	# build and package
	local image="${DOCKER_REGISTRY}/${artifact}"
	local commit
	commit=$(lib_git_current_commit)
	local tag="${branch}.${commit}"

	lib_log_info "IMAGE=$image"
	lib_log_info "BRANCH=$branch"
	lib_log_info "COMMIT=$commit"
	lib_log_info "TAG=$tag"

	lib_docker_build_image "$PWD/Dockerfile" "$image" \
		--platform "linux/amd64" \
		--tag "$tag" \
		--tag "latest" \
		--build-arg "artifact_version=${tag}"

	if [[ $? -ne 0 ]]; then
		lib_log_error "Docker build failed"
		return 1
	fi

	# docker login
	if [[ -n "${DOCKER_USERNAME:-}" && -n "${DOCKER_PASSWORD:-}" && -n "${DOCKER_REGISTRY:-}" ]]; then
		echo "${DOCKER_PASSWORD}" | docker login "${DOCKER_REGISTRY}" -u "${DOCKER_USERNAME}" --password-stdin
		if [[ $? -ne 0 ]]; then
			lib_log_error "Docker login failed"
			return 1
		fi
	fi

	lib_docker_push_image "${image}:${tag}" || { lib_log_error "Failed to push image ${image}:${tag}"; return 1; }
	lib_docker_push_image "${image}:latest" || { lib_log_error "Failed to push image ${image}:latest"; return 1; }

	lib_log_header_done "$0"
}

# Function: lib_pipeline_setup
# Description: Runs the Ansible setup playbook (ahteslabs.ops.servers) for a host
# Usage: lib_pipeline_setup <env> <host>
# Parameters:
#   $1 - Environment name
#   $2 - Host to setup
# Returns: ansible-playbook exit code
lib_pipeline_setup() {
	lib_log_header_starting "$0"
	local env="$1"
	local host="$2"
	local vault_file="${ANSIBLE_VAULT_PASSWORD_FILE:-./secrets/.vault_pass}"

	ansible-playbook -i "inventories/${env}/hosts.yml" ahteslabs.ops.servers \
		--extra-vars "myhome=${PWD}" \
		--private-key="${PRIVATE_KEY}" \
		--vault-password-file="${vault_file}" \
		--limit "$host"

	if [[ $? -ne 0 ]]; then
		lib_log_error "Ansible setup playbook failed"
		return 1
	fi

	lib_log_header_done "$0"
}

# Function: lib_pipeline_deployment
# Description: Runs the Ansible deployment playbook (ahteslabs.ops.deployment) with optional blue-green support.
#              Records deployment state after completion.
# Usage: lib_pipeline_deployment <env> <app> <component> <host>
# Parameters:
#   $1 - Environment name
#   $2 - Application name
#   $3 - Component name
#   $4 - Host to deploy to
# Returns: ansible-playbook exit code
lib_pipeline_deployment() {
	lib_log_header_starting "$0"
	local env="$1"
	local app="$2"
	local component="$3"
	local host="$4"
	local vault_file="${ANSIBLE_VAULT_PASSWORD_FILE:-./secrets/.vault_pass}"
	local bg="${BLUEGREEN:-false}"

	local extra_vars="app=${app} component=${component} env=${env} myhome=${PWD}"
	if [[ "$bg" == "true" ]]; then
		extra_vars="${extra_vars} bluegreen=true"
		lib_log_info "Blue-green deployment enabled for '${app}-${component}'"
	fi

	lib_log_info "Deploying '${app}-${component}' to '${host}' with env '${env}'..."
	ansible-playbook -i "inventories/${env}/hosts.yml" ahteslabs.ops.deployment \
		--extra-vars "${extra_vars}" \
		--private-key="${PRIVATE_KEY}" \
		--vault-password-file="${vault_file}" \
		--limit "$host"

	if [[ $? -ne 0 ]]; then
		lib_log_error "Ansible deployment playbook failed for '${app}-${component}'"
		return 1
	fi

	lib_log_success "Deployment complete: '${app}-${component}' to '${host}'"

	# Record deployment state
	local commit="${GIT_COMMIT:-unknown}"
	local tag="${IMAGE_TAG:-latest}"
	local color="${BG_TARGET_COLOR:-standard}"
	lib_state_record_deployment "$env" "$app" "$component" "$color" "$tag" "$commit"

	lib_log_header_done "$0"
}
