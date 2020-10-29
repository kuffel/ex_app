GIT_HASH=$(git log --pretty=format:'%h' -n 1)
CURRENT_VERSION="$(cat VERSION)-${GIT_HASH}"
sed -i "s/version: \"*.*.*\",/version: \"$CURRENT_VERSION\",/" ./mix.exs