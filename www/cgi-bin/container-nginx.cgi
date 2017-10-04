#!/bin/bash
source source/functions.sh
. tmp/globals
cat base/header 
cat base/nav|sed "s/screen4/green/g"
cat base/advanced|sed "s/yellow nginx/green/g"
FQDN=$(hostname).lan
case "${REQUEST_METHOD}" in
        "POST")
		read ACTION
		#echo $ACTION
		DOTHIS=$(echo $ACTION|cut -d "&" -f5|cut -d "=" -f1)
		URL=$(echo $ACTION|cut -d "&" -f1|cut -d "=" -f2)
		NGINXTO=$(echo $ACTION|cut -d "&" -f2|cut -d "=" -f2)
		PORTFROM=$(echo $ACTION|cut -d "&" -f3|cut -d "=" -f2)
		PORTTO=$(echo $ACTION|cut -d "&" -f4|cut -d "=" -f2)
		case $DOTHIS in
			"DELETE")
				OLDURL=$(echo $ACTION|cut -d "&" -f6|cut -d "=" -f2)
                		OLDNGINXTO=$(echo $ACTION|cut -d "&" -f7|cut -d "=" -f2)
                		OLDPORTFROM=$(echo $ACTION|cut -d "&" -f8|cut -d "=" -f2)
                		OLDPORTTO=$(echo $ACTION|cut -d "&" -f9|cut -d "=" -f2)
				sed -i "/${OLDNGINXTO} ${OLDURL}.${FQDN} ${OLDPORTFROM} ${OLDPORTTO}/d" tmp/nginx
				sort -k 2,2 -o tmp/nginx tmp/nginx
				echo "nginx.sh" > tmp/trigger
				;;
			"AMEND")
				OLDURL=$(echo $ACTION|cut -d "&" -f6|cut -d "=" -f2)
                		OLDNGINXTO=$(echo $ACTION|cut -d "&" -f7|cut -d "=" -f2)
                		OLDPORTFROM=$(echo $ACTION|cut -d "&" -f8|cut -d "=" -f2)
				sed -i "/$OLDNGINXTO ${OLDURL}.${FQDN} ${OLDPORTFROM} ${OLDPORTTO}/d" tmp/nginx
				echo ${NGINXTO} ${URL}.${FQDN} ${PORTFROM} ${PORTTO} >> tmp/nginx
				sort -k 2,2 -o tmp/nginx tmp/nginx
				echo "nginx.sh" > tmp/trigger
				;;
			"ADD")
				[[ "$URL" != "" ]] && echo ${NGINXTO} ${URL}.${FQDN} ${PORTFROM} ${PORTTO} >> tmp/nginx
				sort -k 2,2 -o tmp/nginx tmp/nginx
				echo "nginx.sh" > tmp/trigger
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
echo "<tr align=\"center\"><td class=\"label black\" colspan=\"6\">Manage nginx proxy-forwarding</td></tr>"

LISTED=false
while read NAME IMAGE STATUS
do
	if [[ $(echo $STATUS|grep -c -e "^Up") -eq 1 ]]
	then
		LISTED=true
		break
	fi
done < tmp/containers

if [[ "$LISTED" == "true" ]]
then

	echo "<td class=\"label label3\">URL</td><td></td><td class=\"label label2\">To</td><td class=\"label label2\">Port From</td><td class=\"label label2\">Port To</td></tr>"
	while read NGINXTO URL PORTFROM PORTTO
	do
		CONTAINERREF=false
		echo "<form action=\"container-nginx.cgi\" method=\"POST\">"
		URL=$(echo $URL|sed "s/.${FQDN}//g")
		echo "<tr><td class=\"label label3\"><input type=\"text\" class=\"textbox green\" name=\"URL\" value=\"$URL\"></td>"
		echo "</td><td class=\"label label3\"><input type=\"text\" class=\"textbox green\" value=\".${FQDN}\" disabled></td>"
		echo "<td><select name=\"NGINXTO\" class=\"label yebel2 yellow\">"
		while read NAME IMAGE STATUS
		do
			if [[ $(echo $STATUS|grep -c -e "^Up") -eq 1 ]]
			then
				if [[ "$NAME" == "$NGINXTO" ]]
				then
					CONTAINERREF=true
					echo "<option selected value=\"$NAME\">$NAME</option>"
				else
					echo "<option value=\"$NAME\">$NAME</option>"
				fi
			fi
		done < tmp/containers
		[[ "$CONTAINERREF" == "false" ]] && echo "<option class=\"red\" selected value=\"$NGINXTO\">$NGINXTO</option>"
		echo "</select></td>"
		. tmp/globals
		CONTAINERREF=false
		echo "<td class=\"label label2\"><select name=\"PORTFROM\" class=\"label yebel2 yellow\">"
		for PORT in $PORTS
		do
			if [[ "$PORT" == "$PORTFROM" ]]
			then
				CONTAINERREF=true
				echo "<option selected value=\"$PORT\">$PORT</option>"
			else
				echo "<option value=\"$PORT\">$PORT</option>"
			fi
        	done
		[[ "$CONTAINERREF" == "false" ]] && echo "<option selected value=\"$PORTFROM\">$PORTFROM</option>"
		echo "</select></td>"
		echo "<td class=\"label label2\"><input type=\"text\" class=\"textbox green\" name=\"PORTTO\" value=\"$PORTTO\"></td>"
		echo "<td><input type=\"submit\" name=\"AMEND\" value=\"Amend\" class=\"button yellow\"></td>"
		echo "<td><input type=\"submit\" name=\"DELETE\" value=\"Delete\" class=\"button red\"></td></tr>"
		echo "<input type=\"hidden\" name=\"OLDURL\" value=\"$URL\">"
		echo "<input type=\"hidden\" name=\"OLDNGINXTO\" value=\"$NGINXTO\">"
		echo "<input type=\"hidden\" name=\"OLDPORTFROM\" value=\"$PORTFROM\">"
		echo "<input type=\"hidden\" name=\"OLDPORTTO\" value=\"$PORTTO\"></form>"

	done < tmp/nginx
	echo "<form action=\"container-nginx.cgi\" method=\"POST\">"
	echo "<tr><td class=\"label label3\"><input type=\"text\" class=\"textbox yellow\" name=\"URL\"></td><td class=\"label label3\"><input type=\"text\" class=\"textbox yellow\" value=\".${FQDN}\" disabled></td>"
	echo "<td><select name=\"NGINXTO\" class=\"label yebel2 yellow\">"
	while read NAME IMAGE STATUS
	do
		if [[ $(echo $STATUS|grep -c -e "^Up") -eq 1 ]]
		then
			echo "<option value=\"$NAME\">$NAME</option>"
		fi
	done < tmp/containers
	echo "</select></td>"
	echo "<td class=\"label label2\"><select name=\"PORTFROM\" class=\"label yebel2 yellow\">"
		for PORT in $PORTS
		do
	               echo "<option value=\"$PORT\">$PORT</option>"
	        done
	echo "</select></td>"
	echo "<td class=\"label label2\"><input type=\"text\" class=\"textbox yellow\" name=\"PORTTO\" value=\"57772\"></td>"
	echo "<td><input type=\"submit\" name=\"ADD\" value=\"Add\" class=\"button green\"></td></tr>"
	echo "</form></table>"
else
	echo "<tr align=\"center\"><td class=\"label yellow\" colspan=\"6\">No containers running</td></tr></table>"
fi
cat base/footer



