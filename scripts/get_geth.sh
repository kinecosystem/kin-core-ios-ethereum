#!/bin/bash

# updates / downloads and installs a pre-built Geth framework with an i386 slice

export LOCAL_GETH_COMMIT=$(touch geth-commit && cat geth-commit )
export REMOTE_GETH_COMMIT=$(git ls-remote https://github.com/kinfoundation/Geth-iOS.git | grep HEAD | awk '{ print $1}')

curr_dir=$PWD
target_dir=$curr_dir/KinSDK/Geth.framework

if [ $LOCAL_GETH_COMMIT != $REMOTE_GETH_COMMIT ] || [ ! -r $target_dir ] ; then
  echo "Geth library out of date or missing. Updating..."
  rm -r KinSDK/Geth.framework 2>/dev/null
  cd /tmp
  rm -r -f Geth-iOS
  git clone --depth=1 https://github.com/kinfoundation/Geth-iOS.git
  cd Geth-iOS
  unzip -a Geth.framework.zip
  cp -r Geth.framework $target_dir
  cd ..
  rm -rf Geth-iOS 2>/dev/null
  cd $curr_dir
  echo $REMOTE_GETH_COMMIT > geth-commit
fi
