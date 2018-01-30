#!/bin/bash

cat base/header
cat base/nav|sed "s/green build/yellow/g"
source source/functions.sh 
source source/filelist.sh
. tmp/globals
THISROOT=${SHAREDIR}
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
				if [[ "$SUBMITTEDPATH" == "$THISROOT" ]]
				then
					NEWPATH="${SUBMITTEDPATH}"
				else
					NEWPATH="$(echo ${SUBMITTEDPATH}|rev|cut -d "/" -f2-|rev)"
				fi
			else
				NEWPATH="${SUBMITTEDPATH}/${VALUE}"
			fi
			THISPATH="${NEWPATH}"
			[[ "${NEWPATH}" == "" ]] && NEWPATH=${THISROOT}
			echo "<p class=\"instruction\">Choose a routine to import</p>"
			echo "<form action=\"./container-custom.cgi\" method=\"POST\"><table>"
			echo "<input type=\"hidden\" name=\"path\" value=\"$NEWPATH\">"
			[[ "$NEWPATH" != "$THISROOT" ]] && echo "<tr><td><img src=\"/images/parent-folder.png\" alt=\"PARENT FOLDER\" class=\"filelistlogo\"><input type=\"submit\" name=\"dir\" value=\"..\" class=\"filelisting\"></td></tr>"
			list_all "$NEWPATH"
			echo "</table></form>"
		else
			. tmp/globals
			echo "<table align=\"center\"><tr>"
			echo "<td class=\"filelisting black\">Routine:</td>"
			echo "<td class=\"filelisting yellow\">$VALUE</td></tr>"
			echo "<form action=\"./terminal.cgi\" method=\"POST\">"
			echo "<tr><td class=\"filelisting yellow\">Namespace</td><td><select name=\"namespace\">"
			DEFINSTANCE=$(docker exec $RTNCONTAINER ccontrol list|grep "(default)"|cut -d "'" -f2)
			for NS in $(docker exec $RTNCONTAINER /bin/sh -c "echo -e \"_SYSTEM\nj2andUtoo\nD ##class(%SYS.Namespace).ListAll(.result) zw result\nh\n\"|csession ${DEFINSTANCE}|grep result|grep -Fv "^"|cut -d \"\\\"\" -f2")
			do
				echo "<option value=\"$NS\">$NS</option>"
			done
			echo "</select></td></tr>"
			#CACHEROUTINE=$VALUE
			#CACHEROUTINEDIR=$(echo $CURRENTPATH|cut -d "=" -f2|sed "s/%2F/\//g")
			#write_global CACHEROUTINE
			#write_global CACHEROUTINEDIR
			echo "<td><input type=\"submit\" name=\"CACHERTN\" value=\"Install\" class=\"button black\"></td>"		
			echo "<input type=\"hidden\" name=\"path\" value=\"$SUBMITTEDPATH\">"
			echo "<input type=\"hidden\" name=\"file\" value=\"$VALUE\">"
			echo "</form>"
			echo "<td><form action=\"./container-custom.cgi\" method=\"GET\">"
			echo "<input type=\"submit\" value=\"Cancel\" class=\"button gray\"></form></td></tr>"
		fi
        ;;
	*)
		echo "<p class=\"instruction\">Choose a routine to import</p>"
		echo "<form action=\"./container-custom.cgi\" method=\"POST\"><table>"
		echo "<input type=\"hidden\" name=\"path\" value=\"$THISROOT\">"
		list_all "${THISROOT}"
		echo "</table></form>"
esac
cat base/footer
