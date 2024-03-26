document.addEventListener('alpine:init', () => {
	Alpine.data('app', () => ({
		feeds:["https://kisdigital.com/rss"],
  		feedData: [],


		async init() {
			fetch(`/api/get-feed?feed=${this.feeds[0]}`)
			.then(res => res.json())
			.then(res => {
				this.feedData = res.items
			})
		},
	}))
})