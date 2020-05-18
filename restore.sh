#!/bin/sh -l

echo "CONAN_USER_HOME $CONAN_USER_HOME"
echo "INPUT_BOT_NAME $INPUT_BOT_NAME" 
echo "INPUT_BOT_TOKEN $INPUT_BOT_TOKEN"
echo "INPUT_CACHE_NAME $INPUT_CACHE_NAME"
echo "INPUT_KEY $INPUT_KEY"
echo "HOME $HOME" 
echo "GITHUB_JOB $GITHUB_JOB"
echo "GITHUB_REF $GITHUB_REF"
echo "GITHUB_SHA $GITHUB_SHA" 
echo "GITHUB_REPOSITORY $GITHUB_REPOSITORY" 
echo "GITHUB_REPOSITORY_OWNER $GITHUB_REPOSITORY_OWNER"
echo "GITHUB_RUN_ID $GITHUB_RUN_ID"
echo "GITHUB_RUN_NUMBER $GITHUB_RUN_NUMBER"
echo "GITHUB_ACTOR $GITHUB_ACTOR" 
#echo "GITHUB_WORKFLOW $GITHUB_WORKFLOW" 
#echo "GITHUB_HEAD_REF $GITHUB_HEAD_REF" 
#echo "GITHUB_BASE_REF $GITHUB_BASE_REF" 
echo "GITHUB_EVENT_NAME $GITHUB_EVENT_NAME" 
#echo "GITHUB_URL $GITHUB_URL"
#echo "GITHUB_API_URL $GITHUB_API_URL"
#echo "GITHUB_WORKSPACE $GITHUB_WORKSPACE" 
#echo "GITHUB_ACTION $GITHUB_ACTION"
#echo "GITHUB_EVENT_PATH $GITHUB_EVENT_PATH"
echo "HOST OS $RUNNER_OS"
#echo "RUNNER_TOOL_CACHE $RUNNER_TOOL_CACHE"
#echo "RUNNER_TEMP $RUNNER_TEMP"
#echo "RUNNER_WORKSPACE $RUNNER_WORKSPACE"
#echo "ACTIONS_RUNTIME_URL $ACTIONS_RUNTIME_URL"
#echo "ACTIONS_RUNTIME_TOKEN $ACTIONS_RUNTIME_TOKEN" 
#echo "ACTIONS_CACHE_URL $ACTIONS_CACHE_URL"

#cache_hit=0
#echo "::set-output name=cache-hit::$cache_hit"

echo "Commit by $GITHUB_ACTOR with SHA $GITHUB_SHA on $GITHUB_REF"

echo "Using cache $INPUT_CACHE_NAME"

# 0. Make sure path exists and change dir to it
mkdir -p $CONAN_USER_HOME
cd $CONAN_USER_HOME

# 1. Check out cache - shallow and fetch
echo "Checking out at $CONAN_USER_HOME"
BRANCH=master
git clone https://${INPUT_BOT_NAME}:${INPUT_BOT_TOKEN}@github.com/${INPUT_CACHE_NAME}.git ${CONAN_USER_HOME} --branch=${BRANCH}
# If it fails - exit 1

# 2. Check if explicit key exits
echo "Trying explicit key $INPUT_KEY"

# If it does - check out explicit and set cache_hit to 1
if [ $(git tag -l "$INPUT_KEY") ]; then
    git checkout ${INPUT_KEY}
    echo "::set-output name=cache-hit::1"
    exit 0
fi

# 3. If it doesn't check if fallback exits
echo "Trying fallback key"

# If it does - check out fallback and set cache_hit to 2

# If it doesn't - set cache_hit to 0

echo "::set-output name=cache-hit::0"
