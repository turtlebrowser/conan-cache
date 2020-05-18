# conan-cache action

This action caches a .conan directory

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
  id: cache-conan
  uses: actions/conan-cache@v1
  env:
    cache-name: cache-conan-modules
  with:
    path: ${{ env.CONAN_USER_HOME }}
    key: ${{ runner.os }}-builder-${{ env.cache-name }}-${{ hashFiles('conanfile.py') }}
    fallback: ${{ runner.os }}-builder-${{ env.cache-name }}-
~~~~
