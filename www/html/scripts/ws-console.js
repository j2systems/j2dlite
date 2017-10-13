//websocket handler

var wsUri = "ws://" + window.location.hostname + ":4201/";
var URL;
var websocket;

function init()
{
	testWebSocket();
}

function CloseTerminal()
{
	doSend("noconsole=true");
	websocket.close();
	removeElement("rootconsole");
	window.location="/cgi-bin/system.cgi";	
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
	doSend("console=J2DOCKERROOT");
}

function onClose(evt)
{
	doSend("noconsole=true");
	websocket.close();
	window.location="/cgi-bin/system.cgi";
}

function WebSocketClose() 
{
	websocket.close();
}
function onError(evt)
{
//	writeToScreen('<span style="color: red;">ERROR:</span> ' + evt.data);

}

function doSend(message)
{
	websocket.send(message);
}

function removeElement(name)
{
	var elem = document.getElementById(name);
	elem.parentNode.removeChild(elem);
}
 
function onMessage(evt)
{
	if (evt.data.substr(0, 4) == "http") {
		URL=evt.data;
		setTimeout(displayConsole,1000);
		var newTD = document.createElement("TD");
		newTD.setAttribute("id","tmp")
		newTD.setAttribute("class","information black")
		newTD.innerTest = "Launching console..."
		newTD.innerHTML = "Launching console..."
		document.getElementById("dockerterm").appendChild(newTD);
	}
}
function displayConsole() 
{
	var newTD = document.createElement("TD");
	var newIframe= document.createElement("iframe");
        newIframe.setAttribute("src", URL);
	newIframe.setAttribute("class",'iconsole');
	newIframe.setAttribute("id",'rootconsole');
	newTD.appendChild(newIframe);
	removeElement("tmp");
	document.getElementById("dockerterm").appendChild(newTD);	
}	


window.addEventListener("load", init, false);

