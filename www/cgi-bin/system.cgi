#!/bin/bash
source source/functions.sh
. tmp/globals
MANHOSTIP=$(env|grep "REMOTE_ADDR"|cut -d "=" -f2)
if [[ $(echo $HTTP_USER_AGENT|grep -c "Windows") -eq 1 ]]
then
        MANHOSTTYPE=WINDOWS
elif [[ $(echo $HTTP_USER_AGENT|grep -c "Macintosh") -eq 1 ]]
then
        MANHOSTTYPE=MAC
elif [[ $(echo $HTTP_USER_AGENT|grep -c "Linux") -eq 1 ]]
then
        MANHOSTTYPE=LINUX
else
        MANHOSTTYPE=OTHER
fi
write_global MANHOSTTYPE
write_global MANHOSTIP
cat base/header 
cat base/nav|sed "s/screen4/green/g"
cat base/advanced
echo "<input type=\"hidden\" id=\"IP\" value=\"${MANHOSTIP}\">"
cat base/footer
