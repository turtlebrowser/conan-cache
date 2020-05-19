#!/bin/sh -l

REPO_BRANCH=master

echo "$GITHUB_EVENT_NAME : Commit by $GITHUB_ACTOR with SHA $GITHUB_SHA on $GITHUB_REF"
echo "Using cache $INPUT_CACHE_NAME"

# 0. Make sure path exists and change dir to it
mkdir -p $CONAN_USER_HOME
cd $CONAN_USER_HOME

# 1. Check out cache
#    If it fails - exit 1
echo "Checking out at CONAN_USER_HOME: $CONAN_USER_HOME"
git clone https://${INPUT_BOT_NAME}:${INPUT_BOT_TOKEN}@github.com/${INPUT_CACHE_NAME}.git ${CONAN_USER_HOME} --branch=master || exit 1

touch test.txt

# 2. Check if explicit key exits
#    If it does - check out explicit and set cache_hit to 1
echo "Trying explicit key $INPUT_KEY"
if [ $(git tag -l "$INPUT_KEY") ]; then
    git checkout ${INPUT_KEY}
    echo "::set-output name=cache-hit::1"
    exit 0
fi

# 3. If it doesn't check if fallback exits
#    If it does - check out fallback and set cache_hit to 2
FALLBACK_KEY="host-${RUNNER_OS}-target-${RUNNER_OS}-${REPO_BRANCH}"
echo "Trying fallback key $FALLBACK_KEY"
if [ $(git tag -l "$FALLBACK_KEY") ]; then
    git checkout ${FALLBACK_KEY}
    echo "::set-output name=cache-hit::2"
    exit 0
fi

# If it doesn't - set cache_hit to 0
echo "::set-output name=cache-hit::0"
