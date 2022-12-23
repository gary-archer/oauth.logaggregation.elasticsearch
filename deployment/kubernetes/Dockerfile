#
# A utility Docker container that has the curl and bash tools installed
# This enables the wait.sh and initdata.sh scripts to be run in the init template
#
FROM alpine:latest
RUN apk add --update curl bash && rm -rf /var/cache/apk/*
