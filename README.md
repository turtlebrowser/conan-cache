# Conan Cache GitHub Action

![CI](https://github.com/turtlebrowser/conan-cache/workflows/CI/badge.svg?branch=master)

The action uses a GitHub repository as a cache for a .conan directory to speed up very slow builds. It was made specifically to offset the cost of a conan-qt build with QtWebEngine turned on. The cache can be populated in the GitHub action pipeline, or offline on a computer and then pushed to the repo. This second workflow is to help with builds that are too slow for GitHub Actions, where a step cannot take longer than 6 hours, and has limited disk space. See below for how to do an offline filling of the cache. 

The setup process for the action requires the creation of a bot account and a GitHub repo to hold the cache. See below for details.

**When to use**: The conan-cache action was created to make CI builds possible for projects where building conan modules takes a lot of time, "a lot of time" is here measured in hours. The cache is also useful for local builds. If you have an artifactory then that is probably a better solution than this. Upload a prebuilt artifact there. (That might be added as an option to conan-cache in the future).

**Works on**: Linux, Windows and MacOS 

This action was inspired by the builtin [GitHub Cache Action](https://help.github.com/en/actions/configuring-and-managing-workflows/caching-dependencies-to-speed-up-workflows), which might be more than adequate for your needs. See [here](https://github.com/turtlebrowser/conan-cache/blob/master/README.md#example-using-the-builtin-github-cache-instead-for-conan) for how you can use it for conan modules. The builtin GitHub Cache Action has some [limitations](https://help.github.com/en/actions/configuring-and-managing-workflows/caching-dependencies-to-speed-up-workflows#usage-limits-and-eviction-policy), however, and tends to have a lot of intermittant failures to retrieve the cache, which can be unacceptable when building without takes a long time.

See also [this trick](https://github.com/turtlebrowser/conan-cache/blob/master/README.md#using-github-cache-action-as-a-pre-cache-since-git-lfs-costs-money) using a combination of GitHub Cache Action and Conan Cache.

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

### `lfs_limit`
**Optional** In number of MB. Files with a size larger than lfs_limit are added to Git Large File Storage (LFS), defaults to 50MB, GitHub supports max 100MB, and will generate a warning at 50MB files.

## Outputs

### `cache-hit`
The state of the cache hit: no hit (0), hit on explicit key (1), hit on fallback key (2).
(**An explicit key is represented in the repo as a tag, a fallback key is represented as a branch**)

## Example usage

Assumed environment
~~~~
    env:
      CONAN_USER_HOME: "${{ github.workspace }}/release/"
      CONAN_USER_HOME_SHORT: "${{ github.workspace }}/release/short"
~~~~

Action setup
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

After conan has filled the cache, clean it up
~~~~
    - name: Clean up Conan
      run: |
        conan remove -f "*" --builds
        conan remove -f "*" --src
        conan remove -f "*" --system-reqs
~~~~

Use the _cache-hit_ output
~~~~
      - name: On cache miss add bincrafters remote
        if: ${{ steps.cache-conan.outputs.cache-hit == 0 }}
        run: conan remote add bincrafters https://api.bintray.com/conan/bincrafters/public-conan
~~~~

## Using GitHub Cache Action as a pre-cache (since git lfs costs money)

A trick that can be used is to use the [GitHub Cache Action](https://help.github.com/en/actions/configuring-and-managing-workflows/caching-dependencies-to-speed-up-workflows) as a first level cache. It has limited space and often fails to fetch the cache for unknown reasons, but many times it will suffice and you can save on git lfs bandwith costs. Here is an example of how that could look. Note that the example doesn't use _restore-keys_, that is because the GitHub Cache Action's _cache-hit_ is a boolean that will only signal if the _key_ was hit (this is **not** how it works in Conan Cache). Also, if the _key_ doesn't hit, then you most likely have a change in your conanfile.py and should fetch from Conan Cache anyway.

Note: Make sure it has been added to the Conan Cache properly using this action first, otherwise the short paths will be wrong on Windows. They are fixed in save.sh.

~~~~
    # Check if GitHub Cache has it, because that's free
    - name: Using the builtin GitHub Cache Action for .conan
      id: github-cache-conan
      uses: actions/cache@v1
      env:
        cache-name: cache-conan-modules
      with:
        path: ${{ env.CONAN_USER_HOME }}
        key: host-${{ runner.os }}-target-${{ runner.os }}-${{ hashFiles('conanfile.py') }}
        
    # If GitHub Cache doesn't have it, get from Conan Cache (has git lfs cost)
    - name: Cache Conan modules
      if: steps.github-cache-conan.outputs.cache-hit != 'true'
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

## Environment in manual steps below

### `CACHE_GITHUB`
GitHub account that has the cache repo
### `CACHE_GITHUB_REPO`
Name of the cache repo
### `CONAN_USER_HOME`
Conan variable, sets the directory in which .conan will be found
### `CONAN_USER_HOME_SHORT`
Conan variable, sets the directory which will be used for [Conan short paths](https://docs.conan.io/en/latest/reference/conanfile/attributes.html#short-paths) (Windows only)
### `LFS_LIMIT`
The file size at which a file should be added to Git LFS rather than to git. GitHub sets a max file size of 100MB.

## Make an empty repo

This is the structure that is expected by conan-cache of an empty cache

~~~
git clone git@github.com:${CACHE_GITHUB}/${CACHE_GITHUB_REPO}.git
cd ${CACHE_GITHUB_REPO}
mkdir .conan && touch .conan/conan-cache.marker
touch .gitattributes
~~~

Fill the .gitattributes with this contents (especially important for Windows)
~~~
$ cat .gitattributes
* -text
~~~

~~~
mkdir short && touch short/conan-cache.marker
git add -A
git commit -m "Setup cache"
git push
~~~

## How to use locally

~~~
git clone git@github.com:${CACHE_GITHUB}/${CACHE_GITHUB_REPO}.git
cd ${CACHE_GITHUB_REPO}
git checkout <branch>
git lfs pull
export CONAN_USER_HOME="c:/release"
export CONAN_USER_HOME_SHORT=${CONAN_USER_HOME}/short
find .conan/ -name .conan_link -exec perl -pi -e 's=CONAN_USER_HOME_SHORT=$ENV{CONAN_USER_HOME_SHORT}=g' {} +
~~~

## Populating the cache locally

### Prep: Creating the platform branch (first time)

~~~
export CONAN_USER_HOME="c:/release"
export CONAN_USER_HOME_SHORT=${CONAN_USER_HOME}/short
git clone git@github.com:${CACHE_GITHUB}/${CACHE_GITHUB_REPO}.git $CONAN_USER_HOME
cd $CONAN_USER_HOME
git checkout -b <branch>
git push -u origin <branch>
~~~

### Prep: Using the platform branch (after the first time)

~~~
export CONAN_USER_HOME="c:/release"
export CONAN_USER_HOME_SHORT=${CONAN_USER_HOME}/short
git clone git@github.com:${CACHE_GITHUB}/${CACHE_GITHUB_REPO}.git $CONAN_USER_HOME
cd $CONAN_USER_HOME
git clean -df
git checkout .
git checkout <branch>
git pull
git lfs pull
find .conan/ -name .conan_link -exec perl -pi -e 's=CONAN_USER_HOME_SHORT=$ENV{CONAN_USER_HOME_SHORT}=g' {} +
~~~

The final step is to insert the local CONAN_USER_HOME_SHORT path instead of the placeholder

### Populate: Build the target project with CONAN_USER_HOME and CONAN_USER_HOME_SHORT set

This step assumes it is being run in the same shell as one of the prep steps.

Build the target project, this will fill the cache. Then remove traces of the build process. Replace hardcoded paths with the placeholder _CONAN_USER_HOME_SHORT_. Then add any files exeeding the LFS limit for the project to _git lfs_. Add/remove everything as is with _git add -A_, commit and push. Start a build on GitHub and the branch will be tested and tagged automatically.

~~~
cd <path to project checkout>
git pull
rm -rf build
# Make a cmake switch to turn on UPDATE build obsolete:
# mkdir build && cd build && cmake -DUPDATE_CONAN=ON -DCMAKE_BUILD_TYPE=Release ..
mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release ..
conan remove -f "*" --builds
conan remove -f "*" --src
conan remove -f "*" --system-reqs
cd $CONAN_USER_HOME
find .conan/ -name .conan_link -exec perl -pi -e 's=$ENV{CONAN_USER_HOME_SHORT}=CONAN_USER_HOME_SHORT/=g' {} +
export LFS_LIMIT=50
find .conan short -type f -size +${LFS_LIMIT}M -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'
find .conan short -type f -size +${LFS_LIMIT}M -execdir git lfs track {} \;
git add -A
git commit -m "Local build"
git push
~~~

## Example using the builtin GitHub Cache Action instead for .conan

Assumed environment
~~~~
    env:
      CONAN_USER_HOME: "${{ github.workspace }}/release/"
      CONAN_USER_HOME_SHORT: "${{ github.workspace }}/release/short"
~~~~

Action setup
~~~
    - name: Using the builtin GitHub Cache Action for .conan
      if: matrix.os == 'windows-latest'
      id: cache-conan
      uses: actions/cache@v1
      env:
        cache-name: cache-conan-modules
      with:
        path: ${{ env.CONAN_USER_HOME }}
        key: ${{ runner.os }}-builder-${{ env.cache-name }}-${{ hashFiles('conanfile.py') }}
        restore-keys: ${{ runner.os }}-builder-${{ env.cache-name }}-
~~~
