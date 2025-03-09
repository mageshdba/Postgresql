======================================
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
==================================================================================================================================================================

SERVER INSTALLATION

##VERSION 12

Postgres instalation from package method or YUM method:

Pre-requisites:
==============
sudo dnf -y update

sudo dnf module list postgresql

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
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres
                                                             : postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres
                                                             : postgres=CTc/postgres
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



sudo yum install postgresql13 postgresql13-server



==================================================================================================================================================================



##VERSION 14

sudo dnf -y update

sudo dnf module list postgresql

sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm

sudo dnf -qy module disable postgresql

sudo dnf install -y postgresql14-server
 
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb

This will create the initial data as well as the main configuration file, which will be written to 
/var/lib/pgsql/14/data/postgresql.conf

systemctl enable postgresql-14
systemctl status postgresql-14
systemctl start postgresql-14

service postgresql-14 status

sudo -u postgres psql
sudo -i -u postgres
psql
 
psql -c "alter user postgres with password 'Pgadmin@123'"
CREATE DATABASE testdb;

\q

     data_directory
------------------------
 /var/lib/pgsql/14/data

mkdir /postgresql/data
chown -R postgres:postgres /dbdata01/postgres

OLD DIR
/var/lib/pgsql/14/data
NEW DIR
/data01/postgres


chown -R postgres:postgres /dbdata01/postgresql/data


service postgresql-14 stop

sudo rsync -av /var/lib/pgsql/14/data /dbdata01/postgresql

vi  /var/lib/pgsql/14/data/postgresql.conf

Output:
….
….
….
#------------------------------------------------------------------------------
# FILE LOCATIONS
#------------------------------------------------------------------------------
# The default values of these variables are driven from the -D command-line
# option or PGDATA environment variable, represented here as ConfigDir
data_directory = '/dbdata01/postgres' # use data in another directory
                                       # (change requires restart)
hba_file = '/etc/postgresql/14/maincd /pg_hba.conf' # host-based authentication file
                                       # (change requires restart)
ident_file = '/etc/postgresql/14/main/pg_ident.conf' # ident configuration file
….
….
listen_addresses = '*'                  # what IP address(es) to listen on;

log_directory = '/dberrorlog/postgresql'


cat /var/lib/pgsql/14/data/postgresql.conf

vi  /var/lib/pgsql/14/data/postgresql.conf

data_directory = '/dbdata/pgsql/data' # use data in another directory
                                       # (change requires restart)

vi /var/lib/pgsql/14/data/pg_hba.conf
# IPv4 local connections:
host    all             all             0.0.0.0/0            scram-sha-256
# IPv6 local connections:
host    all             all             ::/0                 scram-sha-256



RESTART/START
service postgresql-14 status
service postgresql-14 start

LOGIN
sudo -u postgres psql
or
sudo -i -u postgres
or
psql

SHOW data_directory;
   data_directory
--------------------
 /postgresql/data
(1 row)


4GB RAM / 4 CORE CPU
max_connections = 10000
shared_buffers = 7GB
wal_buffers
effective_cache_size
max_wal--4GB 
work_mem --2GB
maintenance_work_mem 
Max_parallel_workers -- set to 8 or above)
max_worker_processes --set to 8 or above)
max_parallel_workers_per_gather (pls set to 6 or above)
temp_buffers
Checkpoint timeout -- 30 min and max_val_size as 2gb is required

log_statement


select * from pg_settings where name like '%max_connections%';
select * from pg_settings where name like '%shared_buffers%';
select * from pg_settings where name like '%wal_buffers%';
select * from pg_settings where name like '%effective_cache_size%';
select * from pg_settings where name like '%max_wal%';
select * from pg_settings where name like '%work_mem%';
select * from pg_settings where name like '%maintenance_work_mem%';
select * from pg_settings where name like '%max_parallel_workers%';
select * from pg_settings where name like '%max_worker_processes%';
select * from pg_settings where name like '%max_parallel_workers_per_gather%';
select * from pg_settings where name like '%temp_buffers%';
select * from pg_settings where name like '%checkpoint%';
select * from pg_settings where name like '%pg_stat_statements%';
select * from pg_settings where name like '%statement%';
