#!/bin/bash

##################################################################################
# A script to deploy the Elastic Stack to Docker Compose on a development computer
##################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Download development SSL certificates if required
#
./downloadcerts.sh
if [ $? -ne 0 ]; then
  exit
fi

#
# Run the docker deployment to deploy Elasticsearch, Kibana and Filebeat
#
docker compose --project-name elasticstack up --force-recreate --detach
if [ $? -ne 0 ]; then
  echo "Problem encountered running Docker image"
  exit 1
fi

#
# Wait for endpoints to become available
#
echo 'Waiting for Elasticsearch endpoints to become available ...'
ELASTIC_URL='https://logs.authsamples-dev.com:9200'
while [ "$(curl -k -s -o /dev/null -w ''%{http_code}'' "$ELASTIC_URL" -u 'elastic:Password1')" != '200' ]; do
  sleep 2
done
