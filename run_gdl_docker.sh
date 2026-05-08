#!/usr/bin/env bash

if ! docker image inspect gsdo_downloader_gdl; then
docker build -t gsdo_downloader_gdl -f docker/Dockerfile .
fi

docker run -it -u $(id -u):$(id -g) \
	-v "$(pwd):/work" --workdir /work \
	-e HOME=/tmp --detach gsdo_downloader_gdl
