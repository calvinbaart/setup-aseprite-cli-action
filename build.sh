#!/bin/bash

set -e

if [ -f "$PWD/build/bin/aseprite" ]; then
  echo "Skipping build as cache hit."
  exit 0
fi

cd clone
git checkout temp

mkdir -p submodules/aseprite/aseprite
git clone --recurse-submodules -j8 https://github.com/aseprite/aseprite.git submodules/aseprite/aseprite
cd submodules/aseprite/aseprite
./build.sh --auto
