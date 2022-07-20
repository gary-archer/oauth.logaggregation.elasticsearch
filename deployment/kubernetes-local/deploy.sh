#!/bin/bash

##################################################################
# This deploys Elastic Stack resources into the Kubernetes cluster
##################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create a secret for the private key password of the Elasticsearch certificate that cert-manager will create
#
kubectl -n elasticstack delete secret elasticsearch-pkcs12-password 2>/dev/null
kubectl -n elasticstack create secret generic elasticsearch-pkcs12-password --from-literal=password='Password1'
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Elasticsearch certificate secret'
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

kubectl -n elasticstack delete configmap wait-script 2>/dev/null
kubectl -n elasticstack create configmap wait-script --from-file=../utils/wait.sh
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the config map for the Elasticsearch wait script'
  exit 1
fi

kubectl -n elasticstack delete configmap initdata-script 2>/dev/null
kubectl -n elasticstack create configmap initdata-script --from-file=../utils/initdata.sh
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the config map for the Elasticsearch init data script'
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
# Create a secret for the private key password of the Kibana certificate that cert-manager will create
#
kubectl -n elasticstack delete secret kibana-pkcs12-password 2>/dev/null
kubectl -n elasticstack create secret generic kibana-pkcs12-password --from-literal=password='Password1'
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Kibana certificate secret'
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
# Create a configmap to deploy the root certificate that filebeat must trust in order to call Elasticsearch over SSL
#
kubectl -n elasticstack delete configmap filebeat-root-cert 2>/dev/null
kubectl -n elasticstack create configmap filebeat-root-cert --from-file=../../../certs/default.svc.cluster.local.ca.pem
if [ $? -ne 0 ]; then
  echo '*** Problem creating Filebeat SSL root CA configmap'
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
