#!/bin/sh -l

cd $CONAN_USER_HOME

#FALLBACK_KEY="host-${RUNNER_OS}-target-${INPUT_TARGET_OS}-${REPO_BRANCH}"
echo "Check if on branch"
if [ $(git symbolic-ref --short -q HEAD) ]; then
    echo "Currently on fallback key"
    git status
    git config user.email "you@example.com"
    git config user.name "${INPUT_BOT_NAME}"
    git add *
    git commit -m "$GITHUB_EVENT_NAME : Commit by $GITHUB_ACTOR with SHA $GITHUB_SHA on $GITHUB_REF"
    git push
    #git push origin --delete <tagname>
else
    echo "Got hit on explicit key"
    git status
fi

# If no changes were made - exit 0

# if cache_hit was 1 (explicit) - should you update?

# If cache_hit was 0 (miss) or 2 (fallback) - make a new explicit
