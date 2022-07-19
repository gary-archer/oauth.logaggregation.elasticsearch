#!/bin/bash

########################################################################
# Wait for Elasticsearch to become available when the system is deployed
########################################################################

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

#
# Wait for endpoints to become available
#
echo 'Waiting for Elasticsearch endpoints to become available ...'
while [ "$(curl -k -s -o /dev/null -w ''%{http_code}'' "$ELASTIC_URL" -u "$ELASTIC_USER:$ELASTIC_PASSWORD")" != '200' ]; do
  sleep 2
done
