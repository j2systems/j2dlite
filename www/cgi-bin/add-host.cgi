#!/bin/bash
source source/functions.sh
if [[ $(echo $HTTP_USER_AGENT|grep -c "Windows") -eq 1 ]]                                        
then                                                                                             
        MCHOSTTYPE=WINDOWS                                                                      
elif [[ $(echo $HTTP_USER_AGENT|grep -c "Macintosh") -eq 1 ]]                                    
then                                                                                                               
        MCHOSTTYPE=MAC                                                                                                                               
elif [[ $(echo $HTTP_USER_AGENT|grep -c "Linux") -eq 1 ]]                                                                                             
then                                                                                                                                                  
        MCHOSTTYPE=LINUX                                                                                                                                
else                                                                                                                                                     
        MCHOSTTYPE=OTHER                                                                                                                                
fi
cat base/header 
cat base/nav|sed "s/green build/yellow/g"
echo "<table align=\"center\">"
echo "<tr align=\"center\"><td class=\"label blue\" colspan=\"4\">Add ${REMOTE_ADDR} as Integrated Client</td></tr>"
echo "<tr><td class=\"label label2\">Username</td><td class=\"label label2\">Password</td><td class=\"label label3\">Studio</td><td class=\"label label3\">Atelier</td></tr>"
echo "<form action=\"./terminal.cgi\" method=\"POST\">"
echo "<tr><td class=\"label label2\"><input type=\"text\" class=\"textbox tblack\" name=\"USERNAME\"></td>"
echo "<td class=\"label label2\"><input type=\"password\" class=\"textbox tblack\" name=\"PASSWORD\"></td>"
echo "<input type=\"hidden\" name=\"OSTYPE\" value=\"${MCHOSTTYPE}\">"
echo "<td class=\"label label3\"><input type=\"checkbox\" name=\"STUDIO\"></td>"
echo "<td class=\"label label3\"><input type=\"checkbox\" name=\"ATELIER\"></td></tr>"
echo "<tr><td><input type="submit" name=\"ADDCLIENT\" class=\"button\" value="Submit"></td></tr></form></table>"
echo "<table width=\"100%\"><tr><td width=\"100%\" height=\"3px\" class=\"blue build\"></td></tr>"
echo "<table align=\"center\">"
echo "<tr><td class=\"label\" colspan=\"6\">Registered Management Clients</td></tr>"
echo "<tr class=\"information blue\"><td>HOST</td><td>USERNAME</td><td>OS</td><td>INTEGRATED</td><td>STUDIO</td><td>ATELIER</td></tr>"
while read HOST USERNAME TYPE INTEGRATED STUDIO ATELIER
do
	if [[ "$INTEGRATED" == "true" ]]
	then
		echo "<tr class=\"information yellow\">"
	else
		echo "<tr class=\"information light\">"
	fi
	echo "<td>$HOST</td><td>$USERNAME</td><td>$TYPE</td><td>$INTEGRATED</td><td>$STUDIO</td><td>$ATELIER</td></tr>"
done < wsdetail_MClients
echo "<tr></tr><tr><td class=\"label\" colspan=\"6\">Rejected Management Clients</td></tr>"                         
echo "<tr class=\"information blue\"><td>HOST</td></tr>"
while read HOST
do                                                                                                           
	echo "<tr class=\"information light\"><td>$HOST</td></tr>"

done < system/wsdetail_MClients_declined
echo "</table>"
cat base/footer



