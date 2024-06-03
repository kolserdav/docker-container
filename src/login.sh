#!/usr/bin/bash

set -e

if [ -f .env ]; then
    set -a 
    source .env
    set +a
fi

echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin