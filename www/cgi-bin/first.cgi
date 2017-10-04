#!/bin/bash
echo "Content-type: text/html"
echo ""

echo "<html><head><title>Bash as CGI"
echo "</title></head><body>"

echo $(ls -al)
echo "<h1>Hello world</h1>"
#/usr/bin/env
cat /var/www/html/css/buttons
echo "<table id=\"header\" align=\"center\">"


query=$(echo $QUERY_STRING|cut -d "=" -f2)
query1=$(echo $query|cut -d "&" -f1)
query2=$(echo $query|cut -d "&" -f2)
echo "Find container:  $query1"
echo "with tag:  $query2"


echo "</table></body></html>"

