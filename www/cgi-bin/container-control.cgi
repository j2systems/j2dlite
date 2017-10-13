#!/bin/bash

source source/functions.sh

. tmp/globals
[[ -f tmp/containers ]] && rm -f tmp/containers
cat base/header 
cat base/nav|sed "s/screen3/green/g"
echo "<input type=\"hidden\" id=\"IP\" value=\"${REMOTE_ADDR}\">"
cat base/ws-container
echo "<div id=\"CONTAINERS\"></div>"
cat base/footer
