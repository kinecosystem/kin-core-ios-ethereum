#!/bin/bash

which go > /dev/null

if [ $? -gt 0 ]; then
	echo "Please install go."
	exit 1
fi

BRANCH=master

if [ -n $1 ]; then
	if [ "$1" == '-h' ]; then
		echo "Usage: ./update_geth.sh [branch]"
		echo ""
		echo "If no branch is provided, master will be checked out."
		exit 0
	fi

	BRANCH=$1
fi

if [ ! -d ./go-ethereum ]; then
	git clone --depth=10 git@github.com:kinfoundation/go-ethereum.git
fi

cd go-ethereum

git checkout $BRANCH
git pull

make ios

if [ $? -gt 0 ]; then
	echo "Build failed!"
	exit 1
fi

rm -rf ../KinSDK/Geth.framework
cp -a build/bin/Geth.framework ../KinSDK
