/*
	Added  for scripts related to Guideline page
*/

// method to move listitems from one list to another
// from Rule/Ruleset List to Guideline list 
function MoveListItems(sourceList,destinationList) {
	var sourceObj,destObj,tempObj;
	var i,j,k;

	sourceObj=document.getElementById(sourceList);
	destObj=document.getElementById(destinationList);
	
	if((sourceObj==null)||(destObj==null))
		return;
	//debugger;
	if(sourceObj.selectedIndex<0)
	{
		alert("Please select an item to add");
		return;
	}
	//listitems count
	i=sourceObj.options.length;
	k=destObj.options.length;
	j=0;
	while(j<i)
	{
		if(sourceObj.options[j].selected)
		{
			tempObj=new Option(sourceObj.options[j].text,sourceObj.options[j].value);
			if(tempObj.value.substring(0,1)==2) //Pricing Block
			{
				tempObj.style.color='red';
			}
			if(tempObj.value.substring(0,1)==3) //Added for PowerLookup Implementation
			{
				tempObj.style.color='Orange';
			}
			destObj.add(tempObj,k);
			sourceObj.remove(j);
			i--;
			k++;
		}
		else
		{
			j++;
		}		
	}
		
}

//From guidelineList to Rule/Ruleset Lists
function RemoveToListItems(sourceList,destinationList1,destinationList2)
{
	var sourceObj,ruleObj,ruleSetObj,tempObj;
	var i,j,k,m;

	sourceObj=document.getElementById(sourceList);
	ruleObj=document.getElementById(destinationList1);
	ruleSetObj=document.getElementById(destinationList2);
	
	if((sourceObj==null)||(ruleObj==null)||(ruleSetObj==null))
		return;
	
	if(sourceObj.selectedIndex<0)
	{
		alert("Please select an item to remove");
		return;
	}
	//listitems count
	i=sourceObj.options.length;
	k=ruleObj.options.length;
	m=ruleSetObj.options.length;
	
	j=0;
	while(j<i)
	{
		if(sourceObj.options[j].selected)
		{
			tempObj=new Option(sourceObj.options[j].text,sourceObj.options[j].value);
			
			if(sourceObj.options[j].value.substring(0,1)==0) //rule
				ruleObj.add(tempObj,k);
			else if(sourceObj.options[j].value.substring(0,1)==1) //ruleset
			{
				ruleSetObj.add(tempObj,m);
			}
			else if(sourceObj.options[j].value.substring(0,1)==3) //'Added for PowerLookup Implementation
			{
				tempObj.style.color='Orange';
				ruleSetObj.add(tempObj,m);
			}

			else if(sourceObj.options[j].value.substring(0,1)==2) //Pricing Block
			{
				tempObj.style.color='red';
				ruleObj.add(tempObj,0);
			}
				
			sourceObj.remove(j);
			i--;
			k++;
		}
		else
		{
			j++;
		}		
	}
		
}


function SetPricingBlockColor()
{
	var gdlObj,ruleObj,ruleSetObj,tempObj;
	var i,j,k,m;

	gdlObj=document.getElementById('lstGuideline');
	ruleObj=document.getElementById('lstRules');
	
	
	if((gdlObj==null)||(ruleObj==null))
		return;
	
	//listitems count
	i=gdlObj.options.length;
	j=0;
	while(j<i)
	{
		if(gdlObj.options[j].value.substring(0,1)==2) //Pricing Block
		{
			gdlObj.options[j].style.color='red';
		}
		j++;
	}
	
	k=ruleObj.options.length;
	j=0;
	while(j<k)
	{
		if(ruleObj.options[j].value.substring(0,1)==2) //Pricing Block
		{
			ruleObj.options[j].style.color='red';
		}
		j++;
	}
	
	
}

//to move rule/ruleset up or down
//updwnFlag - 0 to moveup 1 to movedown
function ChangePos(objList,updwnFlag)
{
	var sourceObj,tempObj;
	var i,j,k,m;
	var selText,selValue,Selected,selColor;
	
	sourceObj=document.getElementById(objList);
	
	
	if(sourceObj==null)
		return;
	
	if(sourceObj.selectedIndex<0)
	{
		alert("Please select an item to Move");
		return;
	}
	//alert(sourceObj.selectedIndex);
	//listitems count
	i=sourceObj.options.length;
		
	j=0;
	if(updwnFlag==0)
	{
		while(j<i)
		{
			
			if(sourceObj.options[j].selected)
			{
				if(j==0) break;
				if(j>0)
				{
					selText=sourceObj.options[j-1].text;	
					selValue=sourceObj.options[j-1].value;
					Selected=sourceObj.options[j-1].selected;
					selColor=sourceObj.options[j-1].style.color;
					
					sourceObj.options[j-1].text=sourceObj.options[j].text;
					sourceObj.options[j-1].value=sourceObj.options[j].value;
					sourceObj.options[j-1].selected=sourceObj.options[j].selected;
					sourceObj.options[j-1].style.color=sourceObj.options[j].style.color;
					
					sourceObj.options[j].text=selText;	
					sourceObj.options[j].value=selValue;
					sourceObj.options[j].selected=Selected;
					sourceObj.options[j].style.color=selColor;
				}
			}
			j++;
		}
	}
	else if(updwnFlag==1)
	{
		j=i-1;
		while(j>=0)
		{
			if(sourceObj.options[j].selected)
			{
				if(j==i-1) break;
				if(j<i)
				{
					selText=sourceObj.options[j+1].text;	
					selValue=sourceObj.options[j+1].value;
					Selected=sourceObj.options[j+1].selected;
					selColor=sourceObj.options[j+1].style.color;
					
					sourceObj.options[j+1].text=sourceObj.options[j].text;
					sourceObj.options[j+1].value=sourceObj.options[j].value;
					sourceObj.options[j+1].selected=sourceObj.options[j].selected;
					sourceObj.options[j+1].style.color=sourceObj.options[j].style.color;
					
					sourceObj.options[j].text=selText;	
					sourceObj.options[j].value=selValue;
					sourceObj.options[j].selected=Selected;
					sourceObj.options[j].style.color=selColor;
				}
			}
			j--;
		}
		
	}
}


function selectAll(isAll)
{
	var lst = document.getElementById("lstGuideline");
	if (lst != null)
	{
		var bln;
		lst.multiple = true;
		
		if (isAll==0)
		{
			bln = false;
		}
		else
		{
			bln = true;
		}
		
		for (var i=0;i<lst.options.length;i++)
		{
			
			lst.options[i].selected = bln;
		}
		return false;
	}
}

function selectAllForSave()
{
	var lstGdl = document.getElementById("lstGuideline");
	if (lstGdl != null)
	{
			
		lstGdl.multiple = true;
		for (var i=0;i<lstGdl.options.length;i++)
		{
			
			lstGdl.options[i].value = lstGdl.options[i].value + "|" +  lstGdl.options[i].text;
			lstGdl.options[i].selected = true;
		}
	}
		return true;
}
//Added for PowerLookup Implementation
//start
function SetColorPowerLookup()
{
	ListColor('lstGuideline'); 
	ListColor('lstRulesets');
}
				    
function ListColor(ListName)
{	    

		var ddlRef = document.getElementById(ListName);
		var i,iLength = ddlRef.options.length-1;
		for(i=0;i<=iLength;i++)
		{
			var toColor=ddlRef.options[i].value.split('|');
			if (Number(toColor[0]) == 3)
				ddlRef.options[i].style.color='orange';
		}
		
}
//end