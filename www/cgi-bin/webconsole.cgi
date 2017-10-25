#!/bin/bash

. /tmp/globals
cat base/header
echo "<table width="100%"><tr><td width="100%" height="3px" class="green build"></td></tr></table>"
echo "<table align=\"center\"><tr id=\"dockerterm\"></tr></table>"
RETURNURL="summary.cgi"
echo "<script src="/scripts/ws-console.js"></script>" 
cat base/termclose
cat base/footer
