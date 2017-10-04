#!/bin/bash

[[ ! -f /tmp/management_clients ]] && touch tmp/management_clients
source source/functions.sh
. tmp/globals
cat base/header 
cat base/nav|sed "s/screen4/green/g"

if [[ "$REQUEST_METHOD" == "POST" ]]
then
	read INFO
	echo $INFO
fi

THISCOLOR=blue
echo "<table align=\"center\"><tr><td class=\"information\">Advanced options</td></tr></table>"
echo "<table width=\"100%\"><tr><td width=\"100%\" height=\"3px\" class=\"build\"></td></tr></table>"
echo "<table align=\"center\"><tr>"
echo "<form action=\"./container-nginx.cgi\" method=\"GET\"><td><input type=\"submit\" name=\"NGINX\" value=\"nginx\" class=\"button blue\"></td></form>"
echo "<form action=\"./container-ports.cgi\" method=\"GET\"><td><input type=\"submit\" name=\"HOSTS\" value=\"fw ports\" class=\"button blue\"></td></form>"
echo "<form action=\"./advanced.cgi\" method=\"POST\"><td><input type=\"submit\" name=\"OTHER\" value=\"other\" class=\"button blue\"></td></form>"
echo "<form action=\"./advanced.cgi\" method=\"POST\"><td><input type=\"submit\" name=\"MANUAL\" value=\"manual\" class=\"button blue\"></td></form>"
echo "</tr></table>"
echo "<table width=\"100%\"><tr><td width=\"100%\" height=\"3px\" class=\"blue build\"></td></tr>"

echo "<table align=\"center\">"
echo "<tr><td><form action=\"./terminal.cgi\" method=\"POST\"><input type=\"submit\" name=\"TERMINAL\" value=\"Terminal\" class=\"button green\"></td></tr>"
echo "</table>"
echo "<table width=\"100%\">"
echo "<tr><td width=\"100%\" height=\"3px\" class=\"yellow build\"></td></tr>"
echo "</table>"

cat base/footer



