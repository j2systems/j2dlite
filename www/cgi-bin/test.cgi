#!/bin/bash
source source/functions.sh
. tmp/globals
cat base/header 
cat base/nav|sed "s/screen4/green/g"
cat base/advanced|sed "s/green build/yellow build/g"

echo "<input type=\"hidden\" id=\"IP\" value=\"${MANHOSTIP}\">"


echo "<td><button id=\"restart\" onclick=\"doSend('restart')\" class=\"button yellow\">Restart</button></td>"                                                    
echo "<td><button id=\"shutdown\" onclick=\"doSend(\'shutdown\')\" class=\"button red\">SHUTDOWN</button></td>"                                                    

cat base/mclient 
cat base/footer
