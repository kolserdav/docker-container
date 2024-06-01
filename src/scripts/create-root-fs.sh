#!/usr/bin/bash

set -e

generate_platform() {
  echo '#!/usr/bin/bash' > $platform_generated_path
  echo "platform=$platform" >> $platform_generated_path
  echo "echo $platform" >> $platform_generated_path
}

platform_generated_path=$(dirname "$0")/../constants/generated/platform.sh

user=$(whoami)

platform=$(sh $(dirname "$0")/../constants/platform.sh)
platform=$(echo $platform | sed "s/linux\///g")
platform_arr=($(echo $platform | tr "," "\n"))

generate_platform

rootfs=$(sh $(dirname "$0")/../constants/rootfs.sh)

for arch in "${platform_arr[@]}"
do  
  echo "Creating rootfs for arch $arch"
  rootfs_arch=$rootfs-$arch
  sudo rm -rf $rootfs_arch
  sudo debootstrap --arch=$arch --foreign stable $rootfs_arch/
  qemu=$arch
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

