#!/bin/sh -l

cd $CONAN_USER_HOME

#FALLBACK_KEY="host-${RUNNER_OS}-target-${INPUT_TARGET_OS}-${REPO_BRANCH}"
echo "Check if on branch"
if [ $(git symbolic-ref --short -q HEAD) ]; then
    echo "Conan Cache: Currently on fallback key"
    
    echo "Conan Cache: replace ${CONAN_USER_HOME_SHORT} with CONAN_USER_HOME_SHORT"
    find .conan/ -name .conan_link -exec sed -i s=${CONAN_USER_HOME_SHORT}=$CONAN_USER_HOME_SHORT/=g {} +
    
    git status
    
    echo "Conan Cache: Configure git"
    git config user.email "you@example.com"
    git config user.name "${INPUT_BOT_NAME}"
    
    echo "Conan Cache: Find all files bigger than 100MB"
    find .conan/ -type f -size +100000k -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'

    echo "Conan Cache: Find all files bigger than 50MB"
    find .conan/ -type f -size +50000k -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'
    
    echo "Conan Cache: HARDCODED LFS tracking of libQt5WebEngineCore"
    git lfs track 'libQt5WebEngineCore.so.*'
    git lfs track 'libQt5WebEngineCore.*.dylib'
    # git lfs track 'Qt5WebEngineCore.dll'
    
    echo "Conan Cache: Add everything"
    git add -A
    
    echo "Conan Cache: Commit locally"
    git commit -m "$GITHUB_EVENT_NAME : Commit by $GITHUB_ACTOR with SHA $GITHUB_SHA on $GITHUB_REF"
        
    echo "Conan Cache: Push to GitHub"
    git push
    
    echo "Conan Cache: Tag with explicit key : $INPUT_KEY"
    git tag $INPUT_KEY
    
    echo "Conan Cache: Push explicit key"
    git push origin $INPUT_KEY
else
    echo "Got hit on explicit key : $INPUT_KEY"
    git status
fi
