const Parser = require('rss-parser')
const parser = new Parser()

exports.handler = async (event, context) => {
	let feed = await parser.parseURL(event.queryStringParameters.feed)

	return {
		statusCode: 200,
		body: JSON.stringify(feed),
		headers: {
			'Access-Control-Allow-Origin': '*',
			'Access-Control-Allow-Headers': 'Content-Type',
			'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE'
		}
	}
}