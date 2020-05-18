#!/bin/sh -l

cache_hit=0
echo "::set-output name=cache-hit::$cache_hit"

BOT_NAME=$1
BOT_TOKEN=$2
CACHE_NAME=$3
EXPLICIT_KEY=$4
FALLBACK_KEY=$5
WHERE_TO_CHECKOUT=$6
BRANCH_NAME=$7

echo "Running as $BOT_NAME using cache $CACHE_NAME"

# Check out cache - shallow and fetch
echo "Checking out at $WHERE_TO_CHECKOUT"

cd $WHERE_TO_CHECKOUT

#git clone https://${BOT_NAME}:${BOT_TOKEN}@github.com/${CACHE_NAME}.git --branch=${BRANCH_NAME}

# If it fails - exit 1

# Check if explicit key exits

echo "Trying explicit key $EXPLICIT_KEY"

# If it does - check out explicit and set cache_hit to 1

# If it doesn't check if fallback exits

echo "Trying explicit key $FALLBACK_KEY"

# If it does - check out fallback and set cache_hit to 2

# If it doesn't - set cache_hit to 0

echo "::set-output name=cache-hit::$cache_hit"
