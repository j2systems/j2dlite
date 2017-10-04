#!/bin/bash
source source/functions.sh
cat base/header
case "${REQUEST_METHOD}" in
	"POST")
		read INFO
		THISNAME=$(echo $INFO|cut -d "&" -f1|cut -d "=" -f2)
		THISPATH=$(echo $INFO|cut -d "&" -f2|cut -d "=" -f2|sed "s,%2F,/,g")
		THISFILE=$(echo $INFO|cut -d "&" -f3|cut -d "=" -f2)
		THISACTION=$(echo $INFO|cut -d "&" -f4|cut -d "=" -f2)
		#echo $INFO
		#echo $THISPATH
		write_global THISNAME
		write_global THISFILE
		write_global THISPATH
		write_global THISACTION
		echo "go" > tmp/dockerbuild
		#echo "Build $THISFILE from $THISPATH"
		echo "<table width=\"100%\"  align=\"center\">"
		echo "<tr></tr><tr><td class=\"information\">\"$THISACTION\" has been instigated.  The console below will tell you when the task has completed.</td></tr><br>"
		echo "<tr></tr><tr><td class=\"information\">Do not close this window until you see \"Session closed.\" in the console</td></tr><br>"
		echo "<tr></tr><tr><td class=\"information\"><iframe src=\"http://$(hostname):4200\" class=\"iframe\"></iframe></td></tr></table>"
	;;
	*)
		echo "Something went very wrong"
	;;
esac
cat base/footer
