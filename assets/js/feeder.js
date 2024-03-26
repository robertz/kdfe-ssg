document.addEventListener('alpine:init', () => {
	Alpine.data('app', () => ({
		feeds: [
			"https://kisdigital.com/rss",
			"https://www.raymondcamden.com/feed.xml",
			"https://www.petefreitag.com/rss"
		],
  		feedData: [],


		async init() {
			this.feeds.forEach(ele => {
				fetch(`/api/get-feed?feed=${ele}`)
					.then(res => res.json())
					.then(res => {
						this.feedData = this.feedData.concat(res.items)
					})
			})
		},

		get sortedFeeds(){
			return this.feedData.sort((a,b) => {
				return new Date(b.isoDate) - new Date(a.isoDate);
			})
		},
	}))
})