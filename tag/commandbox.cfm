<!---
layout: main
view: page
--->
<cfset tag="commandbox" />
<cfoutput>
<h4>Posts tagged as #tag#</h4>
<cfloop array="#collections.byTag[generateSlug(tag)]#" index="i">
	<p><a href="#i.permalink#" class="post-link text-decoration-none">#i.title#</a></p>
</cfloop>
</cfoutput>