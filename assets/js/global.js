"use strict";

const KDGlobal = function() {

	const linkDecorator = () => {
		let post = document.querySelector(".decorate-links")
		if(!post) return
		let links = [...post.querySelectorAll("a")]
		// apply classes and attributes to all comment links
		links.forEach(link => {
			link.classList.add('post-link')
			link.setAttribute('target', '_blank')
		})
	}

	return {
		init: function() {
			linkDecorator()
		}
	}
}()

document.addEventListener('DOMContentLoaded', function () {
	KDGlobal.init()
})