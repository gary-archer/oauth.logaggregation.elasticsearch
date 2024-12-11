# Elasticsearch Log Aggregation

Resources for demo level deployments of the Elastic Stack, used for API log aggregation.\
This is part of an overall [Effective API Logging](https://github.com/gary-archer/oauth.blog/tree/master/public/posts/effective-api-logging.mdx) design.

## Docker Commands

First ensure that a Docker engine is installed.

### Configure DNS and SSL

Configure DNS by adding the logs domain name to your hosts file:

```text
127.0.0.1 localhost logs.authsamples-dev.com
```

Download SSL development certificates:

```bash
./downloadcerts.sh
```

Next configure [Browser SSL Trust](https://github.com/gary-archer/oauth.blog/tree/master/public/posts/developer-ssl-setup.mdx#trust-a-root-certificate-in-browsers) for the SSL root certificate:

```text
./certs/authsamples-dev.ca.crt
```

### Deploy the System

Run the following command to deploy Docker components for Elasticsearch, Kibana and Filebeat:

```bash
./deploy.sh
```

The script waits for completion and then opens Kibana in the system browser.\
Sign in with a username of `elastic` and a password of `Password1`, then query API logs.

### Free Resources

Run the following command to free Docker resources:

```bash
./teardown.sh
```

## Further Information

- See the [Elasticsearch Log Aggregation Setup](https://github.com/gary-archer/oauth.blog/tree/master/public/posts/log-aggregation-setup.mdx) for details on how to run APIs and test clients.
- See [API Platform Technical Support Analysis](https://github.com/gary-archer/oauth.blog/tree/master/public/posts/api-technical-support-analysis.mdx) for some example queries on API logs.
