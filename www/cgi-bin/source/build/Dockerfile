
FROM centos:7
RUN yum -y update \
	&& yum -y install telnet-server httpd which tar hostname net-tools \
	&& yum -y clean all


ENV TMP_INSTALL_DIR=/tmp/distrib \
	container=docker

ARG password="j2andUtoo"
ARG cache=HS-2016.2.1.806.0.17136-hscore15.02_hsaa15.02_hspi15.02_hsviewer15.02_linkage15.02-b9912
ARG TIMEZONE=GMT
ARG CACHEDIR="/InterSystems/hs"

WORKDIR ${TMP_INSTALL_DIR}
ADD cache.key ${CACHEDIR}/cache.key
ADD csp.conf /etc/httpd/conf.d/csp.conf
ADD scripts/healthshare /etc/init.d/healthshare
ADD source base/ops/source/InitialLoad
ADD scripts/telnetd /sbin/telnetd
ADD scripts/pseudo-init /sbin/pseudo-init
ADD ${cache}-lnxrhx64.tar.gz /tmp/${cache}-lnxrhx64.tar.gz
VOLUME /InterSystems/jrnpri
VOLUME /InterSystems/jrnalt
RUN rm -f /etc/localtime && ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
	&& /usr/sbin/adduser -r cacheusr \
	&& echo cacheusr:$password | /usr/sbin/chpasswd \
	&& /usr/sbin/groupadd -r cachegrp \
	&& mkdir /InterSystems/db \
	&& chown cacheusr:cacheusr /InterSystems/db /InterSystems/jrnalt /InterSystems/jrnpri \
	&& chmod 775 /InterSystems/db /InterSystems/jrnalt /InterSystems/jrnpri

# create a template csp.conf for apache and set apache to auto-start

# setup the env for cinstall_silent
ENV	ISC_PACKAGE_INSTANCENAME="HS" \
	ISC_PACKAGE_INSTALLDIR="${CACHEDIR}" \
	ISC_PACKAGE_UNICODE="Y" \
	ISC_PACKAGE_CLIENT_COMPONENTS="" \
	ISC_PACKAGE_INITIAL_SECURITY="Normal" \
	ISC_INSTALLER_MANIFEST="/tmp/Installer.xml,Custom.Util.WorkbenchInstall" \
	ISC_INSTALLER_LOGFILE="/tmp/Installer.log" \
	ISC_INSTALLER_LOGLEVEL="2" \
	ISC_PACKAGE_USER_PASSWORD=${password} \
	ISC_PACKAGE_CSP_CONFIGURE="Y" \
	ISC_PACKAGE_CSP_SERVERTYPE="Apache" \
	ISC_PACKAGE_CSP_APACHE_CONF="/etc/httpd/conf.d/csp.conf" 


ADD Installer.xml /tmp/Installer.xml

RUN cd /tmp/HS-2016.2.1.806.0.17136-hscore15.02_hsaa15.02_hspi15.02_hsviewer15.02_linkage15.02-b9912-lnxrhx64.tar.gz/HS-2016.2.1.806.0.17136-hscore15.02_hsaa15.02_hspi15.02_hsviewer15.02_linkage15.02-b9912-lnxrhx64/ \
	&& ./cinstall_silent \
	
	&& cd /tmp \
	&& /bin/rm -rf ./${cache}-lnxrhx64 \
	&& chmod 755 /etc/init.d/healthshare \
	&& chkconfig --level 345 httpd on \
	&& chkconfig --level 345 healthshare on \
	&& chkconfig --level 345 ISCAgent on \
	&& ${ISC_PACKAGE_INSTALLDIR}/bin/ccontrol stop ${ISC_PACKAGE_INSTANCENAME} quietly \
	
# ENTRYPOINT ["/sbin/pseudo-init"]

