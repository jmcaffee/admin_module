////////////////////////////////////////////////////////////////////////////////////////////////////
//	Issue # : 9464																									
//	Date    : 13 Dec 2006																						
//	Purpose	: To implement search functionality to the decision process pages					
//  Modification History:																							
////////////////////////////////////////////////////////////////////////////////////////////////////

//Variable to store the clone of list box options
var oSearchParams;

//Creates search param object and assigns the values
function CreateSearchParams(CtrlSearchItem,CtrlSearchText,CtrlToSearch,SearchAll)
{

	oSearchParams = new SearchParams();
	oSearchParams.CtrlSearchItem = document.getElementById(CtrlSearchItem);
	oSearchParams.CtrlSearchText = CtrlSearchText;
	oSearchParams.CtrlToSearch = CtrlToSearch;
	if (document.getElementById(CtrlSearchText)!=null)
	{
		document.getElementById(CtrlSearchText).onkeydown = HandleKeyPress;
		if(document.getElementById(CtrlSearchText).value != "")
			Search();
			if (SearchAll=="true")
			{
			  document.getElementById(CtrlSearchItem).selectedIndex=0;
			}
			}		
}

// Search params object
function SearchParams()
{
	this.CtrlSearchItem;
	this.CtrlSearchText;
	this.CtrlToSearch;
	this.SearchValues;
}

function Search()
{
	
	//SearchParams must be created before start searching...
	if(oSearchParams == null || typeof(oSearchParams) == "undefined")
		return;

	//SearchParams values are needed to search ...
	if(oSearchParams.CtrlSearchText == null || oSearchParams.CtrlSearchItem == null || oSearchParams.CtrlToSearch == null)
		return;

	var SearchText = document.getElementById(oSearchParams.CtrlSearchText).value.toLowerCase();

	//Search Text cannot be empty..
	if(SearchText == "")
	{
		alert("Enter text to search.");
		document.getElementById(oSearchParams.CtrlSearchText).focus();
		return false;
	}		
	// Forward to search all page if the searchitem type is all otherwise search the ctrl.
	if(oSearchParams.CtrlSearchItem.options[oSearchParams.CtrlSearchItem.selectedIndex].value == "all")
	{		
		var a = oSearchParams.CtrlSearchItem.document.location.pathname.indexOf('/admin/product/');
		if(a>=0)
		{
			SearchAllProducts(SearchText);
		}
		else
		{		
			SearchAll(SearchText);
		}
	}
	else
	{		
		SearchCtrl(SearchText);	
	}
}

// Forward to search all page..
function SearchAll(SearchText)
{
	location.href="searchresults.aspx?searchtext=" + SearchText;
}
function SearchAllProducts(SearchText)
{
	location.href="../decision/searchresults.aspx?searchtext=" + SearchText;
} 
//Search list control in the page..
function SearchCtrl(SearchText)
{
	var icount;
	
	
	if(oSearchParams.SearchValues == null || typeof(oSearchParams.SearchValues) == "undefined")
		oSearchParams.SearchValues = document.getElementById(oSearchParams.CtrlToSearch).parentElement.innerHTML;
	
	if( ClearSearch(false))
	{
		var ddlCtrltoSearch = document.getElementById(oSearchParams.CtrlToSearch);
		
		for(icount=ddlCtrltoSearch.options.length-1;icount>=0;icount--)
		{
			if(ddlCtrltoSearch.options[icount].text.toLowerCase().indexOf(SearchText) == -1)
				ddlCtrltoSearch.options.remove(icount);
		}
	}
	
	if(ddlCtrltoSearch.options.length==0)
	{
		alert("No records found.");
	}
}

//Clear search
function ClearSearch(Reset)
{
	if(Reset)
	{
		document.getElementById(oSearchParams.CtrlSearchText).value = "";
		document.getElementById(oSearchParams.CtrlSearchText).focus();
	}
	
	if(oSearchParams.SearchValues != null && typeof(oSearchParams.SearchValues) != "undefined")
	{
		document.getElementById(oSearchParams.CtrlToSearch).parentElement.innerHTML =oSearchParams.SearchValues;
		return true;
	}
	
	return false;
}

function HandleKeyPress()
{
	if(event.keyCode == 13)
	{
		Search();
		document.getElementById(oSearchParams.CtrlSearchText).focus();
		event.cancelBuble= true;
		event.returnValue = false;
	}
}
