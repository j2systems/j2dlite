//websocket handler

var wsUri = "ws://" + window.location.hostname + ":4201/";
var URL;
var myip;
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

function createButton(name,displaytext,elem,script,action,thisclass) 
{
	var todiv = document.getElementById(elem)
	buttonID = name.toLowerCase();
	var newtd=document.createElement("TD")
	var newbtn = document.createElement("BUTTON");
	newbtn.setAttribute("id", buttonID + '-button');
	newbtn.innerHTML = displaytext;
	newbtn.innerText = displaytext;
	newbtn.setAttribute("onclick", script + '("' + action + '")');
	newbtn.setAttribute("class", thisclass);
	newtd.appendChild(newbtn);
	todiv.appendChild(newtd);
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
//	var elem = document.getElementById(name);
//	elem.parentNode.removeChild(elem);
	document.getElementById(name).innerHTML="";
}
 
function onMessage(evt)
{
	var clientstatus=evt.data;
	if (clientstatus == "false") {
		document.getElementById("MC").innerHTML="<td>New client detected.  Add " + myip + " as Management Host?</td>";
		createButton("Yes","Yes","MC","acceptHost",myip,"button yellow");
		createButton("No","No","MC","declineHost",myip,"button yellow");
	}else {
		removeElement("MC");
	}
}
window.addEventListener("load", init, false);

