#!/usr/bin/bash

set -e

set -a 
source .env
set +a

user=$(whoami)
platform=$(sh $(dirname "$0")/../constants/platform.sh)
platform_arr=($(echo $platform | tr "," "\n"))

for platform_name in "${platform_arr[@]}"
do  
  arch=$(echo $platform_name | sed "s/linux\///g")
  rootfs_arch=$ROOTFS_PATH/$platform_name
  echo "Creating rootfs for arch $arch to $rootfs_arch"
  sudo rm -rf $rootfs_arch
  qemu=$arch
  if [ $arch = 'ppc64le' ]; then
    arch=ppc64el
  fi

  sudo debootstrap --arch=$arch --foreign stable $rootfs_arch/
  
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

