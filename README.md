# Conan Cache GitHub Action

The action uses a GitHub repository as a cache for a .conan directory to speed up very slow builds. It was made specifically to offset the cost of a conan-qt build with QtWebEngine turned on. The cache can be populated in the GitHub action pipeline, or offline on a computer and then pushed to the repo. This second workflow is to help with builds that are too slow for GitHub Actions, where a step cannot take longer than 6 hours, and has limited disk space. The setup requires the creation of a bot account and a repo to hold the cache.

## Inputs

### `bot_name`
**Required** The name of the GitHub bot

### `bot_token`
**Required** The personal access token of the GitHub bot

### `cache_name`
**Required** The GitHub repo used for this cache

### `key`
**Required** An explicit key to store this cache under

### `target_os`
**Optional** Target OS if different from host OS

## Outputs

### `cache-hit`
Cache a hit on a key: no hit (0), explicit key (1), fallback key (2)

## Example usage
~~~~
    - name: Cache Conan modules
      id: cache-conan
      uses: turtlebrowser/conan-cache@master
      with:
          bot_name: ${{ secrets.BOT_NAME }}
          bot_token: ${{ secrets.BOT_TOKEN }}
          cache_name: ${{ env.CACHE_GITHUB }}/${{ env.CACHE_GITHUB_REPO }}
          key: host-${{ runner.os }}-target-${{ runner.os }}-${{ hashFiles('conanfile.py') }}
          target_os: ${{ runner.os }}
          lfs_limit: 60
~~~~

## Setup
* Create a GitHub bot account that will be used to manage the conan cache
* Create a GitHub repo for your conan cache
* Add your bot as a collaborator on the cache with write access
* Create a personal access token for your bot [https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line]
* Add the personal access token as a secret to your repos workflow [https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets]
* Follow the instructions below to set up an empty cache

## Make an empty repo

This is the structure that is expected by conan-cache

~~~
git clone git@github.com:${CACHE_GITHUB}/${CACHE_GITHUB_REPO}.git
mkdir .conan && touch .conan/conan-cache.marker
touch .gitattributes
mkdir short && touch short/conan-cache.marker
git add -A
git commit -m "Setup cache"
git push
~~~

## How to use locally

Might be needed to pull locally
~~~
git clone git@github.com:${CACHE_GITHUB}/${CACHE_GITHUB_REPO}.git
cd ${CACHE_GITHUB_REPO}
git checkout <branch>
git lfs pull
export CONAN_USER_HOME=`pwd`
export CONAN_USER_HOME_SHORT=${CONAN_USER_HOME}/short
find .conan/ -name .conan_link -exec perl -pi -e 's=CONAN_USER_HOME_SHORT=$ENV{CONAN_USER_HOME_SHORT}=g' {} +
~~~
