#!/bin/bash

[ $# -eq 0 ] && { echo "Usage: $0 <full path to APPLICATION checkout>"; exit 1; }

confirm() {
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

APPLICATION_DIR="$1"

header() {
    echo -e "\e[35m$1\e[0m"
}

echo "APPLICATION dir: " ${APPLICATION_DIR}

[ ! -d ${APPLICATION_DIR} ] && { echo "${APPLICATION_DIR} DOES NOT EXIST"; exit 1; }

export CONAN_USER_HOME="/Code/release/"

[ ! -d ${CONAN_USER_HOME} ] && { echo "${CONAN_USER_HOME} DOES NOT EXIST"; exit 1; }

export CONAN_USER_HOME_SHORT=${CONAN_USER_HOME}/short

[ ! -d ${CONAN_USER_HOME_SHORT} ] && { echo "${CONAN_USER_HOME_SHORT} DOES NOT EXIST"; exit 1; }

export LFS_LIMIT=50
export CONAN_SYSREQUIRES_MODE=enabled

header "Prepare Cache for update"

confirm "Clean cache? [y/N]" && cd ${CONAN_USER_HOME} && git clean -df && git checkout . && git checkout host-Linux-target-Linux-ubuntu-latest-master

confirm "Update cache? [y/N]" && cd ${CONAN_USER_HOME} && git pull && git lfs pull

confirm "DELETE the whole cache? [y/N]" && cd ${CONAN_USER_HOME} && conan remove -f "*"

confirm "Prepare short paths [y/N]" && cd ${CONAN_USER_HOME} && find .conan/ -name .conan_link -exec perl -pi -e 's=CONAN_USER_HOME_SHORT=$ENV{CONAN_USER_HOME_SHORT}=g' {} +

header "Populate the Cache"

confirm "Update APPLICATION? [y/N]" && cd ${APPLICATION_DIR} && git pull

confirm "Remove old build directory? [y/N]" && cd ${APPLICATION_DIR} && rm -rf build

confirm "Create build directory? [y/N]" && cd ${APPLICATION_DIR} && mkdir build

confirm "Start build? [y/N]" && cd ${APPLICATION_DIR} && cd build && cmake -DUPDATE_CONAN=ON -DCMAKE_BUILD_TYPE=Release ..

header "Clean Conan"

confirm "Clean Conan builds? [y/N]" && conan remove -f "*" --builds

confirm "Clean Conan src? [y/N]" && conan remove -f "*" --src

confirm "Clean Conan system-reqs? [y/N]" && conan remove -f "*" --system-reqs

header "Prep for cache upload"

confirm "Fix short paths? [y/N]" && cd ${CONAN_USER_HOME} && find .conan/ -name .conan_link -exec perl -pi -e 's=$ENV{CONAN_USER_HOME_SHORT}=CONAN_USER_HOME_SHORT=g' {} +

confirm "Clean up .conan_link.bak? [y/N]" && cd ${CONAN_USER_HOME} && find -name .conan_link.bak -execdir rm {} \;

confirm "List files over ${LFS_LIMIT}M? [y/N]" && cd ${CONAN_USER_HOME} && find .conan short -type f -size +${LFS_LIMIT}M -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'

confirm "LFS track files over ${LFS_LIMIT}M? [y/N]" && cd ${CONAN_USER_HOME} && find .conan short -type f -size +${LFS_LIMIT}M -execdir git lfs track {} \;

header "Upload cache"

confirm "Add everything to git? [y/N]" && cd ${CONAN_USER_HOME} && git add -A

confirm "Commit to git? [y/N]" && cd ${CONAN_USER_HOME} && git commit -m "Local build"

confirm "Push to GitHub? [y/N]" && cd ${CONAN_USER_HOME} && git push

header "Test cache locally"

confirm "TEST: Prepare short paths [y/N]" && cd ${CONAN_USER_HOME} && find .conan/ -name .conan_link -exec perl -pi -e 's=CONAN_USER_HOME_SHORT=$ENV{CONAN_USER_HOME_SHORT}=g' {} +

confirm "TEST: Remove old build directory? [y/N]" && cd ${APPLICATION_DIR} && rm -rf build

confirm "TEST: Create build directory? [y/N]" && cd ${APPLICATION_DIR} && mkdir build

confirm "TEST: Start REGULAR build? [y/N]" && cd ${APPLICATION_DIR} && cd build && cmake -DUPDATE_CONAN=OFF -DCMAKE_BUILD_TYPE=Release ..
