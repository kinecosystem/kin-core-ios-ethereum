#!/usr/bin/env bash

# prepare testrpc accounts parameter string e.g. --account="0x11c..,1000" --account="0xc5d...,1000" ....
source ./scripts/testrpc-accounts.sh
for account in ${account_array[@]}; do
    accounts=$accounts$(printf ' --account="%s,%s"' "$account" "$balance")
done

if (nc -z localhost 8545); then
    echo "Using existing testrpc instance on port $(ps -fade | grep -e 'node.*testrpc' | head -n 1 | awk '{print $2}')"
else
    echo -n "Starting testrpc instance on port "
    testrpc "$accounts" -u 0 -u 1 -p "$port" > testrpc.log 2>&1 & echo $! > testrpc.pid
    echo $(cat testrpc.pid)
fi
