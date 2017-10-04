#!/bin/bash
# source functions

source source/functions.sh 2>&1
source source/manage_hosts.sh 2>&1
source source/manage_registry.sh 2>&1
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
[[ $(echo $DETAIL|grep -c "TERMINAL=") -eq 1 ]] && MODE="TERMINAL" && echo "<script src="/scripts/wslite.js"></script>"
if [[ "$MODE" != "unknown" ]]
then
		echo "<table width=\"100%\"  align=\"center\">"
		echo "<tr></tr><tr><td class=\"information\">\"$MODE\" has been initiated.</td></tr></table>"
		if [[ "$MODE" != "TERMINAL" ]]
		then
			cat base/websocket
			echo "<table width=\"100%\"  align=\"center\">"
			echo "<tr></tr><tr><td class=\"information\">The button below will go green when the task has completed.</td></tr>"
			echo "<tr></tr><tr><td class=\"information\">Closing this window will terminate the process.</td></tr></table>"
		else
			echo "terminal.sh" > tmp/trigger
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
		[[ $(echo $DETAIL|grep -c "STUDIO=") -eq 1 ]] && STUDIO=true
		[[ $(echo $DETAIL|grep -c "ATELIER=") -eq 1 ]] && ATELIER=true
		HOSTIP=$(env|grep "REMOTE_ADDR"|cut -d "=" -f2)
		write_global USERNAME
		write_global PASSWORD
		write_global STUDIO
		write_global ATELIER
		write_global HOSTIP
		echo "mclientsetup.sh" > tmp/nag
	;;

	"BUILD")
		BUILDNAME=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2)
		[[ "$BUILDNAME" == "" ]] && BUILDNAME="j2docker"
		BUILDPATH=$(echo $DETAIL|cut -d "&" -f2|cut -d "=" -f2|sed "s,%2F,/,g")
		BUILDFILE=$(echo $DETAIL|cut -d "&" -f3|cut -d "=" -f2)
		write_global BUILDNAME
		write_global BUILDPATH
		write_global BUILDFILE
		RETURNURL="image-run.cgi"
		echo "dockerbuild.sh" > tmp/nag
	;;
 	"IMPORT")
                INFO=$(echo $DETAIL|cut -d "&" -f2-)
                IMPORTPATH=$(echo $INFO|cut -d "&" -f1|cut -d "=" -f2|sed "s,%2F,/,g")
                IMPORTFILE=$(echo $INFO|cut -d "&" -f2|cut -d "=" -f2)
                IMPORTNAME=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2)
		write_global IMPORTPATH
		write_global IMPORTFILE
		write_global IMPORTNAME
		RETURNURL="image-run.cgi"
		echo "dockerimport.sh" > tmp/nag
	;;
 	"LOAD")
                INFO=$(echo $DETAIL|cut -d "&" -f2-)
                LOADPATH=$(echo $INFO|cut -d "&" -f1|cut -d "=" -f2|sed "s,%2F,/,g")
                LOADFILE=$(echo $INFO|cut -d "&" -f2|cut -d "=" -f2)
		write_global LOADPATH
		write_global LOADFILE
		RETURNURL="image-run.cgi"
		echo "dockerload.sh" > tmp/nag
	;;
 	"CACHEINST")
                INSTALLCONTAINER=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2)
                INSTALLERPATH=$(echo $DETAIL|cut -d "&" -f3|cut -d "=" -f2|sed "s,%2F,/,g")
                INSTALLER=$(echo $DETAIL|cut -d "&" -f4|cut -d "=" -f2)
		write_global INSTALLCONTAINER
		write_global INSTALLERPATH
		write_global INSTALLER
		RETURNURL="container-control.cgi"
		echo "cacheinstaller.sh" > tmp/nag
	;;
	 "CACHERTN")
                NAMESPACE=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2|sed "s/%25/%/g")
                CACHEROUTINEDIR=$(echo $DETAIL|cut -d "&" -f3|cut -d "=" -f2|sed "s,%2F,/,g")
                CACHEROUTINE=$(echo $DETAIL|cut -d "&" -f4|cut -d "=" -f2)
		write_global NAMESPACE
		write_global CACHEROUTINEDIR
		write_global CACHEROUTINE
		RETURNURL="container-control.cgi"
		echo "dockercacheimport.sh" > tmp/nag
	;;
	"RUN")
		echo $DETAIL>tmp/run
		RETURNURL="container-control.cgi"
                echo "dockerrun.sh" > tmp/nag
        ;;
	"RUNCUSTOM")
		echo $DETAIL>tmp/run
		RETURNURL="container-control.cgi"
                echo "dockerruncustom.sh" > tmp/nag
        ;;
	"EXPORT")
		EXPORTPATH=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2|sed "s,%2F,/,g")
                EXPORTCONTAINER=$(echo $DETAIL|cut -d "&" -f2|cut -d "=" -f2)
		write_global EXPORTPATH
                write_global EXPORTCONTAINER
		RETURNURL="container-control.cgi"
		echo "dockerexport.sh" > tmp/nag
 	;;
	"SAVE")
                SAVEPATH=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2|sed "s,%2F,/,g")
		SAVECONTAINER=$(echo $DETAIL|cut -d "&" -f2|cut -d "=" -f2)
		write_global SAVEPATH
                write_global SAVECONTAINER
		RETURNURL="container-control.cgi"
		echo "dockersave.sh" > tmp/nag
 	;;
	"PULL")
		PULLIMAGE=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2|sed "s,%2F,/,g")
		write_global PULLIMAGE
		RETURNURL="image-run.cgi"
		echo "dockerpull.sh" > tmp/nag
 	;;
	"RMI")
		RMIIMAGE=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2-)
		write_global RMIIMAGE
		RETURNURL="image-delete.cgi"
		echo "dockerrmi.sh" > tmp/nag
 	;;
	"TERMINAL")
		RETURNURL="system.cgi"
		
	;;
	*)
		echo "Need to handle $DETAIL"
	;;
esac
if [[ "$MODE" == "TERMINAL" ]]
then
	cat base/termclose
else
	cat base/close|sed "s/summary.cgi/$RETURNURL/g"
fi
cat base/footer		

