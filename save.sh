#!/bin/sh -l

BOT_NAME=$1
BOT_TOKEN=$2
CACHE_NAME=$3
EXPLICIT_KEY=$4
FALLBACK_KEY=$5
WHERE_TO_CHECKOUT=$6
BRANCH_NAME=$7

echo "Checkout is at $WHERE_TO_CHECKOUT"
echo "Explicit key $EXPLICIT_KEY"
echo "Fallback key $FALLBACK_KEY"
cache_hit=1

# If no changes were made - exit 0

# if cache_hit was 1 (explicit) - should you update?

# If cache_hit was 0 (miss) or 2 (fallback) - make a new explicit

echo "::set-output name=cache-hit::$cache_hit"
