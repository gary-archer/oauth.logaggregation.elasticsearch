# Elasticsearch Log Aggregation

Resources for deploying the Elastic Stack and using it to aggregate API logs.\
The following notes describe the default local development setup.

## Prerequisites

First ensure that Docker and Node.js are installed.

## Run an API Load Test

Start by running one of this blog's final APIs in a parallel folder, to generate logs:

- [Final Node.js API](https://github.com/gary-archer/oauth.apisample.nodejs)
- [Final .NET API](https://github.com/gary-archer/oauth.apisample.netcore)
- [Final Java API](https://github.com/gary-archer/oauth.apisample.javaspringboot)

If the Node.js API is used then the following commands would be run:

```bash
cd ..
git clone https://github.com/gary-archer/oauth.apisample.nodejs
cd oauth.apisample.nodejs
npm run testsetup
npm run loadtest
```

## DNS and SSL Configuration

Next add DNS domains to the local computer by editing the hosts file:

```text
127.0.0.1  localhost api.authsamples-dev.com login.authsamples-dev.com logs.authsamples-dev.com
```

Next trust the root certificate by adding it to your computer's SSL trust store:

```text
oauth.apisample.nodejs/certs/authsamples-dev.ca.pem
```

## Deploy ElasticStack

Then run the following script to deploy the Elastic Stack components to the local computer:

```bash
./deployment/docker-local/deploy.sh
```

## Connect to the Elastic Stack

Next connect to the ElasticSearch API to which logs will be sent:

```bash
curl -u 'elastic:Password1' https://logs.authsamples-dev.com:9200
```

Then login to Kibana with credentials `elastic / Password1` and this URL:

- https://logs.authsamples-dev.com:5601/app/dev_tools#/console

![Kibana UI](./doc/kibana.png)

## Analyse Logs

View logs for the load test, or slice and dice the error data via [SQL or Lucene queries](https://authguidance.com/api-technical-support-analysis/):

```text
GET apilogs*/_search
{ 
  "query" :
  {
    "match" :
    {
      "errorId" : 30229
    }
  }
}
```

## Free Docker Resources

Run these commands to tear down all Docker containers:

```bash
cd logaggregation.elasticsearch
./deployment/docker-local/teardown.sh
cd ../oauth.websample.final
./localtokenhandler/deployment/docker-local/teardown.sh
```
