#!/bin/sh -l

cd $CONAN_USER_HOME

#FALLBACK_KEY="host-${RUNNER_OS}-target-${INPUT_TARGET_OS}-${REPO_BRANCH}"
echo "Check if on branch"
if [ $(git symbolic-ref --short -q HEAD) ]; then
    echo "Conan Cache: Currently on fallback key"
    git status
    
    echo "Conan Cache: Configure git"
    git config user.email "you@example.com"
    git config user.name "${INPUT_BOT_NAME}"
    
    git pull
    
    echo "Conan Cache: Add everything"
    git add -A
    #git add --all -- ':!.conan/data/qt/*'
    echo "Conan Cache: Commit locally"
    git commit -m "$GITHUB_EVENT_NAME : Commit by $GITHUB_ACTOR with SHA $GITHUB_SHA on $GITHUB_REF"
    
    echo "Conan Cache: LFS Migrate Info"
    git lfs migrate info
    echo "Conan Cache: LFS Migrate Import Everything"
    git lfs migrate import --everything
    
    git pull --rebase
    
    echo "Conan Cache: Push to GitHub"
    git push
    
    #echo "Conan Cache: Tag with explicit key : $INPUT_KEY"
    #git tag $INPUT_KEY
    #echo "Conan Cache: Push explicit key"
    #git push origin $INPUT_KEY
else
    echo "Got hit on explicit key : $INPUT_KEY"
    git status
fi

# If no changes were made - exit 0

# if cache_hit was 1 (explicit) - should you update?

# If cache_hit was 0 (miss) or 2 (fallback) - make a new explicit
