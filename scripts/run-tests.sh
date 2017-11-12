#!/usr/bin/env bash

# use this script to run your tests

# export account address environment variables
# see this file for available variables
source ./scripts/testrpc-accounts.sh

# export token contract address environment variable
export TOKEN_CONTRACT_ADDRESS=$(cat ./token-contract-address)


# TEST COMMANDS GO HERE
xcodebuild test -project KinSDK/KinSDK.xcodeproj \
-scheme KinTestHost \
-sdk iphonesimulator \
-destination 'platform=iOS Simulator,name=iPhone 7,OS=11.0' \
"OTHER_SWIFT_FLAGS=-D TEST_RPC"
