
Run openssh...exe and accept defaults.

save sshd_config to c:\program files\openssh\etc and restart openssh:

From admin command line:

	net stop opensshd
	net start opensshd

From Manage Computer\Services
	click on openssh, click stop.  click start.
	

if ssh fails, check your that windows firewall accepts tcp port 22 inbound from your local subnet.

