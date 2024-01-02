<!---
layout: main
view: page
permalink: /tag/{{tag}}.html
pagination:
  alias: tag
  data: ["cfml","commandbox","food","misc","sql"]
--->
<cfoutput>
	<h4>Posts tagged as #prc.tag#</h4>
	<cfloop array="#collections.byTag[generateSlug(prc.tag)]#" index="i">
		<p><a href="#i.permalink#" class="post-link text-decoration-none">#i.title#</a></p>
	</cfloop>
</cfoutput>
