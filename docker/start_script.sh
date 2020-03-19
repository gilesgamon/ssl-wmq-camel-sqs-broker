#!/bin/bash

# Importing credentials from the ECS Task IAM Role
#{
#    "AccessKeyId": "ACCESS_KEY_ID",
#    "Expiration": "EXPIRATION_DATE",
#    "RoleArn": "TASK_ROLE_ARN",
#    "SecretAccessKey": "SECRET_ACCESS_KEY",
#    "Token": "SECURITY_TOKEN_STRING"
#}

if [ $AWS_CONTAINER_CREDENTIALS_RELATIVE_URI ] ; then
	echo "export AWS_CONTAINER_CREDENTIALS_RELATIVE_URI=$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI" >> /root/.profile

	curl 169.254.170.2$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI > /tmp/creds

	export AWS_CREDS=`cat /tmp/creds`
	export AccessKeyId=`node -pe 'JSON.parse(process.env.AWS_CREDS).AccessKeyId'`
	export SecretAccessKey=`node -pe 'JSON.parse(process.env.AWS_CREDS).SecretAccessKey'`
	export Token=`node -pe 'JSON.parse(process.env.AWS_CREDS).Token'`

sleep 3600

	java -DawsAccessKey=${AccessKeyId} -DawsSecretKey=${SecretAccessKey} -DsessionToken=${Token} -jar broker-1.0-SNAPSHOT.jar
else
	echo "sleeping ... 'cos I don't have AWS_CONTAINER_CREDENTIALS_RELATIVE_URI set - diagnostic help"
	sleep 3600
fi