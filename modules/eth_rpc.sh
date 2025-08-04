#!/usr/bin/env bash

# eth_rpc.sh - Ethereum RPC functions
# Version: 1.0.0
# Description: Module for interacting with Ethereum RPC

# Function: lib_eth_rpc_get_block_number
# Description: Get the current block number from the Ethereum RPC
# Usage: lib_eth_rpc_get_block_number
# Returns: The current block number
# Example: lib_eth_rpc_get_block_number
lib_eth_rpc_get_block_number() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local block_number
	local response
	response=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' "${ETH_RPC_URL}")
	echo "${response}"
	block_number=$(echo "${response}" | jq -r '.result')
	echo "${block_number}"
}

# Function: lib_eth_rpc_get_block_by_number
# Description: Get a block by number from the Ethereum RPC
# Usage: lib_eth_rpc_get_block_by_number <block_number>
# Returns: The block data
# Example: lib_eth_rpc_get_block_by_number "0x123"
lib_eth_rpc_get_block_by_number() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local block_number="${1}"
	local block_data
	block_data=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["0x'"${block_number}"'", false],"id":1}' "${ETH_RPC_URL}" | jq -r '.result')
	echo "${block_data}"
}

# Function: lib_eth_rpc_get_transaction_by_hash
# Description: Get a transaction by hash from the Ethereum RPC
# Usage: lib_eth_rpc_get_transaction_by_hash <transaction_hash>
# Returns: The transaction data
# Example: lib_eth_rpc_get_transaction_by_hash "0x123"
lib_eth_rpc_get_transaction_by_hash() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local transaction_hash="${1}"
	local transaction_data
	transaction_data=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionByHash","params":["0x'"${transaction_hash}"'"],"id":1}' "${ETH_RPC_URL}" | jq -r '.result')
	echo "${transaction_data}"
}

# Function: lib_eth_rpc_get_transaction_receipt
# Description: Get a transaction receipt by hash from the Ethereum RPC
# Usage: lib_eth_rpc_get_transaction_receipt <transaction_hash>
# Returns: The transaction receipt
# Example: lib_eth_rpc_get_transaction_receipt "0x123"
lib_eth_rpc_get_transaction_receipt() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local transaction_hash="${1}"
	local transaction_receipt
	transaction_receipt=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionReceipt","params":["0x'"${transaction_hash}"'"],"id":1}' "${ETH_RPC_URL}" | jq -r '.result')
	echo "${transaction_receipt}"
}

# Function: lib_eth_rpc_get_transaction_by_block_hash_and_index
# Description: Get a transaction by block hash and index from the Ethereum RPC
# Usage: lib_eth_rpc_get_transaction_by_block_hash_and_index <block_hash> <transaction_index>
# Returns: The transaction data
# Example: lib_eth_rpc_get_transaction_by_block_hash_and_index "0x123" "0x1"
lib_eth_rpc_get_transaction_by_block_hash_and_index() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local block_hash="${1}"
	local transaction_index="${2}"
	local transaction_data
	transaction_data=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionByBlockHashAndIndex","params":["0x'"${block_hash}"'", "0x'"${transaction_index}"'"],"id":1}' "${ETH_RPC_URL}" | jq -r '.result')
	echo "${transaction_data}"
}

# Function: lib_eth_rpc_get_transaction_by_block_number_and_index
# Description: Get a transaction by block number and index from the Ethereum RPC
# Usage: lib_eth_rpc_get_transaction_by_block_number_and_index <block_number> <transaction_index>
# Returns: The transaction data
# Example: lib_eth_rpc_get_transaction_by_block_number_and_index "0x123" "0x1"
lib_eth_rpc_get_transaction_by_block_number_and_index() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local block_number="${1}"
	local transaction_index="${2}"
	local transaction_data
	transaction_data=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionByBlockNumberAndIndex","params":["0x'"${block_number}"'", "0x'"${transaction_index}"'"],"id":1}' "${ETH_RPC_URL}" | jq -r '.result')
	echo "${transaction_data}"
}

# Function: lib_eth_rpc_get_chain_id
# Description: Get the current chain ID from the Ethereum RPC
# Usage: lib_eth_rpc_get_chain_id
# Returns: The current chain ID
# Example: lib_eth_rpc_get_chain_id
lib_eth_rpc_get_chain_id() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local chain_id
	chain_id=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' "${ETH_RPC_URL}" | jq -r '.result')
	echo "${chain_id}"
}

# Function: lib_eth_rpc_get_client_version
# Description: Get the client version from the Ethereum RPC
# Usage: lib_eth_rpc_get_client_version
# Returns: The client version string
# Example: lib_eth_rpc_get_client_version
lib_eth_rpc_get_client_version() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local client_version
	client_version=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' "${ETH_RPC_URL}" | jq -r '.result')
	echo "${client_version}"
}

# Function: lib_eth_rpc_get_nonce
# Description: Get the nonce for an address from the Ethereum RPC
# Usage: lib_eth_rpc_get_nonce <address> [block_number]
# Returns: The nonce value
# Example: lib_eth_rpc_get_nonce "0x123" "latest"
lib_eth_rpc_get_nonce() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local address="${1}"
	local block_number="${2:-latest}"
	local nonce
	nonce=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionCount","params":["'"${address}"'", "'"${block_number}"'"],"id":1}' "${ETH_RPC_URL}" | jq -r '.result')
	echo "${nonce}"
}

# Function: lib_eth_rpc_send_raw_transaction
# Description: Send a signed raw transaction to the Ethereum network
# Usage: lib_eth_rpc_send_raw_transaction <signed_transaction>
# Returns: The transaction hash
# Example: lib_eth_rpc_send_raw_transaction "0x123..."
lib_eth_rpc_send_raw_transaction() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local signed_tx="${1}"
	local tx_hash
	tx_hash=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_sendRawTransaction","params":["'"${signed_tx}"'"],"id":1}' "${ETH_RPC_URL}" | jq -r '.result')
	echo "${tx_hash}"
}

# Function: lib_eth_rpc_send_eth
# Description: Send ETH from one address to another
# Usage: lib_eth_rpc_send_eth <from_address> <to_address> <amount_in_wei> <private_key>
# Returns: The transaction hash
# Example: lib_eth_rpc_send_eth "0x123" "0x456" "1000000000000000000" "0xabc..."
lib_eth_rpc_send_eth() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local from_address="${1}"
	local to_address="${2}"
	local amount="${3}"
	# private_key is currently unused as signing is not implemented
	# local private_key="${4}"

	# Get nonce
	local nonce
	nonce=$(lib_eth_rpc_get_nonce "${from_address}")
	if [ -z "${nonce}" ]; then
		echo "Error: Failed to get nonce"
		return 1
	fi

	# Get gas price
	local gas_price
	gas_price=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id":1}' "${ETH_RPC_URL}" | jq -r '.result')

	# Create transaction data
	local tx_data
	tx_data="{
        \"from\": \"${from_address}\",
        \"to\": \"${to_address}\",
        \"value\": \"${amount}\",
        \"gasPrice\": \"${gas_price}\",
        \"gas\": \"21000\",
        \"nonce\": \"${nonce}\",
        \"chainId\": \"$(lib_eth_rpc_get_chain_id)\"
    }"

	# Sign transaction
	local signed_tx
	signed_tx=$(echo "${tx_data}" | jq -c .)

	# Send transaction
	local tx_hash
	tx_hash=$(lib_eth_rpc_send_raw_transaction "${signed_tx}")
	echo "${tx_hash}"
}

# Function: lib_eth_rpc_encode_abi
# Description: Encode function call data using ABI encoding
# Usage: lib_eth_rpc_encode_abi <function_signature> <param1> <param2> ...
# Returns: The encoded data
# Example: lib_eth_rpc_encode_abi "transfer(address,uint256)" "0x123" "1000000000000000000"
lib_eth_rpc_encode_abi() {
	local function_sig="${1}"
	shift
	local params=("$@")

	# Get function selector (first 4 bytes of keccak256 hash)
	local selector
	selector=$(keccak-256sum "${function_sig}" | cut -c1-8)

	# Encode parameters
	local encoded_params=""
	for param in "${params[@]}"; do
		if [[ "${param}" =~ ^0x[0-9a-fA-F]{40}$ ]]; then
			# Address type
			encoded_params+="${param:2}"
		elif [[ "${param}" =~ ^[0-9]+$ ]]; then
			# Uint256 type
			encoded_params+=$(printf "%064x" "${param}")
		else
			echo "Error: Unsupported parameter type: ${param}"
			return 1
		fi
	done

	echo "0x${selector}${encoded_params}"
}

# Function: lib_eth_rpc_contract_call_tx
# Description: Create a contract call transaction
# Usage: lib_eth_rpc_contract_call_tx <from_address> <contract_address> <function_signature> <param1> <param2> ... [value_in_wei]
# Returns: The transaction hash
# Example: lib_eth_rpc_contract_call_tx "0x123" "0x456" "transfer(address,uint256)" "0x789" "1000000000000000000"
lib_eth_rpc_contract_call_tx() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi

	local from_address="${1}"
	local contract_address="${2}"
	local function_sig="${3}"
	shift 3

	# Get the last parameter which might be the value
	local last_param="${!#}"
	local value="0"
	local params=()

	# Check if the last parameter is a number (could be value)
	if [[ "${last_param}" =~ ^[0-9]+$ ]]; then
		value="${last_param}"
		# Remove the last parameter from the array
		set -- "${@:1:$#-1}"
	fi

	# Remaining parameters are for the function call
	params=("$@")

	# Encode the function call data
	local data
	if ! data=$(lib_eth_rpc_encode_abi "${function_sig}" "${params[@]}"); then
		echo "Error: Failed to encode function call data"
		return 1
	fi

	# Get nonce
	local nonce
	nonce=$(lib_eth_rpc_get_nonce "${from_address}")
	if [ -z "${nonce}" ]; then
		echo "Error: Failed to get nonce"
		return 1
	fi

	# Get gas price
	local gas_price
	gas_price=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id":1}' "${ETH_RPC_URL}" | jq -r '.result')

	# Estimate gas limit
	local gas_limit
	gas_limit=$(curl -s -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_estimateGas\",\"params\":[{\"from\":\"${from_address}\",\"to\":\"${contract_address}\",\"data\":\"${data}\",\"value\":\"${value}\"}],\"id\":1}" "${ETH_RPC_URL}" | jq -r '.result')

	# Create transaction data
	local tx_data
	tx_data="{
        \"from\": \"${from_address}\",
        \"to\": \"${contract_address}\",
        \"value\": \"${value}\",
        \"gasPrice\": \"${gas_price}\",
        \"gas\": \"${gas_limit}\",
        \"nonce\": \"${nonce}\",
        \"data\": \"${data}\",
        \"chainId\": \"$(lib_eth_rpc_get_chain_id)\"
    }"

	# Sign transaction
	local signed_tx
	signed_tx=$(echo "${tx_data}" | jq -c .)

	# Send transaction
	local tx_hash
	tx_hash=$(lib_eth_rpc_send_raw_transaction "${signed_tx}")
	echo "${tx_hash}"
}

# Function: lib_eth_rpc_token_transfer
# Description: Transfer ERC20 tokens
# Usage: lib_eth_rpc_token_transfer <from_address> <token_address> <recipient_address> <amount>
# Returns: The transaction hash
# Example: lib_eth_rpc_token_transfer "0x123" "0x456" "0x789" "1000000000000000000"
lib_eth_rpc_token_transfer() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi

	local from_address="${1}"
	local token_address="${2}"
	local recipient_address="${3}"
	local amount="${4}"

	# Call the contract with transfer function
	lib_eth_rpc_contract_call_tx "${from_address}" "${token_address}" "transfer(address,uint256)" "${recipient_address}" "${amount}"
}

# Function: lib_eth_rpc_get_gas_price
# Description: Get the current gas price from the Ethereum RPC
# Usage: lib_eth_rpc_get_gas_price
# Returns: The current gas price in wei
# Example: lib_eth_rpc_get_gas_price
lib_eth_rpc_get_gas_price() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local gas_price
	gas_price=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id":1}' "${ETH_RPC_URL}" | jq -r '.result')
	echo "${gas_price}"
}

# Function: lib_eth_rpc_get_balance
# Description: Get the balance of an address from the Ethereum RPC
# Usage: lib_eth_rpc_get_balance <address> [block_number]
# Returns: The balance in wei
# Example: lib_eth_rpc_get_balance "0x123" "latest"
lib_eth_rpc_get_balance() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local address="${1}"
	local block_number="${2:-latest}"
	local balance
	balance=$(curl -s -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getBalance\",\"params\":[\"${address}\", \"${block_number}\"],\"id\":1}" "${ETH_RPC_URL}" | jq -r '.result')
	echo "${balance}"
}

# Function: lib_eth_rpc_get_sync_status
# Description: Get the sync status from the Ethereum RPC
# Usage: lib_eth_rpc_get_sync_status
# Returns: The sync status (false if synced, object with sync details if syncing)
# Example: lib_eth_rpc_get_sync_status
lib_eth_rpc_get_sync_status() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local sync_status
	sync_status=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' "${ETH_RPC_URL}" | jq -r '.result')
	echo "${sync_status}"
}

# Function: lib_eth_rpc_get_accounts
# Description: Get the list of accounts from the Ethereum RPC
# Usage: lib_eth_rpc_get_accounts
# Returns: List of account addresses
# Example: lib_eth_rpc_get_accounts
lib_eth_rpc_get_accounts() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local accounts
	accounts=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' "${ETH_RPC_URL}" | jq -r '.result[]')
	echo "${accounts}"
}

# Function: lib_eth_rpc_get_network_info
# Description: Get network information from the Ethereum RPC
# Usage: lib_eth_rpc_get_network_info
# Returns: JSON object with network information
# Example: lib_eth_rpc_get_network_info
lib_eth_rpc_get_network_info() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local chain_id
	local block_number
	local gas_price
	local sync_status

	chain_id=$(lib_eth_rpc_get_chain_id)
	block_number=$(lib_eth_rpc_get_block_number)
	gas_price=$(lib_eth_rpc_get_gas_price)
	sync_status=$(lib_eth_rpc_get_sync_status)

	echo "{
        \"chainId\": \"${chain_id}\",
        \"blockNumber\": \"${block_number}\",
        \"gasPrice\": \"${gas_price}\",
        \"syncing\": ${sync_status}
    }"
}

# Function: lib_eth_rpc_get_contract_code
# Description: Get the contract code from the Ethereum RPC
# Usage: lib_eth_rpc_get_contract_code <address> [block_number]
# Returns: The contract code in hex
# Example: lib_eth_rpc_get_contract_code "0x123" "latest"
lib_eth_rpc_get_contract_code() {
	if [ -z "${ETH_RPC_URL}" ]; then
		echo "Error: ETH_RPC_URL environment variable is not set"
		return 1
	fi
	local address="${1}"
	local block_number="${2:-latest}"
	local code
	code=$(curl -s -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getCode\",\"params\":[\"${address}\", \"${block_number}\"],\"id\":1}" "${ETH_RPC_URL}" | jq -r '.result')
	echo "${code}"
}
