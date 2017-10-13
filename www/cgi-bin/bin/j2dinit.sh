#!/bin/bash

# init script to configure environment
# if no first_run exists, create zfs  drive and directIO vol

# $MOUNTDRIVE exported from /opt/bootlocal.sh

if [[ ! -f ${MOUNTDRIVE}/first_run ]]
then
	clear
	echo "First run.  This will check and configure zfs volumes"
	echo
	echo "Stage 1. check disk available for ZFS.  This should be /dev/?db"
	echo
	DRIVEPREFIX=$(echo ${MOUNTDRIVE}|cut -d "/" -f3|cut -c 1)
	DEVICE=/dev/${DRIVEPREFIX}db
	echo "Checking for ${DEVICE}"
	echo
	if [[ "$(fdisk -l | grep ${DEVICE})" == "" ]]
	then
		echo "Storage disk not found."
		echo "To continue, shut down the machine, add a (recommended) 50G drive"
		echo "and start the machine"
		exit
	fi
	echo "${DEVICE} found."
	echo
	echo -n "Checking for any existing docker zfs volumes..."
	if [[ $(zfs list|grep -c docker) -eq 0 ]]
	then
		echo "not found."
		echo
		echo "Creating docker volume"
		echo
		zpool create -f docker -m /var/lib/docker ${DEVICE}
		if [[ $(zfs list|grep -c docker) -eq 0 ]]
		then
			echo "Could not create zfs docker."
			echo "Command attempted:"
			echo "zpool create -f docker -m /var/lib/docker ${DEVICE}"
			echo
			echo "Check dmesg."
			echo
			exit
		else
			echo "Created docker pool."
			zfs list
		fi
	else
		echo "found."
		echo
	fi
	echo -n "Checking for directIO volume..."                             
	if [[ $(zfs list|grep -c directIO) -eq 0 ]]
	then
		echo "not found."
		echo "Creating directIO volume for xfs."
		echo
		zfs create -V 10G docker/directIO
		mkfs.xfs /dev/zvol/docker/directIO
		echo "Created."
		echo
	else
		echo "found." 
	fi
	touch ${MOUNTDRIVE}/first_run 
fi
# mount cgroups and volumes
echo "Mounting cgroups and volumes"

# cgroups
bash cgroupfs-mount 

# Wait for IP address
HOSTIP=$(ifconfig eth0|grep "inet addr"|tr -s " "|cut -d ":" -f2|cut -d " " -f1)
while [[ "$HOSTIP" == "" ]]
do
	sleep 1                                                                                    
	HOSTIP=$(ifconfig eth0|grep "inet addr"|tr -s " "|cut -d ":" -f2|cut -d " " -f1)        
done
# www
if [[ ! -f ${MOUNTDRIVE}/web/new ]] 
then
	# just been pulled by /opt/bootlocal.sh
	HERE=$(pwd)
	cd ${MOUNTDRIVE}/web/
	#git pull https://github.com/j2systems/j2dlite
       	cd ${HERE}
                  
else
	# update next time
	rm -rf ${MOUNTDRIVE}/web/new
fi                                         
[[ ! -d /var/www ]] && mkdir /var/www                                                   
mount --bind ${MOUNTDRIVE}/web/www /var/www                                             

# Ready for globals.
SHAREDIR=/mnt/shared 
WWWROOT=/var/www/cgi-bin
SOURCEPATH=${WWWROOT}/source
BINPATH=${WWWROOT}/bin
SYSTEMPATH=${WWWROOT}/system
TMPPATH=${WWWROOT}/tmp
JOBREQUESTPATH=${TMPPATH}/jobrequests
JOBQUEUEPATH=${TMPPATH}/jobqueue
JOBSTATUSPATH=${TMPPATH}/jobstatus
HOSTNAME=$(hostname)
[[ ! -d ${TMPPATH} ]] && mkdir ${TMPPATH} && chmod 777 ${TMPPATH}
[[ ! -d ${SYSTEMPATH} ]] && mkdir ${SYSTEMPATH} && chmod 777 ${SYSTEMPATH}
[[ ! -d ${MOUNTDRIVE}/system ]] && mkdir ${MOUNTDRIVE}/system && chmod 777 ${MOUNTDRIVE}/system
[[ ! -d ${JOBREQUESTPATH} ]] && mkdir ${JOBREQUESTPATH} && chmod 777 ${JOBREQUESTPATH}
[[ ! -d ${JOBQUEUEPATH} ]] && mkdir ${JOBQUEUEPATH} && chmod 777 ${JOBQUEUEPATH}
[[ ! -d ${JOBSTATUSPATH} ]] && mkdir ${JOBSTATUSPATH} && chmod 777 ${JOBSTATUSPATH}
[[ ! -f ${TMPPATH}/globals ]] && touch ${TMPPATH}/globals && chmod 777 ${TMPPATH}/globals
[[ ! -d /var/lib/docker/volumes ]] && mkdir /var/lib/docker/volumes

source ${SOURCEPATH}/functions.sh
write_global WWWROOT
write_global BINPATH
write_global SOURCEPATH
write_global SYSTEMPATH
write_global TMPPATH
write_global MOUNTDRIVE
write_global JOBREQUESTPATH
write_global JOBQUEUEPATH
write_global JOBSTATUSPATH
write_global HOSTIP 
write_global HOSTNAME
write_global SHAREDIR

# keep system dir out of gits way

mount --bind /mnt/sda1/system/ /var/www/cgi-bin/system

for REFERENCE in management_clients known_ips
do                                           
        if [[ ! -f ${SYSTEMPATH}/${REFERENCE} ]]
        then                                    
                touch ${SYSTEMPATH}/${REFERENCE}
                chmod 666 ${SYSTEMPATH}/${REFERENCE}
        fi                                          
done 
# directIO may have just been created.  Check and format if required.
[[ $(blkid /dev/zvol/docker/directIO|grep -c "xfs") -eq 0 ]] && mkfs.xfs /dev/zvol/docker/directIO                                                                                      
mount /dev/zvol/docker/directIO /var/lib/docker/volumes                                 

#NEED CODE HERE TO DETECT AND INSTALL VMWARE/VIRTUALBOX/PARALLELS                                                                                   
mkdir /mnt/shared
chmod 777 /mnt/shared
vmhgfs-fuse -o allow_other /mnt/shared

ln -s /usr/local/etc/ssl/certs /etc/ssl

#Start websocket, job listener, apache, zfs and docker 
echo "Starting interaction services"                             
nohup /var/www/cgi-bin/bin/init.sh >> /var/log/system.log & 

echo "http://${HOSTIP}/"

