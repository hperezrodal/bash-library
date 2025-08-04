#!/usr/bin/env bash

# Example script demonstrating the use of Ethereum RPC functions
# Make sure to source the eth_rpc.sh module before running this script

# Source the library
if [ -z "${BASH_LIBRARY_PATH:-}" ]; then
	echo "Error: BASH_LIBRARY_PATH is not set"
	exit 1
fi

if [ ! -f "$BASH_LIBRARY_PATH/lib-loader.sh" ]; then
	echo "Error: Library file not found at $BASH_LIBRARY_PATH/lib-loader.sh"
	exit 1
fi

source "$BASH_LIBRARY_PATH/lib-loader.sh"

# Example 1: Basic network information
echo "Example 1: Getting basic network information"
echo "------------------------------------------"
echo "Current block number: $(lib_eth_rpc_get_block_number)"
echo "Chain ID: $(lib_eth_rpc_get_chain_id)"
echo "Client version: $(lib_eth_rpc_get_client_version)"
echo ""

# Example 2: Getting block information
echo "Example 2: Getting block information"
echo "-----------------------------------"
latest_block=$(lib_eth_rpc_get_block_number)
echo "Latest block number: ${latest_block}"
echo "Latest block data: $(lib_eth_rpc_get_block_by_number "${latest_block}")"
echo ""

# Example 3: Getting transaction information
echo "Example 3: Getting transaction information"
echo "----------------------------------------"
# Get a transaction from the latest block
block_data=$(lib_eth_rpc_get_block_by_number "${latest_block}")
transaction_hash=$(echo "${block_data}" | jq -r '.transactions[0]')
if [ "${transaction_hash}" != "null" ]; then
	echo "Transaction hash: ${transaction_hash}"
	echo "Transaction data: $(lib_eth_rpc_get_transaction_by_hash "${transaction_hash}")"
	echo "Transaction receipt: $(lib_eth_rpc_get_transaction_receipt "${transaction_hash}")"
else
	echo "No transactions found in the latest block"
fi
echo ""

# Example 4: Getting nonce for an address
echo "Example 4: Getting nonce for an address"
echo "--------------------------------------"
# Replace with a real Ethereum address
address="0x1234567890123456789012345678901234567890"
echo "Nonce for address ${address}: $(lib_eth_rpc_get_nonce "${address}")"
echo ""

# Example 5: Sending ETH (commented out as it requires actual signing)
echo "Example 5: Sending ETH (commented out)"
echo "------------------------------------"
# Uncomment and modify these values to send ETH
# from_address="0x1234567890123456789012345678901234567890"
# to_address="0x0987654321098765432109876543210987654321"
# amount="1000000000000000000"  # 1 ETH in wei
# private_key="0x..."  # Your private key
# echo "Sending transaction: $(lib_eth_rpc_send_eth "${from_address}" "${to_address}" "${amount}" "${private_key}")"
echo ""

# Example 6: Contract interaction (commented out as it requires actual signing)
echo "Example 6: Contract interaction (commented out)"
echo "--------------------------------------------"
# Uncomment and modify these values to interact with a contract
# from_address="0x1234567890123456789012345678901234567890"
# contract_address="0x0987654321098765432109876543210987654321"
# # Example data for a simple transfer function call
# data="0xa9059cbb0000000000000000000000000987654321098765432109876543210987654321000000000000000000000000000000000000000000000000000000000000000001"
# value="0"
# echo "Sending contract transaction: $(lib_eth_rpc_contract_call_tx "${from_address}" "${contract_address}" "${data}" "${value}")"
echo ""

# Example 7: Getting transaction by block and index
echo "Example 7: Getting transaction by block and index"
echo "-----------------------------------------------"
# Get the first transaction from the latest block
echo "First transaction in latest block: $(lib_eth_rpc_get_transaction_by_block_number_and_index "${latest_block}" "0x0")"
echo ""

# Example 8: Error handling
echo "Example 8: Error handling"
echo "------------------------"
# Try to get block data with invalid block number
echo "Invalid block number result: $(lib_eth_rpc_get_block_by_number "invalid")"
echo ""

echo "All examples completed!"
