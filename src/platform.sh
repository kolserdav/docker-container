#!/usr/bin/bash

# Supported ports: https://www.debian.org/ports/#portlist-released

platform=linux/i386,linux/amd64,linux/arm64,linux/ppc64le,linux/s390x
#platform=linux/i386

if [ $1 = 'debian' ] && [ $2 = 'buster' ]; then
  platform=$(echo $platform | sed "s/linux\/s390x,*//g" | sed "s/,*$//")
  platform=$(echo $platform | sed "s/linux\/ppc64le,*//g" | sed "s/,*$//")
fi

echo $platform