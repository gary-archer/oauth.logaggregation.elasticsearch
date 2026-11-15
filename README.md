# OAuth Elasticsearch Log Aggregation

Resources for demo level deployments of the Elastic Stack, used for OAuth and API log aggregation.\
This is part of an overall [Effective API Logging](https://github.com/gary-archer/oauth.blog/tree/master/public/posts/effective-api-logging.mdx) design.

## Docker Commands

First ensure that a Docker engine is installed.

API performance is a little suboptimal, due to the nature of the AWS API gateway:

- SPA requests first call the AWS API gateway for the BFF domain and invoke the wildcard lambda.  
- The wildcard lambdas then makes an upstream request to AWS API gateway for the API domain.  

See the [Cloud Native Token Handler](https://github.com/gary-archer/oauth.tokenhandler.cloudnative) for a better performing token handler with the same architecture.

## Local Development Quick Start

Run the code sample from a terminal on Linux, macOS or Windows (with Git bash).  
The deployment uses [Real World OAuth Development URLs](https://github.com/gary-archer/oauth.blog/blob/master/public/posts/developer-ssl-setup.mdx#real-world-oauth-development-urls) on a local computer.  

### Administrator Setup

You must use admin permissions to configure infrastructure before you run the code.  
First, add DNS entries in your `/etc/hosts` file:

```bash
127.0.0.1 localhost logs.authsamples-dev.com
```

Make sure OpenSSL 3+ is installed, specify a secrets folder, then create development certificates:

```bash
export SECRETS_FOLDER="$HOME/secrets"
mkdir -p "$SECRETS_FOLDER"
./certs/create.sh
```

Then, configure [Browser HTTPS Trust](https://github.com/gary-archer/oauth.blog/blob/master/public/posts/developer-ssl-setup.mdx#configure-operating-system-trust) for the SSL root certificate at the following location:

```text
./certs/authsamples-dev.ca.crt
```

### Deploy the System

Run the following command to deploy Docker components for Elasticsearch, Kibana and Filebeat:

```bash
./deploy.sh
```

The script waits for completion and then opens Kibana in the system browser.\
Sign in with one of the following test user accounts and a password of `Password1`.

| Username | Description |
| -------- | ----------- |
| elastic | An Elasticsearch and Kibana administrator. |
| support@example.com | A user with access to request logs in the apilogs index alias. |
| security@example.com | A user with access to audit logs in the apiauditlogs index alias. |

### Use Logs

See the [Elasticsearch Log Aggregation Setup](https://github.com/gary-archer/oauth.blog/tree/master/public/posts/log-aggregation-setup.mdx) for details on this deployment and local log aggregation.\
See [API Technical Support Analysis](https://github.com/gary-archer/oauth.blog/tree/master/public/posts/api-technical-support-analysis.mdx) for some example queries on aggregated API logs.

### Free Resources

Run the following command to free Docker resources:

```bash
./teardown.sh
```
