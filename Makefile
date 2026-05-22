#!/usr/bin/env make
SHELL=/bin/bash

DOCKER=podman

HOST_PATH_TO_PROJECT="$$(pwd)"
CONTAINER_PATH_TO_MOUNT_PROJECT=/home/"$$(whoami)"/"$$(basename $$(pwd))"

NO_NETWORK=
NETWORK=$$([ -n "${NO_NETWORK}" ] && echo "none" || echo "host")

NVIDIA_GPU=$$([ -n "${WITH_NVIDIA_GPU}" ] && echo $$([ DOCKER = "podman" ] && echo "--device nvidia.com/gpu=all --security-opt=label=disable" || echo "--privileged --gpus=all"))

GEMINI_IMAGE=gemini_arch
GEMINI_CONTAINER=gemini_arch
UUID=$(shell id -u)
GUID=$(shell id -g)
UNAME=$(shell whoami)

ARCH_BASE_IMAGE=techgk/arch:latest

WITH_USERNS=$$(eval [ "podman" == "${DOCKER}" ] && echo "--userns=keep-id")

MAKERC=.makerc
include ${CURDIR}/${MAKERC}

list:
	@ $(MAKE) -pRrq -f Makefile : 2>/dev/null \
		| grep -e "^[^[:blank:]]*:$$\|#.*recipe to execute" \
		| grep -B 1 "recipe to execute" \
		| grep -e "^[^#]*:$$" \
		| sed -e "s/\(.*\):/\1/g" \
		| sort

build:
	@ ${DOCKER} build \
		--net=pasta:-4 \
		--build-arg USER_ID=${UUID} \
		--build-arg GROUP_ID=${GUID} \
		--build-arg USER_NAME=${UNAME} \
		--build-arg ARCH_BASE_IMAGE=${ARCH_BASE_IMAGE} \
		-t ${GEMINI_IMAGE} .;

run:
	${DOCKER} run --rm -it \
		--shm-size 2g \
		--network ${NETWORK} \
		--name "${GEMINI_CONTAINER}" \
		${WITH_USERNS} \
		--security-opt label=type:container_runtime_t \
		-v "${CURDIR}"/docker_files/home:/home/${UNAME} \
		-v "${HOST_PATH_TO_PROJECT}":"${CONTAINER_PATH_TO_MOUNT_PROJECT}" \
		--workdir "${CONTAINER_PATH_TO_MOUNT_PROJECT}" \
		${GEMINI_IMAGE}

logs:
	@ ${DOCKER} logs -f "${GEMINI_CONTAINER}"

bash:
	@ ${DOCKER} exec -it "${GEMINI_CONTAINER}" /bin/bash
