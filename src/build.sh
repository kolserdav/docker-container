#!/usr/bin/bash

set -e

oss=$(sh $(dirname "$0")/os.sh)
oss_arr=($(echo $oss | tr "," "\n"))

for os in "${oss_arr[@]}"
do
    echo "Build OS $os ..."
    sh -c "$(dirname $0)/$os/build.sh"
done