#!/bin/bash

# Bash Library - Docker Module
# Version: 1.0.0
# Description: Provides Docker image build and push operations

# Function: lib_docker_build_image
# Description: Builds a Docker image with multiple tags, platforms, and build arguments.
#              Supports BUILD_CONTEXT_BASE environment variable for custom build contexts.
# Usage: lib_docker_build_image "Dockerfile" "image-name" [--platform linux/amd64] [--tag v1.0] [--build-arg KEY=VALUE]
# Parameters:
#   $1 - Dockerfile path (required)
#   $2 - Image name (required)
#   --platform - Target platform (repeatable)
#   --tag      - Image tag (repeatable)
#   --build-arg - Build argument (repeatable)
# Returns: 0 on success, 1 on error
lib_docker_build_image() {
	local dockerfile_path="$1"
	shift
	local image_name="$1"
	shift
	local platforms=()
	local tags=()
	local build_args=()

	while [[ $# -gt 0 ]]; do
		case "$1" in
		--platform)
			platforms+=("$2")
			shift 2
			;;
		--tag)
			tags+=("$2")
			shift 2
			;;
		--build-arg)
			build_args+=("$2")
			shift 2
			;;
		*)
			break
			;;
		esac
	done

	lib_validate_params "lib_docker_build_image" \
		"dockerfile_path" "$dockerfile_path" \
		"image_name" "$image_name" || return 1

	if [[ ! -f "$dockerfile_path" ]]; then
		lib_log_error "lib_docker_build_image: Dockerfile not found at path: $dockerfile_path"
		return 1
	fi

	local -a build_cmd=(docker build -f "$dockerfile_path")

	for arg in "${platforms[@]}"; do
		build_cmd+=(--platform "$arg")
	done

	for arg in "${build_args[@]}"; do
		build_cmd+=(--build-arg "$arg")
	done

	for tag in "${tags[@]}"; do
		build_cmd+=(-t "${image_name}:${tag}")
	done

	if [[ -n "${BUILD_CONTEXT_BASE:-}" ]]; then
		build_cmd+=(--build-context "mytmp=${BUILD_CONTEXT_BASE}")
	fi

	build_cmd+=(.)

	lib_log_info "Building Docker image with tags: ${tags[*]} and build arguments: ${build_args[*]}"
	lib_log_info "${build_cmd[*]}"
	"${build_cmd[@]}"
}

# Function: lib_docker_push_image
# Description: Pushes a Docker image to the configured registry
# Usage: lib_docker_push_image "image:tag"
# Parameters:
#   $1 - Full image reference including tag (required)
# Returns: 0 on success, 1 on error
lib_docker_push_image() {
	local image="$1"

	if [[ -z "$image" ]]; then
		lib_log_error "lib_docker_push_image: image reference is required"
		return 1
	fi

	lib_log_info "Pushing image: $image"
	docker push "$image"
}
