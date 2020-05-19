#!/bin/sh -l

cd $CONAN_USER_HOME

#git add .conan/*
git status

# If no changes were made - exit 0

# if cache_hit was 1 (explicit) - should you update?

# If cache_hit was 0 (miss) or 2 (fallback) - make a new explicit
