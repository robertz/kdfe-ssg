<cfoutput>
<div class="row">
	<div class="col-lg-8 col-md-12">
		<div class="card rf-card-bordered">
			<div class="card-body">
				<div style="background: url(#prc.image#) no-repeat center center; background-size: cover; height: 350px;">
					<div class="bg-dark w-75 opacity-75 p-2">
						<p class="h2 text-white">#prc.title#</p>
						<small class="d-block text-white py-1">#prc.description#</small>
						<cfloop array="#prc.tags#" index="tag">
							<span class="badge bg-light m-1 p-2 h5 text-dark">#tag#</span>
						</cfloop>
						<p class="text-white small text-uppercase">
							#dateFormat(prc.publishdate, "MMMM d, YYYY")# /
							#prc.author#
						</p>
					</div>
				</div>
				<div class="my-3">
					<a href="https://www.facebook.com/sharer/sharer.php?u=#prc.meta.url##prc.permalink#" class="text-decoration-none" target="_blank">
						<i class="bi bi-facebook px-1 text-white fs-5"></i>
					</a>
					<a href="https://www.twitter.com/share?url=#prc.meta.url##prc.permalink#" class="text-decoration-none" target="_blank">
						<i class="bi bi-twitter px-1 text-white fs-5"></i>
					</a>
					<a href="https://www.linkedin.com/sharing/share-offsite/?url=#prc.meta.url##prc.permalink#" class="text-decoration-none" target="_blank">
						<i class="bi bi-linkedin px-1 text-white fs-5"></i>
					</a>
				</div>
				<div class="my-3 text-white post decorate-links">
					#prc.content#
				</div>
				<cfinclude template="disqus.cfm" />
			</div>
		</div>
	</div>
	<div class="col-lg-4 d-none d-lg-block d-xl-block">
		<cfinclude template="sidebar.cfm" />
	</div>
</div>
</cfoutput>