---
layout: main
type: post
title: Scraping Recipes Using ColdFusion
slug: scraping-recipes-using-coldfusion
description: Robert explains using ColdFusion to scrape recipes and return as API data
author: Robert Zehnder
image: https://static.kisdigital.com/ssg/2024/dog-cooking-in-the-kitchen.jpg
tags: 
- coldbox
- cfml
published: true
date: 2024-06-13 18:00:00
---
Yesterday Ray Camden wrote an interesting [blog post](https://www.raymondcamden.com/2024/06/12/scraping-recipes-using-nodejs-pipedream-and-json-ld) about scraping recipes using node.js, Pipedream, and JSON-LD. It looked really neat so I thought I would see what it would take to create the service in ColdFusion.

Ray does a great job of explaining in detail  how he got the idea to write his API. If you would like the background, please check out his post linked above.

That being said, let us look at the code.

### Step One - Getting the JSON-LD

<br>

My API server is running ColdBox, so I have created a handler that will process incoming requests. I will be using jSoup to handle parsing and filtering HTML elements since it makes these kind of tasks trivial. As a general rule I do not put logic in a handler, but since this is a small demo I do not feel too bad about it. I may clean it up proper later.

### Step Two - Getting the Recipe

<br>

Next filter the results looking for instances of `ld+json` elements. If found, process the first element. If everything is copacetic, the results are generated based on the data parsed. Multiple recipes on the page, you are just getting the first one.

```js
component extends="coldbox.system.EventHandler" {

 property name="jSoup" inject="javaLoader:org.jsoup.Jsoup";

 function index( event, rc, prc ){
  var result    = [ : ];
  var recipeURL = event.getValue( "url", "" );

  // Is the url valid-ish?
  if ( !isValid( "url", recipeURL ) ) return {};

  // Parse the page using jSoup
  var jsDoc = jSoup
   .connect( recipeURL )
   .followRedirects( true )
   .userAgent( "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0" )
   .get();

  // Filter the data
  var tag = jsDoc.select( "script[type=application/ld+json]" );

  // Not found? Do not continue processing
  if ( !tag.len() ) return {};

  // Found? Grab the first item
  tag = tag.first();

  var parsed = {};

  // Is it JSON?
  if ( isJSON( tag.html() ) ) parsed = deserializeJSON( tag.html() );

  // Is it array data?
  if ( isArray( parsed ) ) parsed = parsed[ 1 ];

  // Build the results
  if ( !parsed.isEmpty() ) {
   result[ "name" ]         = parsed.name;
   result[ "image" ]        = parsed.image;
   result[ "description" ]  = parsed.description;
   result[ "cookTime" ]     = parsed.cookTime;
   result[ "prepTime" ]     = parsed.prepTime;
   result[ "totalTime" ]    = parsed.totalTime;
   result[ "category" ]     = parsed.recipeCategory;
   result[ "cuisine" ]      = parsed.recipeCuisine;
   result[ "ingredients" ]  = parsed.recipeIngredient;
   result[ "instructions" ] = [];
   for ( var instruction in parsed.recipeInstructions ) {
    if ( !isStruct( instruction ) ) {
     result.instructions.append( instruction );
    } else {
     if ( instruction[ "@type" ] == "HowToStep" ) result.instructions.append( instruction.text );
    }
   }
   result[ "yield" ] = parsed.recipeYield[ 1 ];
  }
  return result;
 }

}
```

<br>

If you read Ray's original post, you can see I shamelessly copied much of his code. I added in a few sanity checks to ensure a proper url was passed and made sure it did not error if an `ld+json` block was not found on the page.

The `result` variable is an ordered struct to keep the keys ordered by how they were created.

### Results

<br>

#### Iced Pumpkin Cookies

<br>

<https://www.allrecipes.com/recipe/10033/iced-pumpkin-cookies/>

Result:

<br>

```json
{
  "name": "Iced Pumpkin Cookies",
  "image": {
    "@type": "ImageObject",
    "url": "https://www.allrecipes.com/thmb/FvtXTdFkika4fqBMwIpek7OgudU=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/10033iced-pumpkin-cookiesSheilaLaLondeVideo4x3-505c68b332134143961078d4165035b9.jpg",
    "height": 1125,
    "width": 1500
  },
  "description": "Soft pumpkin cookies made with canned pumpkin, perfectly spiced with cinnamon, nutmeg, and cloves, are drizzled with sweet icing for a cozy fall treat.",
  "cookTime": "PT15M",
  "prepTime": "PT20M",
  "totalTime": "PT65M",
  "category": [
    "Dessert"
  ],
  "cuisine": [
    "American"
  ],
  "ingredients": [
    "2.5 cups all-purpose flour",
    "2 teaspoons ground cinnamon",
    "1 teaspoon baking powder",
    "1 teaspoon baking soda",
    "0.5 teaspoon ground nutmeg",
    "0.5 teaspoon ground cloves",
    "0.5 teaspoon salt",
    "1.5 cups white sugar",
    "0.5 cup butter, softened",
    "1 cup canned pumpkin puree",
    "1 egg",
    "1 teaspoon vanilla extract",
    "2 cups confectioners' sugar",
    "3 tablespoons milk",
    "1 tablespoon melted butter",
    "1 teaspoon vanilla extract"
  ],
  "instructions": [
    "Preheat the oven to 350 degrees F (175 degrees C). Grease two cookie sheets.",
    "To make the cookies: Combine flour, cinnamon, baking powder, baking soda, nutmeg, cloves, and salt in a medium bowl.",
    "Cream together sugar and butter in a mixing bowl until fluffy, 2 to 3 minutes. Add pumpkin, egg, and vanilla; beat until creamy. Mix in flour mixture until combined. Drop tablespoonfuls of dough onto the prepared cookie sheets; flatten slightly.",
    "Bake in the preheated oven until centers are set, 15 to 20 minutes, switching racks halfway through. Transfer cookies to a wire rack to cool to room temperature, about 30 minutes.",
    "Meanwhile, make the icing: Stir together confectioners&#39; sugar, milk, butter, and vanilla in a bowl until smooth. Add milk as needed, to achieve drizzling consistency.",
    "Drizzle icing over cooled cookies with a fork."
  ],
  "yield": "36"
}
```

<br>

### The API

<br>

The endpoint for the API can be found here:

<https://api.kisdigital.com/recipe/?url=https://www.allrecipes.com/recipe/10033/iced-pumpkin-cookies/>

There are probably a few other adjustments that need to be made to my code, offhand I know I am not validating `@type=Recipe`. However, I did not run in to any issues in the tens of minutes I spent exhaustively testing the API. Also, I am not currently doing "pretty" durations, but I may fix that later.

Finally, my thanks to Ray for a fun diversion. 
