############################################################################
# A utility Docker container that runs a bash script that uses the curl tool
############################################################################
FROM alpine:latest
RUN apk add --update curl bash && rm -rf /var/cache/apk/*

WORKDIR /usr/job

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ./initdata.sh
