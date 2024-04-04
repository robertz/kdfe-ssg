document.addEventListener('alpine:init', () => {
	Alpine.data('app', () => ({
		addFeed: '',
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
				return new Date(b.isoDate) - new Date(a.isoDate)
			})
		},
		addNewFeed(){
			if(isValidUrl(this.addFeed)){

				fetch(`/api/get-feed?feed=${this.addFeed}`)
				.then(res => res.json())
				.then(res => {

					if(typeof res === 'object'){
						this.feeds.push(this.addFeed)
						this.feedData = this.feedData.concat(res.items)
						this.addFeed = ''
					}


				})
			}
		},
	}))
});

function isValidUrl(link) {
	let url;
	try {
		url = new URL(link);
	} catch (_) {
		return false
	}
	return url.protocol === "http:" || url.protocol === "https:"
}

function isJson(str) {
	if (typeof str !== 'string') return false;
	try {
		const result = JSON.parse(str);
		const type = Object.prototype.toString.call(result);
		return type === '[object Object]'
			|| type === '[object Array]';
	} catch (err) {
		return false;
	}
}