#!/bin/bash

#############################################################################
# A script to teardown the Elastic Stack deployment on a development computer
#############################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Do the teardown
#
docker compose --project-name elasticstack down
