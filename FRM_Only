================================================================================
Before Change 
================================================================================

1. Install PG 16 AND Timescale

#Update the timescaledb in pg-14 before upgrade to pg-16

yum install timescaledb-2-postgresql-14-2.14.2-0.el9.x86_64
yum install timescaledb-2-loader-postgresql-14-2.14.2-0.el9.x86_64

mkdir /dbdata/pgsql-16/
mkdir /dberrorlog/pgsql-16/
mkdir /dblog/archive/pgsql-16/
mkdir /dberrorlog/pgsql-16/audit/

#Enable Percona repository:
yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm

#Install percona-release and install the rpm of 16 :
percona-release setup ppg16
yum install percona-ppg-server16 
yum install timescaledb-2-postgresql-16-2.14.2-0.el9.x86_64
yum install timescaledb-2-loader-postgresql-16-2.14.2-0.el9.x86_64
yum install  https://download.postgresql.org/pub/repos/yum/16/redhat/rhel-$(rpm -E %{rhel})-x86_64/pg_cron_16-1.6.2-1PGDG.rhel$(rpm -E %{rhel}).x86_64.rpm -y

rpm -e --nodeps percona-pgaudit16-16.0-2.el9.x86_64

dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum search pgaudit -y
yum install pgauditlogtofile_16.x86_64

#initiate the DB : 

/usr/pgsql-16/bin/postgresql-16-setup initdb
#copy the conf file : 


cp -p /var/lib/pgsql/16/data/postgresql.conf   /var/lib/pgsql/16/data/postgresql.conf_`date +%Y_%m_%d.%H.%M.%S`
cp -p /var/lib/pgsql/16/data/pg_hba.conf /var/lib/pgsql/16/data/pg_hba.conf_`date +%Y_%m_%d.%H.%M.%S`

#change the ownership of the directory : 

chown -R postgres:postgres /dbdata/pgsql-16/
chown -R postgres:postgres /dberrorlog/pgsql-16/
chown -R postgres:postgres /dblog/archive/pgsql-16/
chown -R postgres:postgres /dberrorlog/pgsql-16/audit/


#edit the conf file and hba of pgsql 16 :


cat /var/lib/pgsql/14/data/postgresql.conf > /var/lib/pgsql/16/data/postgresql.conf
cat /var/lib/pgsql/14/data/pg_hba.conf > /var/lib/pgsql/16/data/pg_hba.conf


vi /var/lib/pgsql/16/data/postgresql.conf

## port = 5432
## data_directory = '/dbdata/pgsql-16'
## log_directory = '/dberrorlog/pgsql-16'
## pgaudit.log_directory='/dberrlog/pgsql-16/audit'
## archive_command = 'test ! -f /dblog/archive/pgsql-16/%f && cp %p /dblog/archive/pgsql-16/%f'

#CHECK ALL extensions including pgauditlogtofile
shared_preload_libraries = 'pgcrypto,pg_cron,pg_stat_statements,timescaledb,dblink,pgaudit,pgauditlogtofile,pg_stat_monitor'    # (change requires restart)




systemctl stop postgresql-16
rsync -av /var/lib/pgsql/16/data/ /dbdata/pgsql-16/
systemctl start postgresql-16


#Install VERSION 16 timescale 

psql -U db2dba --port 5432 --host 127.0.0.1 postdgres 

SELECT * FROM pg_extension ;

Install
================================================================================
#During Change 
================================================================================
#Stop Application 
#check the cluster compatible : 

service postgresql-16 stop

#steps of postgresql 16 upgrade : 

#Login TO PG VERSION 14

psql -U db2dba --port 5665 --hosy 127.0.0.1 postdgres 
1. Promote New server AS PRIMARY 
SELECT pg_promote();

alter extension timescaledb update;
alter extension timescaledb_toolkit update;

2. postgresql 14 should be running untill link the cluster from old to new . 

su - postgres 


##Check
/usr/pgsql-16/bin/pg_upgrade --old-bindir /usr/pgsql-14/bin --new-bindir /usr/pgsql-16/bin  --old-datadir /dbdata/pgsql  --new-datadir /dbdata/pgsql-16 --check 

##Stop VERSION 14
service postgresql-16 start

##Link
/usr/pgsql-16/bin/pg_upgrade --old-bindir /usr/pgsql-14/bin --new-bindir /usr/pgsql-16/bin  --old-datadir /dbdata/pgsql  --new-datadir /dbdata/pgsql-16 --link


3. once all completed then start the service 
service postgresql-16 start

4. source  the FILE
update_extensions.sql

5. Once you start the new server, consider running And switch the user as postgres , do Vacuum :   
su -  postgres
/usr/pgsql-16/bin/vacuumdb --all --analyze-in-stages


6. Running this script will delete the old clusters data files:
./delete_old_cluster.sh


7. change the port :

 vi /var/lib/pgsql/16/data/postgresql.conf
port = 5665 # Change from 5432 TO 5665 here


#Start the postgreqsl service.
service postgresql-16 restart

psql -U db2dba --port 5665 --hosy 127.0.0.1 postgres 

check dbs 
CHECK extensions 


================================================================================
After Change 
================================================================================
Setup DR 
CHECK PMM 
CHECK Audit LOG 
CHECK Error LOG 
CHECK Archive LOG 
CHECK Scripts 
