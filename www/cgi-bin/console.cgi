#!/bin/bash
# source functions
cat base/header
echo "<script src="/scripts/websocket.js"></script>"
echo "<table align=\"center\"><tr><td class=\"information\"><iframe src=\"http://$(hostname):4200\" class=\"iframe\"></iframe></td></tr></table>"
echo "<table align=\"center\"><tr><td>"
echo "<button class=\"button red\" onclick=controlContainer(\"noconsole=KILL\");>Close</button>"
echo "</td></tr></table>"
echo "<table width="100%"><tr><td width="100%" height="3px" class="yellow build"></td></tr></table>"§:

cat base/footer		

