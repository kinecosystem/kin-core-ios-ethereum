#!/usr/bin/env bash

cd truffle

if [ -f 'testrpc.pid' ]; then
    echo "killing testrpc on process id $(cat testrpc.pid)"
    # Don't fail if the process is already killed
    kill -SIGINT $(cat testrpc.pid) || true
    rm -f testrpc.pid
else
    echo "testrpc.pid not found, doing nothing"
fi
