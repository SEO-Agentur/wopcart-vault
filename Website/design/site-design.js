/* WopCart site design: after the mobile menu overlay closes on a same-page anchor link, scroll to the target.
   Core locks page scrolling while the overlay is open and then returns focus to the menu toggle, which cancels
   the normal jump. So wait until that has happened and jump instantly (also fine for reduced motion). */
document.addEventListener('click', function (event) {
	var link = event.target.closest('.wc-header .wp-block-navigation a[href*="#"]');
	if (!link) {
		return;
	}
	var url = new URL(link.href, window.location.href);
	var target = url.hash && url.pathname === window.location.pathname ? document.getElementById(url.hash.slice(1)) : null;
	if (target) {
		window.setTimeout(function () {
			target.scrollIntoView({ behavior: 'auto' });
		}, 400);
	}
}, true); // Capture phase: the navigation block handles the click before it would bubble up to the document.
