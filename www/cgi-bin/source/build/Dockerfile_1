FROM centos:6
RUN yum -y update \
	&& yum -y install xinetd telnet-server httpd which tar hostname net-tools cronie\
	&& yum -y clean all \ 
	&& /usr/sbin/adduser -r cacheusr \
	&& echo cacheusr:$password | /usr/sbin/chpasswd
ENV 	LANG=en_US.UTF-8 \
	LC_ALL=en_US.UTF-8
