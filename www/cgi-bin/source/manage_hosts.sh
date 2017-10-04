#!/bin/bash
#gets, sets, removes hosts entries for managment hosts

add_container(){

	# Adds container details to hosts
	# $1=username $2=host, $3=container name
	HOSTNAME=$(hostname)
	IPADDRESS=$(get_container_ip $3)
	if [[ "$IPADDRESS" != "" ]]
	then
		ssh $1@$2 "/bin/amend_hosts.cmd ADD $IPADDRESS $3 $HOSTNAME" > /dev/null
	fi
}
remove_container(){
	# Removes container from hosts
	# $1=username, $2=host, $3=container name
	ssh $1@$2 "/bin/amend_hosts.cmd DELETE $3" > /dev/null
}
get_container_ip(){
	# Get container IP address
	#$1=container name
	echo $(docker inspect $1|grep -A100 "Networks"|grep IPAddress|grep 172|cut -d ":" -f2|tr -d '," ')
}
configure_routing(){
	DOCKERSUBNET=$(docker network inspect j2docker|grep Subnet|cut -d ":" -f2|cut -d "/" -f1|tr -d " \"")
	if [[ $(ssh $1@$2 route print|grep -c $DOCKERSUBNET) -eq 0 ]]
	then
		HOSTIP=$(ifconfig ens33|grep "inet "|tr -s " "|cut -d " " -f3)
		ssh $1@$2 route add $DOCKERSUBNET mask 255.255.0.0 $HOSTIP > /dev/null
	fi
}
update_managementhosts(){
	# $1=action, $2=container
	DATAPATH=/var/www/cgi-bin/
	source $DATAPATH/source/manage_registry.sh
	while read HOST USERNAME TYPE INTEGRATE STUDIO ATELIER
	do
		if [[ "$INTEGRATE" == "true" ]]
		then
			if [[ "$1" == "amend" ]]
			then
				add_container $USERNAME $HOST $2
			else
				remove_container $USERNAME $HOST $2
			fi
			if [[ "$TYPE" == "WINDOWS" && "$INTEGRATE" == "true" ]]
			then
				if [[ "$1" == "delete" ]]
                		then
					remove_registry $USERNAME $HOST $2
				fi
			fi
		fi
	done < $DATAPATH/tmp/management_clients
}
