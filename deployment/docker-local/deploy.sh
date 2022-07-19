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
# Export environment variables to the Docker Compose file and scripts
#
export ELASTIC_URL
export ELASTIC_USER
export ELASTIC_PASSWORD
export KIBANA_USER
export KIBANA_PASSWORD

#
# Run the docker deployment to deploy Elasticsearch, Kibana and Filebeat
#
echo 'Deploying the Elastic Stack ...'
docker compose --project-name elasticstack up --force-recreate --detach
if [ $? -ne 0 ]; then
  echo "Problem encountered running Docker image"
  exit 1
fi

#
# Run the wait script, to ensure that Elasticsearch is available
#
../utils/wait.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Run the script to create the initial Elasticsearch data
#
../utils/initdata.sh
if [ $? -ne 0 ]; then
  exit 1
fi
