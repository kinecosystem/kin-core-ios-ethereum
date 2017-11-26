#!/bin/bash

# downloads and installs a pre-built Geth framework with an i386 slice

echo "Downloading Geth..."
rm -r KinSDK/Geth.framework 2>/dev/null
rm -r gethTemp 2>/dev/null
mkdir gethTemp
cd gethTemp
git clone --depth=1 git@github.com:kinfoundation/Geth-iOS.git
cd Geth-iOS
unzip -a Geth.framework.zip
cp -r Geth.framework ../../KinSDK/Geth.framework
cd ../..
rm -rf gethTemp 2>/dev/null
