#!/bin/bash
# source functions

source source/functions.sh

. /tmp/globals
delete_global MANAGEMENTHOSTS
delete_global CONTAINERS
delete_global NEWCONTAINERS

# check routing tables!

#display page
cat base/header
if [[ "$REQUEST_METHOD" != "POST" ]]
then
	echo "no data post. Need referrel back to cgi"
	exit
fi
MODE=unknown
read DETAIL
#echo $DETAIL
[[ $(echo $DETAIL|grep -c "ADDCLIENT=") -eq 1 ]] && MODE="ADDCLIENT"
[[ $(echo $DETAIL|grep -c "BUILD=") -eq 1 ]] && MODE="BUILD"
[[ $(echo $DETAIL|grep -c "IMPORT=") -eq 1 ]] && MODE="IMPORT"
[[ $(echo $DETAIL|grep -c "RUN=") -eq 1 ]] && MODE="RUN"
[[ $(echo $DETAIL|grep -c "RUNCUSTOM=") -eq 1 ]] && MODE="RUNCUSTOM"
[[ $(echo $DETAIL|grep -c "LOAD=") -eq 1 ]] && MODE="LOAD"
[[ $(echo $DETAIL|grep -c "EXPORT=") -eq 1 ]] && MODE="EXPORT"
[[ $(echo $DETAIL|grep -c "SAVE=") -eq 1 ]] && MODE="SAVE"
[[ $(echo $DETAIL|grep -c "PULL=") -eq 1 ]] && MODE="PULL"
[[ $(echo $DETAIL|grep -c "RMI=") -eq 1 ]] && MODE="RMI"
[[ $(echo $DETAIL|grep -c "CACHEINST=") -eq 1 ]] && MODE="CACHEINST"
[[ $(echo $DETAIL|grep -c "CACHERTN=") -eq 1 ]] && MODE="CACHERTN"
[[ $(echo $DETAIL|grep -c "TERMINAL=") -eq 1 ]] && MODE="TERMINAL"
if [[ "$MODE" != "unknown" ]]
then
		echo "<table width=\"100%\"  align=\"center\">"
		echo "<tr></tr><tr><td class=\"information\">\"$MODE\" has been initiated.</td></tr></table>"
		if [[ "$MODE" != "TERMINAL" ]]
		then
			echo "<table width=\"100%\"  align=\"center\">"
			echo "<tr></tr><tr><td class=\"information\">The button below will go green when the task has completed.</td></tr>"
			echo "<tr></tr><tr><td class=\"information\">Closing this window will terminate the process.</td></tr></table>"
		else
			echo "<table align=\"center\"><tr id=\"dockerterm\"></tr></table>"
		fi
		echo "</table>"
		echo "<table><tr></tr><tr><td class=\"information blue\"></td></tr></table>"
fi
RETURNURL="summary.cgi"
case "$MODE" in
	"ADDCLIENT")
		STUDIO=false
		ATELIER=false
		USERNAME=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2)
		PASSWORD=$(echo $DETAIL|cut -d "&" -f2|cut -d "=" -f2)
		CLIENTTYPE=$(echo $DETAIL|cut -d "&" -f3|cut -d "=" -f2)
		[[ $(echo $DETAIL|grep -c "STUDIO=") -eq 1 ]] && STUDIO=true
		[[ $(echo $DETAIL|grep -c "ATELIER=") -eq 1 ]] && ATELIER=true
		OPERATION="interact=mclientsetup.sh,${USERNAME},${PASSWORD},${CLIENTTYPE},${REMOTE_ADDR},${STUDIO},${ATELIER}"
		;;
	"BUILD")
		BUILDNAME=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2)
		[[ "$BUILDNAME" == "" ]] && BUILDNAME="j2docker"
		BUILDPATH=$(echo $DETAIL|cut -d "&" -f2|cut -d "=" -f2|sed "s,%2F,/,g")
		BUILDFILE=$(echo $DETAIL|cut -d "&" -f3|cut -d "=" -f2)
		OPERATION="interact=dockerbuild.sh,${BUILDNAME},${BUILDPATH},${BUILDFILE}"
		RETURNURL="image-run.cgi"
		;;
 	"IMPORT")
                INFO=$(echo $DETAIL|cut -d "&" -f2-)
                IMPORTPATH=$(echo $INFO|cut -d "&" -f1|cut -d "=" -f2|sed "s,%2F,/,g")
                IMPORTFILE=$(echo $INFO|cut -d "&" -f2|cut -d "=" -f2)
                IMPORTNAME=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2)
		OPERATION="interact=dockerimport.sh,${IMPORTNAME},${IMPORTPATH},${IMPORTFILE}"
		RETURNURL="image-run.cgi"
		;;
 	"LOAD")
                INFO=$(echo $DETAIL|cut -d "&" -f2-)
                LOADPATH=$(echo $INFO|cut -d "&" -f1|cut -d "=" -f2|sed "s,%2F,/,g")
                LOADFILE=$(echo $INFO|cut -d "&" -f2|cut -d "=" -f2)
		OPERATION="interact=dockerload.sh,${LOADPATH},${LOADFILE}"
		RETURNURL="image-run.cgi"
		;;
 	"CACHEINST")
                INSTALLCONTAINER=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2)
                INSTALLPATH=$(echo $DETAIL|cut -d "&" -f3|cut -d "=" -f2|sed "s,%2F,/,g")
                INSTALLFILE=$(echo $DETAIL|cut -d "&" -f4|cut -d "=" -f2)
		OPERATION="interact=cacheinstaller.sh,${INSTALLCONTAINER},${INSTALLPATH},${INSTALLFILE}"
		RETURNURL="container-control.cgi"
		;;
	 "CACHERTN")
                CACHENAMESPACE=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2|sed "s/%25/%/g")
                CACHEROUTINEPATH=$(echo $DETAIL|cut -d "&" -f3|cut -d "=" -f2|sed "s,%2F,/,g")
                CACHEROUTINEFILE=$(echo $DETAIL|cut -d "&" -f4|cut -d "=" -f2)
		OPERATION="interact=dockercacheimport.sh,${CACHENAMESPACE},${CACHEROUTINEPATH},${CACHEROUTINEFILE}"
		RETURNURL="container-control.cgi"
		;;
	"RUN")
		echo $DETAIL>tmp/run
		OPERATION="interact=dockerrun.sh,"
		RETURNURL="container-control.cgi"
        	;;
	"RUNCUSTOM")
		echo $DETAIL>tmp/run
		OPERATION="interact=dockerruncustom.sh,"
		RETURNURL="container-control.cgi"
        	;;
	"SAVE")
                SAVEPATH=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2|sed "s,%2F,/,g")
		SAVECONTAINER=$(echo $DETAIL|cut -d "&" -f2|cut -d "=" -f2)
		OPERATION="interact=dockersave.sh,${SAVEPATH},${SAVECONTAINER}"
		RETURNURL="container-control.cgi"
	 	;;
	"PULL")
		PULLIMAGE=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2|sed "s,%2F,/,g")
		OPERATION="interact=dockerpull.sh,${PULLIMAGE}"
		RETURNURL="image-run.cgi"
	 	;;
	"RMI")
		RMIIMAGE=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2-)
		OPERATION="interact=dockerrmi.sh,${RMIIMAGE}"
		RETURNURL="image-delete.cgi"
	 	;;
	"TERMINAL")
		RETURNURL="system.cgi"
	;;
	*)
		echo "Need to handle $DETAIL"
	;;
esac
echo "<input type=\"hidden\" id=\"operation\" value=\"${OPERATION}\">" 
if [[ "$MODE" == "TERMINAL" ]]
then
	echo "<script src="/scripts/ws-console.js"></script>" 
	cat base/termclose
else
	cat base/ws-terminal
	cat base/close|sed "s/summary.cgi/$RETURNURL/g"
fi
cat base/footer		

