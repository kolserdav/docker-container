#!/usr/bin/bash

set -e


if [ -f .env ]; then
    set -a 
    source .env
    set +a
fi

rootfs_script=$(dirname "$0")/create-rootfs.sh

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

    i386=$ROOTFS_PATH/$release/linux/i386
    if [ -d $i386 ]; then
        echo "Moving $i386"
        sudo mv $i386 $ROOTFS_PATH/$release/linux/386
    fi

    platform=$(sh -c "$(dirname "$0")/../platform.sh debian $release")
    echo "Starting build $ROOTFS_PATH for platforms $platform"
    docker buildx build --platform=$platform -f=$PWD/Dockerfile --build-arg="RELEASE=$release" --output='type=registry' -t="ghcr.io/kolserdav/debian:$release" $latest $ROOTFS_PATH
done