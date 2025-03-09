#Pre steps of postgresql 16 upgrade : 


#Update the timescaledb in pg-14 before upgrade to pg-16

yum install timescaledb-2-postgresql-14-2.14.2-0.el9.x86_64

yum install timescaledb-2-loader-postgresql-14-2.14.2-0.el9.x86_64

sudo -u postgres psql --port 5665 -X

alter extension timescaledb update;
alter extension timescaledb_toolkit update;



--upgrade 16 


mkdir /dbdata/pgsql/
mkdir /dberrorlog/pgsql/
mkdir /dblog/archive/pgsql/
mkdir /dberrorlog/pgsql/audit/


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

/usr/pgsql/bin/postgresql-16-setup initdb

#copy the conf file : 


cp -p /var/lib/pgsql/16/data/postgresql.conf   /var/lib/pgsql/16/data/postgresql.conf_`date +%Y_%m_%d.%H.%M.%S`
cp -p /var/lib/pgsql/16/data/pg_hba.conf /var/lib/pgsql/16/data/pg_hba.conf_`date +%Y_%m_%d.%H.%M.%S`

#change the ownership of the directory : 

chown -R postgres:postgres /dbdata/pgsql/
chown -R postgres:postgres /dberrorlog/pgsql/
chown -R postgres:postgres /dblog/archive/pgsql/
chown -R postgres:postgres /dberrorlog/pgsql/audit/


#edit the conf file and hba of pgsql 16 :


cat /var/lib/pgsql/14/data/postgresql.conf > /var/lib/pgsql/16/data/postgresql.conf
cat /var/lib/pgsql/14/data/pg_hba.conf > /var/lib/pgsql/16/data/pg_hba.conf


vi /var/lib/pgsql/16/data/postgresql.conf

## port = 5432
## data_directory = '/dbdata/pgsql'
## log_directory = '/dberrorlog/pgsql'
## pgaudit.log_directory='/dberrlog/pgsql/audit'
## archive_command = 'test ! -f /dblog/archive/pgsql/%f && cp %p /dblog/archive/pgsql/%f'


:wq


rsync -av /var/lib/pgsql/16/data/ /dbdata/pgsql/

systemctl start postgresql-16


#check the cluster compatible : 

service postgresql-16 stop

#postgresql 14 should be running untill link the cluster from old to new . 


su - postgres 

/usr/pgsql/bin/pg_upgrade --old-bindir /usr/pgsql-14/bin --new-bindir /usr/pgsql/bin  --old-datadir /dbdata/pgsql  --new-datadir /dbdata/pgsql --check 

/usr/pgsql/bin/pg_upgrade --old-bindir /usr/pgsql-14/bin --new-bindir /usr/pgsql/bin  --old-datadir /dbdata/pgsql  --new-datadir /dbdata/pgsql --link


#once all completed then start the service 

service postgresql-16 start

#source  the FILE

update_extensions.sql

# Once you start the new server, consider running And switch the user as postgres , do Vacuum :   

su -  postgres

/usr/pgsql/bin/vacuumdb --all --analyze-in-stages


#Running this script will delete the old clusters data files:

#DELETE Old Cluster

./delete_old_cluster.sh


#change the port :

 vi /etc/postgresql/16/main/postgresql.conf
port = 5432 # Change to 5432 here
 vi /etc/postgresql/16/main/postgresql.conf
port = 5665 # Change to 5433 here


#Start the postgreqsl service.

service postgresql-16 restart
