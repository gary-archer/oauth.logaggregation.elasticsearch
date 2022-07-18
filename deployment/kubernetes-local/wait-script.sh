#!/bin/bash

################################################################
# A script used by the init job to initialize Elasticsearch data
################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

for i in $(seq 1 300); do nc -zvw1 elasticsearch-svc 9200 && exit 0 || sleep 200; done; exit 1