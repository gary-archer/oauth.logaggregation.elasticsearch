#!/bin/bash

##################################################################
# This deploys Elastic Stack resources into the Kubernetes cluster
##################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Check prerequisites
#
if [ "$ENVIRONMENT_FOLDER" == "" ]; then
  echo '*** Environment variables neeed by the deploy API script have not been supplied'
  exit 1
fi

#
# Use a timestamp based tag and support both KIND and DockerHub repositories
#
TAG=$(cat ./dockertag.txt)
if [ "$DOCKER_REPOSITORY" == "" ]; then
  export DOCKER_IMAGE="elasticjob:$TAG"
else
  export DOCKER_IMAGE="$DOCKER_REPOSITORY/elasticjob:$TAG"
fi

#
# Create the elasticstack namespace
#
kubectl delete namespace elasticstack 2>/dev/null
kubectl create namespace elasticstack
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the elasticstack namespace'
  exit 1
fi

#
# Enable sidecar injection for all components
#
kubectl label namespace elasticstack istio-injection=enabled --overwrite
if [ $? -ne 0 ]; then
  echo '*** Problem encountered enabling sidecar injection for the applications namespace'
  exit 1
fi

#
# Enable Mutual TLS for all components
#
kubectl -n elasticstack delete -f ./mtls.yaml 2>/dev/null
kubectl -n elasticstack apply  -f ./mtls.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered enabling peer authentication for the applications namespace'
  exit 1
fi

#
# Trigger deployment of Elasticsearch to the Kubernetes cluster
#
kubectl -n elasticstack delete -f ./elasticsearch.yaml 2>/dev/null
kubectl -n elasticstack apply  -f ./elasticsearch.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered deploying Elasticsearch'
  exit 1
fi

#
# Create configmaps for JSON files and scripts used by the Elasticsearch init job
#
kubectl -n elasticstack delete configmap schema-json 2>/dev/null
kubectl -n elasticstack create configmap schema-json --from-file=../data/schema.json
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the config map for the Elasticsearch schema data'
  exit 1
fi

kubectl -n elasticstack delete configmap ingestion-json 2>/dev/null
kubectl -n elasticstack create configmap ingestion-json --from-file=../data/ingestion-pipeline-cloudnative.json
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the config map for the Elasticsearch ingestion pipeline data'
  exit 1
fi

kubectl -n elasticstack delete configmap initdata-script 2>/dev/null
kubectl -n elasticstack create configmap initdata-script --from-file=../shared/initdata.sh
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the config map for the Elasticsearch init data script'
  exit 1
fi

#
# Produce the final Elastic Job YAML using the envsubst tool
#
envsubst < ./elasticsearch-init-template.yaml > ./elasticsearch-init.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered running envsubst to produce the final Kibana yaml file'
  exit 1
fi

#
# Run a Job to initialize Elasticsearch data once the system is up
#
kubectl -n elasticstack delete -f ./elasticsearch-init.yaml 2>/dev/null
kubectl -n elasticstack apply  -f ./elasticsearch-init.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered initializing Elasticsearch data'
  exit 1
fi

#
# Produce the final YAML using the envsubst tool
#
envsubst < ./kibana-template.yaml > ./kibana.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered running envsubst to produce the final Kibana yaml file'
  exit 1
fi
envsubst < ./ingress-template.yaml > ./ingress.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered running envsubst to produce the final ingress yaml file'
  exit 1
fi

#
# Trigger deployment of Kibana components to the Kubernetes cluster
#
kubectl -n elasticstack delete -f ./kibana.yaml 2>/dev/null
kubectl -n elasticstack apply  -f ./kibana.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered deploying Kibana'
  exit 1
fi

#
# Deploy the Kibana ingress
#
kubectl -n elasticstack delete -f ./ingress.yaml 2>/dev/null
kubectl -n elasticstack apply  -f ./ingress.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered deploying the Kibana ingress'
  exit 1
fi

#
# Trigger deployment of Filebeat components to the Kubernetes cluster
#
kubectl -n elasticstack delete -f ./filebeat.yaml 2>/dev/null
kubectl -n elasticstack apply  -f ./filebeat.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered deploying Kibana'
  exit 1
fi
