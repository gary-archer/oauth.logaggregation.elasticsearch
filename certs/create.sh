#!/bin/bash

######################################################################################################
# A script to create an SSL certificate in a secrets folder that can be used for multiple code samples
######################################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Do nothing if the final files exist for this code sample
#
KEY_PATH='./authsamples-dev.ssl.key'
if [ -f "$KEY_PATH" ]; then
  exit 0
fi

#
# Otherwise require an environment variable
#
if [ "$SECRETS_FOLDER" == '' ]; then
  echo 'You must supply a SECRETS_FOLDER environment variable to the certificate creation script'
  exit 1
fi

if [ ! -d "$SECRETS_FOLDER" ]; then
  echo 'The SECRETS_FOLDER does not exist'
  exit 1
fi

#
# If certificates already exist for another code sample, copy them to the local folder
#
ROOT_CA_PATH="$SECRETS_FOLDER/authsamples-dev.ca.crt"
KEY_PATH="$SECRETS_FOLDER/authsamples-dev.ssl.key"
CERT_PATH="$SECRETS_FOLDER/authsamples-dev.ssl.crt"
if [ -f "$ROOT_CA_PATH" ] && [ -f "$KEY_PATH" ] && [ -f "$CERT_PATH" ]; then
  cp "$ROOT_CA_PATH" .
  cp "$KEY_PATH" .
  cp "$CERT_PATH" .
  exit 0
fi

#
# Create the certs
#
./makecerts.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Copy certificate files locally
#
cp "$ROOT_CA_PATH" .
cp "$KEY_PATH" .
cp "$CERT_PATH" .