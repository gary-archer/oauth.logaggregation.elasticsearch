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
if [ "$KIBANA_SYSTEM_USER" == '' ]; then
  echo 'The environment variable KIBANA_SYSTEM_USER is not set'
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
# Register the kibana system user's password in Elasticsearch to prevent a 'Kibana server is not ready yet' error
# https://www.elastic.co/guide/en/elasticsearch/reference/7.17/breaking-changes-7.8.html#builtin-users-changes
#
echo 'Setting the Kibana system user password ...'
HTTP_STATUS=$(curl -k -s -X POST "$ELASTIC_URL/_security/user/$KIBANA_SYSTEM_USER/_password" \
-u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
-H "content-type: application/json" \
-d "{\"password\":\"$KIBANA_PASSWORD\"}" \
-o /dev/null \
-w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "*** Problem encountered setting the Kibana system password: $HTTP_STATUS"
  exit 1
fi

#
# Create the Elasticsearch schema for apilogs
#
echo 'Creating the Elasticsearch schema ...'
HTTP_STATUS=$(curl -k -s -X PUT "$ELASTIC_URL/_index_template/apilogs" \
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
