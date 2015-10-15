var lastMenu = null;
var ua = navigator.userAgent;
var opera = /opera [56789]|opera\/[56789]/i.test(ua);
var ie = !opera && /MSIE/.test(ua);
var ie50 = ie && /MSIE 5\.[01234]/.test(ua);
var ie6 = ie && /MSIE [6789]/.test(ua);
var ieBox = ie && (document.compatMode == null || document.compatMode != "CSS1Compat");
var moz = !opera && /gecko/i.test(ua);
var nn6 = !opera && /netscape.*6\./i.test(ua);

function showMenu(name, srcE) {
	var menuE = (name == null) ? null : document.getElementById(name);
	if (lastMenu != null) lastMenu.style.display = 'none';
	if (menuE != null) {
		if (srcE != null && menuE.style.right == 0 && menuE.style.left == 0) {
			var left = srcE.offsetLeft;
			if (ie &&  srcE.offsetParent != null) left -= srcE.offsetParent.offsetLeft;
			
			menuE.style.left = left;
			menuE.style.top = 0;
			//alert('left: ' + left + '; parent: ' + srcE.offsetParent.offsetLeft);
		}
		menuE.style.display = 'block';
		lastMenu = menuE;
	}
}

function clearMenus(srcE) {
	if (srcE == window.event.srcElement) {
		if (lastMenu != null) lastMenu.style.display = 'none';
		lastMenu = null;
		return false;
	}
}

function openHelp(url) {
	var w = 480, h = 340;
	if (document.all || document.layers) {
		w = screen.availWidth;
		h = screen.availHeight;
	}

	var popW = 500, popH = 500;
	var leftPos = (w-popW)/2, topPos = (h-popH)/2;

	helpWin = window.open(url,'cq_help','width=' + popW + ',height=' + popH + ',top=' + topPos + ',left=' + leftPos + ',toolbar=no,location=no,directories=no,status=no,menubar=no');
	helpWin.focus();
}	
