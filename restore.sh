#!/bin/sh -l

echo "Path $1"
echo "Explicit key $2"
echo "Fallback key $3"
cache_hit=1

# Check out cache - shallow and fetch

# If it fails - exit 1

# Check if explicit key exits

# If it does - check out explicit and set cache_hit to 1

# If it doesn't check if fallback exits

# If it does - check out fallback and set cache_hit to 2

# If it doesn't - set cache_hit to 0

echo "::set-output name=cache-hit::$cache_hit"
