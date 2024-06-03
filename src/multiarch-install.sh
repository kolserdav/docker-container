#!/usr/bin/bash

set -e

docker buildx create --name multiarch --driver docker-container --use