//websocket handler

var wsUri = "ws://" + window.location.hostname + ":4201/";
var URL;
var myip;
var arrayLabels;
var arrayFields;
var arrayStyles;


function init()
{
	divid = document.getElementById("MC");
	testWebSocket();
}


function testWebSocket()
{
	websocket = new WebSocket(wsUri);
	websocket.onopen = function(evt) { onOpen(evt) };
	websocket.onclose = function(evt) { onClose(evt) };
	websocket.onerror = function(evt) { onError(evt) };
	websocket.onmessage = function(evt) { onMessage(evt) };

}
function onOpen(evt)
{
	myip = document.getElementById("IP").value;
	doSend("checkclient=" + myip);
	createTable("advanced");
	createRow("advanced","advanced-table","")
	createSeperator("advanced","green");
	createTable("submenu");
	createRow("submenu","submenu-table","")
	doSend("advancedbuttons");
}

function onClose(evt)
{
	websocket.close();
}

function WebSocketClose() 
{
	websocket.close();
}
function onError(evt)
{

}

function doSend(message)
{
		websocket.send(message);
}

function createTable(thisDIV)
{
	var todiv = document.getElementById(thisDIV);
	var newTable = document.createElement("TABLE");
	var newTB = document.createElement("TBODY");
	newTB.setAttribute("id",thisDIV + "-table");
	newTable.appendChild(newTB);
	newTable.setAttribute("align","center");
	todiv.appendChild(newTable);
}

function createSeperator(thisDIV,thisStyle)
{
	var todiv = document.getElementById(thisDIV);
	var newTable = document.createElement("TABLE");
	var newTB = document.createElement("TBODY");
	newTB.setAttribute("id",thisDIV + "-seperator");
	newTable.appendChild(newTB);
	newTable.setAttribute("align","center");
	newTable.setAttribute("width","100%");
	todiv.appendChild(newTable);
	createRow(thisDIV + "-seperator",thisDIV + "-seperator","");
	var newTD = document.createElement("TD");
	newTD.setAttribute("width","100%");
	newTD.setAttribute("height","3px");
	newTD.setAttribute("class",thisStyle + " build");
	toRow = document.getElementById(thisDIV + "-seperator-row");
	toRow.appendChild(newTD);	
}

function createElement(name,type,value,targetelement,style,context)
{
	//window.alert(name + type + value + targetelement + style);
	var newTD = document.createElement("TD");
	if (type == "PASSWORD") {
		type = "INPUT";
		var secure = "password"
	}else {
		var secure = "text"
	}
	if (type == "HIDDEN") {
		type = "INPUT" ;
		var secure = "hidden"
	}
	switch (type) {
		case "INPUT":
			//window.alert(value)
			var newinput = document.createElement("INPUT");
			newinput.setAttribute("id", name);
			newinput.setAttribute("type",secure);
			newinput.setAttribute("onchange",'doTask("' + context + '=Amend,' + name + '")');
			newinput.setAttribute("value", value);
			newinput.innerText = value;
			newinput.setAttribute("class",style);
			newTD.appendChild(newinput);
			break;
			
		case "SELECT":
			var newSelect = document.createElement("SELECT");
			var theseDetails=value.split(":");
			newSelect.setAttribute("id",name);
			newSelect.setAttribute("onchange",'doTask("' + context + '=Amend,' + name + '")');
			options = theseDetails[1].split(" ");
//			for (var option of options) {
			options.forEach(function(option) {
				var newOPT = document.createElement("OPTION");
				newOPT.value = option;
				newOPT.innerHTML = option;
				if (option == theseDetails[0]) {
					newOPT.selected=true;
				}
				newSelect.appendChild(newOPT);
			});
			newTD.appendChild(newSelect);
			break;
		case "BUTTON":
			var detail = name.split("-");
			action = context + "=" + value + "," + detail[0].toLowerCase();
			var newbtn = document.createElement("BUTTON");
			newbtn.setAttribute("id", value);
			newbtn.innerHTML = value;
			newbtn.innerText = value;
			newbtn.setAttribute("onclick", 'doTask' + '("' + action + '")');
			newbtn.setAttribute("class", "button " + style);
			newTD.appendChild(newbtn);
			//
			break;
		case "LINE":
			var newHR = document.createElement("HR");
			newTD.appendChild(newHR);
			break;
		default:
			newTD.innerHTML = value;
			newTD.setAttribute("class",style);
			newTD.setAttribute("id",name);
		}
	document.getElementById(targetelement).appendChild(newTD);
}

function elementCount()
{
	GetHeaders = document.getElementById("detail0-row").children;
	//TheseElements = document.getElementById("detail" + thisRow + "-row").children; 
	actualCount=0;
	headerCount = GetHeaders.length;
	for (var i = 0; i < headerCount; i++) {
		if (GetHeaders[i].innerText != "") {
			actualCount++;
		}
	}
	return actualCount;
}


function doTask(detail)
{
	commandString = detail.split("=");
	command = commandString[1].split(",");
	item = commandString[0];
	action = command[0];
	thisRef = command[1].split(/([0-9]+)$/);
	thisRow = thisRef[1];
	GetHeaders = document.getElementById("detail0-row").children;
	TheseElements = document.getElementById("detail" + thisRow + "-row").children;
	headerCount = GetHeaders.length;
	actualCount = elementCount();

	//window.alert(actualCount)
	if (TheseElements[actualCount] != null) {
		buttonCaption=(TheseElements[actualCount].innerText);
	} else {
		buttonCaption="";	
	}
	//window.alert(buttonCaption+","+action)
	sendData = "";
	dataFieldCount = 0;
	dataCount = 0;
	for (var i = 0; i < actualCount; i++) {
		newData = "";
		if (TheseElements[i].innerText == "") {
			newData = TheseElements[i].children[0].value;
		}else {
			newData = TheseElements[i].innerText
		}
		dataFieldCount++;
		if (newData != "") {
			dataCount++;
		}
		if (sendData == "") {
			sendData = newData;
		}else {
			sendData = sendData + "," + newData;
		}
	}
	//window.alert(action);
	switch(action) {
	 	case "Amend":
			if (buttonCaption == "Add" || buttonCaption == "New") {
				if (dataCount == dataFieldCount) {
					doSend("SysReq=" + action + "," + item + "," + thisRow + ":" + sendData);
				}else {
					//window.alert("All fields require data:" + dataCount);
				}	
			}
			break;
		case "Remove":
			doSend("SysReq=" + action + "," + item + "," + thisRow + ":" + sendData);
		}
	
}


function createButton(name,displaytext,elem,script,action,thisclass) 
{
	buttonID = name.toLowerCase();
	var newbtn = document.createElement("BUTTON");
	newbtn.setAttribute("id", buttonID + '-button');
	newbtn.innerHTML = displaytext;
	newbtn.innerText = displaytext;
	newbtn.setAttribute("onclick", script + '("' + action + '")');
	newbtn.setAttribute("class", thisclass);
	var newTD = document.createElement("TD");
	newTD.appendChild(newbtn)
	document.getElementById(elem).appendChild(newTD);
}

function createLabel(thisText,element,style)
{
	var toElem = document.getElementById(element);
	var newTD=document.createElement("TD");	
	newTD.innerHTML = thisText;
	newTD.setAttribute("class",style);
	toElem.appendChild(newTD);
}

function createRow(name,element,lastelement)
{
	var toElem = document.getElementById(element);
	var newTR = document.createElement("TR");
	newTR.setAttribute("id",name + "-row");
	//window.alert(lastelement);
	if (lastelement == "") {
		toElem.appendChild(newTR);
	}else {
		var lastElem = document.getElementById(lastelement);
		toElem.insertBefore(newTR,lastElem);
	}
}
function declineHost(myip)
{
	doSend("rejectclient=" + myip);
}

function acceptHost(myip)                                                      
{                                                                               
	window.location="/cgi-bin/add-host.cgi"
}  

function removeElement(name)
{
	document.getElementById(name).innerHTML="";
}

function highlightButton(name,rowName)
{
	//window.alert(name + rowName);
	var menuButtons = document.getElementById(rowName).children; 
	for (var i = 0; i < menuButtons.length; i++)
	{
		var thisButton= menuButtons[i].children;
		thisButton[0].setAttribute("class", "navsmall button yellow");
	}
	document.getElementById(name.toLowerCase() + "-button").setAttribute("class", "navsmall button green lighttext");
}

function doConsole()
{
	window.open("./webconsole.cgi","_self");
}

function doSHUTDOWN()
{
	doSend("shutdown")
}

function doRestart()
{
	doSend("restart")
}

function onMessage(evt)
{
	var thismessage=evt.data.split(",")
//window.alert(thismessage);
	var category=thismessage[0];
	if (thismessage[2] == "CONSOLE") {
		doConsole(thismessage);
	}else {
		switch (category) {
			case "ADVMENU": 
				//window.alert("Message: " + evt.data);
				createButton(thismessage[2],thismessage[2],"advanced-row","doSend","submenu=" + thismessage[2],"navsmall button yellow");
				break;
			case "SUBMENU":
				//window.alert("Message: " + evt.data);
				var context=thismessage[1];
				switch (context) {
				case "RELOAD":
					document.getElementById("submenu-row").innerHTML = "";
					break;
				case "END":
					if (document.getElementById("submenu-seperator-row") == null) {
						createSeperator("submenu","green");
					}
					break;
				default:
					//window.alert(thismessage);
					highlightButton(thismessage[1],"advanced-row");
					if (document.getElementById("detail-table") != null) {
						document.getElementById("detail-table").innerHTML = "";
					}
					createButton(thismessage[2],thismessage[2],"submenu-row","doSend","getDetail=" + thismessage[2],thismessage[3]); 
				}
				break;
			case "DETAIL":
				var subcontext=thismessage[2];
				switch (subcontext) {
					case "REFRESH":
						//clear and populate headings. Line contains headings/Button Labels
						arrayLabels = thismessage;
						//clear and populate headings
					break;
					case "FIELDS":
						//create field array.  Line contains element types.
						arrayFields = thismessage;
						break;
					case "STYLES":
						//create style array.  Line contains styles.
						//Create first line based on Labels, Fields and Styles
						highlightButton(thismessage[1],"submenu-row");
						arrayStyles = thismessage;
						//window.alert(arrayLabels + " - " + arrayFields + " - " + arrayStyles);
						if (document.getElementById("detail-table") != null) {
							document.getElementById("detail-table").innerHTML = "";
						}else {
							createTable("detail");
						}								
						createRow("detail0","detail-table","")
						for (var i = 3; i < arrayLabels.length ; i++) {																	
							if (arrayFields[i] != "BUTTON") {
								createElement("detail0-" + arrayLabels[i],"TD",arrayLabels[i],"detail0-row","label yellow","")
							}else {
								createElement("detail0-" + arrayLabels[i],"TD","","detail0-row","","")
							}
						}
						break;
					case "LINE":
						//window.alert("yep");
						createRow("detail" + thismessage[3],"detail-table","");
						var countHeaders = elementCount();
						for (var i = 0; i < countHeaders; i++) {
							//window.alert("detail" + thismessage[3] + "-row");
							createElement("","LINE","","detail" + thismessage[3] + "-row","","");
						}
						break;

					default:
						//add data row
						//Message receved format: DETAIL,menu context (zfs,VPN,etc.),row counter,info......
						createRow("detail" + thismessage[2],"detail-table","")
						//add data elements
						for (var i = 3; i < thismessage.length ; i++) {
							//PLACEHOLDER
							createElement(arrayLabels[i] + thismessage[2],arrayFields[i],thismessage[i],"detail" + thismessage[2] + "-row",arrayStyles[i],thismessage[1]);
						}
						//add button elements
						for (var i = 3; i < arrayLabels.length ; i++) {
							if (arrayFields[i] == "BUTTON") {
								if (arrayLabels[i].search(":") > 0) {
									var buttonLabels = arrayLabels[i].split(":");
									var buttonStyles =  arrayStyles[i].split(":");
									//window.alert(thismessage);
									if (thismessage[3] == ""){
										buttonLabel = buttonLabels[1];
										buttonStyle = buttonStyles[1];
									}else {
										buttonLabel = buttonLabels[0];
										buttonStyle = buttonStyles[0];
									}
								}else {
									buttonLabel = arrayLabels[i];
									buttonStyle = arrayStyles[i];
								}
								if (buttonLabel == "") {
									createElement("","TD","","detail" + thismessage[2] + "-row","");
								}else {
									createElement(thismessage[0] + thismessage[2] + "-" + arrayLabels[i],arrayFields[i],buttonLabel,"detail" + thismessage[2] + "-row",buttonStyle,thismessage[1]);
								}
							}
						}
					break;
				}
				break;
			case "CONTAINERDETAIL":
				updateButtonRow(thismessage);
				break;
			
			default:
				//writeToStatus("Message: " + evt.data)
		}
	}
}

window.addEventListener("load", init, false);

