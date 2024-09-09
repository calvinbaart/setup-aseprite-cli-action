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
  apt-get install -y ninja-build xorg-dev cmake g++ libharfbuzz-dev
else
  choco install ninja
fi

cmake -E make_directory build
cmake -E chdir build cmake -G Ninja -DENABLE_UI=OFF ../clone/submodules/aseprite/aseprite
cd build

if [ "$(uname)" == "Darwin" ]; then
  ninja
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  ninja
else
  ninja -j 1
fi
