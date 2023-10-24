#!/usr/bin/env bash
set -e

source .env

NETWORK="$1"

if [ -z "$NETWORK" ]; then
    NETWORK=LOCAL
fi

NETWORK=$(echo "$NETWORK" | tr 'a-z' 'A-Z')

echo "Network: $NETWORK"

RPC_KEY_NAME="${NETWORK}_RPC"
DEPLOYMENTS_KEY_NAME="$(echo "$NETWORK" | tr 'A-Z' 'a-z')"
CONTRACTS_VERIFY_KEY_NAME="${NETWORK}_VERIFY_KEY"

RPC_URL="${!RPC_KEY_NAME}"
DEPLOYMENTS_FOLDER="${!DEPLOYMENTS_KEY_NAME}"
CONTRACTS_VERIFY_KEY="${!CONTRACTS_VERIFY_KEY_NAME}"

echo "Deploying: URL=${RPC_URL} to FOLDER=${DEPLOYMENTS_FOLDER} VERIFY_KEY=${CONTRACTS_VERIFY_KEY}"
# Deploy using the first anvil account.
forge script script/forge/Deployer.s.sol:DeployScript \
    -f "${RPC_URL}" \
    --private-key "${OWNER_PRIVATE_KEY}" \
    --broadcast

if [[ "$VERIFY_CONTRACTS" == "true" && -n "$CONTRACTS_VERIFY_URL" ]]; then
    address=$(jq -r \
        '.transactions[0].contractAddress' \
        ./broadcast/AssetRegistryDeployer.s.sol/$CHAIN_ID/run-latest.json)

    forge verify-contract  \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --verifier-url $CONTRACTS_VERIFY_URL $address AssetAddressesProviderRegistry \
    --watch
fi
# Generate deployment file.
./script/sh/gen-deployment-file.sh "$DEPLOYMENTS_FOLDER" "SimpleOracle" "Deployer" "simple_oracle"