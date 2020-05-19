const AWS = require("aws-sdk");
AWS.config.update({ region: process.env.REGION });
const dynamoDb = new AWS.DynamoDB.DocumentClient();
var sqs = new AWS.SQS({ apiVersion: '2012-11-05' });

var txQueueURL = process.env.SQS_REQUEST_QUEUE_NAME;
const maxRetries = 5000;

exports.handler = function(event, context, callback) {

    const timer = setTimeout(() => {
        console.log("Oh no this Lambda function is going to die becuase it is out of time in 3 seconds...");
    }, context.getRemainingTimeInMillis() - 3 * 1000);

    console.log(`event: ${JSON.stringify(event)}`);
    console.log(`context: ${JSON.stringify(context)}`);

    // Parse input variables

    var myVars = { MyEmail: "joe@learning.consulting", MyFirstname: "Joe", MySurname: "Bloggs" };

    if (event.hasOwnProperty('queryStringParameters')) {
    	if (event.queryStringParameters != null) {
	    	if (event.queryStringParameters.hasOwnProperty('MyFirstname')) myVars.MyFirstname = event.queryStringParameters.MyFirstname;
	    	if (event.queryStringParameters.hasOwnProperty('MySurname')) myVars.MySurname = event.queryStringParameters.MySurname;
	    	if (event.queryStringParameters.hasOwnProperty('MyEmail')) myVars.MyEmail = event.queryStringParameters.MyEmail;
	    }
    }

    messageBody = `Dear ${myVars.MyFirstname} ${myVars.MySurname}, this is just a test, don't worry nothing will be sent to ${myVars.MyEmail}`;

    var txParams = {
        DelaySeconds: 0,
        MessageBody: messageBody,
        QueueUrl: txQueueURL
    };

    console.log(`txParams=${JSON.stringify(txParams)}`);

    sendSQS(event, context, txParams)
        .then(data => {

            var messageId = data.MessageId;
            console.log(`sendSQS returned data= ${JSON.stringify(data)}`);
            fetchResponse(event, context, messageId, 0, callback, timer)
        })
        .catch(err => {
            console.log(`sendSQS error: ${err}`);
            clearTimeout(timer);
            return callback(null, { statusCode: 404, body: "Could not send message", headers: { "Content-Type": "application/json", 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Credentials': true } })
        })
};

function sendSQS(event, context, txParams) {
    return new Promise((resolve, reject) => {
        sqs.sendMessage(txParams, function(err, data) {
            if (err) {
                console.log("Error", err);
                reject(err);
            } else {
                resolve(data);
            }
        });
    });
}

function fetchResponse(event, context, messageId, retryCount, callback, timer) {
    return new Promise((resolve, reject) => {
    	var found = 0;

    	let params = {
    		TableName: process.env.TABLE_NAME,
    		Key: { "AwsSqsMessageId": messageId}
    	};

    	console.log(`doing get with params=${JSON.stringify(params)}`);

    	dynamoDb.get(params, (err, data) => {
    		if (err) {
    			console.log(`Not this time`);
    		} else {
    			if (data.hasOwnProperty('Item')) {
	    			console.log(`Found item ${JSON.stringify(data)}`);
	    			found++;
	    			dynamoDb.delete(params, err => {
	    				if (err) {
	    					console.log(`Failed to delete record, not fatal`);
		    				clearTimeout(timer);
		    				return callback(null, { statusCode: 200, body: data.Item.Body, headers: { "Content-Type": "application/json" } });
	    				} else {
	    					console.log(`deleted record, al done`);
		    				clearTimeout(timer);
		    				return callback(null, { statusCode: 200, body: data.Item.Body, headers: { "Content-Type": "application/json" } });
	    				}
	    			})
	    		}
    		}
	        if (found == 0) {
		        if (retryCount >= maxRetries) {
		            clearTimeout(timer);
		            return callback(null, { statusCode: 404, body: "Didn't get valid message", headers: { "Content-Type": "application/json", 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Credentials': true } });
		        } else {
		            console.log(`fetchResponse: let's poll DynamoDB again`)
		            return (fetchResponse(event, context, messageId, retryCount + 1, callback, timer))
		        }
		    }
    	})

    });
}

