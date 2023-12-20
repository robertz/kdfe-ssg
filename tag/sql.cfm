<!---
layout: main
view: page
--->
<cfset tag="sql" />
<cfoutput>
<h4>Posts tagged as #tag#</h4>
<cfloop array="#collections.byTag[generateSlug(tag)]#" index="i">
	<p><a href="#i.permalink#" class="post-link text-decoration-none">#i.title#</a></p>
</cfloop>
</cfoutput>
