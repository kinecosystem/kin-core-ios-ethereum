#!/bin/bash

# downloads and installs a pre-built Geth framework with an i386 slice

echo "Downloading Geth..."
target_dir=$PWD/KinSDK/Geth.framework
rm -r KinSDK/Geth.framework 2>/dev/null
cd /tmp
rm -r Geth-iOS 2>/dev/null
git clone --depth=1 git@github.com:kinfoundation/Geth-iOS.git
cd Geth-iOS
unzip -a Geth.framework.zip
cp -r Geth.framework $target_dir
cd ..
rm -rf Geth-iOS 2>/dev/null
