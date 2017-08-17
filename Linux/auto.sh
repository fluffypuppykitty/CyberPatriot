#!/bin/bash

sudo apt-get install ufw gufw libpam-cracklib auditd bum 
sudo ufw default deny incoming && sudo ufw default allow outgoing && sudo ufw enable
sudo 	echo "password	requisite			pam_cracklib.so retry=3 minlen=8 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1
		password	[success=1 default=ignore]	pam_unix.so obscure use_authtok try_first_pass sha512 remember=5 minlen=8
		password	requisite			pam_deny.so
		password	required			pam_permit.so
		password	optional	pam_gnome_keyring.so " > /etc/pam.d/common-password	
echo "Common-password - "

sudo echo "MAIL_DIR        /var/mail
		FAILLOG_ENAB		yes
		LOG_UNKFAIL_ENAB	no
		LOG_OK_LOGINS		no
		SYSLOG_SU_ENAB		yes
		SYSLOG_SG_ENAB		yes
		FTMP_FILE	/var/log/btmp
		SU_NAME		su
		HUSHLOGIN_FILE	.hushlogin
		ENV_SUPATH	PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
		ENV_PATH	PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
		TTYGROUP	tty
		TTYPERM		0600
		ERASECHAR	0177
		KILLCHAR	025
		UMASK		022

		PASS_MAX_DAYS	90
		PASS_MIN_DAYS	10
		PASS_WARN_AGE	7
		LOGIN_RETRIES		5
		LOGIN_TIMEOUT		60

		UID_MIN			 1000
		UID_MAX			60000
		GID_MIN			 1000
		GID_MAX			60000
		CHFN_RESTRICT		rwh
		DEFAULT_HOME	yes
		USERGROUPS_ENAB yes
		ENCRYPT_METHOD SHA512" > /etc/login.defs
echo "Login - "

sudo echo "auth	[success=1 default=ignore]	pam_unix.so nullok_secure
		auth	requisite			pam_deny.so
		auth	required			pam_permit.so
		auth  	required			pam_tally2.so deny=5 onerr=fail unlock_time=1" > /etc/pam.d/common-auth
echo "Common-Auth - "

sudo echo "log_file = /var/log/audit/audit.log
		log_format = RAW
		log_group = root
		priority_boost = 4
		flush = INCREMENTAL
		freq = 20
		num_logs = 4
		disp_qos = lossy
		dispatcher = /sbin/audispd
		name_format = NONE
		##name = mydomain
		max_log_file = 5 
		max_log_file_action = ROTATE
		space_left = 75
		space_left_action = SYSLOG
		action_mail_acct = root
		admin_space_left = 50
		admin_space_left_action = SUSPEND
		disk_full_action = SUSPEND
		disk_error_action = SUSPEND
		##tcp_listen_port = 
		tcp_listen_queue = 5
		tcp_max_per_addr = 1
		##tcp_client_ports = 1024-65535
		tcp_client_max_idle = 0
		enable_krb5 = no
		krb5_principal = auditd
		##krb5_key_file = /etc/audit/audit.key" > /etc/audit/auditd.conf
echo "Audit - "

sudo auditctl -e 1
sudo apt-get --purge remove john
