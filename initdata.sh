#!/bin/bash

############################################################
# Set up initial Elasticsearch data when creating the system
############################################################

cd "$(dirname "${BASH_SOURCE[0]}")"
RESPONSE_FILE=response.txt

#
# These environment variables must exist
#
if [ "$ELASTIC_URL" == '' ]; then
  echo 'The environment variable ELASTIC_URL is not set'
  exit 1
fi
if [ "$ELASTIC_USER" == '' ]; then
  echo 'The environment variable ELASTIC_USER is not set'
  exit 1
fi
if [ "$ELASTIC_PASSWORD" == '' ]; then
  echo 'The environment variable ELASTIC_PASSWORD is not set'
  exit 1
fi
if [ "$KIBANA_SYSTEM_USER" == '' ]; then
  echo 'The environment variable KIBANA_SYSTEM_USER is not set'
  exit 1
fi
if [ "$KIBANA_PASSWORD" == '' ]; then
  echo 'The environment variable KIBANA_PASSWORD is not set'
  exit 1
fi

#
# Also wait until Elasticsearch is ready
#
echo 'Waiting for Elasticsearch endpoints to become available ...'
while [ "$(curl -k -s -o /dev/null -w ''%{http_code}'' "$ELASTIC_URL" -u "$ELASTIC_USER:$ELASTIC_PASSWORD")" != '200' ]; do
  sleep 2
done

#
# Register the kibana system user's password in Elasticsearch to prevent a 'Kibana server is not ready yet' error
# https://www.elastic.co/guide/en/elasticsearch/reference/7.17/breaking-changes-7.8.html#builtin-users-changes
#
echo 'Setting the Kibana system user password ...'
HTTP_STATUS=$(curl -k -s -X POST "$ELASTIC_URL/_security/user/$KIBANA_SYSTEM_USER/_password" \
  -u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
  -H "content-type: application/json" \
  -d "{\"password\":\"$KIBANA_PASSWORD\"}" \
  -o "$RESPONSE_FILE" \
  -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "*** Problem encountered setting the Kibana system password: $HTTP_STATUS"
  cat "$RESPONSE_FILE"
  exit 1
fi

#
# Create the Elasticsearch index template for API logs
#
echo 'Creating the Elasticsearch index template ...'
HTTP_STATUS=$(curl -k -s -X PUT "$ELASTIC_URL/_index_template/api" \
  -u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
  -H "content-type: application/json" \
  -d @index-template.json \
  -o "$RESPONSE_FILE" \
  -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "*** Problem encountered creating the api index template: $HTTP_STATUS"
  cat "$RESPONSE_FILE"
  exit 1
fi

#
# Create the Elasticsearch ingestion pipeline for API logs
#
echo 'Creating the Elasticsearch ingestion pipeline ...'
  HTTP_STATUS=$(curl -k -s -X PUT "$ELASTIC_URL/_ingest/pipeline/api" \
  -u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
  -H "content-type: application/json" \
  -d @ingestion-pipeline.json \
  -o "$RESPONSE_FILE" \
  -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "*** Problem encountered creating the api ingestion pipeline: $HTTP_STATUS"
  cat "$RESPONSE_FILE"
  exit 1
fi

#
# Add Elasticsearch aliases that simplify queries
#
echo 'Adding Elasticsearch index aliases ...'
  HTTP_STATUS=$(curl -k -s -X POST "$ELASTIC_URL/_aliases" \
  -u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
  -H "content-type: application/json" \
  -d @index-aliases.json \
  -o "$RESPONSE_FILE" \
  -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "*** Problem encountered creating index aliases: $HTTP_STATUS"
  cat "$RESPONSE_FILE"
  exit 1
fi
