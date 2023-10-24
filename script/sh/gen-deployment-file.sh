#!/usr/bin/env bash
set -e

source .env

NETWORK_FOLDER="$1" 
CHAIN_ID="$2" 
FROM_SC="$3"
DEPLOY_SC="$4"
DEPLOYED_FILENAME="$5"

mkdir -p deployments/$NETWORK_FOLDER



abi=$(jq -c "{abi: .abi}" ./out/$FROM_SC.sol/$FROM_SC.json)
address=$(jq -c \
    "{address: .transactions[0].contractAddress}" \
    ./broadcast/$DEPLOY_SC.s.sol/$CHAIN_ID/run-latest.json)
blocknumberhex=$(jq -rc \
    ".receipts[0].blockNumber" \
    ./broadcast/$DEPLOY_SC.s.sol/$CHAIN_ID/run-latest.json)
blocknumber=$(cast --to-base $blocknumberhex 10)
echo "$abi $address {\"blockNumber\": $blocknumber}" | jq -s add >./deployments/$NETWORK_FOLDER/$DEPLOYED_FILENAME.json
