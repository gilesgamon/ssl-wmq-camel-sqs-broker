#!/bin/bash

if [ $AWS_CONTAINER_CREDENTIALS_RELATIVE_URI ] ; then
	echo "export AWS_CONTAINER_CREDENTIALS_RELATIVE_URI=$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI" >> /root/.profile

	curl 169.254.170.2$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI > /tmp/creds

	export AWS_CREDS=`cat /tmp/creds`
	export AccessKeyId=`node -pe 'JSON.parse(process.env.AWS_CREDS).AccessKeyId'`
	export SecretAccessKey=`node -pe 'JSON.parse(process.env.AWS_CREDS).SecretAccessKey'`
	export SessionToken=`node -pe 'JSON.parse(process.env.AWS_CREDS).Token'`

	export CLASSPATH=/opt/camel-broker
	sed -i 's/MQ_HOSTNAME/$MQ_HOSTNAME/g' /opt/camel-broker/broker.properties

	if [ ! $SUDO_USER ] ; then
		# Debugging - hold off starting inside true ECS task
		# sleep 3600
		echo "Go..."
	fi
	java -Daws.AWS_ACCESS_KEY_ID=${AccessKeyId} -Daws.AWS_SECRET_ACCESS_KEY=${SecretAccessKey} -Daws.AWS_SESSION_TOKEN=${SessionToken} -jar broker-1.0-SNAPSHOT.jar
else
	echo "sleeping ... 'cos I don't have AWS_CONTAINER_CREDENTIALS_RELATIVE_URI set - diagnostic help"
fi
