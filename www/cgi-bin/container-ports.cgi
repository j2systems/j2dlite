#!/bin/bash

source source/functions.sh
. tmp/globals
if [[ "$PORTS" == "" ]]
then
	for THISPORT in 22 23 80 1972 4201 4202 8080 57772
	do
		append_global PORTS $THISPORT
	done
	. tmp/globals
fi
cat base/header 
cat base/nav|sed "s/screen4/green/g"
cat base/advanced|sed "s/yellow ports/green/g"
case "${REQUEST_METHOD}" in
        "POST")
		read ACTION
		. tmp/globals
		DOTHIS=$(echo $ACTION|cut -d "&" -f2|cut -d "=" -f1)
		THISPORT=$(echo $ACTION|cut -d "&" -f1|cut -d "=" -f2)
		case $DOTHIS in
			"DELETE")
				remove_entry_global PORTS $THISPORT
				echo "config.sh" > tmp/trigger
				;;
			"ADD")
				if [[ "$THISPORT" != "" ]]
				then
					append_global PORTS $THISPORT
					echo "config.sh" > tmp/trigger
				fi 
				;;
			*)
				echo "Action = ${DOTHIS}"
				;;
		esac
		;;

	"GET")
		;;
esac
unset PORTS
. tmp/globals
echo "<table align=\"center\">"
echo "<tr align=\"center\"><td class=\"label blue\" colspan=\"2\">Manage firewall ports</td></tr>"
echo "<td class=\"label label4\">Port</td><td></td></tr>"

for PORT in $PORTS
do
	MATCH=false
	for THISPORT in $DEFAULTPORTS
	do
		if [[ "$THISPORT" == "$PORT" ]]
		then
			MATCH=true
			break
		fi
	done
	if [[ "$MATCH" == "false" ]]
	then
		echo "<form action=\"container-ports.cgi\" method=\"POST\">"
        	echo "<tr><td class=\"label label4\"><input type=\"text\" class=\"textbox green\" name=\"PORT\" value=\"$PORT\"></td>"
		echo "<td><input type=\"submit\" name=\"DELETE\" value=\"Delete\" class=\"button red\"></td></tr></form>"
	
	else
		echo "<tr><td class=\"label label4\"  class=\"textbox green\">$PORT</td></tr>"
	fi
done

echo "<form action=\"container-ports.cgi\" method=\"POST\">"
echo "<tr><td class=\"label label4\"><input type=\"text\" class=\"textbox yellow\" name=\"PORT\"></td>"
echo "<td><input type=\"submit\" name=\"ADD\" value=\"Add\" class=\"button green\"></td></tr>"
echo "</form></table>"
cat base/footer



