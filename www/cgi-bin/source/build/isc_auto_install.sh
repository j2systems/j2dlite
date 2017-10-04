#!/bin/bash
export TIMEZONE=GMT
export CACHEDIR="/InterSystems/hs"
export PASSWORD="j2andUtoo"
export ISC_PACKAGE_INSTANCENAME="HS"
export ISC_PACKAGE_INSTALLDIR="${CACHEDIR}"
export ISC_PACKAGE_UNICODE="Y"
export ISC_PACKAGE_CLIENT_COMPONENTS=""
export ISC_PACKAGE_INITIAL_SECURITY="Normal"
export ISC_INSTALLER_LOGFILE="/tmp/Installer.log"
export ISC_INSTALLER_LOGLEVEL="2"
export ISC_PACKAGE_USER_PASSWORD=${PASSWORD}
export ISC_PACKAGE_CSP_CONFIGURE="Y"
export ISC_PACKAGE_CSP_SERVERTYPE="Apache"
export ISC_PACKAGE_CSP_APACHE_CONF="/etc/httpd/conf.d/csp.conf"
export ISC_PACKAGE_STARTCACHE="N"
export ISC_INSTALLER_LOGFILE="/tmp/Installer.log" 
/usr/sbin/adduser -r cacheusr
echo cacheusr:$PASSWORD | /usr/sbin/chpasswd
/usr/sbin/groupadd -r cachegrp
mkdir -p /InterSystems/db  /InterSystems/jrnalt /InterSystems/jrnpri
chown cacheusr:cacheusr /InterSystems/db /InterSystems/jrnalt /InterSystems/jrnpri
chmod 775 /InterSystems/db /InterSystems/jrnalt /InterSystems/jrnpri
INSTALLER=$(find /tmp/build -name cinstall_silent)
$INSTALLER

mv /tmp/cache.key ${CACHEDIR}/mgr/cache.key
##move journals
ccontrol start hs
echo -e "_SYSTEM\nj2andUtoo\nzn \"%SYS\" d ^JRNSTOP\ny\nh\n"|csession hs
echo -e "_SYSTEM\nj2andUtoo\nzn \"%SYS\" s SYSOBJ=##Class(Config.Journal).Open() s SYSOBJ.CurrentDirectory=\"/InterSystems/jrnpri\" s TranMode=\$\$SetTransactionMode^%apiOBJ(0) s tSC=SYSOBJ.%Save() w tSC\nh\n"|csession hs
echo -e "_SYSTEM\nj2andUtoo\nzn \"%SYS\" s SYSOBJ=##Class(Config.Journal).Open() s SYSOBJ.AlternateDirectory=\"/InterSystems/jrnalt\" s TranMode=\$\$SetTransactionMode^%apiOBJ(0) s tSC=SYSOBJ.%Save() w tSC\nh\n"|csession hs

ccontrol stop $ISC_PACKAGE_INSTANCENAME quietly
rm -rf /tmp/build
#chown cacheusr:cacheusr /InterSystems -R
chmod 755 /etc/init.d/healthshare 
chkconfig --level 345 httpd on
chkconfig --level 345 healthshare on
chkconfig --level 345 ISCAgent on
chkconfig --level 345 xinetd on
sed -i "s,yes,no,g" /etc/xinetd.d/telnet
sed -i "s,# . /etc/rc.d/init.d/functions,. /etc/rc.d/init.d/functions,g" /etc/init.d/healthshare
rm -f /etc/localtime && ln -s /usr/share/zoneinfo/GMT /etc/localtime
