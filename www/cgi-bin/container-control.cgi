#!/bin/bash

source source/functions.sh

. tmp/globals
[[ -f tmp/containers ]] && rm -f tmp/containers
cat base/header 
cat base/nav|sed "s/screen3/green/g"

docker ps -a --format "{{.Names}} ({{.Image}}) {{.Status}}" > tmp/containers
CONTAINERCOUNT=$(wc -l tmp/containers|cut -d " " -f1)
if [[ "$CONTAINERCOUNT" == "0" ]]
then
	echo "<table align=\"center\"><tr><td class=\"information yellow\">No containers configured</td></tr></table>"
else
	cat base/wscontrol 
	echo "<table width=\"100%\"><tr><td width=\"100%\" height=\"3px\" class=\"green build\"></td></tr></table>"

	while read NAME IMAGE STATUS
	do
		ISHS=$(isHS ${NAME})
		echo "<table id=\"table-${NAME}\"align=\"left\">"
		if [[ $(echo $STATUS|grep -c -e "^Up") -eq 1 ]]
		then
			echo "<tr id=\"buttonbar-$NAME\"><td id=\"hs-${NAME}\" style=\"display:none\">${ISHS}</td><td id=\"container-$NAME\" class=\"condet label3 tgreen tbold\">$NAME</td><td class=\"condet label4\">$IMAGE</td><td id=\"ip-$NAME\" class=\"condet label2\">$(get_container_ip $NAME)</td>"				
			for BUTTONNAME in Stop Console
			do
				LCASE=$(echo $BUTTONNAME|tr [A-Z] [a-z])
				echo "<td id=\"${LCASE}-${NAME}\"><button id=\"${NAME}-${LCASE}\" class=\"button button${LCASE}\" onclick=controlContainer(\"${LCASE}=$NAME\")>$BUTTONNAME</button></td>"
			done
			for BUTTONNAME in CacheCon CacheImp CacheRtn
			do
				LCASE=$(echo $BUTTONNAME|tr [A-Z] [a-z])
				if [[ "${ISHS}" == "true" ]]
				then
					echo "<td id=\"${LCASE}-${NAME}\"><button id=\"${NAME}-${LCASE}\" class=\"button button${LCASE}\" onclick=controlContainer(\"${LCASE}=$NAME\")>$BUTTONNAME</button></td>"
				else
					echo "<td id=\"${LCASE}-${NAME}\"><button id=\"${NAME}-${LCASE}\" class=\"button buttoninvisible\" disabled>$BUTTONNAME</button></td>"
				fi
				

			done
			#[[ "${ISHS}" == "false" ]] && echo "<td></td><td></td><td></td>"
			echo "</tr>"
		else
			echo "<tr id=\"buttonbar-$NAME\"><td id=\"hs-${NAME}\" style=\"display:none\">${ISHS}</td><td id=\"container-$NAME\" class=\"condet label3 tyellow tbold\">$NAME</td><td class=\"condet label4\">$IMAGE</td><td id=\"ip-$NAME\" class=\"condet label2\">(offline)</td>"
			for BUTTONNAME in Start Export Commit Delete
			do
				LCASE=$(echo $BUTTONNAME|tr [A-Z] [a-z])
				echo "<td id=\"${LCASE}-${NAME}\"><button id=\"${NAME}-${LCASE}\" class=\"button button${LCASE}\" onclick=controlContainer(\"${LCASE}=$NAME\")>$BUTTONNAME</button></td>"
			done
			echo "</tr>"
	
		fi
		#echo "</table><input type=\"hidden\" id=\"${NAME}-isHS\" value=\"${ISHS}\""
		echo "<table id=\"table-con${NAME}\" align=\"center\" width=\"100%\"><tr id=\"$NAME\"></tr></table>"
	done < tmp/containers

fi


cat base/footer
