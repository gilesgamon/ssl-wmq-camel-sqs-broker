const replace = require('replace-in-file');
const FileLocation = '../src/main/resources/broker.properties'

var aws_cred = ["ACCESS_KEY", "SECRET_KEY"]
var camel_options = ["QUEUE_MANAGER", "MQ_HOSTNAME", "MQ_PORT", "MQ_CHANNEL", "MQ_REQUEST_QUEUE", "MQ_RESPONSE_QUEUE", "MQ_CIPHER"]
var required_env_params = ["AWS_CRED", "CAMEL_VALUES", "CLIENT_KEY", "CLIENT_CRT", "ROOT_PEM", "INTERMEDIATE_PEM"]

function checkEnv (env_name) {
	// crach out if we haven't been given correct env params
    if (!process.env.env_name) {
        console.log(`Issue accessing Env ${env_name}`)
        process.exit(1)
    }
    return
}

function prepare(event, context, options = null) {

    // Check we have the required env settings
	for (var index = 0 ; index < required_env_params.length ; index++ ) {
		checkEnv(required_env_params[index])
	}

    // load the Env settings
    var aws_values = JSON.parse(process.env.AWS_CRED)
    var camel_values = JSON.parse(process.env.CAMEL_VALUES)

    var client_key = process.env.CLIENT_KEY
    var client_crt = process.env.CLIENT_CRT
    var root_pem = process.env.ROOT_PEM
    var intermediate_pem = process.env.INTERMEDIATE_PEM
    var options = { files: FileLocation }

    // now check the internal values are complete
    for (var index = 0; index < aws_cred.length; index++) {
        if (!aws_values[aws_cred[index]]) {
            console.log(`Error accessing Env ${aws_cred[index]}`)
            process.exit(1)
        }
    }

    for (index = 0; index < camel_options.length; index++) {
        if (!camel_values[camel_options[index]]) {
            console.log(`Error accessing Env ${camel_options[index]}`)
            process.exit(1)
        }
    }

    // do substitution for AWS_CREDS
    for (var index = 0; index < aws_cred.length; index++) {
        options.from = aws_cred[index]
        options.to = aws_values[aws_cred[index]]
        try {
            const results = replace.sync(options);
            console.log(`Replacement of ${options.from} results:`, results);
        } catch (error) {
            console.error('Error occurred:', error);
        }
    }
    // do substitution for CAMEL_OPTIONS
    for (var index = 0; index < camel_options.length; index++) {
        options.from = camel_options[index]
        options.to = camel_values[camel_options[index]]
        try {
            const results = replace.sync(options);
            console.log(`Replacement of ${options.from} results:`, results);
        } catch (error) {
            console.error('Error occurred:', error);
            process.exit(1)
        }
    }

    saveFileData(pem_joiner(client_key, 3), '../client.key')
    saveFileData(pem_joiner(client_crt, 1), '../client.crt')
    saveFileData(pem_joiner(root_pem, 1), '../caCert.pem')
    saveFileData(pem_joiner(intermediate_pem, 1), '../intermediate.pem')
}

function pem_joiner (mucky_pem, gaps) {
	

	var lines = mucky_pem.split(' ')
	var temp = []
	var output = []
	var new_lines = []
	// we an't be sure how it'll come to use, so make it consitient
	for ( var dex = 0; dex < lines.length ; dex++) {
		if (lines[dex] != lines[dex].split('\n')) {
			temp = lines[dex].split('\n')
			new_lines = new_lines.concat(temp)
		} else {
			new_lines.push(lines[dex])
		}
	}
	// for ( dex = 0; dex < new_lines.length ; dex++) {
	// 	console.log(`${dex}:${new_lines[dex]}`)
	// }
	var temp = []
	lines = new_lines
	var top_of_header = gaps + 1
	var top_of_footer = (lines.length - gaps - 1)
	// join the header back up
	for (var index = 0 ; index <= gaps ; index++) {
		temp.push(lines[index])
	}
	output.push(temp.join(' '))
	// deal with main body
	for (var index = top_of_header ; index < top_of_footer ; index++ ) {
		output.push(lines[index])
	}
	// deal with footer
	temp = []
	for (var index = top_of_footer ; index < lines.length ; index++) {
		temp.push(lines[index])
	}
	output.push(temp.join(' '))
	return output.join("\n")
}

function saveFileData (rawData, fileName) {
    return new Promise((resolve, reject) => {
        // Write the variables out for newman
        let fs = require('fs');

        fs.writeFile(fileName, rawData, function(err) {
            if (err) {
                console.log(`Error trying to write ${fileName}: ${err}`);
                reject(`Error trying to write ${fileName}`);
            }
            console.log('Saved data to', fileName);
            resolve();
        });
    })
}

module.exports = { prepare };

require('make-runnable');