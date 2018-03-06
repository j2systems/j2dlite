#!/bin/sh
# 
 # Purge journals
echo -e "_SYSTEM\nj2andUtoo\nzn \"%SYS\"\nd PURGE^JOURNAL\n1\nh\n"|csession hs

# Stop instance
ccontrol stop hs quietly

# Move journals to /InterSystems/hs/mgr/journal
mkdir -p /InterSystems/hs/mgr/journal/jrnpri 
mkdir -p /InterSystems/hs/mgr/journal/jrnalt

find /InterSystems/jrnpri/ -type f -exec mv {} ${CACHEDIR}/mgr/journal/jrnpri/ \; 
find /InterSystems/jrnalt/ -type f -exec mv {} ${CACHEDIR}/mgr/journal/jrnalt/ \; 

# ready to shutdown
