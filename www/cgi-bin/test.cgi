#!/bin/bash
# source functions
#display page
cat base/header
HOSTIP=$(env|grep "REMOTE_ADDR"|cut -d "=" -f2)
echo "<input type=\"hidden\" id=\"IP\" value=\"$HOSTIP\">"
echo "<table align=\"center\"><tr id=\"mh\" align=\"center\" class=\"filelisting\"></tr></table>"
cat base/wstest
cat base/footer
