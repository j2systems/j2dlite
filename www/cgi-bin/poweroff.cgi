#!/bin/bash
source source/functions.sh
. tmp/globals
cat base/header 
echo "<table align=\"center\"><tr><td class=\"information\">System shutting down</td></tr></table"
cat base/footer
echo "system-shutdown.sh" > tmp/trigger

