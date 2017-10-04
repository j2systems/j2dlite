#!/bin/bash

file_list() {

	for FILE in $(ls -l $1|grep -e "^-"|tr -s " "|cut -d " " -f9)
	do
		echo "<tr><td><img src=\"/images/file-icon.png\" alt=\"FILE\" class=\"filelistlogo\"></td><td><input type=\"submit\" name=\"file\" value=\"$FILE\" class=\"filelisting\"></td></tr>"
	done
}
dir_list() {
	for DIRECTORY in $(ls -l $1|grep -e "^d"|tr -s " "|cut -d " " -f9)
	do
		echo "<tr><td><img src=\"/images/folder-icon.png\" alt=\"FOLDER\" class=\"filelistlogo\"></td><td><input type=\"submit\" name=\"dir\" value=\"$DIRECTORY\" class=\"filelisting\"></td></tr>"
	done
}
dir_list2() {
	for DIRECTORY in $(ls -l $1|grep -e "^d"|tr -s " "|cut -d " " -f9)
	do
		echo "<tr><td><img src=\"/images/folder-icon.png\" alt=\"FOLDER\" class=\"filelistlogo\"></td><td><input type=\"submit\" name=\"dir\" value=\"$DIRECTORY\" class=\"dirlisting\"></td></tr>"
	done
}

list_all() {
	file_list $1
	dir_list $1
}
