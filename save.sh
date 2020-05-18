#!/bin/sh -l

echo "Path $1"
echo "Explicit key $2"
echo "Fallback key $3"
cache_hit=1

# If no changes were made - exit 0

# if cache_hit was 1 (explicit) - should you update?

# If cache_hit was 0 (miss) or 2 (fallback) - make a new explicit

echo "::set-output name=cache-hit::$cache_hit"
