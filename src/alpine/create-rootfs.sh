#!/usr/bin/bash

set -e

OS=alpine

if [ -f .env ]; then
    set -a 
    source .env
    set +a
fi

user=$(whoami)

releases=$(sh $(dirname "$0")/releases.sh)
releases_arr=($(echo $releases | tr "," "\n"))

rel="none"
for release in "${releases_arr[@]}"
do
  if [ $release = $1 ]; then
    rel=$release
  fi
done

if [ $rel = "none" ]; then
  echo "Release not passed or not accept. Required one of: $releases, received: $1"
  exit 1
fi

platform=$(sh -c "$(dirname "$0")/../platform.sh $OS $rel")
platform_arr=($(echo $platform | tr "," "\n"))

for platform_name in "${platform_arr[@]}"
do  
  arch=$(echo $platform_name | sed "s/linux\///g")

  rootfs_arch=$ROOTFS_PATH/$OS/$rel/$platform_name
  if [ -d $rootfs_arch ]; then
    sudo rm -rf $rootfs_arch
  fi
  sudo mkdir -p $rootfs_arch
  echo "Creating rootfs for arch $arch to $rootfs_arch"
  
  qemu=$arch
  
  if [ $qemu = 'arm64' ]; then
    qemu=aarch64
  fi
  if [ $qemu = 'amd64' ]; then
    qemu=x86_64
  fi
  if [ $qemu = 'i386' ]; then
    qemu=x86
  fi

  version=$rel
  if [ $rel = 'v3.18' ]; then
    version='3.18.6'
  fi
  if [ $rel = 'v3.19' ]; then
    version='3.19.1'
  fi
  if [ $rel = 'v3.20' ]; then
    version='3.20.0'
  fi

  tar_name=alpine-minirootfs-$version-$qemu.tar.gz
  sudo wget https://dl-cdn.alpinelinux.org/alpine/$rel/releases/$qemu/$tar_name -O $rootfs_arch/$tar_name
  sudo tar -xvzf $rootfs_arch/$tar_name -C $rootfs_arch
  sudo rm $rootfs_arch/$tar_name
  sudo chown $user:$user -R $rootfs_arch/
done

