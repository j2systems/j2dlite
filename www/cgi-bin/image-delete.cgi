#!/bin/bash
. bin/image_array.sh
cat base/header 
cat base/nav|sed "s/yellow screen2/green/g"

echo "<table align=\"center\"><tr><td colspan=\"2\" align=\"center\" class=\"p\">Delete Image(s).</td></tr><tr></tr>"
echo "<tr><th>Repository:Tag</th><th></th></tr>"

echo "<form action="./terminal.cgi" method=\"POST\">"
while read REP TAG LOCATION ID SIZE
do
	[[ "$REP" == "<none>" ]] && REP=$ID
	[[ "$TAG" == "<none>" ]] && TAG=""
	LABEL=$(echo $REP|sed "s,/,_FSLASH_,g")
	echo "<tr>"
  	if [[ "$LOCATION" == "LOCAL" ]]
	then
		echo "<td class=\"labelother yellow\">$REP:$TAG</td>"
		echo "<td><form action="./terminal.cgi" method=\"POST\">"
		echo "<input type=\"hidden\" name=\"IMAGE\" value=\"${ID}\">"
		echo "<input type=\"submit\" name=\"RMI\" value=\"Delete\" class=\"button red\">"
		echo "</form></td></tr>"
	fi
done < tmp/images

echo "<table width=\"100%\">"
echo "<tr><td width=\"100%\" height=\"3px\" class="yellow"></td></tr>"
echo "</table>"

cat base/footer
