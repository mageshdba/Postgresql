Postgresql 14 to 16 upgrade :


REF : https://docs.percona.com/postgresql/15/major-upgrade.html#on-red-hat-enterprise-linux-and-centos-using-yum

Note  :

1.Data_directory of  psql-16 must create in the data_directory of psql-14 .
	/dbdata/pgsql-14/
	/dbdata/pgsql-16/

2. Before check the pg_upgrade ,should stop the old and new versions of postgresql .



#Install Percona Distribution for PostgreSQL 16 packages.

#Enable Percona repository:
yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm

#Install percona-release :
sudo percona-release setup ppg16
sudo yum install percona-ppg-server16	

#Extensions:

timescale
-----------
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

On v14
yum install timescaledb-2-postgresql-16 -y  
yum install timescaledb-toolkit-postgresql-16 -y
yum install percona-pgaudit14-*
On v16
yum install timescaledb-2-postgresql-16 -y  
yum install timescaledb-toolkit-postgresql-16 -y

#stat_monitor
yum install percona-pg_stat_monitor16  -y

#pg_cron
yum install  https://download.postgresql.org/pub/repos/yum/16/redhat/rhel-$(rpm -E %{rhel})-x86_64/pg_cron_16-1.6.2-1PGDG.rhel$(rpm -E %{rhel}).x86_64.rpm -y

yum download  https://download.postgresql.org/pub/repos/yum/16/redhat/rhel-$(rpm -E %{rhel})-x86_64/pg_cron_16-1.6.2-1PGDG.rhel$(rpm -E %{rhel}).x86_64.rpm -y
#initilize the db 
/usr/pgsql-16/bin/postgresql-16-setup initdb

#start the service 

sudo systemctl start postgresql-16

#Ensure the packages is installed or not which is compatiable to psql-16
percona-postgresql16-libs-16.1-2.el9.x86_64
percona-postgresql16-16.1-2.el9.x86_64
percona-postgresql16-server-16.1-2.el9.x86_64
percona-postgresql16-contrib-16.1-2.el9.x86_64
timescaledb-2-loader-postgresql-16-2.13.1-0.el9.x86_64
timescaledb-2-postgresql-16-2.13.1-0.el9.x86_64
timescaledb-toolkit-postgresql-16-1.18.0-0.x86_64

##Need to install the extensions rpm which are present in older version of postgresql. 

##for example :
In older version ,if the timescaledb were installed in two more versions like 2.12.2 & 2.13.1 , we should install the same in the newer postgres version also .


#CONF BACKUP
cp -p /var/lib/pgsql/16/data/postgresql.conf   /var/lib/pgsql/16/data/postgresql.conf_`date +%Y_%m_%d.%H.%M.%S`
cp -p /var/lib/pgsql/16/data/pg_hba.conf /var/lib/pgsql/16/data/pg_hba.conf_`date +%Y_%m_%d.%H.%M.%S`

chown -R postgres:postgres /var/lib/pgsql/16/data/

chown -R postgres:postgres  /dbdata/pgsql-16/

rsync -av /var/lib/pgsql/16/data/ /dbdata/pgsql-16/

#Edit the postgresql.conf file :
##change the conf file and hba file in new version compatible as same like older version .

vi /var/lib/pgsql/16/data/postgresql.conf

[root@aws-aps1-poc-demo-dbs-03 ~]# cat /var/lib/pgsql/16/data/postgresql.conf
data_directory = '/dbdata/pgsql-16'
log_directory = '/dberrlog/pgsql-16'
listen_addresses = '*'
port = 5432
max_connections = 10000
superuser_reserved_connections = 5

shared_buffers = 580MB
work_mem = 64MB
maintenance_work_mem = 193MB
effective_cache_size=1548

max_worker_processes = 8
max_parallel_workers_per_gather = 4
max_parallel_maintenance_workers = 4
max_parallel_workers = 8
checkpoint_timeout = 1800

max_wal_size = 3GB
min_wal_size = 2GB
max_wal_senders = 3

log_connections = 'on'
log_destination = 'csvlog'
log_disconnections = 'on'
log_filename = 'postgresql-%Y%m%d_%H%M.log'
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,host=%h'
log_min_messages = warning
log_rotation_age = 1d
log_rotation_size = 0
log_statement = 'mod'
log_timezone = 'Asia/Kolkata'
log_truncate_on_rotation = on
logging_collector = on

shared_preload_libraries = 'pg_cron,pgcrypto,pg_stat_statements,timescaledb,pgaudit,dblink,pg_stat_monitor'

wal_level = hot_standby
hot_standby = on
archive_mode = on
archive_command = 'test ! -f /dblog/pgsql-16/archive-14/%f && cp %p /dblog/pgsql-16/archive-14/%f'
#primary_conninfo = 'user=replusr port=5665 host= application_name=.replusr'
primary_slot_name = 'slot_1'
pgaudit.log_directory='/dberrorlog/audit-16'
pgaudit.log = 'ddl, role, read, write'
pgaudit.log_catalog = on
pgaudit.log_level = warning

#change the hba file 

vi /var/lib/pgsql/16/data/pg_hba.conf

[root@aws-aps1-poc-demo-dbs-03 ~]# cat /var/lib/pgsql/16/data/pg_hba.conf
local   all             all                                     peer
host    all             all             0.0.0.0/0           scram-sha-256

#start the service 

service postgresql-16 start

#stop the service in 14 & 16  :

service postgresql-14 stop 

service postgresql-16 stop 

#switch the user as postgres :

su - postgres 

1. check the pg_upgrade *Clusters are compatible*

Please change the respective datadir path in the --old-datadir and --new-datadir 

Before running the command.

/usr/pgsql-16/bin/pg_upgrade --old-bindir /usr/pgsql-14/bin --new-bindir /usr/pgsql-16/bin  --old-datadir /dbdata/pgsql  --new-datadir /dbdata/pgsql-16 --check 


[postgres@aws-aps1-poc-demo-dbs-03 ~]$ /usr/pgsql-16/bin/pg_upgrade --old-bindir /usr/pgsql-14/bin --new-bindir /usr/pgsql-16/bin  --old-datadir /dbdata/pgsql  --new-datadir /data/dbdata/pgsql-16 --check
Performing Consistency Checks
-----------------------------
Checking cluster versions                                     ok
Checking database user is the install user                    ok
Checking database connection settings                         ok
Checking for prepared transactions                            ok
Checking for system-defined composite types in user tables    ok
Checking for reg* data types in user tables                   ok
Checking for contrib/isn with bigint-passing mismatch         ok
Checking for incompatible "aclitem" data type in user tables  ok
Checking for presence of required libraries                   ok
Checking database user is the install user                    ok
Checking for prepared transactions                            ok
Checking for new cluster tablespace directories               ok

*Clusters are compatible*


2. once it completed then link the old version to new version using the below command 

usr/pgsql-16/bin/pg_upgrade --old-bindir /usr/pgsql-14/bin --new-bindir /usr/pgsql-16/bin  --old-datadir /data/dbdata/pgsql-14  --new-datadir /data/dbdata/pgsql-16 --link
<<------------------------------------------------------------------------------------------------
Performing Consistency Checks
-----------------------------
Checking cluster versions                                     ok
Checking database user is the install user                    ok
Checking database connection settings                         ok
Checking for prepared transactions                            ok
Checking for system-defined composite types in user tables    ok
Checking for reg* data types in user tables                   ok
Checking for contrib/isn with bigint-passing mismatch         ok
Checking for incompatible "aclitem" data type in user tables  ok
Creating dump of global objects                               ok
Creating dump of database schemas
                                                              ok
Checking for presence of required libraries                   ok
Checking database user is the install user                    ok
Checking for prepared transactions                            ok
Checking for new cluster tablespace directories               ok

If pg_upgrade fails after this point, you must re-initdb the
new cluster before continuing.

Performing Upgrade
------------------
Setting locale and encoding for new cluster                   ok
Analyzing all rows in the new cluster                         ok
Freezing all rows in the new cluster                          ok
Deleting files from new pg_xact                               ok
Copying old pg_xact to new server                             ok
Setting oldest XID for new cluster                            ok
Setting next transaction ID and epoch for new cluster         ok
Deleting files from new pg_multixact/offsets                  ok
Copying old pg_multixact/offsets to new server                ok
Deleting files from new pg_multixact/members                  ok
Copying old pg_multixact/members to new server                ok
Setting next multixact ID and offset for new cluster          ok
Resetting WAL archives                                        ok
Setting frozenxid and minmxid counters in new cluster         ok
Restoring global objects in the new cluster                   ok
Restoring database schemas in the new cluster
                                                              ok
Adding ".old" suffix to old global/pg_control                 ok

If you want to start the old cluster, you will need to remove
the ".old" suffix from /data/dbdata/pgsql-14/global/pg_control.old.
Because "link" mode was used, the old cluster cannot be safely
started once the new cluster has been started.
Linking user relation files
                                                              ok
Setting next OID for new cluster                              ok
Sync data directory to disk                                   ok
Creating script to delete old cluster                         ok
Checking for extension updates                                notice

Your installation contains extensions that should be updated
with the ALTER EXTENSION command.  The file
    update_extensions.sql
when executed by psql by the database superuser will update
these extensions.

Upgrade Complete
----------------
Optimizer statistics are not transferred by pg_upgrade.
Once you start the new server, consider running:
    /usr/pgsql-16/bin/vacuumdb --all --analyze-in-stages
Running this script will delete the old clusters data files:
    ./delete_old_cluster.sh

>>
-----------------------------------------------------------------------------------------------

3. once all completed then start the service 
service postgresql-16 start

4. source  the FILE
update_extensions.sql

5. Once you start the new server, consider running And switch the user as postgres , do Vacuum :   
sudo -u postgres
/usr/pgsql-16/bin/vacuumdb --all --analyze-in-stages


#Running this script will delete the old clusters data files:

6. DELETE Old Cluster
./delete_old_cluster.sh


7. change the port :

sudo vim /etc/postgresql/16/main/postgresql.conf
port = 5432 # Change to 5432 here
sudo vim /etc/postgresql/14/main/postgresql.conf
port = 5665 # Change to 5433 here


#Start the postgreqsl service.

sudo vim /etc/postgresql/16/main/postgresql.conf
port = 5665 # Change to 5432 here
sudo vim /etc/postgresql/14/main/postgresql.conf
port = 5432 # Change to 5433 here

#Start the postgreqsl service.

service postgresql-16 start


============================================



sudo yum install percona-pgaudit16