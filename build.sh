#!/bin/bash

set -e

if [ -f "$PWD/build/bin/aseprite" ]; then
  echo "Skipping build as cache hit."
  exit 0
fi

cd clone
git checkout temp

mkdir -p submodules/aseprite/aseprite
mkdir -p submodules/skia
git clone --recurse-submodules -j8 https://github.com/aseprite/aseprite.git submodules/aseprite/aseprite
git clone --recurse-submodules -j8 https://github.com/aseprite/skia.git submodules/skia
cd ..

if [ "$(uname)" == "Darwin" ]; then
  brew install ninja
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  apt-get update
  apt-get install -y ninja-build xorg-dev cmake g++ libharfbuzz-dev libwebp-dev gn
else
  choco install ninja
fi

build_skia() {
	echo Building Skia...
	local _skiadir="./clone/submodules/skia/obj"
	export CXX=g++
	export CC=gcc
	export AR=ar
	export NM=nm
	# Flags can be found by running `gn args --list "$_skiadir"` from skia's directory.
	# (Pipe the output somewhere, there's a LOT of args.)
	#
	# The flags are chosen to provide the API required by Aseprite and nothing else (if possible),
	# so as to reduce the compilation time and final binary size.
	#
	# Individual rationales:
	#   is_official_build: Suggested by the build instructions.
	#   skia_build_fuzzers: We don't care about them.
	#   skia_enable_pdf: Not used by Aseprite.
	#   skia_enable_skottie: Not used by Aseprite.
	#   skia_enable_sksl: laf seems to want to use it... but no references are made anywhere.
	#   skia_enable_svg: Not used by Aseprite. It seems it has its own SVG exporter.
	#   skia_use_lib*_{encode,decode}: Aseprite only loads PNG assets, so only libpng is required.
	#   skia_use_expat: Only required for the Android font manager and SVGCanvas/SVGDevice.
	#   skia_use_piex: Not used by Aseprite. Only used for reading RAW files.
	#   skia_use_xps: Not used outside of Windows.
	#   skia_use_zlib: Only used for PDF and RAW files.
	#   skia_use_libgifcodec: Only used for GIFs, which Aseprite doesn't use.
	#   skia_enable_{particles,skparagraph,sktext}: Aseprite does not link against this library.
	env -C skia gn gen "$_skiadir" --args="$(printf '%s ' \
is_official_build=true skia_build_fuzzers=false \
skia_enable_{pdf,skottie,sksl,svg}=false \
skia_use_{libjpeg_turbo,libwebp}_{encode,decode}=false \
skia_use_{expat,piex,xps,zlib,libgifcodec}=false \
skia_enable_{particles,skparagraph,sktext}=false)"
	ninja -C "$_skiadir" skia modules
}

build_skia()

cmake -E make_directory build
cmake -E chdir build cmake -G Ninja -DENABLE_UI=OFF -DENABLE_UPDATER=OFF -DLAF_WITH_{EXAMPLES,TESTS}=OFF -DLAF_BACKEND=skia -DSKIA_DIR="../clone/submodules/skia" -DSKIA_LIBRARY_DIR="../clone/submodules/skia/obj" -DUSE_SHARED_{CMARK,CURL,FMT,GIFLIB,JPEGLIB,ZLIB,LIBPNG,TINYXML,PIXMAN,FREETYPE,HARFBUZZ,LIBARCHIVE,WEBP}=YES ../clone/submodules/aseprite/aseprite
cd build

if [ "$(uname)" == "Darwin" ]; then
  ninja
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  ninja
else
  ninja -j 1
fi
