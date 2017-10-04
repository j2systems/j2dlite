#!/bin/bash
#
# Builds an images 

BASEDIR=/var/www/cgi-bin
TEMPLATEDIR=$BASEDIR/source/build
BUILDDIR=$BASEDIR/build
source $BASEDIR/source/functions.sh
#give a couple of seconds for terminal
sleep 2
HERE=$(pwd)
cd $BASEDIR
. tmp/globals

[[ ! -d $BUILDDIR ]] && mkdir $BUILDDIR && chmod 777 $BUILDDIR

#stage 1.  If centos base not available, create it ## TO DO

	echo "Starting image build of $BUILDFILE"
	/bin/cp -f $TEMPLATEDIR/Dockerfile_1 $BUILDDIR/Dockerfile
	chmod 777 $BUILDDIR/Dockerfile
	[[ "$BUILDNAME" == "" ]] && BUILDNAME="j2docker"
	echo "Building base Centos image."
	docker build -t j2systems/docker:centos6HS $BUILDDIR/. 2>&1
	echo "Created j2systems/docker:centos6HS"

#Stage 2. install.  Need to untar kit, export local vars and cinstall

	echo "Untarring $BUILDFILE.  This will take some time"
	docker run -itd --name $BUILDNAME  --network j2docker -v $SHAREDIR:/mnt/host j2systems/docker:centos6HS /bin/sh 2>&1
	SUBDIR=$(echo $BUILDPATH|sed "s,$SHAREDIR/,,g")
	docker exec $BUILDNAME mkdir /tmp/build 
	docker cp $BUILDPATH/cache.key $BUILDNAME:/tmp/cache.key
	docker exec $BUILDNAME /bin/tar zxf /mnt/host/$SUBDIR/$BUILDFILE -C /tmp/build 2>&1
	CACHEDIR="/hs/InterSystems"
	echo "Copying over runtimes"
	while read FILENAME DIRECTORY
	do
		docker cp $TEMPLATEDIR/$FILENAME $BUILDNAME:$DIRECTORY/$FILENAME
	done < $TEMPLATEDIR/base_files
	echo "Running install..."
	docker exec $BUILDNAME /bin/sh /tmp/isc_auto_install.sh 2>&1
	echo "Cleaning up ..."
	echo "Stopping instance, removing install and commiting"
	docker stop $BUILDNAME 2>&1 1> /dev/null
	docker commit --change='ENTRYPOINT ["/sbin/pseudo-init"]' $BUILDNAME j2systems/docker:HS${BUILDNAME} 2>&1
	echo "Removing intermediary container"
	docker rm $BUILDNAME
	echo "Process complete"
	echo "SCRIPT END"
	# Stop instance
	delete_global BUILDNAME
	delete_global BUILDFILE
	delete_global BUILDPATH
	. ${BASEDIR}/bin/zfs-status.sh
	cd $HERE
	
