#!/bin/bash

cat base/header
cat base/nav
source source/functions.sh
. tmp/globals
ROOTPATH=$SHAREDIR
case "${REQUEST_METHOD}" in
	"POST")
		read INSTRUCTION
		if [[ "$INSTRUCTION" == "BUILD=Build" ]]
		then
			append_global IMAGEMODE=build
			NEWPATH=$ROOTPATH
                	echo "<p class=\"instruction\">Choose a file to build or import</p>"
                	echo "<form action=\"./build-image.cgi\" method=\"POST\"><table>"
                	echo "<input type=\"hidden\" name=\"path\" value=\"$NEWPATH\">"
                	for FILE in $(ls -l $NEWPATH|grep -e "^-"|tr -s " "|cut -d " " -f9)
                	do  
                        	echo "<tr><td><img src=\"/images/file-icon.png\" alt=\"FILE\" class=\"filelistlogo\"></td><td><input type=\"submit\" name=\"file\" value=\"$FILE\" class=\"filelisting\"></td></tr>"
                	done
                	for DIRECTORY in $(ls -l $NEWPATH|grep -e "^d"|tr -s " "|cut -d " " -f9)
                	do  
                        	echo "<tr><td><img src=\"/images/folder-icon.png\" alt=\"FOLDER\" class=\"filelistlogo\"></td><td><input type=\"submit\" name=\"dir\" value=\"$DIRECTORY\" class=\"filelisting\"></td></tr>"
                	done
		elif [[ "$INSTRUCTION" == "IMPORT=Import" ]]
		then
			MODE=import
			echo "call import"
		elif [[ "$INSTRUCTION" == "EXPORT=Export" ]]
		then
			echo "call export"
		elif [[ "$INSTRUCTION" == "SEARCH=Search" ]]
		then
			echo "call search"
		else
			CURRENTPATH=$(echo $INSTRUCTION|cut -d "&" -f1)
			INFO=$(echo $INSTRUCTION|cut -d "&" -f2)
			TYPE=$(echo $INFO|cut -d "=" -f1)
			VALUE=$(echo $INFO|cut -d "=" -f2)
			SUBMITTEDPATH=$(echo $CURRENTPATH|cut -d "=" -f2|sed "s,%2F,/,g")
			#echo $CURRENTPATH,$INFO,$TYPE,$VALUE,$SUBMITTEDPATH
			if [[ "$TYPE" == "dir" ]]
				then
				if [[ "$VALUE" == ".." ]]
				then
					if [[ "$SUBMITTEDPATH" == "$ROOTPATH" ]]
					then
						NEWPATH=$(echo $SUBMITTEDPATH)
					else
						NEWPATH=$(echo $SUBMITTEDPATH|rev|cut -d "/" -f2-|rev)
					fi
				else
					NEWPATH=$SUBMITTEDPATH/$VALUE
				fi
				THISPATH=$NEWPATH
				[[ "$NEWPATH" == "" ]] && NEWPATH=$ROOTPATH
				echo "<p class=\"instruction\">Choose software</p>"
				echo "<form action=\"./build-image.cgi\" method=\"POST\"><table>"
				echo "<input type=\"hidden\" name=\"path\" value=\"$NEWPATH\">"
				[[ "$NEWPATH" != "$ROOTPATH" ]] && echo "<tr><td><img src=\"/images/parent-folder.png\" alt=\"PARENT FOLDER\" class=\"filelistlogo\"><input type=\"submit\" name=\"dir\" value=\"..\" class=\"filelisting\"></td></tr>"
				for FILE in $(ls -l $NEWPATH|grep -e "^-"|tr -s " "|cut -d " " -f9)
				do
					echo "<tr><td><img src=\"/images/file-icon.png\" alt=\"FILE\" class=\"filelistlogo\"></td><td><input type=\"submit\" name=\"file\" value=\"$FILE\" class=\"filelisting\"></td></tr>"
				done
				for DIRECTORY in $(ls -l $NEWPATH|grep -e "^d"|tr -s " "|cut -d " " -f9)
				do
        				echo "<tr><td><img src=\"/images/folder-icon.png\" alt=\"FOLDER\" class=\"filelistlogo\"></td><td><input type=\"submit\" name=\"dir\" value=\"$DIRECTORY\" class=\"filelisting\"></td></tr>"
				done
			else
	                        echo "<table align=\"center\"><tr>"
				echo "<td class=\"button black\">File:</td>"
				echo "<td class=\"filelisting yellow\">$VALUE</td></tr>"
				echo "<td class=\"button black\">Name:</td>"
				echo "<form action=\"./build.cgi\" method=\"POST\" target=\"_blank\">"
				echo "<td class=\"filelisting yellow\"><input type=\"text\" name=\"NEWCONTAINER\" class=\"textbox yellow\"></td></tr></table>"
				echo "<table align=\"center\">"
				echo "<input type=\"hidden\" name=\"path\" value=\"$SUBMITTEDPATH\">"
				echo "<input type=\"hidden\" name=\"file\" value=\"$VALUE\">"
				echo "<tr><td></td>"
				echo "<td><input type=\"submit\" name=\"action\" value=\"Build\" class=\"button black\"></td>"
				echo "<td><input type=\"submit\" name=\"action\" value=\"Import\" class=\"button black\"></td>"
				echo "</form>"
				echo "<td><form action=\"./build-image.cgi\" method=\"GET\">"
	                        echo "<input type=\"submit\" value=\"Cancel\" class=\"button gray\"></form></td></tr>"
        	        fi
		fi
        ;;

	*)
		NEWPATH=$ROOTPATH
		echo "<p class=\"instruction\">Choose a file to build or import</p>"
		echo "<form action=\"./build-image.cgi\" method=\"POST\"><table>"
                echo "<input type=\"hidden\" name=\"path\" value=\"$NEWPATH\">"
                for FILE in $(ls -l $NEWPATH|grep -e "^-"|tr -s " "|cut -d " " -f9)
                do      	
			echo "<tr><td><img src=\"/images/file-icon.png\" alt=\"FILE\" class=\"filelistlogo\"></td><td><input type=\"submit\" name=\"file\" value=\"$FILE\" class=\"filelisting\"></td></tr>"
		done
		for DIRECTORY in $(ls -l $NEWPATH|grep -e "^d"|tr -s " "|cut -d " " -f9)
		do      
			echo "<tr><td><img src=\"/images/folder-icon.png\" alt=\"FOLDER\" class=\"filelistlogo\"></td><td><input type=\"submit\" name=\"dir\" value=\"$DIRECTORY\" class=\"filelisting\"></td></tr>"
                done        
esac

echo "</table>"
cat base/footer
