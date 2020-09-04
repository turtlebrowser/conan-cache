#!/bin/sh -l

INPUT_LFS_LIMIT=${INPUT_LFS_LIMIT:-50}

cd $CONAN_USER_HOME

#FALLBACK_KEY="host-${RUNNER_OS}-target-${INPUT_TARGET_OS}-${REPO_BRANCH}"
echo "Conan Cache: Check if on branch"
if [ $(git symbolic-ref --short -q HEAD) ]; then
    echo "\n Conan Cache: Currently on fallback key"
    
    echo "\n Conan Cache: Install Conan"
    pip3 install wheel setuptools
    pip3 install conan --upgrade
    
    echo "\n Conan Cache: Clean Conan"
    conan remove -f "*" --builds
    conan remove -f "*" --src
    conan remove -f "*" --system-reqs
    
    echo "\n Conan Cache: replace ${CONAN_USER_HOME_SHORT} with CONAN_USER_HOME_SHORT"
    find .conan/ -name .conan_link -exec perl -pi -e 's|\Q$ENV{CONAN_USER_HOME_SHORT}\E|CONAN_USER_HOME_SHORT|g' {} +
    find .conan -name .conan_link.bak -exec rm {} +
    
    git status
    
    echo "\n Conan Cache: Configure git"
    git config user.email "you@example.com"
    git config user.name "${INPUT_BOT_NAME}"
    
    echo "\n Conan Cache: Find all files bigger than 100MB"
    find .conan short -type f -size +100M -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'

    echo "\n Conan Cache: Find all files bigger than 50MB"
    find .conan short -type f -size +50M -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'
    
    echo "\n Conan Cache: Auto LFS track all files bigger than $INPUT_LFS_LIMIT MB"
    find .conan short -type f -size +${INPUT_LFS_LIMIT}M -execdir git lfs track {} \;
    
    echo "\n Conan Cache: Add everything"
    git add -A
    
    echo "\n Conan Cache: Commit locally"
    git commit -m "$GITHUB_EVENT_NAME : Commit by $GITHUB_ACTOR with SHA $GITHUB_SHA on $GITHUB_REF"
        
    echo "\n Conan Cache: Push to GitHub"
    git push
    
    echo "\n Conan Cache: Tag with explicit key : $INPUT_KEY"
    git tag $INPUT_KEY
    
    echo "\n Conan Cache: Push explicit key"
    git push origin $INPUT_KEY
else
    echo "\n Conan Cache: Got hit on explicit key : $INPUT_KEY"
    git status
fi
