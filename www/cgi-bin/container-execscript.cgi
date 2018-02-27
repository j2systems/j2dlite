#!/bin/bash

cat base/header
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
		VALUE=$(echo $INFO|cut -d "=" -f2|tr "+" " ")
		SUBMITTEDPATH=$(echo $CURRENTPATH|cut -d "=" -f2|sed "s,%2F,/,g")
		#echo CP $CURRENTPATH,INF $INFO,TY $TYPE,VAL $VALUE,SUB $SUBMITTEDPATH
		if [[ "$TYPE" == "dir" ]]
			then
			if [[ "$VALUE" == ".." ]]
			then
				if [[ "${SUBMITTEDPATH}" == "${THISROOT}" ]]
				then
					NEWPATH="${SUBMITTEDPATH}"
				else
					NEWPATH="$(echo ${SUBMITTEDPATH}|rev|cut -d "/" -f2-|rev)"
				fi
			else
				NEWPATH="${SUBMITTEDPATH}/${VALUE}"
			fi
			THISPATH="${NEWPATH}"
			[[ "$NEWPATH" == "" ]] && NEWPATH="${THISROOT}"
			echo "<p class=\"instruction\">Choose software</p>"
			echo "<form action=\"./container-execscript.cgi\" method=\"POST\"><table>"
			echo "<input type=\"hidden\" name=\"path\" value=\"$NEWPATH\">"
			[[ "$NEWPATH" != "$THISROOT" ]] && echo "<tr><td><img src=\"/images/parent-folder.png\" alt=\"PARENT FOLDER\" class=\"filelistlogo\"><input type=\"submit\" name=\"dir\" value=\"..\" class=\"filelisting\"></td></tr>"
			list_all "${NEWPATH}"
			echo "</table></form>"
		else
			cat base/nav|sed "s/screen3/green/g"
			echo "<table align=\"center\"><tr>"
			echo "<tr><td class=\"filelisting\">Execute script:</td></tr>"
			echo "<td class=\"filelisting black\"> Container: </td>"
			echo "<td class=\"filelisting yellow\"> ${SCRIPTCONTAINER}</td></tr>"
			echo "<tr><td class=\"filelisting black\">Exec Script:</td>"
			echo "<td class=\"filelisting yellow\">$VALUE</td></tr>"

			INSTALLERPATH=$SUBMITTEDPATH
			INSTALLER=$VALUE
			write_global INSTALLERPATH
			write_global INSTALLER
			 echo "<td><form action=\"./terminal.cgi\" method=\"POST\">"
			echo "<input type=\"submit\" name=\"EXECSCRIPT\" value=\"Run\" class=\"button green\"></form></td>"
			echo "<td><form action=\"./container-execscript.cgi\" method=\"GET\">"
			echo "<input type=\"submit\" value=\"Cancel\" class=\"button gray\"></form></td></tr></table>"
			
		fi
        ;;
	*)
		docker ps -a --format "{{.Names}} ({{.Image}}) {{.Status}}" > tmp/containers
		echo "<p class=\"instruction\">Choose a file to run as installer.</p>"
		echo "<form action=\"./container-execscript.cgi\" method=\"POST\"><table>"
		echo "<input type=\"hidden\" name=\"path\" value=\"$THISROOT\">"
		list_all "${THISROOT}"
		echo "</table></form>"
esac
cat base/footer
