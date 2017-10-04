#!/bin/bash
source source/functions.sh
. source/client.sh
if [[ "$REQUEST_METHOD" == "POST" ]]
then
	read INPUT
	SEARCHFOR=$(echo $INPUT|cut -d "=" -f2)
fi



cat base/header 
cat base/nav|sed "s/green build/yellow/g"
#echo $INPUT
echo "<table align=\"center\"><tr><td class=\"p\" colspan=\"3\">Search for an image</td></tr>"
echo "<tr></tr>"

#search box
echo "<table align=\"center\"><tr>"
echo "<td class=\"filelisting black\">Search for:</td>"
echo "<td class=\"filelisting green\">"
echo "<form action=\"./image-search.cgi\" method=\"POST\"><input type=\"text\" name=\"SEARCH\" class=\"textbox green\"></td>"
echo "<td><input type=\"submit\" value=\"Search\" class=\"button black\"></td></form>"
echo "<tr></tr>"
echo "</table>"


#search results
echo "<table align=\"center\">"
if [[ "$SEARCHFOR" != "" ]]
then
	while IFS= read N
	do
		SOURCE=$(echo $N|cut -d " " -f1)
		REMAINDER=$(echo $N|cut -d " " -f2-|rev)
		AUTOMATED=$(echo $REMAINDER|cut -d " " -f1|rev)
		OFFICIAL=""
		STARS=$(echo $REMAINDER|cut -d " " -f2|rev)
		DESC=$(echo $REMAINDER|cut -d " " -f3-|rev)
		#first row is column headings so echo in yellow
		if [[ "$TITLE" == "" ]]
		then
			echo "<tr class=\"filelisting yellow\">"
			echo "<td>SOURCE</td><td>DESC</td><td>STARS</td><td>AUTOMATED</td></tr>"
			TITLE=true
		else
			echo "<tr class=\"searchlisting light\">"
			echo "<td>$SOURCE</td><td>$DESC</td><td>$STARS</td><td>$AUTOMATED</td>"
			echo "<td><form action="./terminal.cgi" method=\"POST\">"
			echo "<input type=\"hidden\" name=\"IMAGE\" value=\"$SOURCE\">"
			echo "<input type=\"submit\" name=\"PULL\" value=\"Get\" class=\"button green\">"
			echo "</form></td><td><input type=\"button\" value=\"Info\" class=\"button black\" onclick=\"window.open('https://hub.docker.com/r/$SOURCE','_blank');\"></td></tr>"
		fi	
	done< <(docker search --limit 20 --no-trunc $SEARCHFOR)
fi

echo "</table>"

cat base/footer
