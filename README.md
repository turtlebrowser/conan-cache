# conan-cache action

LINUX SPECIFIC ACTION: This action caches a .conan directory

## Inputs

### `path`

**Required** The path to the directory containing .conan.

### `key`

**Required** The perferred key to look up, and the key to store

### `fallback`

**Optional** If no hit on key, fallback key to try

## Outputs

### `cache-hit`

Cache a hit on a key: no hit (0), explicit key (1), fallback key (2)

## Example usage
~~~~
    - name: Cache Conan modules
      if: matrix.os == 'ubuntu-latest'
      id: cache-conan
      uses: turtlebrowser/conan-cache@master
      env:
        cache-name: turtlebrowser/conan-cache-linux
      with:
        path: ${{ env.CONAN_USER_HOME }}
        key: ${{ runner.os }}-${{ hashFiles('conanfile.py') }}
        fallback: ${{ runner.os }}
~~~~

## Setup
* Create a machine-user for authenication [https://developer.github.com/v3/guides/managing-deploy-keys/#machine-users]
* Create a repo for your OS's conan cache
* Give your machine-user rights on your cache repo
* Create a personal access token for your machine-user [https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line]
* Add the token as a secret to your workflow [https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets]

## Make an empty repo
~~~
git clone git@github.com:turtlebrowser/conan-cache.git
mkdir .conan
touch .conan/conan-cache.marker
git add .conan/conan-cache.marker
git commit -m "Setup cache"
git push
touch .gitattributes && git add .gitattributes && git commit -m "Add .gitattributes" && git push
~~~

Add the bot account as collaborator on the repo

## Notes

Might be needed to pull
~~~
git lfs pull
~~~
