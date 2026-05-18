#!/usr/bin/env bash

if ! docker image inspect gsdo_downloader_gdl &>/dev/null; then
	docker build -t gsdo_downloader_gdl -f docker/Dockerfile .
fi

mkdir -p data

docker run -it -u $(id -u):$(id -g) \
	-v "$(pwd):/work" --workdir /work \
	-e HOME=/tmp "$@" gsdo_downloader_gdl
