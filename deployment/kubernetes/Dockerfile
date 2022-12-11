#
# A utility Docker container that has the curl and bash tools installed
# This enables the ../utils scripts to be run in Docker for the init job
#
FROM alpine:latest
RUN apk add --update curl bash && rm -rf /var/cache/apk/*
