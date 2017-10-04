#!/bin/bash
#
#while read TYPE RULE;do iptables -D $RULE;done < <(iptables -S|grep $PORT)
#
source /var/www/cgi-bin/source/functions.sh
unset PORTS

#Make sure all default ports always present 
delete_global DEFAULTPORTS
for THISPORT in 22 23 80 1972 3389 4201 4202 8080 57772
do
	append_global DEFAULTPORTS $THISPORT
done
unset THISPORT
. /var/www/cgi-bin/tmp/globals
# PORTS is operational global.  Create it if absent.
if [[ "$PORTS" == "" ]]
then
	. /var/www/cgi-bin/tmp/globals
        for THISPORT in $DEFAULTPORTS
        do
                append_global PORTS $THISPORT
        done
fi

# Read current PORTS and add to public and DOCKER firewall rules if required.
. /var/www/cgi-bin/tmp/globals

for CHAIN in DOCKER
do
	#Allow ping
	iptables -A ${CHAIN} -p icmp -s 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
	for PORT in $PORTS
	do
		if [[ $(iptables -n -L $CHAIN|grep -c $PORT) -eq 0 ]]
		then
			iptables -A $CHAIN -p tcp --dport $PORT -j ACCEPT
		fi
	done
done

# Iterate firewall rules and remove any unused ports

for PORT in $(iptables -n -L DOCKER|grep "dpt:"|cut -d":" -f2)
do 
	MATCH=false
	for THISPORT in $PORTS
	do
		if [[ "$THISPORT" == "$PORT" ]]
		then
			MATCH=true
			break
		fi
	done
	if [[ "$MATCH" == "false" ]]
	then
		iptables -D DOCKER -p tcp --dport $PORT -j ACCEPT
	fi
done



