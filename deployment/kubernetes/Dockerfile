#
# A utility Docker container that has the curl and bash tools installed
# This enables the initdata.sh script from the init template to do its work
#
FROM alpine:latest
RUN apk add --update curl bash && rm -rf /var/cache/apk/*
