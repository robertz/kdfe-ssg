<!---
site:
  title: KISDigital
  description: ColdFusion, ColdBox, CommandBox and other assorted musings
  author: Robert Zehnder
  url: https://kisdigital.com
  image: https://static.kisdigital.com/kisdigital-logo.jpg
--->
<cfoutput>
<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
	<title>#prc.site.title#</title>
	<meta name="description" content="#prc.site.description#">
	<meta name="author" content="#prc.site.author#">
	<meta name="twitter:widgets:theme" content="light">
	<meta name="twitter:widgets:border-color" content="##55acee">
	<cfif prc.type eq "post">
		<meta property="og:title" content="#prc.site.title# | #prc.title#" />
		<meta name="twitter:title" content="#prc.site.title# | #prc.title#" />
		<meta name="twitter:card" content="summary_large_image" />
		<meta property="og:description" content="#prc.description#" />
		<meta name="twitter:description" content="#prc.description#" />
		<meta property="og:image" content="#prc.image#" />
		<meta name="twitter:image" content="#prc.image#" />
	<cfelse>
		<meta property="og:title" content="#prc.site.title#" />
		<meta name="twitter:title" content="#prc.site.title#" />
		<meta name="twitter:card" content="summary_large_image" />
		<meta property="og:description" content="#prc.site.description#" />
		<meta name="twitter:description" content="#prc.site.description#" />
		<meta property="og:image" content="#prc.site.image#" />
		<meta name="twitter:image" content="#prc.site.image#" />
	</cfif>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" crossorigin="anonymous">
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.3/font/bootstrap-icons.css">
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/prism-themes/1.9.0/prism-one-dark.min.css" integrity="sha512-c6S8OdtvoqZCbMfA1lWE0qd368pLdFvVHVILQzNizfowC+zV8rmVKdSlmL5SuidvATO0A7awDg53axd+s/9amw==" crossorigin="anonymous" referrerpolicy="no-referrer" />
	<link rel="stylesheet" href="/assets/css/site.css?v=#prc.build_start#">
</head>
<body style="padding-top: 70px;">

	<header>
		<nav class="header">
			<div class="container">
				<div class="row">
					<div class="col-2">
						<a class="site-link" href="/"><span style="color: var(--post-link-text)">KIS</span>Digital</a>
					</div>
					<div class="col-10"></div>
				</div>
			</div>
		</nav>
	</header>

	<!---Container And Views --->
	<div class="container text-white">
		#renderedHtml#
	</div>

	<!---js --->
	<script src="https://code.jquery.com/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
	<script type="text/javascript" src="//cdn.jsdelivr.net/gh/dkern/jquery.lazy@1.7.10/jquery.lazy.min.js"></script>
	<script type="text/javascript" src="//cdn.jsdelivr.net/gh/dkern/jquery.lazy@1.7.10/jquery.lazy.plugins.min.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.23.0/prism.min.js" integrity="sha512-YBk7HhgDZvBxmtOfUdvX0z8IH2d10Hp3aEygaMNhtF8fSOvBZ16D/1bXZTJV6ndk/L/DlXxYStP8jrF77v2MIg==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
	<script src="/assets/js/global.js?v=#prc.build_start#"></script>
	<script>
		$(function($) {
			$('.lazy img').lazy()
		})
	</script>
</body>
</html>
</cfoutput>
