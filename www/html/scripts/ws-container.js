//websocket handler

var wsUri = "ws://" + window.location.hostname + ":4201/";
var output;
var online  = true;
var thismode = "console";
var thiscontainer = "";
var thisaction = "";
var previouscontainer = "";
var poll = false;
var jobname = "";
var thisip = "";
var flashTimer;
var polltimer;
var thiscol = false;
var cachewebopen = false;
var consoleopen = false;
var cacheroutineopen = false;
var cacherunrt = false;
var jobaction = "";
var sendMessage = "";
var resent = false;
var existingconsole = "";
var context="";

function init()
{
	output = document.getElementById("outputtd");
	document.getElementById("outputtd").style.color = '#00CC00';
	testWebSocket();
}

// SEND COMMAND //
//
// A button is scripted to run controlContainer("<command>=<container name>")
// This function redirects if appropriate
// 

function controlContainer(dothis)
{
	sendMessage=dothis;
	previouscontainer = thiscontainer;
	thisaction = dothis.substring(0, dothis.indexOf('='));
	thiscontainer = dothis.substring(dothis.indexOf('=') + 1, dothis.length);
	writeToStatus(thisaction + ' '  + thiscontainer + ' requested.');
	switch (thisaction) {
		case "cachertn":
			importcacheroutine(thiscontainer);
			break;
		case "cachecon":
			cacheweb(thiscontainer);
			break;
		case "cachesmp":
			var URL = "http://" + thiscontainer + ":57772/csp/sys/UtilHome.csp"
			window.open(URL,"_blank");
			break;
		case "commit":
			displayCommitDialogue(thiscontainer);
			break;
		case "stop":
			if (document.getElementById('con' + thiscontainer) != null) {
				removeElement('con' + thiscontainer);
				consoleopen=false;
			}
			if (document.getElementById('ccon' + thiscontainer) != null) {
				removeElement('ccon' + thiscontainer);
			}
		default:
			//disableButtons(true);
			doSend(dothis);
	}
}

// OPERATIONAL ENVIRONMENT //
//
// Websocker message is formatted as WHAT_INFORMATION_RELATES_TO,detail
//
// 1.  createButtonRow		Create button row
// 2.  updateButtonRow		Update buttons for a button row
// 3.  updateDetails		Job queue output requested every 2s.  
//				Depending on job status, button will deactivate, flash or disappear
// 4.  createIframe		Used to create iframes for console and, if HS, Cache console
// 5.  cacheweb 		Displays cache console
// 6.  displayConsole		Displays linux terminal
// 7.  displayCommitDialogue 	Display input box for tagging a commit image
// 8.  removeCommitDialogue	Removes the input box for tagging a commit image
// 9.  commitContainer		Sends a commit job request
// 10. runcacheroutine		Goes to import cache routine page 
// 11. toggleButton		Flashes button by toggling between button[name] and button[name]inv css.
// 12. getSystemStatus		Runs every 2 s to get job queue
// 13. removeElement		Removes an element
// 14.   
//	
// Append to DIV element CONTAINERS 
// container NOCONTAINERS creates "No Containers available"
//

function createButtonRow(containerData)
{
	var containerName = containerData[1];
	if (containerName == "CONTAINER-INFO-REFRESH") {
		document.getElementById("CONTAINERS").innerHTML = "";	
	}else {
		if (containerName == "NOCONTAINERS") {
			writeToStatus("No Containers defined.");
		}else {
			var newTable = document.createElement("TABLE");
			var newRow = document.createElement("TR");
			newTable.setAttribute("align", "left");
			newTable.setAttribute("id", "table-" + containerName);
			newRow.setAttribute("id","buttonbar-" + containerName);
			newTable.appendChild(newRow); 
			document.getElementById("CONTAINERS").appendChild(newTable);
			// add the line for consoles and other input (e.g. commit)
			var newTable = document.createElement("TABLE");
			newTable.setAttribute("id","table-con" + containerName);
			newTable.setAttribute("align","center");
			newTable.setAttribute("width","100%");
			var newRow = document.createElement("TR");
			newRow.setAttribute("id",containerName);
			newTable.appendChild(newRow);
			document.getElementById("CONTAINERS").appendChild(newTable);
			updateButtonRow(containerData);			
		}
	}
}

function updateButtonRow(containerData)
{
	var containerName = containerData[1];
	;
	document.getElementById("buttonbar-" + containerName).innerHTML="";
	var newData = document.createElement("TD");
	newData.setAttribute("id","container-" + containerName);
	if (containerData[3] == "offline") {
		newData.setAttribute("class", "condet label3 tyellow tbold");
	}else {
		newData.setAttribute("class", "condet label3 tgreen tbold");
	}
	newData.innerHTML = containerName;
	document.getElementById("buttonbar-" + containerName).appendChild(newData);
	var newData = document.createElement("TD");
	newData.setAttribute("class", "condet label4");
	newData.setAttribute("id","tag-" + containerName); 
	newData.innerHTML = containerData[2];
	document.getElementById("buttonbar-" + containerName).appendChild(newData);
	var newData = document.createElement("TD");
	newData.setAttribute("id","ip-" + containerName);
	newData.setAttribute("class", "condet label2");
	newData.innerHTML = containerData[3];
	document.getElementById("buttonbar-" + containerName).appendChild(newData);
	//now add buttons
	if (containerData[3] == "offline") {
		newButtons = ["Start","Export","Commit","Delete"];
	}else {
		if (containerData[4] == "true") {
			newButtons = ["Stop","Console","CacheCon","CacheRtn","CacheSMP","ExecScript"];
		}else {
			newButtons = ["Stop","Console","ExecScript"];
		}
	}
//	for (var thisButton of newButtons) {
	newButtons.forEach(function(thisButton) {
		buttonID = thisButton.toLowerCase();
		var newTD = document.createElement("TD");
		newTD.setAttribute("id", buttonID + '-' + containerName);
		var newbtn = document.createElement("BUTTON");
		newbtn.setAttribute("id", containerName + '-' + buttonID);
		newbtn.innerHTML = thisButton;
		newbtn.innerText = thisButton;
		newbtn.setAttribute("onclick", 'controlContainer("' + buttonID + '=' + containerName + '")');
		newbtn.setAttribute("class", 'button button' + buttonID);
		newTD.appendChild(newbtn);
		document.getElementById('buttonbar-' + containerName).appendChild(newTD);
	});	
}

function updateDetails(thismessage)
{
	//window.alert(thismessage);
	mcIP=thismessage[1];
	thisCommand=thismessage[2];
	theseSubCommands=thisCommand.split(" ");
	thisAction=theseSubCommands[1];
//	if (theseSubCommands[2].includes("=")) {
	if (theseSubCommands[2].indexOf("=") > 0) {
		thisContainerDetail = theseSubCommands[2].split("=");
		thisContainer = thisContainerDetail[0];
	}else {
		thisContainer = theseSubCommands[2];
	}
	thisStatus=thismessage[3];
	switch (thisStatus) {
		case "QUEUED":
			//invert and lock buttons related to container
			document.getElementById(thisContainer + '-' + thisAction).setAttribute("class", 'button button' + thisAction +'stby');
			document.getElementById(thisContainer + '-' + thisAction).disabled = true;
			document.getElementById(thisContainer + '-' + thisAction).setAttribute("style","cursor:default"); 
			break;
		case "RUNNING":
			//flash appropriate button.  Already locked from QUEUED
			toggleButton(thisContainer,thisAction);
			writeToStatus(thisAction + " " + thisContainer + " running...");
			break;
		case "COMPLETE":
			//update row entry
			switch (thisAction) {
				case "stop":
					//refresh line
					if (document.getElementById("containerConsole") != null) {
						if (document.getElementById("containerConsole").getAttribute("value") == thisContainer) {
							removeElement("containerConsole");
						}
					}
					doSend("containerinfo=" + thisContainer);
					break;
				case "start":
					//refresh line
					doSend("containerinfo=" + thisContainer);
					break;
				case "commit":
					//set commit to normal. 
					document.getElementById(thisContainer + "-commit").setAttribute("class", 'button buttoncommit');  
					break;
				case "export":
					document.getElementById(thisContainer + "-export").setAttribute("class", 'button buttonexport');
					break;
				case "delete":
					//remove thisContainer rows
					removeElement("table-" + thisContainer);
					removeElement("table-con" + thisContainer);
					if (document.getElementById("CONTAINERS").childElementCount == 0) {
						writeToStatus("No Containers defined.");
					}
					break;
				}
			break;
		case "IDLE":
			writeToStatus("");
			break;
		case "FAILED":
			writeToStatus("Error: " + thismessage[2] + " - failed.");
			doSend("containerinfo=" + thisContainer);
			break;						
		}
}

/////////

function createIframe(url,id,container)
{
	var newTD = document.createElement("TD");
	var newIframe= document.createElement("iframe");
        newIframe.setAttribute("src", url);
	newIframe.setAttribute("class",'iconsole');
	if (id.substring(0, 4) == "con") {
		newTD.setAttribute("id","containerConsole");
		newTD.setAttribute("value",container);
	}else {
		newTD.setAttribute("id",id + container);
	}
	newTD.setAttribute("class", 'test');
	newTD.appendChild(newIframe);
	if (id.substring(0, 4) == "ccon") {
		document.getElementById(container).appendChild(newTD);
	}else {
		var ThisRef = document.getElementById(container);
		ThisRef.insertBefore(newTD, ThisRef.childNodes[0]);
	}
}

function importcacheroutine(thiscontainer)
{
	doSend('post=' + thiscontainer);
	if (consoleopen == true) {
		removeElement('con' + existingconsole);
	}
        window.location="/cgi-bin/container-custom.cgi";
}

function cacheweb(thiscontainer)
{
	if (document.getElementById('ccon' + thiscontainer) != null ) {	
		removeElement('ccon' + thiscontainer);
		document.getElementById(thiscontainer + '-cachecon').setAttribute("class", 'button buttoncachecon');
		//writeToStatus('Cache console closed.');
	}else {	
		createIframe('http://' + thiscontainer + ':57772/terminal/?ns=USER&clean=1',"ccon",thiscontainer);
		document.getElementById(thiscontainer + '-cachecon').setAttribute("class", 'button buttoncacheconinv');
		//writeToStatus('Cache console open.');
	}
}

function displayConsole(detail)
{
	//0=info,1=ip,2=container,3=on/off.  if 3 on, 4=url
	mcIP=document.getElementById("IP").value;
	messageTargetedAt=detail[1];
	if (mcIP == messageTargetedAt) {
		//It's for this client, so console on or off?
		if (detail[3] == "on") {
			//remove any existing consoles.  id will be "containeConsole"
			existingcon = document.getElementById("containerConsole");
			if (existingcon != null) {
				container=existingcon.getAttribute("value");
				removeElement("containerConsole");
				document.getElementById(container + '-console').setAttribute("onclick", 'controlContainer("console=' + container + '")');
				document.getElementById(container + '-console').setAttribute("class", 'button buttonconsole');				 
			}				
			//show the console
			createIframe(detail[4],"con",detail[2]);
			//set console button to issue noconsole
			document.getElementById(detail[2] + '-console').setAttribute("onclick", 'controlContainer("noconsole=' + detail[2] + '")');
			//invert console button
			document.getElementById(detail[2] + '-console').setAttribute("class", 'button buttonconsoleinv');
		}else {
			//remove console
			removeElement("containerConsole");
			//set console button to issue console
			document.getElementById(detail[2] + '-console').setAttribute("onclick", 'controlContainer("console=' + detail[2] + '")');
			//invert console button
			document.getElementById(detail[2] + '-console').setAttribute("class", 'button buttonconsole');
		}
	}
}

function displayCommitDialogue(containerName)
{
	//invert the commit button and set it to remove CommitDialogue
	document.getElementById(containerName + '-commit').setAttribute("onclick", 'removeCommitDialogue("' + containerName + '")');
	document.getElementById(containerName + '-commit').setAttribute("class", 'button buttoncommitinv');
	var newRow = document.createElement("TR");
	newRow.setAttribute("id","commitdialogue-" + containerName);
	var newData = document.createElement("TD");
	newData.className = "condet label3";
	newRow.appendChild(newData); 
	var newData = document.createElement("TD");
	newData.className = "condet label4 yellow";
	newData.innerText="Enter Tag name to commit " + containerName + " and click Submit ->";
	newRow.appendChild(newData);
	var newData = document.createElement("TD");
	var newInput = document.createElement("INPUT");
	newInput.type = "text";
	thisValue = document.getElementById("tag-" + containerName).innerText;	
	newInput.value =  thisValue.substring(thisValue.indexOf(":")+1,thisValue.length -1) + "-Final";
	newInput.className = "textbox light tblack";
	newInput.setAttribute("id","committag");
	newData.appendChild(newInput);
	newRow.appendChild(newData);
	var newData = document.createElement("TD");
	var newBtn = document.createElement("BUTTON");
	newBtn.setAttribute("id", containerName + '-commit');
	newBtn.innerHTML = "Submit";
	newBtn.innerText = "Submit";
	newBtn.setAttribute("onclick", 'commitContainer("' + containerName + '")');
	newBtn.setAttribute("class", "button buttoncommit");
	newData.appendChild(newBtn);
	newRow.appendChild(newData); 
	document.getElementById("table-con" + containerName).appendChild(newRow);
}

function removeCommitDialogue(containerName)
{
	//invert the commit button and set it to display CommitDialogue
	document.getElementById(containerName + '-commit').setAttribute("onclick", 'controlContainer("commit=' + containerName + '")');
	document.getElementById(containerName + '-commit').setAttribute("class", 'button buttoncommit');
	removeElement("commitdialogue-" + containerName);	
}

function commitContainer(containerName)
{
	var commitTag=document.getElementById("committag").value;
	doSend("commit=" + containerName + "=" + commitTag);
	removeCommitDialogue(containerName);
}

function importroutine(details)
{
	var mycontainer = details.substring(details.indexOf('=') + 1, details.length);
	controlContainer(details);
}

function runcacheroutine(thiscontainer)
{
	doSend('post=' + thiscontainer);
	if (consoleopen == true) {
		removeElement('con' + existingconsole);
        }
	window.location="/cgi-bin/image-cacheinstaller.cgi";

}

function cacheroutine(details)
{
	var mycontainer = details.substring(details.indexOf('=') + 1, details.length);
	document.getElementById(mycontainer).innerHTML = '<td height="1px" class="gray build" colspan="100%"><td></tr>';
	controlContainer(details);
}
function toggleButton(containerName,buttonName)
{
	//if netither normal or inv, start with normal
	var buttonStatus=document.getElementById(containerName + "-" + buttonName).getAttribute("class")
	if (buttonStatus== "button button" + buttonName) {
		document.getElementById(containerName + "-" + buttonName).setAttribute("class", 'button button' + buttonName + 'inv');
	}else {
		document.getElementById(containerName + "-" + buttonName).setAttribute("class", 'button button' + buttonName);
	}
}	

// get system Status
//
function getSystemStatus()
{
	doSend ("systemstatus");
}

function testWebSocket()
{
	websocket = new WebSocket(wsUri);
	websocket.onopen = function(evt) { onOpen(evt) };
	websocket.onclose = function(evt) { onClose(evt) };
	websocket.onmessage = function(evt) { onMessage(evt) };
	websocket.onerror = function(evt) { onError(evt) };
}

function acknowledge()
{
	removeElement("ack-button");
	document.getElementById("outputtd").style.color = '#00cc00';
	writeToStatus("");
}

function removeElement(name)
{
	if (document.getElementById(name) != null) {
		var elem = document.getElementById(name);
		elem.parentNode.removeChild(elem);
	}
		
}

function onOpen(evt)
{
	doSend("containerstatus");
	updates = window.setInterval(getSystemStatus, 2000);
}

function onClose(evt)
{
	if (online)
	{
		if (thismode == "console") {
                        writeToScreen("Task complete.");
                        document.getElementById("other").scrollTop = 100000;
                }else {
                        writeToStatus("Task complete.");
                }
	}else {
		writeToScreen ("Socket error.");
	        document.getElementById("consolereturn").disabled = false;
                document.getElementById("consolereturn").style.background = '#aa0000';
                document.getElementById("consolereturn").value = "Return";
                document.getElementById("consolereturn").style.cursor = "pointer";
	}
}

function onMessage(evt)
{
	var thismessage=evt.data.split(",")
	var category=thismessage[0];
	switch (category) {
		case "CONTAINERINFO": 
			createButtonRow(thismessage);
			break;
		case "JOBINFO":
			updateDetails(thismessage);
			break;
		case "CONSOLE":
			displayConsole(thismessage);
			break;
		case "CONTAINERDETAIL":
			updateButtonRow(thismessage);
			break;
		default:
			//writeToStatus("Message: " + evt.data)
	}
}

function WebSocketClose() {
	websocket.close()
}

function onError(evt)
{
	writeToScreen('<span style="color: red;">ERROR:</span> ' + evt.data);
	online = false;
}

function doSend(message)
{
	thismode = "update";
	websocket.send(message);
}

function writeToStatus(message)
{
	document.getElementById("outputtd").innerHTML = message;
}

function writeToScreen(message)
{
	var tr = document.createElement("TR");
	tr.innerHTML ='<td class="console">' + message + '</td>';
	document.getElementById("output").appendChild(tr);
	document.getElementById("other").scrollTop = 10000;
}

window.addEventListener("load", init, false);

