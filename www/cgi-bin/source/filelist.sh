#!/bin/bash

file_list() {

	HTML="<tr><td><img src=\"/images/file-icon.png\" alt=\"FILE\" class=\"filelistlogo\"></td><td><input type=\"submit\" name=\"file\" value=\""
	while read FILEDETAIL
	do
		FILENAME=$(echo ${FILEDETAIL}|rev|cut -d "/" -f1|rev)
		echo "${HTML}${FILENAME}\" class=\"filelisting\"></td></tr>"
	done < <(find "$1" -type f -maxdepth 1)
}
dir_list() {

	HTML="<tr><td><img src=\"/images/folder-icon.png\" alt=\"FOLDER\" class=\"filelistlogo\"></td><td><input type=\"submit\" name=\"dir\" value=\""
	while read DIRDETAIL
	do
		DIRNAME=$(echo ${DIRDETAIL}|rev|cut -d "/" -f1|rev)
		echo "${HTML}${DIRNAME}\" class=\"filelisting\"></td></tr>"
	done < <(find "$1" -type d -maxdepth 1 -mindepth 1)
}
dir_list2() {
	for DIRECTORY in "$(ls -l $1|grep -e "^d"|tr -s " "|cut -d " " -f9)"
	do
		echo "<tr><td><img src=\"/images/folder-icon.png\" alt=\"FOLDER\" class=\"filelistlogo\"></td><td><input type=\"submit\" name=\"dir\" value=\"$DIRECTORY\" class=\"dirlisting\"></td></tr>"
	done
}

list_all() {
	file_list "$1"
	dir_list "$1"
}
