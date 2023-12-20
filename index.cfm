<!---
layout: main
view: page
--->
<cfoutput>
<div class="row mb-5">
	<cfloop from="1" to="#collections.post.len() gt 3 ? 3 : collections.post.len()#" index="i">
		<cfif i eq 1>
			<div class="col-12 p-1">
				<a href="#collections.post[i].permalink#" class="text-decoration-none">
					<div style="background: url(#collections.post[i].image#) no-repeat center center; background-size: cover; height: 500px;">
						<div class="bg-dark w-75 opacity-75 p-2">
							<p class="h2 text-white">#collections.post[i].title#</p>
							<small class="d-block text-white py-1">#collections.post[i].description#</small>
							<cfloop array="#collections.post[i].tags#" index="tag">
								<span class="badge bg-light m-1 p-2 h5 text-dark">#tag#</span>
							</cfloop>
							<p class="text-white small text-uppercase">
								#dateFormat(collections.post[i].publishdate, "MMMM d, YYYY")# /
								#collections.post[i].author#
							</p>
						</div>
					</div>
				</a>
			</div>
		</cfif>
		<cfif i eq 2>
			<div class="col-6 p-1">
				<a href="#collections.post[i].permalink#" class="text-decoration-none">
					<div style="background: url(#collections.post[i].image#) no-repeat center center; background-size: cover; height: 275px;"></div>
					<div>
						<p class="h4 text-white" style="height: 75px;">#collections.post[i].title#</p>
						<small class="d-block text-white py-1">#collections.post[i].description#</small>
					</div>
				</a>
			</div>
		</cfif>
		<cfif i eq 3>
			<div class="col-6 p-1">
				<a href="#collections.post[i].permalink#" class="text-decoration-none">
					<div style="background: url(#collections.post[i].image#) no-repeat center center; background-size: cover; height: 275px;"></div>
					<div>
						<p class="h4 text-white" style="height: 75px;">#collections.post[i].title#</p>
						<small class="d-block text-white py-1">#collections.post[i].description#</small>
					</div>
				</a>
			</div>
		</cfif>
	</cfloop>
</div>
<cfif collections.post.len() gt 3>
	<div class="h4">Older Posts</div>
	<cfloop from="4" to="#collections.post.len()#" index="i">
		<p><a href="#collections.post[i].permalink#" class="post-link">#collections.post[i].title#</a></p>
	</cfloop>
</cfif>
</cfoutput>