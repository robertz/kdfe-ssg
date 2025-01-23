---
layout: main
type: post
title: Shopify GraphQL query example
slug: shopify-graphql-query-example
description: Robert shows how to query Shopify GraphQL Admin API
author: Robert Zehnder
image: https://static.kisdigital.com/ssg/2025/graphql.jpg
tags:
- cfml
published: true
date: 2025-01-23 18:00:00
---
The CFML `#cfml-beginners` channel on the CFML slack recently had a question about building a request to the Shopify GraphQL Admin API server. If the GraphQL query is not formatted properly, even though it looks great, will cause errors when Shopify gets the request. I looked at this issue briefly because I love a good problem, but given my priorities, I just did not have time to dig in to it. I had just enough time to say "Wow, that sucks." then I had to move on.

As luck would have it, I was recently assigned a Shopify API integration so I have had plenty of time now to look in to this issue.

In depth.

The issue with the GraphQL format is easy to fix, it expects the query to be "flattened" for lack of a better term. Initially I was just going to write a routine that would split the GraphQL query into an array, breaking on `chr(10)`, trimming the resulting value, then joining the array with a `space`. This will return a nicely flattened query that Shopify's API will accept.

The next issue, my service code was littered with replicated `cfhttp` calls. The endpoint never changes, only the query, so I created a wrapper method called `queryGraph(theQuery, theVariables)`. The GraphQL query is passed as `theQuery` and any variables needed can be passed as `theVariables`. This method builds the `cfhttp` body and ensures everything is properly formatted.

Write your query, pass any required variables, and profit.

```js
function queryGraph(required string theQuery, struct theVariables = {}){
    var res = {
        'svrStatus': "-1",
        'data': {}
    }
    // Prepare the query
    var preparedQuery = arguments.theQuery
        .listToArray(chr(10))
        .map((line) => trim(line))
        .toList(" ");
    var body = {
        "query": preparedQuery
    };
    if(!arguments.theVariables.isEmpty()){
        body['variables'] = arguments.theVariables;
    };
    cfhttp(url ="https://" & variables.store & "/admin/api/" & variables.adminAPIVersion & "/graphql.json", method="POST"){
        cfhttpparam(type="header", name="Content-Type", value="application/json");
        cfhttpparam(type="header", name="X-Shopify-Access-Token", value="#variables['X-Shopify-Access-Token']#");
        cfhttpparam(type="body", value=serializeJSON(body));
    }
    if(cfhttp.responseHeader.status_code == 200){
        res['svrStatus'] = "0";
        res.data.append(deserializeJSON(cfhttp.fileContent).data);
    }
   return res;
}
```

<br>

And here is an example request.

```js
	var graphQL = '
		query {
			orders(
				first: 100,
				query: "created_at:>#dateFormat(dateAdd('d', -7, now()), 'yyyy-mm-dd')# AND fulfillment_status:unfulfilled",
				reverse: true
			) {
				edges {
					node {
						id
						updatedAt
					}
				}
			}
		}
	';
	// call the graph and get the response
	var res = queryGraph(graphQL);
	// res.svrStatus will be 0 if successful, non-zero indicates an error
	// res.data will contain the response, if any
```

<br>

This should be easily portable to any other GraphQL server, just make any necessary edits in the `cfhttp` call.
