#!/bin/bash
source source/functions.sh
. tmp/globals
cat base/poweroff 
echo "system-shutdown.sh" > tmp/trigger

