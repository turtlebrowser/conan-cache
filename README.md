# Conan Cache GitHub Action

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
* Create a bot for authenication [https://developer.github.com/v3/guides/managing-deploy-keys/#machine-users]
* Create a repo for your OS's conan cache
* Give your machine-user rights on your cache repo
* Create a personal access token for your machine-user [https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line]
* Add the token as a secret to your workflow [https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets]
* Make sure the bot has write access to your cache repo

## Make an empty repo

This is the structure that is expected by conan-cache

~~~
git clone git@github.com:turtlebrowser/conan-cache.git
mkdir .conan && touch .conan/conan-cache.marker
touch .gitattributes
mkdir short && touch short/conan-cache.marker
git add -A
git commit -m "Setup cache"
git push
~~~

Add the bot account as collaborator on the repo

## How to use locally

Might be needed to pull locally
~~~
git clone git@github.com:turtlebrowser/conan-cache-turtlebrowser.git
cd conan-cache-turtlebrowser
git checkout host-Linux-target-Linux-master
git lfs pull
export CONAN_USER_HOME=`pwd`
~~~
