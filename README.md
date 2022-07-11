# Elasticsearch Log Aggregation

Resources for deploying the Elastic Stack and using it to aggregate API logs.\
The following notes describe the default local development setup.

## Prerequisites

First ensure that API and Logs domains are added to the local hosts file:

```text
127.0.0.1  localhost api.authsamples-dev.com web.authsamples-dev.com localtokenhandler.authsamples-dev.com logs.authsamples-dev.com
```

## Docker Local Setup

Then run the following script to deploy the Elastic Stack on the local computer:

```bash
./deployment/docker-local/deploy.sh
```

Wait for it to be ready and then connect to the ElasticSearch API to which logs will be sent:

```bash
curl -u 'elastic:Password1' https://logs.authsamples-dev.com:9200
```

Then login to Kibana at https://logs.authsamples-dev.com:5600 with credentials `elastic / Password1`:

SCREENSHOT

## Application Setup

First run an integrated SPA and API solution in a parallel folder to generate logs visually.\
Start by running one of this blog's final APIs:




## Analyze API Logs

Analyse logs generated from the UI, using the session ID.\
Run the queries to diagnose your own activity:

SCREENSHOT