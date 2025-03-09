Verify the postgres version and OS version and download package from percona site
	https://www.percona.com/downloads

In our case it is Postgres 14.2 with 8.7 RHEL 
	wget https://downloads.percona.com/downloads/postgresql-distribution-14/14.2/binary/redhat/8/x86_64/percona-pgbouncer-1.16.1-2.el8.x86_64.rpm

If latest version of Postgres 16
	sudo percona-release setup ppg16
	yum install percona-pgbouncer.x86_64

Once installed, create respective directories for pgbouncer and change permission
	mkdir -p /dberrlog/pgbouncer/log
	chown -R pgbouncer. /dberrlog/pgbouncer

Login to psql and run "select usename,passwd from pg_shadow;"

Get the application usernames and its SHA-256 password (password which are static) and put in the following format in /dberrlog/pgbouncer/userlist.txt (needs to be created)
	vi userlist.txt
		"db2dba" "SCRAM-SHA-256$4096:MkNU4TQTtjnTAzgQQBm+Mg==$SQIyxH3yVn+8DASKaFHZuHXmPdAvUkHYwooJjmiohtE=:e5PPjzaypuCKiSxjiD4KOdamPRHxLT6U21S3fRqNWEg="
        "replusr" "SCRAM-SHA-256$4096:eMbCm9mYEDSW3t0WuMjVyg==$uRYWmgY0YTVddisnASgE+cwXdqZwbUXNnv1RIu0MD5E=:tTsYKLzeyBCWyBVk59sKALKcEJ1k7N+1Sl8sVSoP8Io="
        "dwhusr" "SCRAM-SHA-256$4096:ConFstRDhfZld2ZDpFnoxw==$vc2oGN9Khnu/9uPV3Ifimp2+GGnjgqq+gBA04dnOhYo=:CvpvWEKX4ZpjZhsrwg9ahS2ZQU/k0QLszL33W6ufoMg="
        "bkpadmin" "SCRAM-SHA-256$4096:9QTGZe3HfbyYrMQmU9uJqg==$zaubCMu6b86s8c2GEMGyOrsFjh02cBOjxX0bbOjWTIw=:EQ0tVKTr8559I1G41LsmpSixkih2oUsJprtL04NvsoI="
		"m2pappusr" "SCRAM-SHA-256$4096:H2Za7WGKx3UI/1KPryEcVg==$mcoFKwNyT9um8qhs/s87UoHFkYNn7dp+u1oTvLED+po=:4lxbD9P+q7NUaBXhoaBF8+vBFAPu3Gw5XW0zsbpsL2I="
 
	
Make a copy of existing ini file and use the below config
	cd /etc/pgbouncer/
	cp pgbouncer.ini pgbouncer.ini_old
	vi pgbouncer.ini
		;;;
		;;; PgBouncer configuration file
		;;;
		
		;; database name = connect string
		;;
		;; connect string params:
		;;   dbname= host= port= user= password= auth_user=
		;;   client_encoding= datestyle= timezone=
		;;   pool_size= reserve_pool= max_db_connections=
		;;   pool_mode= connect_query= application_name=
		[databases]
		* = host=localhost port=4554
		
		
		[pgbouncer]
		
		logfile = /dberrlog/pgbouncer/log/pgbouncer.log
		pidfile = /var/run/pgbouncer/pgbouncer.pid
		
		ignore_startup_parameters = extra_float_digits,search_path
		
		listen_addr = *
		listen_port = 4004
		
		auth_type = scram-sha-256
		auth_file = /dberrlog/pgbouncer/userlist.txt
		
		so_reuseport = 1
		unix_socket_dir =  /var/run/pgbouncer/
		
		max_client_conn = 15000
		
		pool_mode = transaction
		server_reset_query = 'DISCARD ALL'
		max_prepared_statements = 200
		server_reset_query_always = 1
		
		admin_users = db2dba
	
		stats_users = db2dba, postgres

Start the service
	service pgbouncer start

Login to PGBOUNCER to run its commands

	psql -Udb2dba -h 127.0.0.1 -p 4004 pgbouncer

To reload the config without downtime and disruption of existing applications:

	pgbouncer=# reload;
	RELOAD

	(or)

	sudo -u pgbouncer pgbouncer -R /etc/pgbouncer/pgbouncer.ini -d
