#!/bin/sh -l

INPUT_TARGET_OS=${INPUT_TARGET_OS:-$RUNNER_OS}
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

# 2. Check if explicit key exits
#    If it does - check out explicit and set cache_hit to 1
echo "Trying explicit key $INPUT_KEY"
if [ $(git tag --list "$INPUT_KEY") ]; then
    git checkout ${INPUT_KEY}
    echo "::set-output name=cache-hit::1"
    exit 0
fi

# 3. If it doesn't check if fallback exits
#    If it does - check out fallback and set cache_hit to 2
FALLBACK_KEY="host-${RUNNER_OS}-target-${INPUT_TARGET_OS}-${REPO_BRANCH}"
echo "Trying fallback key $FALLBACK_KEY"
if [ $(git ls-remote origin $FALLBACK_KEY) ]; then
    git checkout ${FALLBACK_KEY}
    echo "::set-output name=cache-hit::2"
    exit 0
else
    # If it doesn't - create the branch and set cache_hit to 0
    echo "Creating fallback key $FALLBACK_KEY"
    git checkout -b ${FALLBACK_KEY}
    git push -u origin ${FALLBACK_KEY}
    echo "::set-output name=cache-hit::0"
fi
