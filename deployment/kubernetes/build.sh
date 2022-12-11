#!/bin/bash

####################################################
# Build resources used in the Elasticsearch init job
####################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Manage differences between local and cloud deployment
#
if [ "$CLUSTER_TYPE" != 'local' ]; then
  
  if [ "$DOCKERHUB_ACCOUNT" == '' ]; then
    echo '*** The DOCKERHUB_ACCOUNT environment variable has not been configured'
    exit 1
  fi

  DOCKER_IMAGE_NAME="$DOCKERHUB_ACCOUNT/elasticjob:v1"
else

  DOCKER_IMAGE_NAME='elasticjob:v1'
fi

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
# On Windows, fix problems with trailing newline characters in Docker scripts downloaded from Git
#
if [ "$PLATFORM" == 'WINDOWS' ]; then
  sed -i 's/\r$//' ../shared/wait.sh
  sed -i 's/\r$//' ../shared/initdata.sh
fi

#
# Build a small Docker image containing curl and bash tools
#
docker build --no-cache -t "$DOCKER_IMAGE_NAME" .
if [ $? -ne 0 ]; then
  echo '*** Elastic job docker build problem encountered'
  exit 1
fi

#
# Push the docker image
#
if [ "$CLUSTER_TYPE" == 'local' ]; then
  kind load docker-image "$DOCKER_IMAGE_NAME" --name oauth
else
  docker image push "$DOCKER_IMAGE_NAME"
fi
if [ $? -ne 0 ]; then
  echo '*** Elastic job docker push problem encountered'
  exit 1
fi
