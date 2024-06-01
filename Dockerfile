FROM --platform=$BUILDPLATFORM scratch AS build
ARG TARGETPLATFORM
ARG BUILDPLATFORM

ARG ROOTFS=rootfs
ARG ROOTFS_ARCH=$ROOTFS-$TARGETPLATFORM

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /

COPY $ROOTFS_ARCH/bin /bin
COPY $ROOTFS_ARCH/etc /etc
COPY $ROOTFS_ARCH/home /home
COPY $ROOTFS_ARCH/media /media
COPY $ROOTFS_ARCH/lib64 /lib64
COPY $ROOTFS_ARCH/lib /lib
COPY $ROOTFS_ARCH/root /root
COPY $ROOTFS_ARCH/run /run
COPY $ROOTFS_ARCH/sbin /sbin
COPY $ROOTFS_ARCH/sys /sys
COPY $ROOTFS_ARCH/srv /srv
COPY $ROOTFS_ARCH/usr /usr
COPY $ROOTFS_ARCH/tmp /tmp
COPY $ROOTFS_ARCH/var /var

RUN apt-get update && apt-get install nginx -y

WORKDIR /home/app

COPY install.sh /home/app/install.sh

CMD ["nginx", "-g", "daemon off;"]