---
layout: main
type: post
title: Running API-to-CSV Scripts with BoxLang
author: Robert Zehnder
slug: running-api-to-csv-scripts-with-boxlang
date: 2025-08-21 18:00:00
published: true
image: https://static.kisdigital.com/ssg/2025/api-to-csv.jpg
description: Quick and easy CSV generation with Boxlang CLI
tags:
- boxlang
- cfml
---
### Running API-to-CSV Scripts with BoxLang

Sometimes you need to pull large amounts of data from APIs and export
that data into a CSV file for analysis in Excel. Normally, you might
build an API endpoint to handle both reading and writing the data.
However, if the process takes **hours** instead of minutes, running it
as a command-line script is a better option.

With **BoxLang**, you can easily create a command-line script that
fetches API data and outputs it as CSV, bypassing web request
limitations.

------------------------------------------------------------------------

### Running BoxLang as a Shell Script

On **Mac** or **Linux**, you can write BoxLang scripts in shell-style
syntax and execute them directly from the command line. Just set the
environment properly.

Here's an example script:

``` bash
#!/usr/bin/env boxlang

// Retrieve command-line arguments (none used here)
args = cliGetArgs();

// Fetch user data from the API
function getUsers() {
	bx:http url="https://jsonplaceholder.typicode.com/users" result="res";
	return JSONDeserialize(res.fileContent);
}

// Call the function
users = getUsers();
headers = [
	"id", "name", "username", "email", "street", "suite", "city", "zipcode", "phone", "website", "company"
];
template = "";
headers.each(header => {
	template = template.listAppend("${#header#}");
});
// Print CSV header
printLn(headers.toList(","));
// Print user data
users.each(user => {
	templateData = [
		id: user.id,
		name: user.name,
		email: user.email,
		username: user.username,
		phone: user.phone,
		website: user.website,
		company: user.company.name,
		street: user.address.street,
		suite: user.address.suite,
		city: user.address.city,
		zipcode: user.address.zipcode
	];
	printLn(stringBind(template, templateData));
});
```

------------------------------------------------------------------------

### How It Works

1.  **Command-line arguments**\
    The script uses `cliGetArgs()` to retrieve arguments. This example
    doesn't use them, but the feature is there if needed.

2.  **Fetching API data**\
    `getUsers()` calls `bx:http` to retrieve a JSON payload, which is
    then deserialized into a native BoxLang structure.

3.  **Generating CSV data**\
    The script prints a CSV header, then iterates through each record
    and outputs the user data as CSV rows.

------------------------------------------------------------------------

### Saving the Output

The script prints to the console using `printLn`. To save the output
into a CSV file, you can use standard shell redirection or `tee`:

``` bash
chmod +x boxlang-users
./boxlang-users | tee users.csv
```

This command runs the script, saves the output into `users.csv`, and
still displays it in the console.

------------------------------------------------------------------------

### Boxlang Script Syntax

If you are not running in a \*nix environment it is just a matter of
creating a Boxlang script template.

``` js
// boxlang-users.bxs
// Retrieve command-line arguments (none used here)
args = cliGetArgs();

// Fetch user data from the API
function getUsers() {
	bx:http url="https://jsonplaceholder.typicode.com/users" result="res";
	return JSONDeserialize(res.fileContent);
}

// Call the function
users = getUsers();
headers = [
	"id", "name", "username", "email", "street", "suite", "city", "zipcode", "phone", "website", "company"
];
template = "";
headers.each(header => {
	template = template.listAppend("${#header#}");
});
// Print CSV header
printLn(headers.toList(","));
// Print user data
users.each(user => {
	templateData = [
		id: user.id,
		name: user.name,
		email: user.email,
		username: user.username,
		phone: user.phone,
		website: user.website,
		company: user.company.name,
		street: user.address.street,
		suite: user.address.suite,
		city: user.address.city,
		zipcode: user.address.zipcode
	];
	printLn(stringBind(template, templateData));
});
```

You can then run the script:

``` bash
boxlang boxlang-users.bxs
```

------------------------------------------------------------------------

### Boxlang Class Syntax

Finally this can also be written as a Boxlang class, we will need to add `function main(args = [])` as the
entry point. Aside from that the code is identical.

``` js
class {
	function getUsers() {
		bx:http url="https://jsonplaceholder.typicode.com/users" result="res";
		return JSONDeserialize(res.fileContent);
	}

	function main(args = []) {
		// Fetch user data
		users = getUsers();
		headers = [
			"id", "name", "username", "email", "street", "suite", "city", "zipcode", "phone", "website", "company"
		];
		// Print CSV header
		printLn(headers.toList(","));
		template = "";
		headers.each(header => {
			template = template.listAppend("${#header#}");
		});
		// Print user data
		users.each(user => {
			templateData = {
				id: user.id,
				name: user.name,
				email: user.email,
				username: user.username,
				phone: user.phone,
				website: user.website,
				company: user.company.name,
				street: user.address.street,
				suite: user.address.suite,
				city: user.address.city,
				zipcode: user.address.zipcode
			};
			// build columns dynamically
			printLn(stringBind(template, templateData));
		});

		cliExit(0);
	}
}
```

This can be invoked as:

``` bash
boxlang boxlang-users.bx
```

------------------------------------------------------------------------

### Real-World Use Case

This example is fairly simple, but in practice you might need to handle
far larger datasets. For instance, one use case involved calling a
GraphQL endpoint that returned **tens of thousands of records**. Running
such a heavy process on a web server wasn't practical because of the
processing time. Instead, executing the script with **BoxLang from the
console** handled the workload efficiently without tying up server
resources.
