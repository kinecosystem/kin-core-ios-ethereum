#!/usr/bin/env bash

if [ -f 'testrpc.pid' ]; then
    echo "killing testrpc on port $(cat testrpc.pid)"
    kill -SIGINT $(cat testrpc.pid) && \
    rm -f testrpc.pid
else
    echo "testrpc.pid not found, doing nothing"
fi
