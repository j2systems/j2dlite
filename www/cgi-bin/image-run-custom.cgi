#!/bin/bash
. bin/image_array.sh
cat base/header 
cat base/nav|sed "s/yellow screen2/green/g"


echo "<table align=\"center\" width=\"100%\"><tr><td colspan=\"5\" align=\"center\" class=\"p\">Run Image with custom startup.</td></tr><tr></tr>"
echo "<tr><th>Repository</th><th>Tag</th><th>(Location)</th><th>Enter name here:</th><th>add extra parameters</th><th>Startup command:</th></tr>"

while read REP TAG LOCATION ID SIZE
do
	[[ "$REP" == "<none>" ]] && REP=$ID
	[[ "$TAG" == "<none>" ]] && TAG=""
	LABEL=$(echo $REP|sed "s,/,_FSLASH_,g")
	echo "<tr>"
  	if [[ "$LOCATION" == "LOCAL" ]]
	then
		echo "<td class=\"label label4 lighttext green\">$REP</td>"
		echo "<td class=\"label label4 lighttext green\">$TAG</td>"
		echo "<td class=\"label label2 lighttext green\">$LOCATION</td>"
		ENTRYPOINT=$(docker inspect --format='{{json .Config.Entrypoint}}' $ID|tr -d " []\"")
		[[ "$ENTRYPOINT" == "null" ]] && ENTRYPOINT=""
	else
		echo "<td class=\"label label4 yellow\">$REP</td>"
		echo "<td class=\"label label4 yellow\">$TAG</td>"
		echo "<td class=\"label label2 yellow\">$LOCATION</td>"
	fi
	echo "<form action="./terminal.cgi" method=\"POST\">"
	echo "<td class=\"label label3 green\"><input type="text" name="${LABEL}_COLON_${TAG}" class=\"textbox green\"></td>"
	echo "<td class=\"label labelrest green\"><input type="text" name="${LABEL}_COLON_${TAG}_CUSTOM" class=\"textbox green\"></td>"
	echo "<td class=\"label label3 green\"><input type="text" name="${LABEL}_COLON_${TAG}_ENTRY" class=\"textbox green\" value=\"$ENTRYPOINT\"></td>"
	echo "<td class=\"label\"><input type=\"submit\" name=\"RUNCUSTOM\" value=\"Run\" class=\"button black\"\"></td>"
	echo "</form></tr>"
done < tmp/images
echo "<table width=\"100%\">"

echo "<tr><td width=\"100%\" height=\"3px\" class="yellow"></td></tr>"
echo "</table>"

cat base/footer
