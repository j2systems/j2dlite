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

function init()
{
	output = document.getElementById("output");
	if (document.getElementById("consolereturn") != null)
		{
			document.getElementById("consolereturn").disabled = true;
			document.getElementById("consolereturn").style.background = '#aa0000';
			document.getElementById("consolereturn").value = "Processing";
			document.getElementById("consolereturn").style.cursor = "none";	
			flash = true;
			flashTimer = window.setInterval(flashConsoleReturn, 1000);
		}else {
			output = document.getElementById("outputtd");
			document.getElementById("outputtd").style.color = '#00CC00';
		}
	testWebSocket();
}

function controlContainer(dothis)
{
	sendMessage=dothis;
	previouscontainer = thiscontainer;
	thisaction = dothis.substring(0, dothis.indexOf('='));
	thiscontainer = dothis.substring(dothis.indexOf('=') + 1, dothis.length);
	writeToStatus(thisaction + ' '  + thiscontainer + ' requested.');
	switch (thisaction) {
		case "cachertn":
			runcacheroutine(thiscontainer);
			break;
		case "cacheimp":
			importcacheroutine(thiscontainer);
			break;
		case "cachecon":
			cacheweb(thiscontainer);
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
			disableButtons(true);
			doSend(dothis);
	}
}

function disableButtons(thisState)
{
	var inputs = document.getElementsByTagName("button");
    	for (var i = 0; i < inputs.length; i++) {
        	inputs[i].disabled = thisState;
		if (thisState == true) {
			inputs[i].setAttribute("style","cursor:default");
		}else {
			if (inputs[i].getAttribute("class") != "button buttoninvisible") {
 				inputs[i].setAttribute("style","cursor:pointer");
			}
		}
    	}
	var inputs = document.getElementsByTagName("input");
    	for (var i = 0; i < inputs.length; i++) {
        	inputs[i].disabled = thisState;
		if (thisState == true) {
			inputs[i].setAttribute("style","cursor:default");
		}else {
			inputs[i].setAttribute("style","cursor:pointer");
		}
    	}
}

function createIframe(url,id,container)
{
	var newTD = document.createElement("TD");
	var newIframe= document.createElement("iframe");
        newIframe.setAttribute("src", url);
	newIframe.setAttribute("class",'iconsole');
	newTD.setAttribute("id",id + container);
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
		writeToStatus('Cache console closed.');
	}else {	
		createIframe('http://' + thiscontainer + ':57772/terminal/?ns=USER&clean=1',"ccon",thiscontainer);
		document.getElementById(thiscontainer + '-cachecon').setAttribute("class", 'button buttoncacheconinv');
		writeToStatus('Cache console open.');
	}
}

function consoleweb(thiscontainer,webURL)
{	
	if (consoleopen == true){
		if (thiscontainer == existingconsole) {      
                	consoleopen = false;
                	removeElement('con' + thiscontainer);
			document.getElementById(thiscontainer + '-console').setAttribute("class", 'button buttonconsole');
			document.getElementById(thiscontainer + '-console').setAttribute("onclick", 'controlContainer("console=' + thiscontainer + '")');
			writeToStatus('Console closed.');
		}else {
			removeElement('con' + existingconsole);
			document.getElementById(existingconsole + '-console').setAttribute("class", 'button buttonconsole');
			document.getElementById(existingconsole + '-console').setAttribute("onclick", 'controlContainer("console=' + existingconsole + '")');
			existingconsole = thiscontainer;
			createIframe(webURL,"con",thiscontainer);
			document.getElementById(thiscontainer + '-console').setAttribute("class", 'button buttonconsoleinv');
			document.getElementById(thiscontainer + '-console').setAttribute("onclick", 'controlContainer("noconsole=' + thiscontainer + '")');
			writeToStatus('Console changed to ' + thiscontainer + '.');
		}
				
	}else {
		consoleopen = true;
		existingconsole = thiscontainer;
		createIframe(webURL,"con",thiscontainer);
		document.getElementById(thiscontainer + '-console').setAttribute("class", 'button buttonconsoleinv');
		document.getElementById(thiscontainer + '-console').setAttribute("onclick", 'controlContainer("noconsole=' + thiscontainer + '")');
	}
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

function flashConsoleReturn()
{
	if (flash == true) {
		var thisback = document.getElementById("consolereturn");
		if (thisback.style.background == "rgb(85, 85, 85)") {
			document.getElementById("consolereturn").style.background = '#aa0000';
		}else {
			document.getElementById("consolereturn").style.background = '#555555';
		}
	}else {
		document.getElementById("consolereturn").disabled = false;
		document.getElementById("consolereturn").style.background = '#00aa00';
		document.getElementById("consolereturn").value = "Return";
		document.getElementById("consolereturn").style.cursor = "pointer";
		window.clearInterval(flashTimer);
		websocket.close();
	}	
}

function testWebSocket()
{
	websocket = new WebSocket(wsUri);
	websocket.onopen = function(evt) { onOpen(evt) };
	websocket.onclose = function(evt) { onClose(evt) };
	websocket.onmessage = function(evt) { onMessage(evt) };
	websocket.onerror = function(evt) { onError(evt) };
}

function checkStatus()
{
	if (poll == true) {
		if (thiscol == true) {
			thiscol = false;
			document.getElementById(jobcontainer + '-' + jobaction).setAttribute("class", 'button button' + jobaction + 'inv');
		}else {
			thiscol = true;
			document.getElementById(jobcontainer + '-' + jobaction).setAttribute("class", 'button button' + jobaction);
		}
		sendMessage = "status=update";
		doSend("status=update");
	}
}

function acknowledge()
{
	removeElement("ack-button");
	document.getElementById("outputtd").style.color = '#00cc00';
	writeToStatus("");
}

function removeElement(name)
{
	var elem = document.getElementById(name);
	elem.parentNode.removeChild(elem);
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
	document.getElementById(elem).appendChild(newbtn);
	

}

function updateButtons(containerName,runStatus)
{

	if (runStatus === "stop") {
		
		existButtons = ["Stop","Console","CacheCon","CacheImp","CacheRtn"];
		newButtons = ["Start","Export","Commit","Delete"];
		document.getElementById('container-' + thiscontainer).class = 'condet label3 tyellow tbold';
		document.getElementById('ip-' + thiscontainer).innerText = '(offline)';
	}else {
		existButtons = ["Start","Export","Commit","Delete"];
		newButtons = ["Stop","Console","CacheCon","CacheImp","CacheRtn"];
		document.getElementById('container-' + thiscontainer).class = 'condet label3 tgreen tbold';
	}
	for (var thisButton of existButtons) {
		var elemName = thisButton.toLowerCase() + '-' + containerName;
		removeElement(elemName);
	}

	for (var thisButton of newButtons) {
		buttonID = thisButton.toLowerCase();
		var newTD = document.createElement("TD");
		newTD.setAttribute("id", buttonID + '-' + containerName);
		var newbtn = document.createElement("BUTTON");
		newbtn.setAttribute("id", containerName + '-' + buttonID);
		newbtn.innerHTML = thisButton;
		newbtn.innerText = thisButton;
		newbtn.setAttribute("onclick", 'controlContainer("' + buttonID + '=' + containerName + '")');
		if (thisButton.substr(0, 5) == "Cache")	{
			if (document.getElementById('hs-' + containerName).innerHTML == 'true') {
				newbtn.setAttribute("class", 'button button' + buttonID);
			}else {
				newbtn.setAttribute("class", 'button buttoninvisible');	
			}
		}else {
			newbtn.setAttribute("class", 'button button' + buttonID);
		}
		newTD.appendChild(newbtn);
		document.getElementById('buttonbar-' + containerName).appendChild(newTD);
	}
}	


function onOpen(evt)
{
//	writeToScreen("Connecting to Docker...");
//	doSend("Test");
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
	if (evt.data == "SCRIPT END") {
		flash = false;
	}else if (evt.data == "TERMHUP") {
		disableButtons(false);
		consoleweb(thiscontainer,evt.data);
	}else if (evt.data == "JOBBED") {
		disableButtons(true);
		flash = true;
		poll = true;
		jobname = thisaction + ' ' + thiscontainer;
		jobaction = thisaction;
		jobcontainer = thiscontainer;
		writeToStatus(jobname + " running...");
		polltimer = window.setInterval(checkStatus, 1000);		
	}else if (evt.data == "COMPLETE") {
		disableButtons(false);
		resent = false;
		poll = false;
		window.clearInterval(polltimer);
		jobaction = "";
		jobcontainer = "";
		document.getElementById("outputtd").style.color = '#00CC00';
 		writeToStatus(jobname + " completed.");
		thiscol = true;
		if (jobname.substring(0, 6) == "delete") {
                        document.getElementById('table-' + thiscontainer).remove();
                        document.getElementById('table-con' + thiscontainer).remove();
                }
		if (jobname.substring(0, 4) == "stop") {
			updateButtons(thiscontainer, "stop");
			document.getElementById('container-' + thiscontainer).className = 'condet label3 tyellow tbold'
		}
		if (jobname.substring(0, 6) == "commit") {
			document.getElementById(thiscontainer + '-commit').className = 'button buttoncommit';
		}
	}else if (evt.data.substr(0, 6) == "START=") {

		thisip=evt.data.substring(evt.data.indexOf('=') + 1, evt.data.length);
		document.getElementById('ip-' + thiscontainer).innerText = thisip;
	}else if (evt.data.substr(0, 6) == "RESEND") {
		if (resent == true) {
			createButton("ack","OK","warn","acknowledge","true","button yellow tblack");
			writeToStatus ('fail: ' + evt.data);
			document.getElementById("outputtd").style.color = '#cc0000';
			resent=false;
		}else {
			resent = true;
			doSend(sendMessage);
		}
	}else if (evt.data == "REFRESH") {
		disableButtons(false);
		if (thisaction == "start") {
	                updateButtons(thiscontainer, "start");
			document.getElementById('ip-' + thiscontainer).innerText = thisip;
			document.getElementById('ip-' + thiscontainer).className = 'condet label2';
			document.getElementById('container-' + thiscontainer).className = 'condet label3 tgreen tbold';
			writeToStatus(thiscontainer + ' started.');
		}
		//if (thisaction == "noconsole") {
		//	document.getElementById(thiscontainer).innerHTML = '<td height="1px" class="gray build" colspan="100%"><td></tr>';
                //}
	}else {
		if (thismode == "console") {
			writeToScreen(evt.data);
			document.getElementById("other").scrollTop = 1000000;
		}else {
			if (evt.data.substr(0, 4) == "http") {
				consoleweb(thiscontainer,evt.data);
				writeToStatus('CONSOLE OPEN for '+ thiscontainer);
				disableButtons(false);
			}else {	
				//writeToStatus("Message: " + evt.data);
				//writeToStatus("");
			}
		}
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

