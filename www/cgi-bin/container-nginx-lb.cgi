#!/bin/bash
source source/functions.sh
[[ ! -f tmp/nginxlb ]] && touch tmp/nginxlb
. tmp/globals
cat base/header 
cat base/nav|sed "s/screen4/green/g"
cat base/advanced|sed "s/yellow loadbal/green/g"
FQDN=$(hostname).lan
case "${REQUEST_METHOD}" in
 "POST")
		read ACTION
		#echo $ACTION
		DOTHIS=$(echo $ACTION|rev|cut -d "&" -f1|rev|cut -d "=" -f2)
		#echo "<br>$DOTHIS<br>"
		URL=$(echo $ACTION|cut -d "&" -f1|cut -d "=" -f2)
		NGINXTO=$(echo $ACTION|cut -d "&" -f2|cut -d "=" -f2)
		PORTFROM=$(echo $ACTION|cut -d "&" -f3|cut -d "=" -f2)
		PORTTO=$(echo $ACTION|cut -d "&" -f4|cut -d "=" -f2)
		case $DOTHIS in
			"Remove")
				URL=$(echo $ACTION|cut -d "&" -f1|cut -d "=" -f2)
				LSTNPORT=$(echo $ACTION|cut -d "&" -f2|cut -d "=" -f2)
				LBNAME=$(echo $ACTION|cut -d "&" -f3|cut -d "=" -f2)
				ALGO=$(echo $ACTION|cut -d "&" -f4|cut -d "=" -f2)
				REMOVEHOST=$(echo $ACTION|cut -d "&" -f5|cut -d "=" -f2)
 				sed -i "/^${URL}/s/${REMOVEHOST}[^ ]*//" tmp/nginxlb
				sed -i "s/  / /g" tmp/nginxlb
				sed -i "s/\ $//g" tmp/nginxlb
				[[ $(grep -e "^$URL" tmp/nginxlb) == "$URL:$LSTNPORT $LBNAME $ALGO" ]] && sed -i "/^${URL}/d" tmp/nginxlb
				echo "nginxlb.sh" > tmp/trigger
				;;
			"Amend")
				URL=$(echo $ACTION|cut -d "&" -f1|cut -d "=" -f2)
				LSTNPORT=$(echo $ACTION|cut -d "&" -f2|cut -d "=" -f2)
				LBNAME=$(echo $ACTION|cut -d "&" -f3|cut -d "=" -f2)
				ALGO=$(echo $ACTION|cut -d "&" -f4|cut -d "=" -f2)

                                CHANGEHOST=$(echo $ACTION|cut -d "&" -f5|cut -d "=" -f2)
                                CHANGEPORT=$(echo $ACTION|cut -d "&" -f6|cut -d "=" -f2)
                                STUPID=$(echo $ACTION|cut -d "&" -f7|cut -d "=" -f1)
				if [[ "$STUPID" == "BACKUP" ]]
				then
					CHANGEBACKUP="true"
					CHANGEWEIGHT=$(echo $ACTION|cut -d "&" -f8|cut -d "=" -f2)
				else
					CHANGEBACKUP=""
					CHANGEWEIGHT=$(echo $ACTION|cut -d "&" -f7|cut -d "=" -f2)
				fi
				sed -i "/^${URL}/s/^${URL}[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]/${URL}:${LSTNPORT} ${LBNAME} ${ALGO} /" tmp/nginxlb
				sed -i "/^${URL}/s/${CHANGEHOST}[^ ]*/${CHANGEHOST}:${CHANGEPORT}:${CHANGEBACKUP}:${CHANGEWEIGHT}/" tmp/nginxlb
                                sed -i "s/  / /g" tmp/nginxlb
                                sed -i "s/\ $//g" tmp/nginxlb
				echo "nginxlb.sh" > tmp/trigger
				;;
			"Append")
				URL=$(echo $ACTION|cut -d "&" -f1|cut -d "=" -f2)
				APPENDHOST=$(echo $ACTION|cut -d "&" -f5|cut -d "=" -f2)
                                APPENDPORT=$(echo $ACTION|cut -d "&" -f6|cut -d "=" -f2)
                                STUPID=$(echo $ACTION|cut -d "&" -f7|cut -d "=" -f1)
                                if [[ "$STUPID" == "BACKUP" ]]
                                then
                                        APPENDBACKUP="true"
                                        APPENDWEIGHT=$(echo $ACTION|cut -d "&" -f8|cut -d "=" -f2)
                                else
                                        APPENDBACKUP=""
                                        APPENDWEIGHT=$(echo $ACTION|cut -d "&" -f7|cut -d "=" -f2)
                                fi
				sed -i "/^$URL/s/$/ ${APPENDHOST}:${APPENDPORT}:${APPENDBACKUP}:${APPENDWEIGHT}/" tmp/nginxlb
				sed -i "s/  / /g" tmp/nginxlb
				echo "nginxlb.sh" > tmp/trigger
				;;
			"Add")
				URL=$(echo $ACTION|cut -d "&" -f1|cut -d "=" -f2)
                                LSTNPORT=$(echo $ACTION|cut -d "&" -f2|cut -d "=" -f2)
                                LBNAME=$(echo $ACTION|cut -d "&" -f3|cut -d "=" -f2)
                                ALGO=$(echo $ACTION|cut -d "&" -f4|cut -d "=" -f2)
				APPENDHOST=$(echo $ACTION|cut -d "&" -f5|cut -d "=" -f2)
                                APPENDPORT=$(echo $ACTION|cut -d "&" -f6|cut -d "=" -f2)
                                STUPID=$(echo $ACTION|cut -d "&" -f7|cut -d "=" -f1)
                                if [[ "$STUPID" == "BACKUP" ]]
                                then
                                        APPENDBACKUP="true"
                                        APPENDWEIGHT=$(echo $ACTION|cut -d "&" -f8|cut -d "=" -f2)
                                else
                                        APPENDBACKUP=""
                                        APPENDWEIGHT=$(echo $ACTION|cut -d "&" -f7|cut -d "=" -f2)
                                fi
                                echo "${URL}:${LSTNPORT} ${LBNAME} ${ALGO} ${APPENDHOST}:${APPENDPORT}:${APPENDBACKUP}:${APPENDWEIGHT}" >> tmp/nginxlb
				echo "nginxlb.sh" > tmp/trigger
				;;
			*)
				echo "Action = ${DOTHIS}"
				;;
		esac
		;;

	"GET")
		;;
esac

echo "<table align=\"center\">"
echo "<tr align=\"center\"><td class=\"label black lighttext\" colspan=\"11\">Manage nginx load-balancing</td></tr>"

### Create list of running containers
LISTED=false
delete_global UPHOSTS
while read NAME IMAGE STATUS
do
	if [[ $(echo $STATUS|grep -c -e "^Up") -eq 1 ]]
	then
		LISTED=true
		append_global UPHOSTS $NAME
	fi
done < tmp/containers
. tmp/globals

### If there is a container running
if [[ "$LISTED" == "true" ]]
then
	echo "<tr><td class=\"label label3\">URL</td><td class=\"label\">Port</td><td class=\"label\">LB Name</td><td class=\"label\">LB Algorithm</td><td class=\"label label2\">To</td><td class=\"label label2\">Port</td><td class=\"label label5\">Backup</td><td class=\"label label5\">Weight</td><td></td><td></td><td class=\"label label5\">Status</td>"
	while read URL LBNAME ALGORITHM HOSTS
	do
		CONTAINERREF=false
		ACTUALURL=$(echo ${URL}|cut -d ":" -f1)
		URLPORT=$(echo ${URL}|cut -d ":" -f2)
###FORM START_A
		echo "<form action=\"container-nginx-lb.cgi\" method=\"POST\">"
		echo "<tr><td class=\"label label3\"><input type=\"text\" class=\"textbox green\" name=\"URL\" value=\"$ACTUALURL\"></td>"
		echo "<td><select name=\"LSTNPORT\">"
###LISi & MATCH DEST PORTS
		for PORT in $PORTS
		do
			if [[ "$PORT" == "$URLPORT" ]]
			then
				CONTAINERREF=true
				echo "<option selected value=\"$PORT\">$PORT</option>"
			else
				echo "<option value=\"$PORT\">$PORT</option>"
			fi
 	done
		echo "</select></td>"

###LB NAME+ALGORITHM
		echo "</td><td class=\"label label3\"><input type=\"text\" class=\"textbox green\" name=\"LBNAME\" value=\"$LBNAME\"></td>"
		echo "<td><select name=\"ALGO\">"
		for KNOWNALGORITHM in least_conn ip_hash
		do
			if [[ "$ALGORITHM" == "$KNOWNALGORITHM" ]]
			then
				CONTAINERREF=true
				echo "<option selected value=\"$ALGORITHM\">$ALGORITHM</option>"
			else
				echo "<option value=\"$KNOWNALGORITHM\">$KNOWNALGORITHM</option>"
			fi
		done
		echo "</select></td>"
###DESTINATION
		FIRSTPASS="false"
		for DESTINATION in $HOSTS
		do	
			WARN="false"
			THISSERVER=$(echo ${DESTINATION}|cut -d ":" -f1)
			THISPORT=$(echo ${DESTINATION}|cut -d ":" -f2)
			THISBACKUP=$(echo ${DESTINATION}|cut -d ":" -f3)
			THISWEIGHT=$(echo ${DESTINATION}|cut -d ":" -f4)
			if [[ "$FIRSTPASS" == "true" ]]
			then
###FORM START_B
				echo "<td></td><td></td><td></td><td></td>"
				echo "<form action=\"container-nginx-lb.cgi\" method=\"POST\">"
				echo "<input type=\"hidden\" name=\"URL\" value=\"${ACTUALURL}\">"
				echo "<input type=\"hidden\" name=\"LISTENPORT\" value=\"${URLPORT}\">"
				echo "<input type=\"hidden\" name=\"LBNAME\" value=\"${LBNAME}\">"
				echo "<input type=\"hidden\" name=\"ALGO\" value=\"${ALGORITHM}\">"
			fi
###LIST RUNNING HOSTS
			echo "<td><select name=\"HOST\">"
			ISFOUND="false"
			for DESTOPTION in $UPHOSTS
		 	do
 				if [[ "$DESTOPTION" == "$THISSERVER" ]]
				then
					echo "<option selected value=\"$DESTOPTION\">$DESTOPTION</option>"
					ISFOUND="true"
				else
				 	echo "<option value=\"$DESTOPTION\">$DESTOPTION</option>"
 		 		fi
 			done
			[[ "$ISFOUND" == "false" ]] && echo "<option selected value=\"$THISSERVER\">${THISSERVER}</option>" && WARN="Offline " 
			echo "</select></td>"
###LIST AVAILABLE PORTS
			echo "<td><select name=\"PORT\">"
			ISFOUND="false"
			for PORT in $PORTS
 			do
 				if [[ "$PORT" == "$THISPORT" ]]
 		 	 	then
					echo "<option selected value=\"$PORT\">$PORT</option>"
	 				ISFOUND="true"
				else
					echo "<option value=\"$PORT\">$PORT</option>"
 				fi
 		 	done
			if [[ "$ISFOUND" == "false" ]] 
			then
				echo "<option selected value=\"$THISPORT\">${THISPORT}</option>"
				if [[ "$WARN" == "false" ]]
				then
					WARN="Bad Port"
				else
					WARN=$(echo "${WARN}+BadPort")
				fi
			fi
 			echo "</select></td>"
###Is is a failover, i.e. backup?
			if [[ "$THISBACKUP" == "true" ]] 
			then
				echo "<td class=\"label label5\"><input type=\"checkbox\" name=\"BACKUP\" value=\"Backup\" class=\"button yellow\" checked></td>"
			else
				echo "<td class=\"label label5\"><input type=\"checkbox\" name=\"BACKUP\" value=\"Backup\" class=\"button yellow\"></td>"
			fi	
###Is it weighted?		
			echo "<td class=\"label label5\"><input type=\"text\" class=\"textbox green\" name=\"WEIGHT\" value=\"$THISWEIGHT\"></td>"
### firstpass now done
			[[ "$FIRSTPASS" == "false" ]] && FIRSTPASS="true"
			echo "<td><input type=\"submit\" name=\"ACTION\" value=\"Amend\" class=\"button yellow\"></td>"
			echo "<td><input type=\"submit\" name=\"ACTION\" value=\"Remove\" class=\"button red\"></td>"
			echo "</form>"
###END OF FORM
			if [[ "$WARN" == "false" ]]
			then
				echo "<td class=\"label label5 tgreen\">OK</tr>"
			else
				echo "<td class=\"label label5 tred\">$WARN</tr>"
			fi
		done
###APPEND
		echo "<form action=\"container-nginx-lb.cgi\" method=\"POST\">"		
		echo "<tr><td></td><td></td><td></td><td></td>"
		echo "<input type=\"hidden\" name=\"URL\" value=\"${ACTUALURL}\">"
		echo "<input type=\"hidden\" name=\"LISTENPORT\" value=\"${URLPORT}\">"
		echo "<input type=\"hidden\" name=\"LBNAME\" value=\"${LBNAME}\">"
		echo "<input type=\"hidden\" name=\"ALGO\" value=\"${ALGORITHM}\">"
	
		echo "<td><select name=\"HOST\">"
		for DESTOPTION in $UPHOSTS
		do
			echo "<option value=\"$DESTOPTION\">$DESTOPTION</option>"
		done
		echo "<option selected value=\"\"></option>"
		echo "</select></td>"
		echo "<td><select name=\"PORT\">"
		for PORT in $PORTS
		do
 			echo "<option value=\"$PORT\">$PORT</option>"
		done
		echo "<option selected value=\"\"></option>"
		echo "</select></td>"
		echo "<td class=\"label label5\"><input type=\"checkbox\" name=\"BACKUP\" value=\"Backup\" class=\"button yellow\"></td>"
 		echo "<td class=\"label label5\"><input type=\"text\" class=\"textbox green\" name=\"WEIGHT\" value=\"\"></td>"
		echo "<td><input type=\"submit\" name=\"ACTION\" value=\"Append\" class=\"button green\"></td><td></td><td></tdi>"
		echo "</form></tr>"
		echo "<tr><td height=\"3px\" colspan=\"11\" class=\"black build\"></td></tr>"
	done < tmp/nginxlb
###NEW ENTRY
	echo "<form action=\"container-nginx-lb.cgi\" method=\"POST\">"
	echo "<tr><td class=\"label label3\"><input type=\"text\" class=\"textbox green\" name=\"URL\" value=\"\"></td>"
	echo "<td><select name=\"LSTNPORT\">"
	for PORT in $PORTS
	do
		echo "<option value=\"$PORT\">$PORT</option>"
 	done
	echo "<option selected value=\"\"></option>"
	echo "</select></td>"
	echo "</td><td class=\"label label3\"><input type=\"text\" class=\"textbox green\" name=\"LBNAME\" value=\"\"></td>"
	echo "<td><select name=\"ALGO\">"
	for KNOWNALGORITHM in least_conn ip_hash
	do
		echo "<option value=\"$KNOWNALGORITHM\">$KNOWNALGORITHM</option>"
 	done
	echo "<option selected value=\"\"></option>"
	echo "</select></td>"
	echo "<td><select name=\"HOST\">"
	for DESTOPTION in $UPHOSTS
	do
		echo "<option value=\"$DESTOPTION\">$DESTOPTION</option>"
	done
	echo "<option selected value=\"\"></option>"
	echo "</select></td>"
	echo "<td><select name=\"PORT\">"
	for PORT in $PORTS
	do
		echo "<option value=\"$PORT\">$PORT</option>"
	done
	echo "<option selected value=\"\"></option>"
 	echo "</select></td>"
	echo "<td class=\"label label5\"><input type=\"checkbox\" name=\"BACKUP\" value=\"Backup\" class=\"button yellow\"></td>"
 	echo "<td class=\"label label5\"><input type=\"text\" class=\"textbox green\" name=\"WEIGHT\" value=\"$WEIGHT\"></td>"
	echo "<td><input type=\"submit\" name=\"ACTION\" value=\"Add\" class=\"button green\"></td><td></td><td></td>"
	echo "</form></tr></table>"
else
	echo "<tr align=\"center\"><td class=\"label yellow\" colspan=\"6\">No containers running</td></tr></table>"
fi

cat base/footer

