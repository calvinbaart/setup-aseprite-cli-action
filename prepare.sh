set -e

# Unfortunately, the GitHub Actions Marketplace strips out all Git details
# (including submodules) on publish, so we have to re-clone our own repository
# to get the Aseprite submodule we plan to build.

mkdir clone
cd clone

git init
git remote add origin https://github.com/calvinbaart/setup-aseprite-cli-action.git
git fetch origin master:temp

echo ::set-output name=sha::$(git rev-parse temp)
