#!/bin/bash
source source/functions.sh
MANHOST=$(nslookup $REMOTE_ADDR|grep name|cut -d "=" -f2|cut -d "." -f1|tr -d " ")
[[ "$MANHOST" == "" ]] && MANHOST=$REMOTE_ADDR
MANHOSTUC=$(echo $MANHOST|tr "[a-z" "[A-Z]")

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
write_global MANHOST
write_global MANHOSTTYPE

