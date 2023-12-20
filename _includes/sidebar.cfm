<cfoutput>
<div>
	<div class="card rf-card-bordered text-white">
		<div class="card-body">
			<div class="card-title">
				<span class="h6">KISDigital</span>
			</div>
			<div class="card-text">
				<small>
					ColdFusion, ColdBox, CommandBox and assorted musings.
				</small>
			</div>
		</div>
	</div>
	<div class="card rf-card-bordered text-white mt-3">
		<div class="card-body">
			<div class="card-title">
				<span class="h6">Tags</span>
			</div>
			<div class="card-text">
				<cfloop array="#collections.tags#" index="tag">
					<a href="/tag/#generateSlug(tag)#"> <span class="h5"><span class="badge bg-info text-muted p-2">#tag#</span></span></a>
				</cfloop>
			</div>
		</div>
	</div>
	<div class="card rf-card-bordered text-white mt-3">
		<div class="card-body">
			<div class="card-title">
				<span class="h6">Recent Posts</span>
			</div>
			<div class="card-text">
				<cfloop from="1" to="5" index="i">
					<a href="#collections.post[i].permalink#" class="post-link text-decoration-none">#collections.post[i].title#</a><br />
				</cfloop>
			</div>
		</div>
	</div>
</div>
</cfoutput>