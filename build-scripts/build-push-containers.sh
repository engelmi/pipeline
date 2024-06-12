#!/bin/bash -xe
#
# Copyright Contributors to the Eclipse BlueChi project
#
# SPDX-License-Identifier: LGPL-2.1-or-later

# The 1st parameter is the image name
IMAGE="$1"

# The 2nd parameter is optional and it specifies the container architecture. If omitted, all archs will be built.
OS="${3:-linux}"
ARCHITECTURES="${2:-amd64 arm64}"
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR="containers"

function push(){
    buildah manifest push --all $IMAGE "docker://quay.io/bluechi/$IMAGE"
}

function build(){
    # remove old image, ignore result
    buildah manifest rm $IMAGE &> /dev/null || true

    buildah manifest create $IMAGE

    for arch in $ARCHITECTURES; do
        for os in $OS; do
            buildah bud --tag "quay.io/bluechi/$IMAGE" \
                --manifest $IMAGE \
                --os ${os} \
                --arch ${arch} \
                -f ${ROOT_DIR}/${IMAGE} \
                ${ROOT_DIR}
        done
    done
}

[ -z ${IMAGE} ] && echo "Requires image name. One of ['bluechi-workshop']." && exit 1

echo "Building containers and manifest for '${IMAGE}'"
echo ""
build
if [ "${PUSH_MANIFEST}" == "yes" ]; then
    push
fi
