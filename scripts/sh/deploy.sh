#!/usr/bin/env bash
set -e

source .env

NETWORK="$1"

if [ -z "$NETWORK" ]; then
    NETWORK=LOCAL
fi

RPC_KEY_NAME="${NETWORK}_RPC"
DEPLOYMENTS_KEY_NAME="${NETWORK}_DEPLOYMENTS"
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

if [[ "$VERIFY_CONTRACTS" == "true" && -z "$CONTRACTS_VERIFY_KEY" ]]; then
    --rpc-url "${RPC_URL}"
    --verify \
    --"${CONTRACTS_VERIFY_KEY}" \
    -vvvv \
    --via-ir
fi

# Generate deployment file.
./script/sh/gen-deployment-file.sh "$DEPLOYMENTS_FOLDER" "SimpleOracle" "Deployer" "simple_oracle"