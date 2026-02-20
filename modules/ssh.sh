#!/bin/bash

# Bash Library - SSH Module
# Version: 1.0.0
# Description: Provides SSH tunnel management functions

# Function: lib_ssh_tunnel_open
# Description: Opens an SSH tunnel if the local port is not already in use.
#              Runs in background. Uses optional jump proxy.
# Usage: lib_ssh_tunnel_open <local_port> <remote_host> <remote_port> <proxy>
# Parameters:
#   $1 - Local port to bind
#   $2 - Remote host to tunnel to
#   $3 - Remote port on the target host
#   $4 - SSH proxy/jump host
# Returns: 0 on success
lib_ssh_tunnel_open() {
	local local_port="$1"
	local remote_host="$2"
	local remote_port="$3"
	local proxy="$4"
	local listener
	listener=$(lsof -i :"$local_port" 2>/dev/null || true)

	if [[ -z "$listener" ]]; then
		lib_log_info "Tunnel (*) 127.0.0.1:${local_port} --> ${remote_host}:${remote_port} started"
		ssh -v -N -L "${local_port}:${remote_host}:${remote_port}" "$proxy" &
	else
		lib_log_info "Tunnel on port ${local_port} already open"
	fi
}

# Function: lib_ssh_tunnel_close
# Description: Closes an SSH tunnel bound to a specific local port
# Usage: lib_ssh_tunnel_close <port>
# Parameters:
#   $1 - Local port of the tunnel to close
# Returns: 0 on success
lib_ssh_tunnel_close() {
	local port="$1"
	pgrep -f "ssh.*${port}" | xargs kill 2>/dev/null || true
	lib_log_info "Tunnel ($port) stopped"
}

# Function: lib_ssh_tunnels_close
# Description: Closes all SSH tunnels to a specific host by killing matching processes
# Usage: lib_ssh_tunnels_close <host>
# Parameters:
#   $1 - Host identifier (matched against process list)
# Returns: 0 on success
lib_ssh_tunnels_close() {
	local host="$1"
	pkill -f "$host" 2>/dev/null || true
	lib_log_info "Tunnels ($host) stopped"
}
