#!/bin/bash

IMAGE_NAME="yokogawa/keepalived-reload-check"

usage() {
  echo >&2 "Usage:"
  echo >&2 "  ${0} all or ${0} \$VERSION"
  echo >&2 "    ex. ${0} 1.2.13"
  exit
}


_all() {
  # v1.2
  for i in {13..24}; do 
    local VERSION=1.2.${i}
    echo "build ${VERSION}."
    build ${VERSION}
  done
  # v1.3
  for i in {0..5}; do 
    local VERSION=1.3.${i}
    echo "build ${VERSION}."
    build ${VERSION}
  done
}

_build() {
  local VERSION=${1}
  if [ -n "${VERSION}" ]; then
    docker build -t ${IMAGE_NAME}:${VERSION} --build-arg KEEPALIVED_VERSION=${VERSION} .
    docker image ls ${IMAGE_NAME}:${VERSION}
  else
    usage
  fi
}   

# main

case ${1} in
  all)
    all
    ;;
  1.*)
    _build ${1}
    ;;
  *)
    usage
    ;;
esac

