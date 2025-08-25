#!/bin/bash

#################################################################################################
# A script to deploy the Elastic Stack to Docker Compose on a development computer
# https://www.elastic.co/guide/en/elastic-stack-get-started/current/get-started-stack-docker.html
#################################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create SSL development certificates if required
#
./certs/create.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Build a small Docker image containing curl and bash tools
#
docker build --no-cache -t elasticjob:latest .
if [ $? -ne 0 ]; then
  echo 'Elastic job docker build problem encountered'
  exit 1
fi

#
# Share a host volume for Elasticsearch data and empty it on every deployment
#
rm -rf data 2>/dev/null
mkdir data
chmod 777 data

#
# Use docker compose to deploy Elasticsearch, Kibana and Filebeat
#
echo 'Deploying the Elastic Stack ...'
docker compose --project-name elasticstack up --force-recreate --detach
if [ $? -ne 0 ]; then
  echo "Problem encountered running Docker image"
  exit 1
fi
sleep 5

#
# Wait until Kibana is available
#
KIBANA_URL='https://logs.authsamples-dev.com/app/dev_tools#/console'
echo 'Waiting for the Elastic Stack to become available ...'
while [ "$(curl -k -s -o /dev/null -w ''%{http_code}'' "$KIBANA_URL")" != '302' ]; do
  sleep 2
done

#
# Get the platform
#
case "$(uname -s)" in

  Darwin)
    PLATFORM="MACOS"
 	;;

  MINGW64*)
    PLATFORM="WINDOWS"
	;;

  Linux)
    PLATFORM="LINUX"
	;;
esac

#
# Open the Kibana URL and login with the following test credentials
# - elastic
# - Password1
#
if [ "$PLATFORM" == 'MACOS' ]; then

  open "$KIBANA_URL"

elif [ "$PLATFORM" == 'WINDOWS' ]; then

  start "$KIBANA_URL"

elif [ "$PLATFORM" == 'LINUX' ]; then

  xdg-open "$KIBANA_URL"

fi
