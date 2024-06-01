#!/usr/bin/bash

set -e

platform=$(sh $(dirname "$0")/constants/generated/platform.sh)

docker buildx build --platform=$platform --output="type=image" --tag="conhos-node:latest" .
