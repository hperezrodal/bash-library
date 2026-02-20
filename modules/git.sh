#!/bin/bash

# Bash Library - Git Operations Module
# Version: 1.0.0
# Description: Provides git repository operations

# Function: lib_git_clone_repo
# Description: Clones a git repository to the specified directory
# Usage: lib_git_clone_repo "git@github.com:user/repo.git" ["/destination/dir"]
# Parameters:
#   $1 - Repository URL (required)
#   $2 - Destination directory (optional, defaults to current directory)
# Returns: 0 on success, 1 on error
lib_git_clone_repo() {
	local repo_url="$1"
	local destination_dir="${2:-.}"

	if [[ -z "$repo_url" ]]; then
		lib_log_error "lib_git_clone_repo: repository URL is required"
		return 1
	fi

	lib_log_info "Cloning repository $repo_url into $destination_dir..."
	git clone "$repo_url" "$destination_dir"
}

# Function: lib_git_pull_latest
# Description: Pulls the latest changes in the current branch
# Usage: lib_git_pull_latest
# Returns: git pull exit code
lib_git_pull_latest() {
	lib_log_info "Pulling the latest changes..."
	git pull
}

# Function: lib_git_current_branch
# Description: Outputs the name of the current git branch
# Usage: lib_git_current_branch
# Returns: 0 on success, outputs branch name to stdout
lib_git_current_branch() {
	git rev-parse --abbrev-ref HEAD
}

# Function: lib_git_is_clean
# Description: Checks if the working directory has no uncommitted changes
# Usage: lib_git_is_clean
# Returns: 0 if clean, 1 if dirty
lib_git_is_clean() {
	if [[ -z $(git status --porcelain) ]]; then
		lib_log_info "Working directory is clean"
		return 0
	else
		lib_log_info "Working directory has uncommitted changes"
		return 1
	fi
}

# Function: lib_git_commit_all
# Description: Stages all changes and commits with the given message
# Usage: lib_git_commit_all "commit message"
# Parameters:
#   $1 - Commit message (required)
# Returns: 0 on success, 1 on error
lib_git_commit_all() {
	local commit_message="$1"

	if [[ -z "$commit_message" ]]; then
		lib_log_error "lib_git_commit_all: commit message is required"
		return 1
	fi

	git add .
	git commit -m "$commit_message"
}

# Function: lib_git_push_branch
# Description: Pushes the current branch to the remote origin
# Usage: lib_git_push_branch
# Returns: git push exit code
lib_git_push_branch() {
	local branch_name
	branch_name=$(lib_git_current_branch)

	lib_log_info "Pushing branch $branch_name to the remote..."
	git push origin "$branch_name"
}

# Function: lib_git_switch_branch
# Description: Switches to the specified branch, creating it if it doesn't exist
# Usage: lib_git_switch_branch "branch-name"
# Parameters:
#   $1 - Branch name (required)
# Returns: 0 on success, 1 on error
lib_git_switch_branch() {
	local branch_name="$1"

	if [[ -z "$branch_name" ]]; then
		lib_log_error "lib_git_switch_branch: branch name is required"
		return 1
	fi

	if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
		lib_log_info "Switching to branch $branch_name..."
		git checkout "$branch_name"
	else
		lib_log_info "Branch $branch_name does not exist. Creating and switching..."
		git checkout -b "$branch_name"
	fi
}

# Function: lib_git_current_commit
# Description: Outputs the short hash of the current commit
# Usage: lib_git_current_commit
# Returns: 0 on success, outputs short commit hash to stdout
lib_git_current_commit() {
	git log -1 --pretty=format:"%h" | tail -n 1
}
