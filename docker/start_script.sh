#!/bin/bash

if [ $AWS_CONTAINER_CREDENTIALS_RELATIVE_URI ] ; then

	echo "export AWS_CONTAINER_CREDENTIALS_RELATIVE_URI=$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI" >> /root/.profile
	curl 169.254.170.2$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI > /tmp/creds

	export AWS_CREDS=`cat /tmp/creds`
	export AccessKeyId=`node -pe 'JSON.parse(process.env.AWS_CREDS).AccessKeyId'`
	export SecretAccessKey=`node -pe 'JSON.parse(process.env.AWS_CREDS).SecretAccessKey'`
	export SessionToken=`node -pe 'JSON.parse(process.env.AWS_CREDS).Token'`

	sed -i "s/MQ_HOSTNAME/$MQ_HOSTNAME/g" /opt/camel-broker/broker.properties

	java -Xbootclasspath/a:/opt/camel-broker/ -jar broker-1.0-SNAPSHOT.jar
	# java -Xbootclasspath/a:/opt/camel-broker/ -Daws.AWS_ACCESS_KEY_ID=${AccessKeyId} -Daws.AWS_SECRET_ACCESS_KEY=${SecretAccessKey} -Daws.AWS_SESSION_TOKEN=${SessionToken} -jar broker-1.0-SNAPSHOT.jar
	exit 1
else
	echo "exiting ... 'cos I don't have AWS_CONTAINER_CREDENTIALS_RELATIVE_URI set - diagnostic help - has task got role? Not just execution role for the host..."
	exit 1
fi
