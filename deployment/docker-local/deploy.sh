#!/bin/bash

#################################################################################################
# A script to deploy the Elastic Stack to Docker Compose on a development computer
# https://www.elastic.co/guide/en/elastic-stack-get-started/current/get-started-stack-docker.html
#################################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Elastic Stack parameters
#
ELASTIC_URL='https://logs.authsamples-dev.com:9200'
ELASTIC_USER='elastic'
ELASTIC_PASSWORD='Password1'
KIBANA_USER='kibana'
KIBANA_PASSWORD='Password1'

#
# Download development SSL certificates if required
#
./downloadcerts.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Export environment variables to the Docker Compose file
#
export ELASTIC_USER
export ELASTIC_PASSWORD
export KIBANA_USER
export KIBANA_PASSWORD

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
while [ "$(curl -k -s -o /dev/null -w ''%{http_code}'' "$ELASTIC_URL" -u 'elastic:Password1')" != '200' ]; do
  sleep 2
done

#
# Register the kibana user's password in Elasticsearch to prevent a 'Kibana server is not ready yet' error
# We do not use this account, but this registration seems to be a requirement in Kibana 8.x
#
HTTP_STATUS=$(curl -k -s -X POST "$ELASTIC_URL/_security/user/$KIBANA_USER/_password" \
-u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
-H "content-type: application/json" \
-d "{\"password\":\"$KIBANA_PASSWORD\"}" \
-o /dev/null \
-w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "*** Problem encountered setting the Kibana password: $HTTP_STATUS"
  exit
fi

#
# Create the Elasticsearch schema for apilogs
#
HTTP_STATUS=$(curl -k -s -X PUT "$ELASTIC_URL/_template/apilogs" \
-u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
-H "content-type: application/json" \
-d @../../data/schema.json \
-o /dev/null \
-w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "*** Problem encountered creating the apilogs schema: $HTTP_STATUS"
  exit
fi

#
# Create the Elasticsearch schema for apilogs
#
HTTP_STATUS=$(curl -k -s -X PUT "$ELASTIC_URL/_ingest/pipeline/apilogs" \
-u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
-H "content-type: application/json" \
-d @../../data/ingestion-pipeline.json \
-o /dev/null \
-w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "*** Problem encountered creating the apilogs ingestion pipeline: $HTTP_STATUS"
  exit
fi
