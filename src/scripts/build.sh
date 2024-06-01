#!/usr/bin/bash

set -e

set -a 
source .env
set +a

platform=$(sh $(dirname "$0")/../constants/platform.sh)
echo "Starting build $ROOTFS_PATH for platforms $platform"

i386=$ROOTFS_PATH/linux/i386
if [ -f $i386 ]; then
    mv $i386 $ROOTFS_PATH/linux/386
fi

docker buildx build --platform=$platform -f=$PWD/Dockerfile --output='type=registry' --tag='ghcr.io/kolserdav/docker-container:latest'  $ROOTFS_PATH
