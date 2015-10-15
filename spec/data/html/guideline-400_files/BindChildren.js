/*---------------------------------------------------------
BindChildren.js
This script is used to dynamically show/hide 
elements based on the value of other elements.

--- Usage ---
Include this script on the page containing the controls.
In page onload event, use the following functions:
	
	bindToList(parentID, childID, values, [behavior])
	bindToCheck(parentID, childID, checked, [behavior])
	bindToImage(parentID, childID, showSrc, hideSrc, [behavior])
	bindValueGroup(groupName, childID, groupIDs)
	setFocus(controlID)
	
	parentID: string containing the ID of the element that
		will be the source of change events
	childID: string containing the ID of the element that
		will be affected by the change events
	values: single value or array of values of the source
		element that will trigger a change event
	behavior: (optional) defines what attribute of the child
		element will be changed. one of the following:
			- 'v': visibility	(e.style.visibility = 'visible'/'hidden')
			- 'e': enabled		(e.disabled = false / true)
			- 'd': display		(e.style.display = 'inline'/'none');
			- 'b': background color
			- 'c': css class
			- 's': style (as in, CSS string)
			- 't': text value
			- 'i': include (applies only to options of selects)
			- 'k': checKed (applies only to checkboxes or radio buttons)
			- 'f': focus
		putting a '!' in front of the element reverses
		behavior, e.g. '!d' will show the child if the value
		is *not* selected. 'd' is default behavior.
	checked: like value, but true or false, no array
	showSrc: the path to the image to display initially
	hideSrc: the path to the image to display when the image
		is clicked. switches with showSrc
		
--- Hints ---
* No error will be thrown if the parent element is not found.
	This enables a static onload script block even if the
	controls themselves are rendered conditionaly on the server.
	However, an error will occur if the child is missing.
* To bind multiple controls to a single element, simply call
	the appropriate bind function multiple times.
* The difference between visible and display is that invisible
	elements still occupy the same space, while un-displayed
	elements will cause surrounding objects to shrink/expand
* If something is already defined for the target event (like
	onchange or onclick) then the action will only occur once
		
-- Samples ---
// show span1 only when list1's value = '1'; 
bindToList('list1', 'span1', '1');

// show span1 only when list1's value = '1' or '3' or '5'; 
bindToList('list1', 'span1', Array('1', '3', '5'));

// enable tbl1 only when chk1 is checked
bindToCheck('chk1', 'tbl1', true, '!e');	

// same as previous example, different approach
bindToCheck('chk1', 'tbl1', false, 'e');	
---------------------------------------------------------*/

// Code executed every time -------------------------------

var boundChildren = new Array();
var boundGroups = new Array();

// functions to extend object functionality
function array_exists(val) {
	var bFound = false;
	for (var i = 0; i < this.length; i++) {
		if (this[i] == val) {
			bFound = true;
			break;
		}
	}
	return bFound;
}

function array_add(val) {
	this[this.length] = val;
}

Array.prototype.exists = array_exists;
Array.prototype.add = array_add;

function string_exists(val) {
	return (this == val);
}

function string_toNumber() {
	return this.replace(/[^\d\.]/g, '') * 1;
}

String.prototype.exists = string_exists;
String.prototype.toNumber = string_toNumber;


// functions begin here -----------------------------------
function changeElement(targetE, value, behavior) {
/* --------------------------------------------------------
Changes an attribute of the specified element
Gets called by the change/click events of bound elements
If value = true, then show or enable. 
-------------------------------------------------------- */
	var args;
	if (targetE == null) {
		alert('target missing! check setup code');
		return;
	}
	if (behavior == null) behavior = 'd';	// default
	if (behavior.substr(0, 1) == '!') {
		value = !value;
		behavior = behavior.substr(1);
	}
	if (behavior.indexOf('|') > 0) args = behavior.split('|');
	
	switch(behavior.substr(0, 1)) {
		case 'v':			// visible
			targetE.style.visibility = (value ? 'visible' : 'hidden' );
			enableValidators(targetE, value);
			break;
		case 'e':			// enabled
			enableElement(targetE, value);
			enableValidators(targetE, value);
			break;
		case 'd' :			// display
			targetE.style.display = (value ? 'inline' : 'none');
			enableValidators(targetE, value);
			var jlblSal;
			jlblSal = document.getElementById('lblSal')
			if (jlblSal != null)
			{
				targetE = jlblSal;
				targetE.style.display = (value ? 'inline' : 'none');
				enableValidators(targetE, value);
			}
			var jtxtSal;
			jtxtSal = document.getElementById('txtSal')
			if (jtxtSal != null)
			{
				targetE = jtxtSal;
				targetE.style.display = (value ? 'inline' : 'none');
				enableValidators(targetE, value);
			}
			break;
		case 'b' :			// background color
			targetE.style.backgroundColor = (value ? args[1] : args[2]);
			break;
		case 'c' :			// css class name
			targetE.className = (value ? args[1] : args[2]);
			break;
		case 's' :			// style
			targetE.style.cssText = (value ? args[1] : args[2]);
			break;
		case 't' :			// text value
			var t = (value ? args[1] : args[2]);
			if (typeof(t) != 'undefined' && t != 'IGNORE') targetE.value = t;
			break;
		case 'i':			// include (for options of selects only)
			moveOption(targetE, args[1], value);
			break;
		case 'k':			// checKed (checkboxes and radio buttons only)
			var x = (value ? args[1] : args[2]);
			if (typeof(x) != 'undefined') {
				switch (x.toLowerCase()) {
					case 'on':
					case 'check':
					case 'true':
					case '1':
						targetE.checked = true;
						break;
					case 'off':
					case 'uncheck':
					case 'false':
					case '0':
						targetE.checked = false;
						break;
				}
			}
			break;
		case 'f':			// focus, only if true
			if (value == true) targetE.focus();
			break;
	}
}

function enableElement(parentE, value) {
// disables object and all child nodes of the specified object
	parentE.disabled = !value;
	if (parentE.hasChildNodes()) {
		var inputs = parentE.getElementsByTagName('INPUT');
		for (var i = 0; i < inputs.length; i++) {
			inputs[i].onfocus = (value ? null : inputs[i].blur);
			inputs[i].disabled = !value;
		}
		var selects = parentE.getElementsByTagName('SELECT');
		for (var i = 0; i < selects.length; i++) {
			selects[i].onfocus = (value ? null : selects[i].blur);
			selects[i].disabled = !value;
		}
	}
}

function enableValidators(parentE, value) {
// enables/disables all validator controls (spans) in the parent control
	if (parentE.tagName == 'SPAN') parentE.enabled = value;
	if (parentE.hasChildNodes()) {
		var spans = parentE.getElementsByTagName('SPAN');
		for (var i = 0; i < spans.length; i++) {
			spans[i].enabled = value;
		}
	}
}

function moveOption(selectE, value, isIncluded) {
// move an option to/from parent.options and .options2
	var index = null;
	
	// find index in current collection
	for (var i = 0; i < selectE.options.length; i++) {
		if (selectE.options[i].value == value) {
			index = i;
			break;
		}
	}
	if (isIncluded) {
		// add to options
		if (index == null && selectE.options2 != null) {
			// find option text in hidden collection
			if (selectE.options2[value] != null) {
				var newOption = new Option(selectE.options2[value], value, false, false);
				selectE.options[selectE.options.length] = newOption;
			}
		}
	} else {
		// remove from options
		if (index != null) {
			if (selectE.options2 == null) selectE.options2 = new Array();
			selectE.options2[value] = selectE.options[index].text;
			selectE.options.remove(index);
		} else {
			// alert('could not find option!');
		}
	}
}

function bindToList(parentID, childID, values, behavior) {
// bind the visiblity of a child control to a list control
	boundChildren.add(bindToList.arguments);
	parentE = document.getElementById(parentID);
	if (parentE != null) {
		// preserve prior event
		attachEvent(parentE, boundList_OnChange, 'change');
		if (behavior == 'i') parentE.options2 = new Array();
		if (behavior != 't') boundList_OnChange(parentE);
	}
}

function bindToCheck(parentID, childID, checked, behavior) {
// bind the visiblity of a child control to a checkbox or radio control
	boundChildren.add(bindToCheck.arguments);
	parentE = document.getElementById(parentID);
	if (parentE != null) {
		attachEvent(parentE, boundCheck_OnClick, 'click');
		boundCheck_OnClick(parentE);
	}
}

function bindToImage(parentID, childID, showSrc, hideSrc, behavior) {
// call this to bind the visiblity of a child control to an image that toggles
	boundChildren.add(bindToImage.arguments);
	parentE = document.getElementById(parentID);
	if (parentE != null) {
		parentE.style.cursor = 'hand';
		attachEvent(parentE, boundImage_OnClick, 'click');
		boundImage_OnClick(parentE);
	}
}

function bindValueGroup(groupName, childID, sourceIDs) {
//  bind the sum of all the values in the group array to the value of a control
	var childE = document.getElementById(childID);
	var sourceEs = new Array();
	for (var i = 0; i < sourceIDs.length; i++) {
		sourceE = document.getElementById(sourceIDs[i]);
		if (sourceE != null ) {
			sourceEs.add(sourceE);
			boundChildren.add(Array(sourceIDs[i], groupName));
			attachEvent(sourceE, boundGroup_OnBlur, 'change');			
		}
	}

	boundGroups[groupName] = new Array(childE, sourceEs);
	boundGroup_Refresh(groupName);
}

function boundGroup_OnBlur(srcE) {
// change event of bound group members; find the group and update it
	var item;
	if (srcE == null) srcE = window.event.srcElement;
	for (var i = 0; i < boundChildren.length; i++) {
		item = boundChildren[i];
		if (item != null) {
			if (srcE.id == item[0]) {
				boundGroup_Refresh(item[1]);
				return;
			}
		}
	}	
}

function boundGroup_Refresh(groupName) {
// update all items in a group
	var group = boundGroups[groupName];
	var childE = group[0];
	var sourceEs = group[1];
	var total = 0, val = 0;
	
	for (var i = 0; i < sourceEs.length; i++) {
		val = sourceEs[i].value.replace(/[^\d\.]/g, '') * 1;
		total += val;
	}
	// format to currency. todo: detect if it is available or not...
	var num = new NumberFormat(total);
	num.setCurrency(true);
	childE.innerText = num.toFormatted();
}

function boundList_OnChange(srcE) {
// change event of bound list objects (select) 
	var item;
	if (srcE == null) srcE = window.event.srcElement;
	for (var i = 0; i < boundChildren.length; i++) {
		item = boundChildren[i];
		if (item != null) {
			if (srcE.id == item[0]) {
				childE = document.getElementById(item[1]);
				//childE.style.display = (item[2].exists(srcE.value)) ? '' : 'none';
				if (childE != null) {
				   changeElement(childE, item[2].exists(srcE.value), item[3]);
				}
			}
		}
	}
}

function boundCheck_OnClick(srcE) {
// change event of bound check elements (input type=checkbox)
	var item;
	if (srcE == null) srcE = window.event.srcElement;
	for (var i = 0; i < boundChildren.length; i++) {
		item = boundChildren[i];
		if (item != null) {
			if (srcE.id == item[0]) {
				childE = document.getElementById(item[1]);
				//childE.style.display = (item[2] == srcE.checked) ? '' : 'none';
				if (childE != null) {
				   changeElement(childE, item[2] == srcE.checked, item[3]);
				}
			}
		}
	}
}

function boundImage_OnClick(srcE) {
// change event of bound image elements
	var item, isReverse = false;
	if (srcE == null) srcE = window.event.srcElement;
	for (var i = 0; i < boundChildren.length; i++) {
		item = boundChildren[i];
		if (item != null) {
			if (srcE.id == item[0]) {
				var childE = document.getElementById(item[1]);
				if (item[4] != null) isReverse = (item[4].substr(0, 1) == '!');
				
				if (srcE.src == item[2]) {
					srcE.title = 'Click to ' + (isReverse ? 'collapse' : 'expand');
					srcE.src = item[3];
					item[3] = srcE.src;
					changeElement(childE, false, item[4]);
				} else {
					srcE.title = 'Click to ' + (isReverse ? 'expand' : 'collapse');
					srcE.src = item[2];
					item[2] = srcE.src;
					changeElement(childE, true, item[4]);
				}
			}
		}
	}
}

// attach a new change event to an element, return the element
function attachEvent(element, newEvent, eventType) {
	if (typeof(eventType) != 'string') eventType = 'change'; else eventType = eventType.toLowerCase();
	if (typeof(element) == 'string') element = document.getElementById(element);
	if (element == null) return;
	if (typeof(element.events) != 'object') element.events = new Array();
	
	// first time registering
	if (typeof(element.events[eventType]) != 'object') {
		element.events[eventType] = new Array();
		if (typeof(element['on' + eventType]) == 'function') element.events[eventType][0] = element['on' + eventType];
		element['on' + eventType] = doEvent;
	}
	var functions = element.events[eventType];
	functions[functions.length] = newEvent;
	
	return element;
}

// this event replaces everything in the 'onclick', 'onchange' etc. events
function doEvent(element, eventType) {
	if (element == null) element = window.event.srcElement;
	if (eventType == null) eventType = window.event.type;
	
	if (typeof(element.events) == 'undefined') return;
	var functions = element.events[eventType.toLowerCase()];
	if (typeof(functions) != 'object') return;
	
	for (var i = 0; i < functions.length; i++) {
		var f = functions[i];
		if (typeof(f) == 'function') {
			f(element);
		} else {
			eval(f);
		}
	}
}

function setFocus(controlID) {
// puts focus on the field specified, if possible
	var e = document.getElementById(controlID);
	if (e != null) {
		if ((!e.disabled) && (e.visible)) e.focus();
	}
}

function toggleSection(span, divID) {
// old function to use plus and minus to show and hide a div
	var div = document.getElementById(divID);
	if (span.innerText == '-') {
		span.innerText = '+';
		div.style.display = 'none';
	} else {
		span.innerText = '-';
		div.style.display = '';
	}
}

function fieldFormat(source, format, arg1, arg2) {
/* --------------------------------------------------------
Formats the contents of a field, usually attached to onblur
source: the element, usually 'this'
format: format specifier; n[umeric], t[elephone], c[urrency],
		s[sn]
arg[x]: format-specific arguments, see below
ex. <input type="text" onblur="fieldFormat(this, 'n', 1);">
-------------------------------------------------------- */
	if (source.value.length > 0) {
		if (format == null) format = 'n';
		var type = format.substr(0,1).toLowerCase();
		switch(type) {
			case 'c':		// currency
				var num = new NumberFormat(source.value);
				num.setCurrency(false);
				num.setPlaces(2);
				source.value = num.toFormatted();
				break;
			case 'n':		// general number; arg1 = places
				var num = new NumberFormat(source.value);
				num.setCurrency(false);
				num.setPlaces((arg1 == null ? 2 : arg1));
				source.value = num.toFormatted();
				break;
			case 't':		// telephone
				var num = source.value.replace(/[^\d]/g, '').substr(0, 10);
				if (num.length > 0) {
					source.value = '(' + num.substr(0,3) + ') ' + num.substr(3,3) + '-' + num.substr(6,4);
				} else {
					source.value = '';
				}
				break;
			case 's':		// ssn
				var num = source.value.replace(/[^\d]/g, '').substr(0, 9);
				if (num.length > 0) {
					source.value = num.substr(0,3) + '-' + num.substr(3,2) + '-' + num.substr(5,4);
				} else {
					source.value = '';
				}				
				break;
		}
	}
	
	if (source.onchange != null) source.onchange();
}

function fieldLimit(source, limit, max, limiter) {
/* --------------------------------------------------------
Limits the maxlength of a field based on a character, attach
	to onkeyup. 
source:		the element, usually 'this'
limit:		number of characters after limiter to allow
max:		absolute max length
limiter:	character to trigger limit, defaults to '.'
ex. <input type="text" onkeyup="fieldLimit(this, 3);">
-------------------------------------------------------- */
	if (limiter == null) limiter = '.';
	if (max == null) max = 999;
	var pos = source.value.indexOf(limiter);
	if (pos > -1 && caretPos(source) > pos) {
		var len = (pos + limit + limiter.length);
		source.maxLength = len;
		if (source.value.length > len) source.value = source.value.substr(0, len);
	} else {
		source.maxLength = max - limit;
	}	
}

function caretPos(textEl) {
// returns the position of the caret within a text box
	var i=textEl.value.length+1;
	if (textEl.createTextRange) {
		theCaret = document.selection.createRange().duplicate();
		while (theCaret.parentElement()==textEl && theCaret.move("character",1)==1) --i;
		return i-1;
	}
	else return -1;
}

function blurPhone(e) {
// backwards-compatible
	fieldFormat(e, 'telephone');
}

// mredkj.com
function NumberFormat(num)
{
this.COMMA = ',';
this.PERIOD = '.';
this.DASH = '-'; 
this.LEFT_PAREN = '('; 
this.RIGHT_PAREN = ')'; 
this.LEFT_OUTSIDE = 0; 
this.LEFT_INSIDE = 1;  
this.RIGHT_INSIDE = 2;  
this.RIGHT_OUTSIDE = 3;  
this.LEFT_DASH = 0; 
this.RIGHT_DASH = 1; 
this.PARENTHESIS = 2; 
this.num;
this.numOriginal;
this.hasSeparators = false;  
this.separatorValue;  
this.inputDecimalValue; 
this.decimalValue;  
this.negativeFormat; 
this.negativeRed; 
this.hasCurrency;  
this.currencyPosition;  
this.currencyValue;  
this.places;
this.setNumber = setNumberNF;
this.toUnformatted = toUnformattedNF;
this.setInputDecimal = setInputDecimalNF; 
this.setSeparators = setSeparatorsNF; 
this.setCommas = setCommasNF;
this.setNegativeFormat = setNegativeFormatNF; 
this.setNegativeRed = setNegativeRedNF; 
this.setCurrency = setCurrencyNF;
this.setCurrencyPrefix = setCurrencyPrefixNF;
this.setCurrencyValue = setCurrencyValueNF; 
this.setCurrencyPosition = setCurrencyPositionNF; 
this.setPlaces = setPlacesNF;
this.toFormatted = toFormattedNF;
this.toPercentage = toPercentageNF;
this.getOriginal = getOriginalNF;
this.getRounded = getRoundedNF;
this.preserveZeros = preserveZerosNF;
this.justNumber = justNumberNF;
this.setInputDecimal(this.PERIOD); 
this.setNumber(num); 
this.setCommas(true);
this.setNegativeFormat(this.LEFT_DASH); 
this.setNegativeRed(false); 
this.setCurrency(true);
this.setCurrencyPrefix('$');
this.setPlaces(2);
}
function setInputDecimalNF(val)
{
this.inputDecimalValue = val;
}
function setNumberNF(num)
{
this.numOriginal = num;
this.num = this.justNumber(num);
}
function toUnformattedNF()
{
return (this.num);
}
function getOriginalNF()
{
return (this.numOriginal);
}
function setNegativeFormatNF(format)
{
this.negativeFormat = format;
}
function setNegativeRedNF(isRed)
{
this.negativeRed = isRed;
}
function setSeparatorsNF(isC, separator, decimal)
{
this.hasSeparators = isC;
if (separator == null) separator = this.COMMA;
if (decimal == null) decimal = this.PERIOD;
if (separator == decimal)
{
this.decimalValue = (decimal == this.PERIOD) ? this.COMMA : this.PERIOD;
}
else
{
this.decimalValue = decimal;
}
this.separatorValue = separator;
}
function setCommasNF(isC)
{
this.setSeparators(isC, this.COMMA, this.PERIOD);
}
function setCurrencyNF(isC)
{
this.hasCurrency = isC;
}
function setCurrencyValueNF(val)
{
this.currencyValue = val;
}
function setCurrencyPrefixNF(cp)
{
this.setCurrencyValue(cp);
this.setCurrencyPosition(this.LEFT_OUTSIDE);
}
function setCurrencyPositionNF(cp)
{
this.currencyPosition = cp
}
function setPlacesNF(p)
{
this.places = p;
}
function toFormattedNF()
{
var pos;
var nNum = this.num; 
var nStr;            
var splitString = new Array(2);   
nNum = this.getRounded(nNum);
nStr = this.preserveZeros(Math.abs(nNum)); 
if (nStr.indexOf(this.PERIOD) == -1)
{
splitString[0] = nStr;
splitString[1] = '';
}
else
{
splitString = nStr.split(this.PERIOD, 2);
}
if (this.hasSeparators)
{
pos = splitString[0].length;
while (pos > 0)
{
pos -= 3;
if (pos <= 0) break;
splitString[0] = splitString[0].substring(0,pos)
+ this.separatorValue
+ splitString[0].substring(pos, splitString[0].length);
}
}
if (splitString[1].length > 0)
{
nStr = splitString[0] + this.decimalValue + splitString[1];
}
else
{
nStr = splitString[0];
}
var c0 = '';
var n0 = '';
var c1 = '';
var n1 = '';
var n2 = '';
var c2 = '';
var n3 = '';
var c3 = '';
var negSignL = (this.negativeFormat == this.PARENTHESIS) ? this.LEFT_PAREN : this.DASH;
var negSignR = (this.negativeFormat == this.PARENTHESIS) ? this.RIGHT_PAREN : this.DASH;
if (this.currencyPosition == this.LEFT_OUTSIDE)
{
if (nNum < 0)
{
if (this.negativeFormat == this.LEFT_DASH || this.negativeFormat == this.PARENTHESIS) n1 = negSignL;
if (this.negativeFormat == this.RIGHT_DASH || this.negativeFormat == this.PARENTHESIS) n2 = negSignR;
}
if (this.hasCurrency) c0 = this.currencyValue;
}
else if (this.currencyPosition == this.LEFT_INSIDE)
{
if (nNum < 0)
{
if (this.negativeFormat == this.LEFT_DASH || this.negativeFormat == this.PARENTHESIS) n0 = negSignL;
if (this.negativeFormat == this.RIGHT_DASH || this.negativeFormat == this.PARENTHESIS) n3 = negSignR;
}
if (this.hasCurrency) c1 = this.currencyValue;
}
else if (this.currencyPosition == this.RIGHT_INSIDE)
{
if (nNum < 0)
{
if (this.negativeFormat == this.LEFT_DASH || this.negativeFormat == this.PARENTHESIS) n0 = negSignL;
if (this.negativeFormat == this.RIGHT_DASH || this.negativeFormat == this.PARENTHESIS) n3 = negSignR;
}
if (this.hasCurrency) c2 = this.currencyValue;
}
else if (this.currencyPosition == this.RIGHT_OUTSIDE)
{
if (nNum < 0)
{
if (this.negativeFormat == this.LEFT_DASH || this.negativeFormat == this.PARENTHESIS) n1 = negSignL;
if (this.negativeFormat == this.RIGHT_DASH || this.negativeFormat == this.PARENTHESIS) n2 = negSignR;
}
if (this.hasCurrency) c3 = this.currencyValue;
}
nStr = c0 + n0 + c1 + n1 + nStr + n2 + c2 + n3 + c3;
if (this.negativeRed && nNum < 0)
{
nStr = '<font color="red">' + nStr + '</font>';
}
return (nStr);
}
function toPercentageNF()
{
nNum = this.num * 100;
nNum = this.getRounded(nNum);
return nNum + '%';
}
function getRoundedNF(val)
{
var factor;
var i;
factor = 1;
for (i=0; i<this.places; i++)
{	factor *= 10; }
val *= factor;
val = Math.round(val);
val /= factor;
return (val);
}
function preserveZerosNF(val)
{
var i;
val = val + '';
if (this.places <= 0) return val; 
var decimalPos = val.indexOf('.');
if (decimalPos == -1)
{
val += '.';
for (i=0; i<this.places; i++)
{
val += '0';
}
}
else
{
var actualDecimals = (val.length - 1) - decimalPos;
var difference = this.places - actualDecimals;
for (i=0; i<difference; i++)
{
val += '0';
}
}
return val;
}
function justNumberNF(val)
{
val = (val==null) ? 0 : val;
var newVal = val + ""; 
var isPercentage = false;
var isFormattedNeg = false;
if (newVal.indexOf('%') != -1)
{
newVal = newVal.replace(/\%/g, '');
isPercentage = true;
}
if (newVal.indexOf(this.DASH) != -1
|| (newVal.indexOf(this.LEFT_PAREN) != -1 && newVal.indexOf(this.RIGHT_PAREN) != -1))
{
newVal = newVal.replace(/[\-\(\)]/g, '');
isFormattedNeg = true;
}
if (this.inputDecimalValue != this.PERIOD)
{
newVal = newVal.replace(/\./g, '');
}
var itrDecimal;
var tempVal = '';
var foundDecimal = false;
for (itrDecimal=0; itrDecimal<newVal.length; itrDecimal++)
{
if (newVal.charAt(itrDecimal) == this.inputDecimalValue)
{
if (foundDecimal)
{
}
else
{
tempVal = tempVal + this.PERIOD;
foundDecimal = true;
}
}
else
{
tempVal = tempVal + newVal.charAt(itrDecimal);
}
}
newVal = tempVal;
if (isFormattedNeg) newVal = '-' + newVal;
if (isNaN(newVal))
{
newVal = parseFloat(newVal.replace(/[^\d\.\-]/g, ''));
newVal = (isNaN(newVal) ? 0 : newVal); 
}
else if (!isFinite(newVal))
{
newVal = 0;
}
if (isPercentage)
{
newVal = newVal / 100;
}
return newVal;
}
