#!/bin/bash

set -e

if [ -f "$PWD/build/bin/aseprite" ]; then
  echo "Skipping build as cache hit."
  exit 0
fi

if [ "$(uname)" == "Darwin" ]; then
  brew install ninja
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  apt-get update
  apt-get install -y ninja-build xorg-dev cmake g++ libcurl4-gnutls-dev libharfbuzz-dev libwebp-dev gn libgif-dev libtiff5-dev libjpeg-dev libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev libtinyxml-dev libtinyxml2-dev libcmark-dev
else
  choco install ninja
fi
  apt-get install -y ninja-build xorg-dev cmake g++ libcurl4-gnutls-dev libharfbuzz-dev libwebp-dev gn libgif-dev libtiff5-dev libjpeg-dev libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev libtinyxml-dev libtinyxml2-dev libcmark-dev
else
  choco install ninja
fi

cd clone
git checkout temp

mkdir -p submodules/aseprite/aseprite
git clone --recurse-submodules -j8 https://github.com/aseprite/aseprite.git submodules/aseprite/aseprite
cd submodules/aseprite/aseprite
./build.sh --auto
