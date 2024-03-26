<!---
type: project
layout: main
title: feeder
--->
<div x-data="app">
	<!--- <input type="text" id="text"> --->

	<div>
		<ul>
			<template x-for="feed in feeds">
				<li x-text="feed"></li>
			</template>
		</ul>
	</div>

	<hr>

	<ul>
		<template x-for="item in feedData" :key="item.title">
			<li x-text="item.title"></li>
		</template>
	</ul>

</div>

<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
<script src="/assets/js/feeder.js"></script>