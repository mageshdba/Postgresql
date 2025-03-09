
SERVER INSTALLATION




PREREQ
-------------



Oman 1	10.80.4.16
Oman 2	10.80.4.17


 
--PREPARE DIR

/dbdata
/dblog
/backup
/dberrlog


OPEN port FOR our VPN - 5432 (default)


sudo yum -y update
sudo yum module list postgresql
https://download.postgresql.org/pub/repos/yum/reporpms/
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum -qy module disable postgresql
sudo yum install -y postgresql14-server
#sudo yum install -y postgresql13-server


This will create the initial data as well as the main configuration file, which will be written to 
/var/lib/pgsql/14/data/postgresql.conf

--Optioonal
temporary turned off SSL check and installed the packages. 

vi /etc/yum.conf 
And then on the editor just add the following line

sslverify=false


Mandatory:
==========
•	#make –version  	#GNU Make version should be 3.80 or above
•	#rpm-qa gcc		#GCC should be installed.

Optioal:
=======
•	#rpm –qa readline	#it is used for to re-call previous executed command on sql prompt.
•	#rpm –qa zlib		#It is used for data compression


cat /etc/os-release
aws s3 ls
getenforce
cat /proc/sys/vm/swappiness
ulimit -a |grep -i open
date

yum install innotop -y
yum install https://github.com/maxbube/mydumper/releases/download/v0.10.7-2/mydumper-0.10.7-2.el7.x86_64.rpm -y
yum install iotop -y
yum install iftop -y
yum install mlocate -y
yum install compat-openssl10 -y



//VERSION - PERCONA 
---------------------------------------

mkdir -p /backup/software/pgsql/14.6
mkdir /backup/software/pgsql/14.6/others


mv /home/sbic-m2p331/pgsql_Extensions.tar /backup/software/pgsql/
tar -xvf /backup/software/pgsql/Postgres_Extensions.tar



mkdir /backup/software/pgsql/14.6/
cd /backup/software/pgsql/14.6/

wget 
https://downloads.percona.com/downloads/postgresql-distribution-14/14.6/binary/redhat/8/x86_64/ppg-14.6-el8-x86_64-bundle.tar

https://downloads.percona.com/downloads/postgresql-distribution-14/14.6/binary/redhat/8/x86_64/ppg-14.6-el8-x86_64-bundle.tar

tar -xvf *.tar
rm -rvf *debug*
rm -rvf *.tar


mv *patroni* /backup/software/pgsql/14.6/others
mv *pgbadger* /backup/software/pgsql/14.6/others
mv *ha*.rpm /backup/software/pgsql/14.6/others

yum install percona-* -y

cd  /backup/software/pgsql/14.6/others/



Install Components 
----------------------------------
--PG_CRON
yum install  https://download.postgresql.org/pub/repos/yum/14/redhat/rhel-8-x86_64/pg_cron_14-1.4.1-1.rhel8.x86_64.rpm -y

--TIMESCALE
yum install https://download.postgresql.org/pub/repos/yum/reporpms/EL-$(rpm -E %{rhel})-x86_64/pgdg-redhat-repo-latest.noarch.rpm -y

(or)

tee /etc/yum.repos.d/timescale_timescaledb.repo <<EOL
[timescale_timescaledb]
name=timescale_timescaledb
baseurl=https://packagecloud.io/timescale/timescaledb/el/$(rpm -E %{rhel})/\$basearch
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/timescale/timescaledb/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
EOL


yum install timescaledb-2-postgresql-14 -y

--TIMESCALE TOOLKIT
yum install timescaledb-toolkit-postgresql-14 -y
  


mkdir -p /dbdata/pgsql/
mkdir -p /dblog/pgsql
mkdir -p /dberrlog/pgsql/
mkdir -p /dberrlog/pgsql/audit/old_logs_audit
mkdir -p /dbdata/tmp/
mkdir -p /backup/scripts/
mkdir -p /dblog/pgsql/archive
mkdir -p /dblog/pgsql/archive


chown -R postgres:postgres /dbdata/pgsql/
chown -R postgres:postgres /dblog/pgsql/
chown -R postgres:postgres /dberrlog/pgsql/
chown -R postgres:postgres /dbdata/tmp/
chown -R postgres:postgres /dblog/pgsql/archive


#--INIT DB

sudo /usr/pgsql-14/bin/postgresql-14-setup initdb 

cp -p /var/lib/pgsql/14/data/postgresql.conf /var/lib/pgsql/14/data/postgresql.conf_`date +%Y_%m_%d.%H.%M.%S`
cp -p /var/lib/pgsql/14/data/pg_hba.conf /var/lib/pgsql/14/data/pg_hba.conf_`date +%Y_%m_%d.%H.%M.%S`


grep '^[[:blank:]]*[^[:blank:]#;]' /var/lib/pgsql/14/data/postgresql.conf
grep '^[[:blank:]]*[^[:blank:]#;]' /var/lib/pgsql/14/data/pg_hba.conf


systemctl enable postgresql-14
systemctl status postgresql-14
systemctl start postgresql-14
service postgresql-14 status

--cnf
/var/lib/pgsql/14/data/pg_hba.conf
/var/lib/pgsql/14/data/postgresql.conf

sudo -u postgres psql 

 
create user db2dba  with superuser createdb password 'Smhnn@123';
CREATE USER replusr WITH replication PASSWORD 'Replusr@123';
CREATE USER m2pappusr WITH createdb PASSWORD 'Javzc9L5>Tth';
grant pg_read_all_data, pg_write_all_data to m2pappusr;
CREATE USER dwhusr WITH createdb PASSWORD 'Appusr@123';


create user bkpadmin SUPERUSER password '1w%<VO5Jx@L3' ;
ALTER USER bkpadmin set default_transaction_read_only = on;



CREATE DATABASE testdb;
SHOW data_directory;

/var/lib/pgsql/14/data

exit 

--RSYNC 
service postgresql-14 stop

OLD DIR
/var/lib/pgsql/14/data/
NEW DIR
/dbdata/pgsql/

sudo rsync -avhz /var/lib/pgsql/14/data/ /dbdata/pgsql/


--RECONFIG 

1.postgresql.conf
-------------
grep '^[[:blank:]]*[^[:blank:]#;]' /var/lib/pgsql/14/data/postgresql.conf > /var/lib/pgsql/14/data/postgresql_updated.conf 
cat /dev/null >  /var/lib/pgsql/14/data/postgresql.conf	
cat  /var/lib/pgsql/14/data/postgresql_updated.conf  > /var/lib/pgsql/14/data/postgresql.conf 

(Optinal)
chown postgres:postgres /var/lib/pgsql/14/data/postgresql.conf


2.pg_hba.conf
-------------

cat /var/lib/pgsql/14/data/pg_hba.conf  |grep '^[[:blank:]]*[^[:blank:]#;]' > /var/lib/pgsql/14/data/pg_hba_updated.conf
cat /dev/null > /var/lib/pgsql/14/data/pg_hba.conf
cat /var/lib/pgsql/14/data/pg_hba_updated.conf > /var/lib/pgsql/14/data/pg_hba.conf



RESTART/START
-------------
select pending_restart from pg_settings ;
service postgresql-14 restart

LOGIN
sudo -u postgres psql
or
sudo -i -u postgres
or
psql

SHOW data_directory;
   data_directory
--------------------
 /dbdata/pgsql
(1 row)


SHOW data_directory;
SHOW config_file;
SHOW hba_file;
show shared_preload_libraries ;

select pending_restart,name,setting from pg_settings where pending_restart='t' ;
----------------------------------------------------------------------


//Extension & control path
 mv -f /backup/software/pgsql/Postgres_Extensions/extensions/* /usr/pgsql-14/share/extension/


mv -f /home/m2p1049/Postgres_Extensions/extensions/* /usr/pgsql-14/share/extension/

 */

//so path
mv -f /backup/software/pgsql/Postgres_Extensions/so/* /usr/pgsql-14/lib/

mv -f /home/m2p1049/Postgres_Extensions/so/* /usr/pgsql-14/lib

*/

//PRIMARY

1.1 Postgres.conf
---------------
data_directory = '/dbdata/pgsql'           # use data in another directory
listen_addresses = '*'          # what IP address(es) to listen on;
port = 4554                             # (change requires restart)
max_connections = 20000                 # (change requires restart)
superuser_reserved_connections = 5      # (change requires restart)

shared_buffers = 1GB                    # min 128kB
temp_buffers = 16MB                     # min 800kB
work_mem = 128MB                                # min 64kB
maintenance_work_mem = 2GB              # min 1MB
effective_cache_size = 11GB
effective_io_concurrency = 200          # 1-1000; 0 disables prefetching

max_worker_processes = 8                # (change requires restart)
max_parallel_workers_per_gather = 4     # taken from max_parallel_workers
max_parallel_maintenance_workers = 4    # taken from max_parallel_workers
max_parallel_workers = 8                # maximum number of max_worker_processes that
checkpoint_timeout = 1800               # range 30s-1d

max_wal_size = 3GB
min_wal_size = 2GB
max_wal_senders = 3             # max number of walsender processes

recovery_target_timeline = 'latest'     # 'current', 'latest', or timeline ID

log_connections = 'on'
log_destination = 'csvlog'              # Valid values are combinations of
log_directory = '/dberrlog/pgsql/'                 # directory where log files are written,
log_disconnections = 'on'
log_filename = 'postgresql-%Y%m%d_%H%M.log'     # log file name pattern,
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,host=%h'               # special values:
log_min_messages = warning              # values in order of decreasing detail:
log_rotation_age = 1d                   # Automatic rotation of logfiles will
log_rotation_size = 0                   # Automatic rotation of logfiles will
log_statement = 'mod'                   # none, ddl, mod, all
log_timezone = 'Asia/Kolkata'
log_truncate_on_rotation = on           # If on, an existing log file with the
logging_collector = on                  # Enable capturing of stderr and csvlog

#shared_preload_libraries = 'pg_cron,pgcrypto,pg_stat_statements,timescaledb,pgaudit,pgauditlogtofile,dblink'    # (change requires restart)

wal_level = hot_standby 
hot_standby = on                        # "off" disallows queries during recovery                # minimal, replica, or logical
archive_mode = on               # enables archiving; off, on, or always
archive_command = 'test ! -f /dblog/pgsql/archive/%f && cp %p /dblog/pgsql/archive/%f'          # command to use to archive a logfile segment
#primary_conninfo = 'user=replusr port=5665 host=172.190.11.61 application_name=172.190.11.61.replusr'                  
#primary_slot_name = 'replication_slot'                   

pgaudit.log_directory='/dberrlog/pgsql/audit'
pgaudit.log = 'ddl, role, read, write'
pgaudit.log_catalog = on
pgaudit.log_level = warning



//STANDBY 


1.2 Postgres.conf
---------------
data_directory = '/dbdata/pgsql'           # use data in another directory
listen_addresses = '*'          # what IP address(es) to listen on;
port = 4554                             # (change requires restart)
max_connections = 20000                 # (change requires restart)
superuser_reserved_connections = 5      # (change requires restart)

shared_buffers = 1GB                    # min 128kB
temp_buffers = 16MB                     # min 800kB
work_mem = 128MB                                # min 64kB
maintenance_work_mem = 2GB              # min 1MB
effective_cache_size = 11GB
effective_io_concurrency = 200          # 1-1000; 0 disables prefetching

max_worker_processes = 8                # (change requires restart)
max_parallel_workers_per_gather = 4     # taken from max_parallel_workers
max_parallel_maintenance_workers = 4    # taken from max_parallel_workers
max_parallel_workers = 8                # maximum number of max_worker_processes that
checkpoint_timeout = 1800               # range 30s-1d

max_wal_size = 3GB
min_wal_size = 2GB
max_wal_senders = 3             # max number of walsender processes

recovery_target_timeline = 'latest'     # 'current', 'latest', or timeline ID

log_connections = 'on'
log_destination = 'stderr'              # Valid values are combinations of
log_directory = '/dberrlog/pgsql/'                 # directory where log files are written,
log_disconnections = 'on'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,host=%h '
log_min_messages = warning
log_rotation_age = 1d
log_rotation_size = 0                   # Automatic rotation of logfiles will
log_statement = 'mod'
log_timezone = 'Asia/Kolkata'
log_truncate_on_rotation = on           # If on, an existing log file with the
logging_collector = on

shared_preload_libraries = 'pg_cron,pgcrypto,pg_stat_statements,timescaledb,pgaudit,pgauditlogtofile,dblink'    # (change requires restart)

wal_level = hot_standby                 # minimal, replica, or logical
hot_standby = on                        
archive_mode = always           # enables archiving; off, on, or always
archive_command = 'test ! -f /dblog/pgsql/archive/%f && cp %p /dblog/pgsql/archive/%f'          # command to use to archive a logfile segment
primary_conninfo = 'user=replusr port=5665 host=172.190.10.24 application_name=172.190.10.24.replusr'                  
primary_slot_name = 'primary_repl_slot'                   


pgaudit.log_directory='/dberrlog/pgsql/audit'
pgaudit.log = 'ddl, role, read, write'
pgaudit.log_catalog = on
pgaudit.log_level = warning


cat /dev/null > /var/lib/pgsql/14/data/pg_hba.conf


//PRIMARY 
2.1 Hba.conf
----------

echo "local   all             all                                     peer"                   >> /var/lib/pgsql/14/data/pg_hba.conf
echo "host    all             all             0.0.0.0/0           scram-sha-256"              >> /var/lib/pgsql/14/data/pg_hba.conf
echo "host    replication     replusr             172.190.11.61/32            scram-sha-256"   >> /var/lib/pgsql/14/data/pg_hba.conf

//STANDBY 
2.2 Hba.conf
----------

echo "local   all             all                                     peer"                   >> /var/lib/pgsql/14/data/pg_hba.conf
echo "host    all             all             0.0.0.0/0            scram-sha-256"             >> /var/lib/pgsql/14/data/pg_hba.conf
echo "host    replication     replusr            172.190.10.24/32            scram-sha-256"  >> /var/lib/pgsql/14/data/pg_hba.conf

cat /var/lib/pgsql/14/data/pg_hba.conf


//LOGIN TYPE
sudo psql -U m2p331 -W -h 172.122.7.152  -p 5665 postgres
psql -h 174.1.0.7  -p 5432 -U readme postgres

grep '^[[:blank:]]*[^[:blank:]#;]' /var/lib/pgsql/14/data/postgresql.conf

/usr/pgsql-14/bin/pg_ctl -D /dbdata/pgsql/data/ stop 

service postgresql-14 restart

sudo -u postgres psql --port 5665


//CREATE EXTENSION 


	create extension plpgsql;
	CREATE EXTENSION dblink;
	create extension pgcrypto;
	create extension pg_stat_statements;
	create extension pg_cron;
	create extension timescaledb;
	CREATE EXTENSION timescaledb_toolkit;
	create extension pgaudit;
	create extension pgauditlogtofile;

select * from pg_extension;


=============================== END OF INSTALLATION  ===================================

=============================== BEGINNING OF CLUSTER ====================================


Step 1:  Login TO Postgres
------------------
Run PSQL as user postgres and access the database named postgres:

sudo -u postgres psql postgres



Step 2: Create a user for REPLICATION wih REPLICATION role
-----------------------------
create user replusr with REPLICATION password 'Replusr@123' login;

OR 

sudo -u postgres createuser -U postgres replusr -P -c 5 --replication

create user replusr with password 'Repl@123';

/*This command performs the following actions:
sudo -u postgres ensures that the createuser command runs as the user postgres. 
Otherwise, Postgres will try to run the command by using peer authentication, which means the command will run under your Ubuntu user account. 
This account probably doesn't have the right privileges to create the new user, which would cause an error.
The -U option tells the createuser command to use the user postgres to create the new user.
The name of the new user is replication. You'll enter that username in the configuration files.
-P prompts you for the new user's password.
-c sets a limit for the number of connections for the new user. The value 5 is sufficient for replication purposes.
--replication grants the REPLICATION privilege to the user named replication.*/




Step 2: Edit Config files - primary
-----------------------------
/*Add and adjust these settings to that file to enable replication*/

--postgresql.conf
vi /var/lib/pgsql/14/data/postgresql.conf


wal_level = hot_standby 
hot_standby = on                        # "off" disallows queries during recovery                # minimal, replica, or logical
archive_mode = on               # enables archiving; off, on, or always
archive_command = 'test ! -f /dblog/pgsql/archive/%f && cp %p /dblog/pgsql/archive/%f'          # command to use to archive a logfile segment
primary_conninfo = 'user=replusr port=5665 host=172.168.0.70 application_name=172.168.0.70.replusr'                  
primary_slot_name = 'standby_repl_slot'  

--pg_hba.conf
cat /var/lib/pgsql/14/data/pg_hba.conf

host    all             all             0.0.0.0/0            scram-sha-256
host    replication     replusr             173.11.37.82/32            scram-sha-256



Step 2: Edit Config files - Standby
-----------------------------

--postgresql.conf
vi /var/lib/pgsql/14/data/postgresql.conf

wal_level = hot_standby                 # minimal, replica, or logical
hot_standby = on                        
archive_mode = always           # enables archiving; off, on, or always
archive_command = 'test ! -f /data/dblog/pgsql-14/archive/%f && cp %p /data/dblog/pgsql-14/archive/%f'          # command to use to archive a logfile segment
primary_conninfo = 'user=replusr port=4554 host=172.168.0.51 application_name=172.168.0.51.replusr'                  
primary_slot_name = 'primary_repl_slot'  

--pg_hba.conf
cat /var/lib/pgsql/14/data/pg_hba.conf

host    all             all             0.0.0.0/0            scram-sha-256
host    replication     replusr             10.80.4.16/32            scram-sha-256


Step 4: CREATE Slots
-----------------------------

select slot_name, active, slot_type, wal_status from pg_replication_slots;


--On PR
select * from pg_create_physical_replication_slot('primary_repl_slot');

--On DR (Optional)

select * from pg_create_physical_replication_slot('replication_slot');

--to drop
select pg_drop_replication_slot('primary_repl_slot');
  


Step 6: Restart the primary server
-----------------------------
service postgresql-14 restart

STANDBY
=======


Step 7 : Stop postgres AND clear data 
-----------------------------
service postgresql-14 stop


rm -rvf *  /dbdata/pgsql/

chown -R  postgres:postgres postgres

--OR
initdb -E UTF-8 /dbdata/pgsql

Step 8: Run the backup utility
-----------------------------
VERSION 14
sudo -u postgres pg_basebackup --pgdata /data/dbdata/psql-14 --format=p --write-recovery-conf --checkpoint=fast --label=mffb --progress --host=172.168.0.51--port=4554 --username=replusr

OR

sudo -u postgres pg_basebackup -h 172.184.57.47 -D /dbdata/pgsql/ -U replication -v -P --xlog-method=stream 
pg_basebackup -h 174.1.0.6 -D /dbdata/pgsql/ -U replication -v -P --xlog-method=stream 
pg_basebackup -h 174.1.0.6 -U replication -D /dbdata/pgsql/
pg_basebackup -h 174.1.0.6 -U replication --checkpoint=fast \ -D /dbdata/pgsql/ -R --slot=some_name -C
pg_basebackup -h 174.1.0.6 -U replication -D /dbdata/pgsql/ --checkpoint=fast -R --slot=some_name -C

cd /dbdata/pgsql
sudo -u pg_basebackup --pgdata /dbdata/pgsql --format=p --write-recovery-conf --checkpoint=fast --label=mffb --progress --host=172.184.73.38 --port=5665 --username=replusr

Node 3
pg_basebackup -h 174.1.0.6 -U replication -D /dbdata/pgsql/ --checkpoint=fast -R --slot=some_name2 -C


==================================== END ===============================================
yum install percona-haproxy -y
 yum install percona-patroni -y
 yum install percona-pgbadger -y
 #yum install pgauditlogtofile_14.x86_64 -y


Some extensions require additional setup in order to use them with Percona Distribution for PostgreSQL. For more information, refer to Enabling extensions.

Starting the service¶

On Debian and Ubuntu
On Red Hat Enterprise Linux and derivatives
After the installation, the default database storage is not automatically initialized. To complete the installation and start Percona Distribution for PostgreSQL, initialize the database using the following command:


/usr/pgsql-15/bin/pgsqlql-15-setup initdb
Start the PostgreSQL service:


sudo systemctl start postgresql-15

Next steps: connect to PostgreSQL.

Enabling extensions¶
Some extensions require additional configuration before using them with Percona Distribution for PostgreSQL. This sections provides configuration instructions per extension.

Patroni

Patroni is the third-party high availability solution for PostgreSQL. The High Availability in PostgreSQL with Patroni chapter provides details about the solution overview and architecture deployment.

While setting up a high availability PostgreSQL cluster with Patroni, you will need the following components:

Patroni installed on every postresql node.

Distributed Configuration Store (DCS). Patroni supports such DCSs as ETCD, zookeeper, Kubernetes though ETCD is the most popular one. It is available upstream as DEB packages for Debian 10, 11 and Ubuntu 18.04, 20.04, 22.04.

For CentOS 8, RPM packages for ETCD is available within Percona Distribution for PostreSQL. You can install it using the following command:


sudo yum install etcd python3-python-etcd
HAProxy.

See the configuration guidelines for Debian and Ubuntu and RHEL and CentOS.

See also

Patroni documentation

Percona Blog:

PostgreSQL HA with Patroni: Your Turn to Test Failure Scenarios
pgBadger

Enable the following options in postgresql.conf configuration file before starting the service:


log_min_duration_statement = 0
log_line_prefix = '%t [%p]: '
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on
log_temp_files = 0
log_autovacuum_min_duration = 0
log_error_verbosity = default
For details about each option, see pdBadger documentation.

pgAudit set-user

Add the set-user to shared_preload_libraries in postgresql.conf. The recommended way is to use the ALTER SYSTEM command. Connect to psql and use the following command:


ALTER SYSTEM SET shared_preload_libraries = 'set-user';
Start / restart the server to apply the configuration.

You can fine-tune user behavior with the custom parameters supplied with the extension.

wal2json

After the installation, enable the following option in postgresql.conf configuration file before starting the service:


wal_level = logical
Connect to the PostgreSQL server¶
By default, postgres user and postgres database are created in PostgreSQL upon its installation and initialization. This allows you to connect to the database as the postgres user.


sudo su postgres
Open the PostgreSQL interactive terminal:


psql
Hint

You can connect to psql as the postgres user in one go:


sudo su postgres psql
To exit the psql terminal, use the following command:


\q
Contact Us
For free technical help, visit the Percona Community Forum.




Steps:
======
step1:Get the Instructons from postgresql.org

sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-6-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum install -y postgresql12-server


sudo service postgresql-12 initdb
sudo chkconfig postgresql-12 on
sudo service postgresql-12 start

Step-2:Install the Reposteries

sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-6-x86_64/pgdg-redhat-repo-latest.noarch.rpm

[root@machine4 ~]# sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-6-x86_64/pgdg-redhat-repo-latest.noarch.rpm
Freeing read locks for locker 0x5: 13205/140084433028864
Freeing read locks for locker 0x7: 13205/140084433028864
Loaded plugins: refresh-packagekit, security, ulninfo
Setting up Install Process
pgdg-redhat-repo-latest.noarch.rpm                                                                 | 6.5 kB     00:00
Examining /var/tmp/yum-root-Wlrfc3/pgdg-redhat-repo-latest.noarch.rpm: pgdg-redhat-repo-42.0-11.noarch
Marking /var/tmp/yum-root-Wlrfc3/pgdg-redhat-repo-latest.noarch.rpm to be installed
Resolving Dependencies
--> Running transaction check
---> Package pgdg-redhat-repo.noarch 0:42.0-11 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

==========================================================================================================================
 Package                      Arch               Version                Repository                                   Size
==========================================================================================================================
Installing:
 pgdg-redhat-repo             noarch             42.0-11                /pgdg-redhat-repo-latest.noarch              11 k

Transaction Summary
==========================================================================================================================
Install       1 Package(s)

Total size: 11 k
Installed size: 11 k
Downloading Packages:
Running rpm_check_debug
Running Transaction Test
Transaction Test Succeeded
Running Transaction
  Installing : pgdg-redhat-repo-42.0-11.noarch                                                                        1/1
  Verifying  : pgdg-redhat-repo-42.0-11.noarch                                                                        1/1

Installed:
  pgdg-redhat-repo.noarch 0:42.0-11

Complete!

Step-2:Install the serve:
========================

[root@machine4 ~]# sudo yum install -y postgresql12-server
Loaded plugins: refresh-packagekit, security, ulninfo
Setting up Install Process
Resolving Dependencies
--> Running transaction check
---> Package postgresql12-server.x86_64 0:12.6-2PGDG.rhel6 will be installed
--> Processing Dependency: postgresql12-libs(x86-64) = 12.6-2PGDG.rhel6 for package: postgresql12-server-12.6-2PGDG.rhel6.x86_64
--> Processing Dependency: postgresql12(x86-64) = 12.6-2PGDG.rhel6 for package: postgresql12-server-12.6-2PGDG.rhel6.x86_64
--> Running transaction check
---> Package postgresql12.x86_64 0:12.6-2PGDG.rhel6 will be installed
---> Package postgresql12-libs.x86_64 0:12.6-2PGDG.rhel6 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

==========================================================================================================================
 Package                             Arch                   Version                          Repository              Size
==========================================================================================================================
Installing:
 postgresql12-server                 x86_64                 12.6-2PGDG.rhel6                 pgdg12                 5.6 M
Installing for dependencies:
 postgresql12                        x86_64                 12.6-2PGDG.rhel6                 pgdg12                 1.7 M
 postgresql12-libs                   x86_64                 12.6-2PGDG.rhel6                 pgdg12                 340 k

Transaction Summary
==========================================================================================================================
Install       3 Package(s)

Total download size: 7.6 M
Installed size: 30 M
Downloading Packages:
(1/3): postgresql12-12.6-2PGDG.rhel6.x86_64.rpm                                                    | 1.7 MB     00:02
(2/3): postgresql12-libs-12.6-2PGDG.rhel6.x86_64.rpm                                               | 340 kB     00:00
(3/3): postgresql12-server-12.6-2PGDG.rhel6.x86_64.rpm                                             | 5.6 MB     00:06
--------------------------------------------------------------------------------------------------------------------------
Total                                                                                     717 kB/s | 7.6 MB     00:10
warning: rpmts_HdrFromFdno: Header V4 DSA/SHA1 Signature, key ID 442df0f8: NOKEY
Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG
Importing GPG key 0x442DF0F8:
 Userid : PostgreSQL RPM Building Project <pgsqlrpms-hackers@pgfoundry.org>
 Package: pgdg-redhat-repo-42.0-11.noarch (@/pgdg-redhat-repo-latest.noarch)
 From   : /etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG
Running rpm_check_debug
Running Transaction Test
Transaction Test Succeeded
Running Transaction
  Installing : postgresql12-libs-12.6-2PGDG.rhel6.x86_64                                                              1/3
  Installing : postgresql12-12.6-2PGDG.rhel6.x86_64                                                                   2/3
  Installing : postgresql12-server-12.6-2PGDG.rhel6.x86_64                                                            3/3
  Verifying  : postgresql12-server-12.6-2PGDG.rhel6.x86_64                                                            1/3
  Verifying  : postgresql12-12.6-2PGDG.rhel6.x86_64                                                                   2/3
  Verifying  : postgresql12-libs-12.6-2PGDG.rhel6.x86_64                                                              3/3

Installed:
  postgresql12-server.x86_64 0:12.6-2PGDG.rhel6

Dependency Installed:
  postgresql12.x86_64 0:12.6-2PGDG.rhel6                    postgresql12-libs.x86_64 0:12.6-2PGDG.rhel6

Complete!

Step-3:Create the cluster
=========================
[root@machine4 ~]# sudo service postgresql-12 initdb
Initializing database:                                     [  OK  ]

Step-4: execute the below one.
===================================
[root@machine4 ~]# sudo chkconfig postgresql-12 on

Step-5:To start the services
============================
[root@machine4 ~]# sudo service postgresql-12 start
Starting postgresql-12 service:                            [  OK  ]

Step-6:To check the cluster Data Directory
=======================================


[root@machine4 ~]# su - postgres
-bash-4.1$ ps -efa|grep postgres
postgres 13898     1  0 16:43 ?        00:00:00 /usr/pgsql-12/bin/postmaster -D /var/lib/pgsql/12/data
postgres 13900 13898  0 16:43 ?        00:00:00 postgres: logger
postgres 13902 13898  0 16:43 ?        00:00:00 postgres: checkpointer
postgres 13903 13898  0 16:43 ?        00:00:00 postgres: background writer
postgres 13904 13898  0 16:43 ?        00:00:00 postgres: walwriter
postgres 13905 13898  0 16:43 ?        00:00:00 postgres: autovacuum launcher
postgres 13906 13898  0 16:43 ?        00:00:00 postgres: stats collector
postgres 13907 13898  0 16:43 ?        00:00:00 postgres: logical replication launcher
root     14074 13795  0 16:46 pts/2    00:00:00 su - postgres
postgres 14075 14074  0 16:46 pts/2    00:00:00 -bash
postgres 14106 14075  3 16:46 pts/2    00:00:00 ps -efa
postgres 14107 14075  0 16:46 pts/2    00:00:00 grep postgres

Step-7:To connect the server
===========================
#su - postgres
-bash-4.1$ psql
psql (8.4.20, server 12.6)
WARNING: psql version 8.4, server version 12.0.
         Some psql features might not work.
Type "help" for help.

postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |  Collation  |    Ctype    |   Access privileges
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/pgsql
                                                             : postgres=CTc/pgsql
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/pgsql
                                                             : postgres=CTc/pgsql
(3 rows)


[root@machine1 ~]# ps -efa|grep postgres
postgres  3576     1  0 02:22 ?        00:00:00 /usr/pgsql-11/bin/postmaster -D /var/lib/pgsql/11/data
postgres  3578  3576  0 02:22 ?        00:00:00 postgres: logger
postgres  3580  3576  0 02:22 ?        00:00:00 postgres: checkpointer
postgres  3581  3576  0 02:22 ?        00:00:00 postgres: background writer
postgres  3582  3576  0 02:22 ?        00:00:00 postgres: walwriter
postgres  3583  3576  0 02:22 ?        00:00:00 postgres: autovacuum launcher
postgres  3584  3576  0 02:22 ?        00:00:00 postgres: stats collector
postgres  3585  3576  0 02:22 ?        00:00:00 postgres: logical replication launcher
root      3590  3342  0 02:22 pts/1    00:00:00 grep postgres


--Red Hat Enterprise Linux v8
sudo dnf module disable postgresql llvm-toolset 

/*On CentOS 7, you should install the epel-release package */
sudo yum -y install epel-release
sudo yum repolist

Configure the repository¶
Install the percona-release repository management tool to subscribe to Percona repositories:

	sudo yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm

1 Enable the repository

Percona provides two repositories for Percona Distribution for PostgreSQL. We recommend enabling the Major release repository to timely receive the latest updates.

To enable a repository, we recommend using the setup command:


sudo percona-release setup ppg-14


PERCONA 

wget https://downloads.percona.com/downloads/pgsqlql-distribution-14/14.6/binary/redhat/8/x86_64/ppg-14.6-el8-x86_64-bundle.tar


--Install the PostgreSQL server package:
sudo yum install percona-postgresql14-server

--Install Components 
sudo yum install percona-haproxy -y
sudo yum install percona-patroni -y
sudo yum install percona-pg_repack14 -y
sudo yum install percona-pgaudit -y
sudo yum install percona-pgaudit14_set_user -y
sudo yum install percona-pgbackrest -y
sudo yum install percona-pgbadger -y
sudo yum install percona-pgbouncer -y
sudo yum install percona-postgresql14-contrib -y
sudo yum install percona-wal2json14 -y
sudo yum install percona-pgaudit.x86_64 -y


/*Start the service¶
After the installation, the default database storage is not automatically initialized. To complete the installation and start Percona Distribution for PostgreSQL, initialize the database using the following command: */
	/usr/pgsql-14/bin/pgsqlql-14-setup initdb 

Start the PostgreSQL service:

sudo systemctl start postgresql-14

Connect to the PostgreSQL server¶
By default, postgres user and postgres database are created in PostgreSQL upon its installation and initialization. This allows you to connect to the database as the postgres user.

sudo -u postgres psql
Open the PostgreSQL interactive terminal:


psql
Hint

You can connect to psql as the postgres user in one go:


sudo su postgres psql
To exit the psql terminal, use the following command:


\q
Contact Us
For free technical help, visit the Percona Community Forum.
To report bugs or submit feature requests, open a JIRA ticket.
For paid support and managed or consulting services , contact Percona Sales.


sudo yum install postgresql13 postgresql13-server
--------------------------------------------------



======================================
CLIENT INSTALL (v10)


sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum -qy module disable postgresql
sudo yum install -y postgresql10-server
sudo /usr/pgsql-10/bin/pgsqlql-10-setup initdb
sudo systemctl enable postgresql-10
sudo systemctl start postgresql-10

CLIENT INSTALL (v12)

sudo yum -y update

sudo tee /etc/yum.repos.d/pgdg.repo<<EOF
[pgdg12]
name=PostgreSQL 12 for RHEL/CentOS 7 - x86_64
baseurl=https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-7-x86_64
enabled=1
gpgcheck=0
EOF

cat  /etc/yum.repos.d/pgdg.repo
[pgdg12]
name=PostgreSQL 12 for RHEL/CentOS 7 - x86_64
baseurl=https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-7-x86_64
enabled=1
gpgcheck=0


sudo yum install postgresql12 


[m2p331@aws-m2p-jumpbox01 ~]$ rpm -qa |grep postgres
postgresql14-libs-14.2-1PGDG.rhel7.x86_64
postgresql14-14.2-1PGDG.rhel7.x86_64
[m2p331@aws-m2p-jumpbox01 ~]$


CLIENT INSTALL (v13)

cat /etc/yum.repos.d/pgdg.repo
pgdg13]
name=PostgreSQL 13 for RHEL/CentOS 7 - x86_64
baseurl=https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-7-x86_64
enabled=1
gpgcheck=0




[root@aws-ind-aps1-m2p-r360-prd-pgsqldb01 ~]# grep '^[[:blank:]]*[^[:blank:]#;]' /var/lib/pgsql/14/data/postgresql.conf > /var/lib/pgsql/14/data/postgresql.conf  

data_directory = '/dbdata/pgsql'           # use data in another directory
listen_addresses = '*'          # what IP address(es) to listen on;
port = 5665                             # (change requires restart)
max_connections = 20000                 # (change requires restart)
superuser_reserved_connections = 5      # (change requires restart)

shared_buffers = 1GB                    # min 128kB
temp_buffers = 16MB                     # min 800kB
work_mem = 128MB                                # min 64kB
maintenance_work_mem = 2GB              # min 1MB
effective_io_concurrency = 200          # 1-1000; 0 disables prefetching
max_worker_processes = 8                # (change requires restart)
max_parallel_workers_per_gather = 4     # taken from max_parallel_workers
max_parallel_maintenance_workers = 4    # taken from max_parallel_workers
max_parallel_workers = 8                # maximum number of max_worker_processes that
max_wal_size = 3GB
min_wal_size = 2GB
recovery_target_timeline = 'latest'     # 'current', 'latest', or timeline ID
max_wal_senders = 3             # max number of walsender processes
effective_cache_size = 11GB

log_directory = '/dberrlog/pgsql/'                 # directory where log files are written,
log_destination = 'csvlog'              # Valid values are combinations of
logging_collector = on                  # Enable capturing of stderr and csvlog
log_filename = 'postgresql-%Y%m%d_%H%M.log'     # log file name pattern,
log_rotation_age = 1d                   # Automatic rotation of logfiles will
log_rotation_size = 0                   # Automatic rotation of logfiles will
log_truncate_on_rotation = on           # If on, an existing log file with the
log_min_messages = warning              # values in order of decreasing detail:
log_connections = 'on'
log_disconnections = 'on'
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,host=%h'               # special values:
log_statement = 'mod'                   # none, ddl, mod, all

shared_preload_libraries = 'pg_cron,pgcrypto,pg_stat_statements,timescaledb,pgaudit,pgauditlogtofile,dblink'    # (change requires restart)

wal_level = hot_standby 
hot_standby = on                        # "off" disallows queries during recovery                # minimal, replica, or logical
archive_mode = on               # enables archiving; off, on, or always
archive_command = 'test ! -f /dblog/pgsql/archive/%f && cp %p /dblog/pgsql/archive/%f'          # command to use to archive a logfile segment
primary_conninfo = 'user=replusr port=5665 host=10.80.4.16 application_name=10.80.4.16.replusr'                  
primary_slot_name = 'standby_repl_slot'                   

pgaudit.log_directory='/dberrlog/pgsql/audit'
pgaudit.log = 'ddl, role, read, write'
pgaudit.log_catalog = on
pgaudit.log_level = warning




--DR

data_directory = '/dbdata/pgsql'           # use data in another directory
listen_addresses = '*'          # what IP address(es) to listen on;
port = 5665                             # (change requires restart)
max_connections = 20000                 # (change requires restart)
superuser_reserved_connections = 5      # (change requires restart)

shared_buffers = 8GB                    # min 128kB
temp_buffers = 16MB                     # min 800kB
work_mem = 128MB                                # min 64kB
maintenance_work_mem = 2GB              # min 1MB
effective_cache_size = 11GB
max_stack_depth = 2MB                   # min 100kB
effective_io_concurrency = 200          # 1-1000; 0 disables prefetching
max_worker_processes = 8                # (change requires restart)
max_parallel_workers_per_gather = 4     # taken from max_parallel_workers
max_parallel_workers = 8                # maximum number of max_worker_processes that
checkpoint_timeout = 1800               # range 30s-1d
max_wal_size = 3GB
min_wal_size = 2GB
max_wal_senders = 3             # max number of walsender processes

log_directory = '/dberrlog/pgsql/'                 # directory where log files are written,
log_destination = 'stderr'              # Valid values are combinations of
log_rotation_age = 1d                   # Automatic rotation of logfiles will
log_rotation_size = 0                   # Automatic rotation of logfiles will
log_truncate_on_rotation = on           # If on, an existing log file with the
log_line_prefix = '%m [%p] '            # special values:
log_timezone = 'Asia/Kolkata'
logging_collector = on
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_min_messages = warning
log_connections = 'on'
log_disconnections = 'on'
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,host=%h '
log_statement = 'mod'

shared_preload_libraries = 'pg_cron,pgcrypto,pg_stat_statements,timescaledb,pgaudit,pgauditlogtofile,dblink'    # (change requires restart)

archive_mode = always           # enables archiving; off, on, or always
wal_level = hot_standby                 # minimal, replica, or logical
primary_conninfo = 'user=replusr port=5665 host=10.80.4.16 application_name=10.80.4.16.replusr'                  
primary_slot_name = 'primary_repl_slot'                   
hot_standby = on                        # "off" disallows queries during recovery

archive_command = 'test ! -f /dblog/pgsql/archive/%f && cp %p /dblog/pgsql/archive/%f'          # command to use to archive a logfile segment

pgaudit.log_directory='/dberrlog/pgsql/audit'
pgaudit.log='write,ddl'
pgaudit.log = 'ddl, role, read, write'
pgaudit.log_catalog = on
pgaudit.log_level = warning




[root@aws-ind-aps1-m2p-r360-prd-pgsqldb01 ~]# grep '^[[:blank:]]*[^[:blank:]#;]' /var/lib/pgsql/14/data/pg_hba.conf
local   all             all                                     peer
host    all             all             0.0.0.0/0            scram-sha-256
host    all             all             ::1/128                 scram-sha-256
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            scram-sha-256
host    replication     all             ::1/128                 scram-sha-256
host    replication     replication           172.184.1.81/32                 md5
[root@aws-ind-aps1-m2p-r360-prd-pgsqldb01 ~]#
[root@aws-ind-aps1-m2p-r360-prd-pgsqldb01 ~]#

