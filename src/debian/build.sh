#!/usr/bin/bash

set -e

OS=debian

if [ -f .env ]; then
    set -a 
    source .env
    set +a
fi

rootfs_script=$(dirname "$0")/create-rootfs.sh

releases=$(sh $(dirname "$0")/releases.sh)
releases_arr=($(echo $releases | tr "," "\n"))

dockerfile_path=$(dirname "$0")/Dockerfile

for release in "${releases_arr[@]}"
do
    latest=""
    if [ $release = 'bookworm' ]; then
        latest="-t=ghcr.io/kolserdav/$OS:latest"
    fi
    echo "Starting build $OS:$release"
    sh -c "$rootfs_script $release"

    lin_path=$ROOTFS_PATH/$OS/$release/linux
    i386=$lin_path/i386
    if [ -d $i386 ]; then
        echo "Moving $i386"
        sudo mv $i386 $lin_path/386
    fi

    platform=$(sh -c "$(dirname "$0")/../platform.sh $OS $release")
    echo "Starting build $ROOTFS_PATH for platforms $platform"
    cache_from="--cache-from=ghcr.io/kolserdav/$OS:$release"
    docker buildx build --platform=$platform -f=$dockerfile_path --build-arg="RELEASE=$release" --build-arg="OS=$OS" \
     --provenance=false --output='type=registry' $cache_from -t="ghcr.io/kolserdav/$OS:$release" $latest $ROOTFS_PATH
done