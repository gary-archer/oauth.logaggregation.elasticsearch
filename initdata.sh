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
  -H 'content-type: application/json' \
  -d "{\"password\":\"$KIBANA_PASSWORD\"}" \
  -o "$RESPONSE_FILE" \
  -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  cat "$RESPONSE_FILE"
  echo "Problem encountered setting the Kibana system password: $HTTP_STATUS"
  exit 1
fi

#
# Create the Elasticsearch index templates
#
echo 'Creating the Elasticsearch request logs index template ...'
HTTP_STATUS=$(curl -k -s -X PUT "$ELASTIC_URL/_index_template/api-request" \
  -u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
  -H 'content-type: application/json' \
  -d @index-template-request.json \
  -o "$RESPONSE_FILE" \
  -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  cat "$RESPONSE_FILE"
  echo "Problem encountered creating the request logs index template: $HTTP_STATUS"
  exit 1
fi

echo 'Creating the Elasticsearch audit logs index template ...'
HTTP_STATUS=$(curl -k -s -X PUT "$ELASTIC_URL/_index_template/api-audit" \
  -u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
  -H 'content-type: application/json' \
  -d @index-template-audit.json \
  -o "$RESPONSE_FILE" \
  -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  cat "$RESPONSE_FILE"
  echo "Problem encountered creating the audit logs index template: $HTTP_STATUS"
  exit 1
fi

#
# Create the Elasticsearch ingestion pipeline for API logs
#
echo 'Creating the Elasticsearch ingestion pipeline ...'
  HTTP_STATUS=$(curl -k -s -X PUT "$ELASTIC_URL/_ingest/pipeline/api" \
  -u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
  -H 'content-type: application/json' \
  -d @ingestion-pipeline.json \
  -o "$RESPONSE_FILE" \
  -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  cat "$RESPONSE_FILE"
  echo "Problem encountered creating the log ingestion pipeline: $HTTP_STATUS"
  exit 1
fi

#
# Create the support and security roles
#
echo 'Creating the support role with access to request logs ...'
HTTP_STATUS=$(curl -k -s -X PUT "$ELASTIC_URL/_security/role/api-support" \
  -u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
  -H 'content-type: application/json' \
  -d @role-support.json \
  -o "$RESPONSE_FILE" \
  -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  cat "$RESPONSE_FILE"
  echo "Problem encountered creating the support role: $HTTP_STATUS"
  exit 1
fi

echo 'Creating the security role with access to audit logs ...'
HTTP_STATUS=$(curl -k -s -X PUT "$ELASTIC_URL/_security/role/api-security" \
  -u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
  -H 'content-type: application/json' \
  -d @role-security.json \
  -o "$RESPONSE_FILE" \
  -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  cat "$RESPONSE_FILE"
  echo "Problem encountered creating the security role: $HTTP_STATUS"
  exit 1
fi

#
# Create the support and security example users
#
echo 'Creating the support user with access to request logs ...'
HTTP_STATUS=$(curl -k -s -X POST "$ELASTIC_URL/_security/user/support@example.com" \
  -u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
  -H 'content-type: application/json' \
  -d @user-support.json \
  -o "$RESPONSE_FILE" \
  -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  cat "$RESPONSE_FILE"
  echo "Problem encountered creating the support user: $HTTP_STATUS"
  exit 1
fi

echo 'Creating the security user with access to audit logs ...'
HTTP_STATUS=$(curl -k -s -X POST "$ELASTIC_URL/_security/user/security@example.com" \
  -u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
  -H 'content-type: application/json' \
  -d @user-security.json \
  -o "$RESPONSE_FILE" \
  -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  cat "$RESPONSE_FILE"
  echo "Problem encountered creating the security user: $HTTP_STATUS"
  exit 1
fi
