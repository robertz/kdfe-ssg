---
layout: main
type: post
title: ColdFusion API Basics - Remote Authentication
author: Robert Zehnder
slug: coldfusion-api-basics-remote-authentication
publishDate: 2020-07-21
published: true
image: https://static.kisdigital.com/images/coldfusion-api-basics-remote-authentication/00_cover.jpeg
description: Outlining the major remote authentication paradigms
tags: 
- cfml
---

APIs are so common place and pervasive in our technology today that we barely even give them a second thought. If you are writing an e-commerce app you might have an API call to verify a user entered a valid shipping address, you might use an API call to put items in a shopping cart, or process a transaction. At the simplest level ColdFusion makes a cfhttp request out to a remote resource.

I have worked with many APIs over the years and the first milestone for any API project is that first successful request. The one where the moon and stars align just so, the breeze is blowing in a particular way, and the gods of the interwebs grace us with a successful response. That may seem a little theatric, but sometimes getting the authentication right is the hardest part of the project; Everything else will just fall in line the groundwork is done right.

#### Authentication types

##### No Authentication

If you are using a public API it is possible there will be no authentication required. There are a few sites like JSONPlaceholder that provide free REST API you can use when you need fake data.

##### Basic Authentication

Basic authentication might be the first step in securing an API call. This would allow you to pass a username and password combination encoded as a hexadecimal string and passed as an authorization header.

``` javascript
cfhttp(url = "https://www.site.com/my/api"){
 cfhttpparam(type = "header", name = "Authorization", value="Basic " & toBase64("username:password"); 
}
```

Basic authentication is one of the simplest techniques of enforcing access controls to web pages and is implemented in all major web servers. Typically you would only want to use basic auth in conjunction with HTTPS since there is no confidentiality protection for your credentials, they are just base64 encoded but not encrypted or hashed in any way.

##### API Key Authentication

Some APIs will authenticate a request by expecting a key in a specific header or URL parameter. Like basic authentication, this scheme is best used over HTTPS because credentials are not encrypted or hashed.

``` javascript
cfhttp(url = "https://www.site.com/my/api"){
 cfhttpparam(type = "header", name = "api-key", value="AwesomeAPI_mykey"); 
}
```

##### Signature Based Authentication

Signature based authentication is popular with online sellers because you can ensure the request was not modified in flight. Here is an example generating the authorization header for a request by concatenating the endpoint URL with the raw post body and generating the HMAC-SHA256 signature.

``` javascript
 var body = {
 'partner_id': instance.props.partner_id,
 'shopid': instance.props.shopid,
 'order_status': criteria.keyExists("orderStatus") ? criteria.orderStatus : "ALL",
 'timestamp': int(dateDiff("s", dateConvert("utc2Local", "January 1 1970 00:00"), now()))
 };
 cfhttp(url = instance.props.apiBase & "orders/get", method = "post"){
 cfhttpparam(type = "header", name = "Content-Type", value = "application/json");
 cfhttpparam(type = "header", name = "Authorization", value = lcase(hmac(instance.props.apiBase & "orders/get|" & serializeJSON(body), instance.props.apiAuth, "HMACSHA256", "UTF-8")));
 cfhttpparam(type = "body", value = serializeJSON(body));
 };
```

It can sometimes present some challenges since some ColdFusion crypto functions do not not always work the way you think they should. ColdFusion is a loosely-typed language, if the API is expecting a numeric value you should ensure that CF is passing the value as a number as opposed to a string.

##### OAuth Based Authentication

Authenticating with OAuth requires calling an endpoint to generate an access token that has a set time to live. Implementation varies by vendor, once your access token expires you might be required to generate a new access token using a refresh token or just generate a new access token.

``` javascript
private string function getBearerToken (){
 var authData = {};
 var authCache = cacheGet("authKey");
 if(authCache.svrStatus == 0){ // Token can be pulled from cache
 authData.append(authCache.data);
 }
 else{ // Generate a new token
 cfhttp(url = instance.props.oauthURL, method = "post"){
 cfhttpparam(type = "header", name = "Content-Type", value = "application/json");
 cfhttpparam(type = "body", value = serializeJSON(instance.props.credentials));
 }
 if(isJSON(cfhttp.fileContent)){ // returned valid json
 authData.append(deserializeJSON(cfhttp.fileContent));
 // set the cache key and do cool stuff
 }
 }
 return authData.keyExists("data") && authData.data.keyExists("token") ? authData.data.token : ""; 
}

public struct function listOrders () {
 var res = {};
 var postBody = {
 "pageNo": criteria.keyExists("pageNo") ? criteria.pageNo : 1,
 "pageSize": criteria.keyExists("pageSize") ? criteria.pageSize : 100
 };
 cfhttp(url = instance.props.apiBase & 'order/platform/list', method = "post"){
 cfhttpparam(type = "header", name = "Authorization", value = "Bearer " & getBearerToken());
 cfhttpparam(type = "header", name = "Content-Type", value = "application/json");
 cfhttpparam(type = "body", value = deserializeJSON(postBody));
 }
 if(isJSON(cfhttp.fileContent)){
 // do stuff with the response 
 }
 return res;
}
```

Each request requires a bearer token to be passed in the authorization header so I will generally create a private method that will return the current token. The first step is to check cache to see if the current token exists, if so, just return the token value. If the token does not exist call the OAuth authorization endpoint, place the token in cache and match the token time-to-live, and finally return the token.

Methods calling the remote API will use getBearerToken() to generate the bearer token each request. If the token expired (no longer exists in cache) it will just seamlessly generate a new token and set a new cache key.

#### Wrapping Up

These are the authentication schemes I have found most often when trying to get an API integration up and running. Even though every implementation is different, it is always nice to see how others have handled it. I hope this gets you pointed in the right direction.
