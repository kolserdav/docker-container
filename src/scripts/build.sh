#!/usr/bin/bash

set -e

set -a 
source .env
set +a

rootfs_script=$(dirname "$0")/create-rootfs.sh

platform=$(sh $(dirname "$0")/../constants/platform.sh)
echo "Starting build $ROOTFS_PATH for platforms $platform"

i386=$ROOTFS_PATH/linux/i386
if [ -f $i386 ]; then
    mv $i386 $ROOTFS_PATH/linux/386
fi

releases=$(sh $(dirname "$0")/../constants/releases.sh)
releases_arr=($(echo $releases | tr "," "\n"))

for release in "${releases_arr[@]}"
do
    latest=""
    if [ $release = 'bookworm' ]; then
        latest="-t=ghcr.io/kolserdav/debian:latest"
    fi
    echo "Starting build debian:$release"
    sh -c "$rootfs_script $release"
    docker buildx build --platform=$platform -f=$PWD/Dockerfile --build-arg="RELEASE=$release" --output='type=registry' -t="ghcr.io/kolserdav/debian:$release" $latest $ROOTFS_PATH
done