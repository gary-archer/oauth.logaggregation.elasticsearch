#!/bin/bash

############################################################
# Set up initial Elasticsearch data when creating the system
############################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

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
if [ "$KIBANA_USER" == '' ]; then
  echo 'The environment variable KIBANA_USER is not set'
  exit 1
fi
if [ "$KIBANA_PASSWORD" == '' ]; then
  echo 'The environment variable KIBANA_PASSWORD is not set'
  exit 1
fi
if [ "$SCHEMA_FILE_PATH" == '' ]; then
  echo 'The environment variable SCHEMA_FILE_PATH is not set'
  exit 1
fi
if [ "$INGESTION_PIPELINE_FILE_PATH" == '' ]; then
  echo 'The environment variable INGESTION_PIPELINE_FILE_PATH is not set'
  exit 1
fi

#
# Register the kibana user's password in Elasticsearch to prevent a 'Kibana server is not ready yet' error
# We do not use this account, but this registration seems to be a requirement in Kibana 8.x
#
echo 'Registering the default Kibana user ...'
HTTP_STATUS=$(curl -k -s -X POST "$ELASTIC_URL/_security/user/$KIBANA_USER/_password" \
-u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
-H "content-type: application/json" \
-d "{\"password\":\"$KIBANA_PASSWORD\"}" \
-o /dev/null \
-w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "*** Problem encountered setting the Kibana password: $HTTP_STATUS"
  exit 1
fi

#
# Create the Elasticsearch schema for apilogs
#
echo 'Creating the Elasticsearch schema ...'
HTTP_STATUS=$(curl -k -s -X PUT "$ELASTIC_URL/_template/apilogs" \
-u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
-H "content-type: application/json" \
-d @"$SCHEMA_FILE_PATH" \
-o /dev/null \
-w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "*** Problem encountered creating the apilogs schema: $HTTP_STATUS"
  exit 1
fi

#
# Create the Elasticsearch schema for apilogs
#
echo 'Creating the Elasticsearch ingestion pipeline ...'
echo '*** DEBUG INGESTION'
cat "$INGESTION_PIPELINE_FILE_PATH"
HTTP_STATUS=$(curl -k -s -X PUT "$ELASTIC_URL/_ingest/pipeline/apilogs" \
-u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
-H "content-type: application/json" \
-d @"$INGESTION_PIPELINE_FILE_PATH" \
-o /dev/null \
-w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "*** Problem encountered creating the apilogs ingestion pipeline: $HTTP_STATUS"
  exit 1
fi
