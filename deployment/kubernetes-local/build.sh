#!/bin/bash

####################################################
# Build resources used in the Elasticsearch init job
####################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

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
  sed -i 's/\r$//' ../utils/wait.sh
  sed -i 's/\r$//' ../utils/initdata.sh
fi

#
# Build a small Docker image containing curl and bash tools
#
docker build --no-cache -f ./Dockerfile_jobutils -t job_utils:v1 .
if [ $? -ne 0 ]; then
  echo '*** Elasticsearch init utils docker build problem encountered'
  exit 1
fi

#
# Load it into kind's Docker registry
#
kind load docker-image job_utils:v1 --name oauth
if [ $? -ne 0 ]; then
  echo '*** Elasticsearch init utils docker deploy problem encountered'
  exit 1
fi
