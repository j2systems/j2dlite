#!/bin/bash

cat base/header
cat base/nav|sed "s/green build/yellow/g"
source source/functions.sh 2>&1
source source/filelist.sh 2>&1
. tmp/globals
THISROOT=$SHAREDIR
case "${REQUEST_METHOD}" in
	"POST")
		read INSTRUCTION
		CURRENTPATH=$(echo $INSTRUCTION|cut -d "&" -f1)
		INFO=$(echo $INSTRUCTION|cut -d "&" -f2)
		TYPE=$(echo $INFO|cut -d "=" -f1)
		VALUE=$(echo $INFO|cut -d "=" -f2)
		SUBMITTEDPATH=$(echo $CURRENTPATH|cut -d "=" -f2|sed "s,%2F,/,g")
		#echo CP $CURRENTPATH,INF $INFO,TY $TYPE,VAL $VALUE,SUB $SUBMITTEDPATH
		if [[ "$TYPE" == "dir" ]]
			then
			if [[ "$VALUE" == ".." ]]
			then
				if [[ "$SUBMITTEDPATH" == "$THISROOT" ]]
				then
					NEWPATH=$(echo $SUBMITTEDPATH)
				else
					NEWPATH=$(echo $SUBMITTEDPATH|rev|cut -d "/" -f2-|rev)
				fi
			else
				NEWPATH=$SUBMITTEDPATH/$VALUE
			fi
			THISPATH=$NEWPATH
			[[ "$NEWPATH" == "" ]] && NEWPATH=$THISROOT
			echo "<p class=\"instruction\">Choose software</p>"
			echo "<form action=\"./image-build.cgi\" method=\"POST\"><table>"
			echo "<input type=\"hidden\" name=\"path\" value=\"$NEWPATH\">"
			[[ "$NEWPATH" != "$THISROOT" ]] && echo "<tr><td><img src=\"/images/parent-folder.png\" alt=\"PARENT FOLDER\" class=\"filelistlogo\"><input type=\"submit\" name=\"dir\" value=\"..\" class=\"filelisting\"></td></tr>"
			list_all $NEWPATH
			echo "</table></form>"
		else
			echo "<table align=\"center\"><tr>"
			echo "<td class=\"button black\">File:</td>"
			echo "<td class=\"filelisting yellow\">$VALUE</td></tr>"
			echo "<td class=\"button black\">Name:</td>"
			echo "<form action=\"./terminal.cgi\" method=\"POST\">"
			echo "<td class=\"filelisting yellow\"><input type=\"text\" name=\"NEWCONTAINER\" class=\"textbox yellow\" value=\"$(echo $VALUE|cut -d "-" -f2)\"></td></tr></table>"
			echo "<table align=\"center\">"
			echo "<input type=\"hidden\" name=\"path\" value=\"$SUBMITTEDPATH\">"
			echo "<input type=\"hidden\" name=\"file\" value=\"$VALUE\">"
			echo "<tr><td></td>"
			echo "<td><input type=\"submit\" name=\"BUILD\" value=\"Build\" class=\"button black\"></td>"
			echo "<td><input type=\"submit\" name=\"IMPORT\" value=\"Import\" class=\"button black\"></td>"
			echo "<td><input type=\"submit\" name=\"LOAD\" value=\"Load\" class=\"button black\"></td>"		
			echo "</form>"
			echo "<td><form action=\"./image-build.cgi\" method=\"GET\">"
			echo "<input type=\"submit\" value=\"Cancel\" class=\"button gray\"></form></td></tr>"
		fi
        ;;
	*)
		echo "<p class=\"instruction\">Choose a file to build or import</p>"
		echo "<form action=\"./image-build.cgi\" method=\"POST\"><table>"
		echo "<input type=\"hidden\" name=\"path\" value=\"$THISROOT\">"
		list_all $THISROOT
		echo "</table></form>"
esac
cat base/footer
