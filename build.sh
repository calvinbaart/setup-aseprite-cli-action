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
cd ..

if [ "$(uname)" == "Darwin" ]; then
  brew install ninja
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  apt-get update
  apt-get install -y ninja-build xorg-dev cmake g++ libcurl4-gnutls-dev libharfbuzz-dev libwebp-dev gn libgif-dev libtiff5-dev libjpeg-dev libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev libtinyxml-dev libtinyxml2-dev libcmark-dev
else
  choco install ninja
fi

build_skia() {
	wget https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-Linux-Release-x64-libstdc++.zip
  unzip Skia-Linux-Release-x64-libstdc++.zip -d skia
}

build_skia

cmake -E make_directory build
cmake -E chdir build cmake -G Ninja -DENABLE_UI=OFF -DENABLE_UPDATER=OFF -DLAF_WITH_{EXAMPLES,TESTS}=OFF -DLAF_BACKEND=skia -DSKIA_DIR="../skia" -DSKIA_LIBRARY_DIR="../skia/out/Release-x64" -DUSE_SHARED_{CMARK,CURL,FMT,GIFLIB,JPEGLIB,ZLIB,LIBPNG,TINYXML,PIXMAN,FREETYPE,HARFBUZZ,LIBARCHIVE,WEBP}=YES ../clone/submodules/aseprite/aseprite
cd build

if [ "$(uname)" == "Darwin" ]; then
  ninja
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  ninja
else
  ninja -j 1
fi
