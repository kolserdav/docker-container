#!/usr/bin/bash

set -e

set -a 
source .env
set +a

echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin