#!/bin/sh -l

echo "Path $1"
echo "Explicit key $2"
echo "Fallback key $3"
cache_hit=1
echo "::set-output name=cache-hit::$cache_hit"
