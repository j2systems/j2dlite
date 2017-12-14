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
		}
	testWebSocket();
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

function removeElement(name)
{
	var elem = document.getElementById(name);
	elem.parentNode.removeChild(elem);
}

function onOpen(evt)
{
	action = document.getElementById("operation").value;
	if (action != "") {
		doSend(action);
	}
}	

function onClose(evt)
{
	if (online)
	{
		writeToScreen("Task complete.");
		document.getElementById("other").scrollTop = 100000;
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
	}else {
//		writeToScreen(event.data);	
		writeToScreen(evt.data);	
		document.getElementById("other").scrollTop = 1000000;
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


function writeToScreen(message)
{
	var tr = document.createElement("TR");
	tr.innerHTML ='<td class="console">' + message + '</td>';
	document.getElementById("output").appendChild(tr);
	document.getElementById("other").scrollTop = 10000;
}

window.addEventListener("load", init, false);

