//***list box UI support functions***
function ShowContents(oList)
{
 try{
    var oOption;
    var oOptions = oList.options;
    for(var i=oOptions.length-1;i>=0;i--){
        oOption = oOptions.item(i);
        if(oOption.selected) alert(oOption.text);
	}
}
 catch(e){}
}

function moveAvailToSelect(iMoveSet, oLstAvail, oLstSelect, oHiddenSelected, oHiddenSelectedNames, oHiddenAvailable){
 try{
		var postalCode = document.getElementById('rdStatePostal_0');
		
		if (postalCode=='undefined' || postalCode == null)
		{
			copyItems(oLstAvail,oLstSelect,iMoveSet);
			if (iMoveSet==1)
				removeSelectedItems(oLstAvail);
				
			else
			{
			   
				clearAllItems(oLstAvail);
				if(document.getElementById('lblAvailFullDisplay') != null)
					document.getElementById('lblAvailFullDisplayv').innerText='';
			}
			
			updateContent(oLstSelect, oHiddenSelected, oHiddenSelectedNames);
			//updateContent(oLstAvail, oHiddenAvailable);
		}
		else
		{
			
			if (document.getElementById('rdStatePostal_0').checked == true)
			{
				copyItems(oLstAvail,oLstSelect,iMoveSet);
				if (iMoveSet==1){
					removeSelectedItems(oLstAvail);
				}
				else
					clearAllItems(oLstAvail);
					
				updateContent(oLstSelect, oHiddenSelected, oHiddenSelectedNames);
			}
			
			if (oLstAvail.id == "tsOrgs_lstAvailable") 
			{
				copyItems(oLstAvail,oLstSelect,iMoveSet);
				if (iMoveSet==1){
				removeSelectedItems(oLstAvail);
				}
				else
				clearAllItems(oLstAvail);
				updateContent(oLstSelect, oHiddenSelected, oHiddenSelectedNames); 
			}	

			//updateContent(oLstAvail, oHiddenAvailable);
		}

	}
 catch(e){}
}

function moveSelectToAvail(iMoveSet, oLstAvail, oLstSelect, oHiddenSelected,oHiddenSelectedNames, oHiddenAvailable){
 try{
	copyItems(oLstSelect,oLstAvail,iMoveSet);
	if (iMoveSet==1)
		removeSelectedItems(oLstSelect);
	else
		clearAllItems(oLstSelect);
		
	updateContent(oLstSelect, oHiddenSelected,oHiddenSelectedNames);
	//updateContent(oLstAvail, oHiddenAvailable);
 }
 catch(e){}
}

function updateContent(oLst,oHidden, oHiddenNames){
//asp.net does not know about client side changes to listboxes; 
//therefore have to build a custom change holder
 try{
	var sListIDs = "|";
	var sListNames = "|";
	var oOption;
	//if (document.getElementById(oLst)==null)return;
	var oOptions = oLst.options;
	for(var i=0;i<oOptions.length;i++){
		oOption = oOptions.item(i);
		sListIDs += oOption.value + "|";
		sListNames += oOption.text + "|";
	}
	oHidden.value = sListIDs;
	oHiddenNames.value = sListNames;
	//alert(oHidden.id + ":" + oHidden.value);
 }
 catch(e){alert(e.description);}
}

function updateContent(oLst,oHidden){
//asp.net does not know about client side changes to listboxes; 
//therefore have to build a custom change holder
 try{
	var sListIDs = "|";
	var oOption;
	//if (document.getElementById(oLst)==null)return;
	var oOptions = oLst.options;
	for(var i=0;i<oOptions.length;i++){
		oOption = oOptions.item(i);
		sListIDs += oOption.value + "|";
	}
	oHidden.value = sListIDs;
	//alert(oHidden.id + ":" + oHidden.value);
 }
 catch(e){alert(e.description);}
}

function copyItems(oLstSource, oLstTarget, iSelectSet, bAllowDups){
//iSelectSet: 1=Selected; 2=All
 try{
    var oOption;
    var oOptions = oLstSource.options;
       for(var i=0;i<oOptions.length;i++){
        var bCopy=false;
        oOption = oOptions.item(i);
        if (iSelectSet==2 || (iSelectSet=1 && oOption.selected))
            if(!bAllowDups){
                if(!itemInList(oLstTarget, oOption.text)) // dup?
                    bCopy=true;
            }
            else
                bCopy=true;

        if (bCopy)
            listAddItem(oLstTarget, oOption.id, oOption.name, oOption.value,oOption.text);
    }

 }
 catch(e){
	
	return false;
 }
}

function itemInList(oLst, value1, bCaseInsensitive){
 try{
    //var oOption;
    var oOptions = oLst.options;
    var sVal = value1;
    var sListItemText;
    if(bCaseInsensitive) sVal=sVal.toUpperCase();
    for(var i=0;i<oOptions.length;i++){
        sListItemText = oOptions.item(i).text;
        if(bCaseInsensitive) sListItemText=sListItemText.toUpperCase();
        if(sListItemText==sVal) return true;
    }
    return false;
 }
 catch(e){
	return false;
 }
}



function listAddItem(oLst, id1, name1, value1, text1){
 try{

    var oOption = document.createElement("OPTION");
	oOption.id = id1;
    oOption.name = name1;
	oOption.value = value1;
    oOption.text = text1;
    oLst.add(oOption);

 }
 catch(e){
	return false;
 }
}

function removeSelectedItems(oLst){
 try{
    var oOption;
    var oOptions = oLst.options;
        
   	/*if(oLst.selectedIndex<0)
	{
		alert("Please select an item to Move");
		return;
	}*/
    for(var i=oOptions.length-1;i>=0;i--){
        oOption = oOptions.item(i);
        if(oOption.selected) oOption.removeNode();
    }

 }
 catch(e){
	return false;
 }
}



function clearAllItems(oLst){
 try{
    var oOption;
    var oOptions = oLst.options;
    for(var i=oOptions.length-1;i>=0;i--){
        oOption = oOptions.item(i);
        oOption.removeNode();
    }

 }
 catch(e){
	return false;
 }
}

function shiftSelectedItems(oLst, iDir){
//iDir: 1=up; 2=down
 try{
    var oOption;
    var oOptionSwitch;
    var oOptions = oLst.options;
   

 	if(oLst.selectedIndex<0)
	{
		alert("Please select an item to Move");
		return;
	}

    if(iDir==1){ //up
        for(var i=0;i<oOptions.length;i++){
            oOption = oOptions.item(i);
            if(oOption.selected && i>0){ //up
                oOptionSwitch = oOptions.item(i-1);
                oLst.insertBefore(oOption,oOptionSwitch);
            }
        }
     }
     if (iDir==2){ //down
            for(var i=oOptions.length-1;i>=0;i--){
                oOption = oOptions.item(i);
                if(oOption.selected && i<oOptions.length-1){
                    oOptionSwitch = oOptions.item(i+1);
                    oLst.insertBefore(oOptionSwitch,oOption);
                }
            }
     }
 }
 catch(e){
	return false;
 }
oLst.focus(); 
}

function showOnClick(lblID,ddlRef)
{
	document.getElementById(lblID).innerText = ddlRef.options[ddlRef.selectedIndex].text;
}

function clearText(lblID)
{
	document.getElementById(lblID).innerText ='';
}

// Added for issue #5633
function notSelectedMessg(lblID)
{
if(document.getElementById(lblID).innerText == '')
  {
   alert("Please select an item.");
      return false;
  }
  else
  {
  document.getElementById(lblID).innerText ='';
  }
 
}
//end

function moveIfselected(iMoveSet, isAdd,oLstAvail, oLstSelect, oHiddenSelected, oHiddenSelectedNames, oHiddenAvailable)
{
	if(oLstAvail.selectedIndex<0 && Number(isAdd)==1 ||oLstSelect.selectedIndex<0 && Number(isAdd)==0 )
	{
		alert("Please select an item to Move");
		return;
	}
	if(Number(isAdd)==1)
		moveAvailToSelect(iMoveSet, oLstAvail, oLstSelect, oHiddenSelected, oHiddenSelectedNames, oHiddenAvailable);
	else
		moveSelectToAvail(iMoveSet, oLstAvail, oLstSelect, oHiddenSelected, oHiddenSelectedNames, oHiddenAvailable);
}