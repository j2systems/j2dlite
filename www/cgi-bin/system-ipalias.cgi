#!/bin/bash
source source/functions.sh
. tmp/globals
cat base/header 
cat base/nav|sed "s/screen4/green/g"
cat base/advanced|sed "s/yellow ipalias/green/g"
case "${REQUEST_METHOD}" in
        "POST")
		read ACTION
		echo $ACTION
		DOTHIS=$(echo ${ACTION}|cut -d "&" -f3|cut -d "=" -f1)
		echo ${DOTHIS}
		URL=$(echo ${ACTION}|cut -d "&" -f1|cut -d "=" -f2)
		TOSERVER=$(echo ${ACTION}|cut -d "&" -f2|cut -d "=" -f2)
		case ${DOTHIS} in
			"DELETE")
#				OLDURL=$(echo $ACTION|cut -d "&" -f6|cut -d "=" -f2)
#                		OLDNGINXTO=$(echo $ACTION|cut -d "&" -f7|cut -d "=" -f2)
#                		OLDPORTFROM=$(echo $ACTION|cut -d "&" -f8|cut -d "=" -f2)
                		OLDPORTTO=$(echo $ACTION|cut -d "&" -f9|cut -d "=" -f2)
	#			sed -i "/${OLDNGINXTO} ${OLDURL}.${FQDN} ${OLDPORTFROM} ${OLDPORTTO}/d" tmp/nginx
		#		sort -k 2,2 -o tmp/nginx tmp/nginx
			#	echo "nginx.sh" > tmp/trigger
				;;
			"AMEND")
				OLDURL=$(echo $ACTION|cut -d "&" -f6|cut -d "=" -f2)
#                		OLDNGINXTO=$(echo $ACTION|cut -d "&" -f7|cut -d "=" -f2)
 #               		OLDPORTFROM=$(echo $ACTION|cut -d "&" -f8|cut -d "=" -f2)
	#			sed -i "/$OLDNGINXTO ${OLDURL}.${FQDN} ${OLDPORTFROM} ${OLDPORTTO}/d" tmp/nginx
		#		echo ${NGINXTO} ${URL}.${FQDN} ${PORTFROM} ${PORTTO} >> tmp/nginx
			#	sort -k 2,2 -o tmp/nginx tmp/nginx
			#	echo "nginx.sh" > tmp/trigger
				;;
			"ADD")
				echo "ADD.......${URL} ${TOSERVER} $(grep -c -e "^${URL} " ${SYTEMPATH}/ip_aliases)"
				[[ "${URL}" != "" ]] && [[ $(grep -c -e "^${URL} " ${SYSTEMPATH}/ip_aliases) -eq 0 ]] && echo "${URL} ${TOSERVER}" >> ${SYSTEMPATH}/ip_aliases
				sort -k 2,2 -o ${SYSTEMPATH}/ip_aliases ${SYSTEMPATH}/ip_aliases
	#			echo "mcclientupdate.sh" > tmp/trigger
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
echo "<tr align=\"center\"><td class=\"label black\" colspan=\"6\">Manage ip aliases</td></tr>"

CONTAINERUP=false
while read NAME IMAGE STATUS
do
	if [[ $(echo $STATUS|grep -c -e "^Up") -eq 1 ]]
	then
		CONTAINERUP=true
		break
	fi
done < tmp/containers

if [[ "${CONTAINERUP}" == "true" ]]
then

	echo "<td class=\"label label3\">URL</td><td class=\"label label3\">To</td>"
	while read URL TOSERVER
	do
		CONTAINERREF=false
		echo "<form action=\"system-ipalias.cgi\" method=\"POST\">"
		echo "<tr><td class=\"label label3\"><input type=\"text\" class=\"textbox green\" name=\"URL\" value=\"${URL}\"></td>"
		echo "<td><select name=\"TOSERVER\" class=\"label yebel2 yellow\">"
		while read NAME IMAGE STATUS
		do
			if [[ $(echo $STATUS|grep -c -e "^Up") -eq 1 ]]
			then
				if [[ "${NAME}" == "${TOSERVER}" ]]
				then
					CONTAINERREF=true
					echo "<option selected value=\"${NAME}\">${NAME}</option>"
				else
					echo "<option value=\"${NAME}\">${NAME}</option>"
				fi
			fi
		done < tmp/containers
		if [[ "${CONTAINERREF}" == "false" ]] 
		then
			echo "<option selected value=\"${TOSERVER}\">${TOSERVER}</option></select><td class=\"label yellow\">OFFLINE</td>"
		else
			echo "</select><td class=\"label green\">ONLINE</td>"
		fi
		echo "<td><input type=\"submit\" name=\"AMEND\" value=\"Amend\" class=\"button yellow\"></td>"
		echo "<td><input type=\"submit\" name=\"DELETE\" value=\"Delete\" class=\"button red\"></td></tr>"
		echo "<input type=\"hidden\" name=\"OLDURL\" value=\"$URL\"></form>"
	done < ${SYSTEMPATH}/ip_aliases
	echo "<form action=\"system-ipalias.cgi\" method=\"POST\">"
	echo "<tr><td class=\"label label3\"><input type=\"text\" class=\"textbox yellow\" name=\"URL\"></td>"
	echo "<td><select name=\"TOSERVER\" class=\"label yebel2 yellow\">"
	while read NAME IMAGE STATUS                                                                                                             
	do                                                                                                                                       
		if [[ $(echo $STATUS|grep -c -e "^Up") -eq 1 ]]                                                                                  
		then                                                                        
			echo "<option value=\"${NAME}\">${NAME}</option>"
		fi                                                                                                                       
	done < tmp/containers
	echo "</select></td>"

	echo "<td><input type=\"submit\" name=\"ADD\" value=\"Add\" class=\"button green\"></td></tr>"
	echo "</form></table>"
else
	echo "<tr align=\"center\"><td class=\"label yellow\" colspan=\"6\">No containers running</td></tr></table>"
fi
cat base/footer



