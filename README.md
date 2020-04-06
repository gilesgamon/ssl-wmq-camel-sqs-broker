
This repo implements a broker using Camel to connect SQS to IBM Websphere (wmq) / IBM MQ using SSL. The non-SSL implementation is fairly straightforwards but IBM haven't made doing the SSL easy!

Now extended, so that the return path is facilitated by putting replies into DynamoDB: this means that now it doesn't matter how many instances or async threads are running in a Lambda - the replies are picked by Lambda from the table.

Fruther complications involved in getting the https setup working correctly back to SQS. There's also a test for Jmeter - which does a round trip from REST-Lambda-SQS-MQ-MQ-SQS-DynamoDB-Lambda-REST in around 500ms based on a t2.medium camel broker and a t2.micro MQ. Suspect I could get better round trip performance by winding down some of the parameters and swapping out my MQ server for a larger instance and of course increasing the cluster size (ASG).

Usage:

WIP but - in principle load some vars (see below) & aws session/credentials loaded and run './parse_params' and assuming you got that working correctly 'cd docker ; ./build.sh', should deliver back an executable (fat) jar and a server-chain.jks. Terraform to follow.

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

Provision DynamoDB with TF (including ttl, which is prep'd in teh data) & check I haven't missed any other key components
Tidy paramater handling (json perhaps) & error checking in scripts
Extend the number of parameters configured through said json (for example performance parameters)
Test implementation & auto remove of the MQ-MQ loopback route
Add optional self deploying MQ docker instance
Paramatise / for-loop setup for routes: allow extensible number of router
Tidy the server-chain.jks, which ought to be fully embedded / or fully externailsed from jar
Some version tagging and paramtisation through the code
Restructure some components (xml in particular) to out the stuff that is version list / plumbing stuff away from the stuff more interesting stuff (routes in particular)
Clean up of ECR
Deployment of MQ Docker setup (not a priority but would be cool to have the whole shooting match laid out)
There's some opportunity to streamline some of the terraform stuff

DONE: Repo to build (using Docker) the jar file, having installed IBM Java, so that it can be deployed without maven and a lot of in-situ build process.
DONE: another repo - Develop terraform (possibly related to above) to deploy artefacts
DONE: Provide terraform for creation of IAM role, with minimum specific capabilities for SQS


VARS required:

// Just the raw PEM text : had to write a small (messy) handler to tidy this up
export CLIENT_KEY=''
export CLIENT_CRT=''
export ROOT_PEM=''
export INTERMEDIATE_PEM=''

export AWS_CRED='{ "ACCESS_KEY": "some_key", "SECRET_KEY": "some_secret" }'
export CAMEL_VALUES='{ "QUEUE_MANAGER": "QM1", "MQ_HOSTNAME": "some_host_name", "MQ_PORT": "1414", "MQ_CHANNEL": "DEV.APP.SVRCONN", "MQ_CIPHER": "SSL_ECDHE_RSA_WITH_AES_256_CBC_SHA384", "MQ_REQUEST_QUEUE": "DEV.QUEUE.1", "MQ_RESPONSE_QUEUE": "DEV.QUEUE.2", "SQS_REQUEST_QUEUE_NAME": "sqs_request_1", "SQS_RESPONSE_QUEUE_NAME": "sqs_response_1", "AWS_REGION": "eu-west-1"}'