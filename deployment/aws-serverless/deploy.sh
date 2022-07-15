#!/bin/bash

######################################################################
# A script to deploy FunctionBeat to AWS to run as a Serverless Lambda
# It then ships logs to my online Elastic Cloud managed service
# https://authguidance.com/cloud-elastic-search-setup
######################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"
