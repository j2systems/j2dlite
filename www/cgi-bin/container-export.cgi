#!/bin/bash

cat base/header
cat base/nav|sed "s/green build/yellow/g"
source source/functions.sh 
source source/filelist.sh
. tmp/globals
THISROOT=$SHAREDIR
case "${REQUEST_METHOD}" in
	"POST")
		read INSTRUCTION
		#echo $INSTRUCTION
		if [[ $(echo $INSTRUCTION|grep -c "EXPORT") -eq 1 || $(echo $INSTRUCTION|grep -c "SAVE") -eq 1 ]] 
		then
			#instigated from containers page
			EXPORTCONTAINER=$(echo $INSTRUCTION|cut -d "=" -f2)
			write_global EXPORTCONTAINER
			NEWPATH=$THISROOT
		else
			. tmp/globals
			#self instigated
			NEWDIR=$(echo $INSTRUCTION|cut -d "&" -f2|cut -d "=" -f2)
			SUBMITTEDPATH=$(echo $INSTRUCTION|cut -d "&" -f1|cut -d "=" -f2|sed "s,%2F,/,g")
			#echo $INSTRUCTION ND $NEWDIR,SUB $SUBMITTEDPATH
			if [[ "$NEWDIR" == ".." ]]
			then
				if [[ "$SUBMITTEDPATH" == "$THISROOT" ]]
					then
						NEWPATH=$(echo $SUBMITTEDPATH)
					else
						NEWPATH=$(echo $SUBMITTEDPATH|rev|cut -d "/" -f2-|rev)
					fi
			else
				NEWPATH=$SUBMITTEDPATH/$NEWDIR
			fi
			[[ "$NEWPATH" == "" ]] && NEWPATH=$THISROOT
		fi
		echo "<table align=\"center\"><tr>"
		echo "<td class=\"button black\">Container:</td>"
		echo "<td class=\"dirlisting yellow\">$EXPORTCONTAINER</td></tr>"
		echo "<td class=\"button black\">Directory:</td>"
		echo "<td class=\"dirlisting yellow\">$NEWPATH</td></tr><tr>"
		echo "</table>"
		echo "<table align=\"center\"><tr>"
  		echo "<td><form action=\"terminal.cgi\" method=\"POST\">"
		echo "<input type=\"hidden\" name=\"PATH\" value=\"$NEWPATH\">"
		echo "<input type=\"hidden\" name=\"CONTAINER\" value=\"$EXPORTCONTAINER\">"
		echo "<input type=\"submit\" name=\"EXPORT\" value=\"Export\" class=\"button black\"></form></td>"
		echo "<td><form action=\"terminal.cgi\" method=\"POST\">"
		echo "<input type=\"hidden\" name=\"PATH\" value=\"$NEWPATH\">"
		echo "<input type=\"hidden\" name=\"CONTAINER\" value=\"$EXPORTCONTAINER\">"
		echo "<input type=\"submit\" name=\"SAVE\" value=\"Save\" class=\"button black\"></form></td>"
                echo "</tr></table>"
		echo "<table align=\"center\">"
		echo "<tr class=\"information light\"><td>Select directory below.</td></tr></table>"
		echo "<table align=\"center\">"
		echo "<form action=\"./container-export.cgi\" method=\"POST\">"
		echo "<input type=\"hidden\" name=\"path\" value=\"$NEWPATH\">"
		[[ "$NEWPATH" != "$THISROOT" ]] && echo "<tr><td><img src=\"/images/parent-folder.png\" alt=\"PARENT FOLDER\" class=\"filelistlogo\"><input type=\"submit\" name=\"dir\" value=\"..\" class=\"filelisting\"></td></tr>"
		dir_list2 $NEWPATH
		echo "</table></form>"
        ;;

esac
cat base/footer
