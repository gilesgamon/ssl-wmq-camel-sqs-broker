
This repo implements a broker using Camel to connect SQS to IBM Websphere (wmq) / IBM MQ using SSL. The non-SSL implementation is fairly straightforwards but IBM haven't made doing the SSL easy!

Now extended, so that the return path is facilitated by putting replies into DynamoDB: this means that now it doesn't matter how many instances or async threads are running in a Lambda - the replies are picked by Lambda from the table. The Lambda currently polls DynamoDB until response is found. An async approach would be better!

Fruther complications involved in getting the https setup working correctly back to SQS. There's also a test for Jmeter - which does a round trip from REST-Lambda-SQS-MQ-MQ-SQS-DynamoDB-Lambda-REST in around 500ms based on a t2.medium camel broker and a t2.micro MQ. Suspect I could get better round trip performance by winding down some of the parameters and swapping out my MQ server for a larger instance and of course increasing the cluster size (ASG).

Have implemented on ECS with EC2 instance and Fargate. The IBM MQ instance is stood up on EC2 as a docker instance for Fargate, because setting up a LB which doesn't mess with SSL and monitors health turned into a 'mare. It's only a PoC stage having a dummy MQ TLS server there anyway.

Have 'turned up the wick' for the DynamoDB read/write - read is (on this setup) approxiamtely 10:1 read:write, because of teh polling. Autoscaling but currently set quite high for testing purposes.

Usage:

WIP but - in principle fiddle with vars (AccountId) 
cd docker ; ./build.sh

In theory - now a fully deployed capability. Take the API Gateway (dev_url) and paste into Server IP in Jmeter test scripy (see test dir)

Test Operation:
You can use the SQS console to select a queue (mq_request) and submit a test message: for example {"type":"login", "payload":{"name":"giles", "city":"Altrincham"}}
This message should be picked up by the camel, routed to the MQ_REQUEST_QUEUE, then (for testing purposes) camel will move it to the MQ_RESPONSE_QUEUE
camel will then find a response and move that back to SQS mq_reply.

Mix of build tools - bash to do some basic admin stuff. Some NodeJS to handle slightly fidlier stuff that, in principle, I would have preferred to do with sed. Docker, which builds jar file (using maven) and clones this.

Non-test:
Remove the MQ-MQ route in camel-context.xml and rebuild the jar

TODO List

Parameters/Templates for (mostly terraform) where it is hardcoded, and shouldn't be - ideally froma  single source that permiates to camel-context etc:
	sqs_request_1, sqs_response_1, MQ_HOSTNAME, AccountId

CW LG definiiton for the API Gateway, so it's clean after teardown
Look at possibility of Async method of getting message back to Lambda
Tidy paramater handling (json perhaps) & error checking in scripts
Extend the number of parameters configured through said json (for example performance parameters)
Test implementation & auto remove of the MQ-MQ loopback route
Paramatise / for-loop setup for routes: allow extensible number of router
Tidy the server-chain.jks, which ought to be fully embedded / or fully externailsed from jar
Some version tagging and paramtisation through the code
Clean up of ECR
There's some opportunity to streamline some of the terraform stuff
Look at number of components being bunled in AWS SDK

DONE: Add optional self deploying MQ docker instance
DONE: move config (camel-context.xml and broker.properties) out of build, into runtime, docker build - making reconfig much smaller docker build
DONE: Restructure some components (xml in particular) to out the stuff that is version list / plumbing stuff away from the stuff more interesting stuff (routes in particular)
DONE: Deployment of MQ Docker setup (not a priority but would be cool to have the whole shooting match laid out)
DONE: Provision DynamoDB with TF (including ttl, which is prep'd in the data) & check I haven't missed any other key components
DONE: Repo to build (using Docker) the jar file, having installed IBM Java, so that it can be deployed without maven and a lot of in-situ build process.
DONE: another repo - Develop terraform (possibly related to above) to deploy artefacts
DONE: Provide terraform for creation of IAM role, with minimum specific capabilities for SQS
