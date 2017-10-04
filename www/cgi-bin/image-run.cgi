#!/bin/bash
. bin/image_array.sh
cat base/header 
cat base/nav|sed "s/yellow screen2/green/g"


echo "<table align=\"center\" width=\"100%\"><tr><td colspan=\"4\" align=\"center\" class=\"p\">Run Image(s) to create running containers.</td></tr><tr></tr>"
echo "<tr><th>Repository</th><th>Tag</th><th>(Location)</th><th>Enter names here</th></tr>"
echo "<form action="./terminal.cgi" method=\"POST\">"
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
		echo "<td class=\"label label3 lighttext green\">$LOCATION</td>"
	else
		echo "<td class=\"label label4 yellow\">$REP</td>"
		echo "<td class=\"label label4 yellow\">$TAG</td>"
		echo "<td class=\"label label3 yellow\">$LOCATION</td>"
	fi
	echo "<td class=\"label labelrest green\"><input type="text" name="${LABEL}_COLON_${TAG}" class=\"textbox green\"></td>"
	echo "</tr>"
done < tmp/images
echo "<tr><td align=\"right\" colspan=\"4\"><input type=\"submit\" name=\"RUN\" value=\"Run\" class=\"button black\"\"></td></tr></table></form>"
echo "<table width=\"100%\">"
echo "<tr><td width="100%" height="3px" class="green"></td></tr>"
echo "<table width=\"100%\">"
echo "<tr><td class=\"slabel label4 gray\">Other Image options:</td>"
echo "<td>"
echo "<input type=\"button\" class=\"button yellow\" onclick=\"location.href='/cgi-bin/image-build.cgi';\" value="Build">"
echo "<input type=\"button\" class=\"button yellow\" onclick=\"location.href='/cgi-bin/image-build.cgi';\" value="Import">"
echo "<input type=\"button\" class=\"button yellow\" onclick=\"location.href='/cgi-bin/image-build.cgi';\" value="Load">"
echo "<input type=\"button\" class=\"button yellow\" onclick=\"location.href='/cgi-bin/image-search.cgi';\" value="Search">"
echo "<input type=\"button\" class=\"button yellow\" onclick=\"location.href='/cgi-bin/image-run-custom.cgi';\" value="Advanced">"
echo "<input type=\"button\" class=\"button red\" onclick=\"location.href='/cgi-bin/image-delete.cgi';\" value="Delete">"
echo "</td></tr></table>"
echo "<table width=\"100%\">"
echo "<tr><td width=\"100%\" height=\"3px\" class="yellow"></td></tr>"
echo "</table>"

cat base/footer
