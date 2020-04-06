const AWS = require("aws-sdk");
AWS.config.update({ region: process.env.REGION });
const dynamoDb = new AWS.DynamoDB.DocumentClient();

exports.handler = function(event, context) {
	console.log(`context=${JSON.stringify(context)}\nevent=${JSON.stringify(event)}`);
	if (event.hasOwnProperty('Records')) {
		event.Records.forEach(record => {
			const { messageId } = record;
			console.log(`Going to save to DB messsage with messageId=${messageId}`);
			writeDB(event, context, record)
			.then(data => {
				console.log(`Saved to DB messsage with messageId=${messageId}`);
				return {};
			})
			.catch(err => {
				console.log(`Issue trying to save to DB. Err=${err}`);
				return {};
			})
		});
	} else {
		console.log(`called but no records found`);
		return {};
	}
}

function writeDB(event, context, record) {
	var functionName = "writeDB";
	return new Promise((resolve, reject) => {
		console.log(`${functionName}: preparing DB record`);
		
		const dayInSeconds = 3600 * 24;;
		const keepFor = 1 * dayInSeconds;
		let now = Date.now();
		let ttl = Number(Math.floor(now / 1000) + keepFor);

		console.log(`${functionName}: about to parse incoming record data`);
		let recordBody = JSON.parse(record.body);
		let awsSqsMessageId = recordBody.AwsSqsMessageId;
		let body = recordBody.MessageBody;
		let sent = Number(record.attributes.SentTimestamp);

		let params = {
			TableName: process.env.TABLE_NAME,
			Item: {
				AwsSqsMessageId: awsSqsMessageId,
				Body: body,
				sentTimestamp: sent,
				DBsave: now,
				eol: ttl
			}
		};

		console.log(`${functionName}: ready to write DB record: ${JSON.stringify(params)}`);
		dynamoDb.put(params, error => {
			if (error) {
				console.log(`${functionName}: Error saving data to DynamoDB: ${JSON.stringify(error)}`);
				reject(`Error saving data to DynamoDB: ${JSON.stringify(error)}`);
			} else {
				console.log(`${functionName}: saved OK:`, params.Item);
				resolve(JSON.stringify(params.Item));
			}
		});
	})
}