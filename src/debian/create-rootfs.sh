#!/usr/bin/bash

set -e

OS=debian

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
  if [ $arch = 'ppc64le' ]; then
    arch=ppc64el
  fi

  sudo debootstrap --arch=$arch --foreign $rel $rootfs_arch/
  
  if [ $qemu = 'arm64' ]; then
    qemu=aarch64
  fi
  if [ $qemu = 'amd64' ]; then
    qemu=x86_64
  fi
  sudo cp /usr/bin/qemu-$qemu-static $rootfs_arch/usr/bin
  sudo chroot $rootfs_arch /bin/bash -c "/debootstrap/debootstrap --second-stage"
  sudo chown $user:$user -R $rootfs_arch/
done

