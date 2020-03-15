
This repo implements a broker using Camel to connect SQS to IBM Websphere (wmq) / IBM MQ using SSL. The non-SSL implementation is fairly straightforwards but IBM haven't
made doing the SSL easy.

Usage:

WIP but - in principle load some vars (see below) and run 'cd docker ; ./build.sh', should deliver back an executable (fat) jar and a server-chain.jks. Terraform to follow.

Now you should have a jar in target and a server-chain.jks in an artefacts directory - copy these to another machine (if required), which has IBM Java installed and use the startup scipts to run it.

This is designed to (ultimately) be run in AWS with configuration held in SecretsManager / SSM. The help achieve this, the configuration is expected to he put into ENV vars
a further iteration of this is expected to switch that to a single var with a JSON structure. TO DO

Test Operation:
You can use the SQS console to select a queue (mq_request) and submit a test message: for example {"type":"login", "payload":{"name":"giles", "city":"Altrincham"}}
This message should be picked up by the camel, routed to the MQ_REQUEST_QUEUE, then (for testing purposes) camel will move it to the MQ_RESPONSE_QUEUE
camel will then find a response and move that back to SQS mq_reply.

Mix of build tools - bash to do some basic admin stuff. Some NodeJS to handle slightly fidlier stuff that, in principle, I would have preferred to do with sed. Docker, which builds jar file (using maven) and clones this.

Non-test:
Remove the MQ-MQ route in camel-context.xml and rebuild the jar

TODO List

DONE-ish (WIP): Repo to build (using Docker) the jar file, having installed IBM Java, so that it can be deployed without maven and a lot of in-situ build process.
Develop terraform (possibly related to above) to deploy artefacts
Tidy paramater handling (json perhaps)
Extend the number of parameters configured through said json (for example SQS queue names, performance parameters)
Test implementation & auto remove of the MQ-MQ loopback route
Paramatise / for-loop setup for routes: allow extensible number of router
Tidy the server-chain.jks, which ought to be fully embedded / or fully externailsed from jar
Provide terraform for creation of IAM role, with minimum specific capabilities for SQS
Some version tagging and paramtisation through the code
Restructure some components (xml in particular) to out the stuff that is version list / plumbing stuff away from the stuff more interesting stuff (routes in particular)


VARS required:

export ACCESS_KEY=''
export SECRET_KEY=''

// Just the raw PEM text : had to write a small (messy) handler to tidy this up
export CLIENT_KEY=''
export CLIENT_CRT=''
export ROOT_PEM=''
export INTERMEDIATE_PEM=''

export AWS_CRED='{ "ACCESS_KEY": "some_key", "SECRET_KEY": "some_secret" }'
export CAMEL_VALUES='{ "QUEUE_MANAGER": "QM1", "MQ_HOSTNAME": "some_host_name", "MQ_PORT": "port=1414", "MQ_CHANNEL": "DEV.APP.SVRCONN", "MQ_CIPHER": "SSL_ECDHE_RSA_WITH_AES_256_CBC_SHA384", "MQ_REQUEST_QUEUE": "DEV.QUEUE.1", "MQ_RESPONSE_QUEUE": "DEV.QUEUE.2"}'