#!/usr/bin/env make
SHELL=/bin/bash

DOCKER=podman

NO_NETWORK=
NETWORK=$$([ -n "${NO_NETWORK}" ] && echo "none" || echo "host")

ANTIGRAVITY_IMAGE=antigravity_arch
ANTIGRAVITY_CONTAINER=antigravity_arch
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
		-t ${ANTIGRAVITY_IMAGE} .;

run:
	${DOCKER} run --rm -it \
		--shm-size 2g \
		--network ${NETWORK} \
		--name "${ANTIGRAVITY_CONTAINER}" \
		${WITH_USERNS} \
		--security-opt label=type:container_runtime_t \
		-v "${CURDIR}"/docker_files/home/.cache:/home/${UNAME}/.cache \
		-v "${CURDIR}"/docker_files/home/.config:/home/${UNAME}/.config \
		-v "${CURDIR}"/docker_files/home/.gemini:/home/${UNAME}/.gemini \
		-v "${CURDIR}"/docker_files/home/.antigravitycli:/home/${UNAME}/.antigravitycli \
		--workdir /home/${UNAME} \
		${ANTIGRAVITY_IMAGE}

logs:
	@ ${DOCKER} logs -f "${ANTIGRAVITY_CONTAINER}"

bash:
	@ ${DOCKER} exec -it "${ANTIGRAVITY_CONTAINER}" /bin/bash
