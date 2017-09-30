#!/bin/bash

# build docker image
docker build --tag="crukci-bioinformatics/shiny-base" .

# or to build docker image from scratch without using the cache
#docker build --tag="crukci-bioinformatics/shiny-base" --no-cache .

# remove dangling/untagged images
#docker rmi $(docker images --filter "dangling=true" -q --no-trunc)

