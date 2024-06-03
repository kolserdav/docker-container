#!/usr/bin/bash

set -e

oss=$(sh $(dirname "$0")/../os.sh)
oss_arr=($(echo $oss | tr "," "\n"))
i=0
ERRORS=()

for os in "${oss_arr[@]}"
do
    echo "Test OS $os ..."
    releases=$(sh $(dirname "$0")/../$os/releases.sh)
    releases_arr=($(echo $releases | tr "," "\n"))

    for release in "${releases_arr[@]}"
    do
      image=test-$os:$release
      docker build --build-arg="RELEASE=$release" -f $(dirname "$0")/Dockerfile.$os -t $image .
      i=$((i+1))
      port=800$i
      container_name=test-$os-$release
      docker run -p "$port:80" --name $container_name -d $image
      res=$(curl "http://127.0.0.1:$port")
      echo "Request result:"
      echo "$res"
      if [[ $res == *"nginx"* ]]; then
        echo "Success test $image"
      else
        echo "Failed test $image"
        ERRORS+=($image)
      fi

      docker stop $container_name
      docker rm $container_name
      docker image rm -f $image
    done
done

if [ ${#a[@]} != 0 ]; then
  echo "Test finished with ${#a[@]} errors"
  exit 1
else
  echo "Test successfully finished with 0 errors"
fi