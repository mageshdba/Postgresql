
ALL THE EXTENSIONS IN THE WORLD:
-------------------------------

--Sample CNF 
shared_preload_libraries = 'pgcrypto,pg_cron,pg_stat_statements,dblink,pgaudit,pgauditlogtofile,timescaledb'    # (change requires restart)




--Create in psql

  


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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1.pgcrypto

download CONTRIB 
yum install postgresql14-contrib -y

create extension pgcrypto;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2.pg_cron
create extension pg_cron;

select * from pg_extension;

yum install  https://download.postgresql.org/pub/repos/yum/14/redhat/rhel-8-x86_64/pg_cron_14-1.4.1-1.rhel8.x86_64.rpm -y

(or)
yum install https://download.postgresql.org/pub/repos/yum/15/redhat/rhel-8-x86_64/pg_cron_15-1.4.2-1.rhel8.x86_64.rpm -y

shared_preload_libraries = 'pg_cron'    # (change requires restart)

postgres=# create extension pg_cron;
CREATE EXTENSION


select * from pg_extensions;

postgres=# select * from pg_extension;
  oid  | extname | extowner | extnamespace | extrelocatable | extversion |         extconfig         | extcondition
-------+---------+----------+--------------+----------------+------------+---------------------------+---------------
 14682 | plpgsql |       10 |           11 | f              | 1.0        |                           |
 16942 | pg_cron |       10 |         2200 | f              | 1.4        | {16945,16944,16964,16963} | {"","","",""}
(2 rows)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


4. TIMESCALEDB Extension 2.7.2

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

For more information on TimescaleDB, please visit the following links:

 1. Getting started: https://docs.timescale.com/timescaledb/latest/getting-started
 2. API reference documentation: https://docs.timescale.com/api/latest
 3. How TimescaleDB is designed: https://docs.timescale.com/timescaledb/latest/overview/core-concepts

Note: Please enable telemetry to help us improve our product by running: ALTER DATABASE "postgres" SET timescaledb.telemetry_level = 'basic';

CREATE EXTENSION timescaledb;



WELCOME TO
 _____ _                               _     ____________
|_   _(_)                             | |    |  _  \ ___ \
  | |  _ _ __ ___   ___  ___  ___ __ _| | ___| | | | |_/ /
  | | | |  _ ` _ \ / _ \/ __|/ __/ _` | |/ _ \ | | | ___ \
  | | | | | | | | |  __/\__ \ (_| (_| | |  __/ |/ /| |_/ /
  |_| |_|_| |_| |_|\___||___/\___\__,_|_|\___|___/ \____/
               Running version 2.7.0
               
               
               
postgres=# select * from pg_extension;
  oid  |   extname   | extowner | extnamespace | extrelocatable | extversion |                                                                                 extconfig
                |                            extcondition
-------+-------------+----------+--------------+----------------+------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------+--------------------------------------------------------------------
 14682 | plpgsql     |       10 |           11 | f              | 1.0        |
                |
 16404 | timescaledb |       10 |         2200 | f              | 2.7.0      | {16421,16422,16443,16456,16470,16469,16488,16487,16503,16502,16525,16541,16542,16558,16570,16571,16613,16620,16642,16654,16664,16668,16684,16703,16718,167
39,16745,16742} | {"","","","","","","","","","","","","","","","WHERE id >= 1000","+
       |             |          |              |                |            |
                |   WHERE KEY = 'exported_uuid' ","","","","","","","","","","",""}
(2 rows)

postgres=#  SELECT * FROM pg_available_extensions WHERE name='timescaledb';
    name     | default_version | installed_version |                              comment
-------------+-----------------+-------------------+-------------------------------------------------------------------
 timescaledb | 2.7.0           | 2.7.0             | Enables scalable inserts and complex queries for time-series data
(1 row)

postgres=#

=======================
ERRORS AND FIX

postgres=#
postgres=# SELECT distinct  sourcefile FROM pg_settings;
               sourcefile
----------------------------------------

 /var/lib/pgsql/14/data/postgresql.conf
(2 rows)

postgres=#

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



5. TIMESCALEDB Extension 2.7.2

--------------------------------


--Install REPO

yum install https://download.postgresql.org/pub/repos/yum/reporpms/EL-$(rpm -E %{rhel})-x86_64/pgdg-redhat-repo-latest.noarch.rpm -y


--Edit Repo

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



--Install RPM
yum install timescaledb-2-postgresql-15

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

6. Toolkit

--Install TimescaleDB Toolkit:
yum install timescaledb-toolkit-postgresql-14 -y

--Create the Toolkit extension in the database:
CREATE EXTENSION timescaledb_toolkit;


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


7. DBLINK 
===========================================

1. Download the package
	 wget https://download.postgresql.org/pub/repos/yum/14/redhat/rhel-8-x86_64/postgresql14-contrib-14.2-1PGDG.rhel8.x86_64.rpm

2. Try to install it. While trying in Recon360 PreProd, we had received error
	[root@aws-preprd-recon360-db01 ext]# yum install postgresql14-contrib-14.2-1PGDG.rhel8.x86_64.rpm
	Updating Subscription Management repositories.
	Last metadata expiration check: 2:41:58 ago on Thu 12 May 2022 10:19:51 AM IST.
	No match for argument: postgresql14-contrib-14.2-1PGDG.rhel8.x86_64.rpm
	Error: Unable to find a match

3. Hence manually extracted the contents
	rpm2cpio postgresql14-contrib-14.2-1PGDG.rhel8.x86_64.rpm | cpio -idmv

4. Find the dblink control file in the same directory in usr/pgsql-14/share/extension/
	dblink--1.0--1.1.sql
	dblink--1.1--1.2.sql
	dblink--1.2.sql
	dblink.control

5. Copy the above files in /usr/pgsql-14/share/extension/ and change the permission to 644

6. Find the dblink.so file in path where you had extracted the rpm (usr/pgsql-14/lib/)
	dblink.so

7. Copy the dblink.so file to /usr/pgsql-14/lib/ and change the permission to 755

8. Add the dblink name in the shared_preload_libraries in /var/lib/pgsql/14/data/postgresql.conf

9. Login to postgres and create the dblink extension

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

8. PGAUDIT 
===========================================
 yum install pgaudit16_14.x86_64

yum install percona-pgaudit.x86_64 -y

Last metadata expiration check: 2:48:33 ago on Fri 18 Mar 2022 04:33:01 PM IST.
Dependencies resolved.
==============================================================================================================================================================================
 Package                                     Architecture                          Version                                        Repository                             Size
==============================================================================================================================================================================
Installing:
 pgaudit16_14                                x86_64                                1.6.2-1.rhel8                                  pgdg14                                 56 k

Transaction Summary
==============================================================================================================================================================================
Install  1 Package

Total download size: 56 k
Installed size: 100 k
Is this ok [y/N]: y
Downloading Packages:
pgaudit16_14-1.6.2-1.rhel8.x86_64.rpm                                                                                                          48 kB/s |  56 kB     00:01
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

[root@az-sin-m2p-preprod-db01 bitcode]# cd /usr/pgsql-14/lib/
[root@az-sin-m2p-preprod-db01 lib]# ls -latr


[root@az-sin-m2p-preprod-db01 lib]# vi /var/lib/pgsql/14/data/postgresql.conf
[root@az-sin-m2p-preprod-db01 lib]# su - postgres
Last login: Thu Mar 17 18:20:56 IST 2022 on pts/0
[postgres@az-sin-m2p-preprod-db01 ~]$ psql
psql (14.0)
Type "help" for help.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Checking if the extension is available before restart of postgres
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
postgres=# select * from pg_extension;
  oid  | extname | extowner | extnamespace | extrelocatable | extversion |         extconfig         | extcondition
-------+---------+----------+--------------+----------------+------------+---------------------------+---------------
 14682 | plpgsql |       10 |           11 | f              | 1.0        |                           |
 16948 | pg_cron |       10 |         2200 | f              | 1.4        | {16951,16950,16970,16969} | {"","","",""}
(2 rows)


postgres=# create extension pgaudit;
CREATE EXTENSION
postgres=# select * from pg_extension;
  oid  | extname | extowner | extnamespace | extrelocatable | extversion |         extconfig         | extcondition
-------+---------+----------+--------------+----------------+------------+---------------------------+---------------
 14682 | plpgsql |       10 |           11 | f              | 1.0        |                           |
 16948 | pg_cron |       10 |         2200 | f              | 1.4        | {16951,16950,16970,16969} | {"","","",""}
 16988 | pgaudit |       10 |         2200 | t              | 1.6.2      |                           |
(3 rows)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Verifyig audit parameters before enabling:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
postgres=# 	
            name            | setting
----------------------------+---------
 pgaudit.log                | none
 pgaudit.log_catalog        | on
 pgaudit.log_client         | off
 pgaudit.log_level          | log
 pgaudit.log_parameter      | off
 pgaudit.log_relation       | off
 pgaudit.log_rows           | off
 pgaudit.log_statement      | on
 pgaudit.log_statement_once | off
 pgaudit.role               |
(10 rows)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Enabling audit for DDL and Write opeations:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
postgres=# set pgaudit.log='write,ddl';
SET
postgres=# SELECT name,setting FROM pg_settings WHERE name LIKE 'pgaudit%';
            name            |  setting
----------------------------+-----------
 pgaudit.log                | write,ddl
 pgaudit.log_catalog        | on
 pgaudit.log_client         | off
 pgaudit.log_level          | log
 pgaudit.log_parameter      | off
 pgaudit.log_relation       | off
 pgaudit.log_rows           | off
 pgaudit.log_statement      | on
 pgaudit.log_statement_once | off
 pgaudit.role               |
(10 rows)

postgres=# create table testaudit(name varchar(10),sign varchar(10));
CREATE TABLE

postgres=# insert into testaudit values('Harish','hari');
INSERT 0 1
postgres=# insert into testaudit values('Sharat^C'hari');
postgres=# alter table testaudit add column message varchar(50);
ALTER TABLE
                                               ^
postgres=# alter table testaudit alter column name type varchar(20);
ALTER TABLE
postgres=# insert into testaudit values('Sharath Shankar','Sharath S','To check value');
INSERT 0 1
postgres=# update testaudit set sign='Sharath' where name='Sharath Shankar';
UPDATE 1
postgres=# insert into testaudit values('Mohan Rao','MohanR','To check deletion');
INSERT 0 1
postgres=# delete from testaudit where sign='MohanR';
DELETE 1
postgres=#


9. PGAUDITLOGTOFILE
===========================================

[root@aws-aps1-prd-bitool-pgdb-01 ~]# yum search pgaudit
yum install pgauditlogtofile_15.x86_64 -y

aws s3 sync s3://m2p-s3-prd-db-bkp/software/postgres/extensions/pgauditlogtofile/ /usr/pgsql-14/share/extension 

postgres=# CREATE EXTENSION pgauditlogtofile;
CREATE EXTENSION


--Add it in conf 
pgaudit.log_directory='/dberrlog/audit'
pgaudit.log='write,ddl'

=============================================================================
Verifying log files for auditing

[root@az-sin-m2p-preprod-db01 log]# grep -i audit postgresql-Fri.log
2022-03-18 14:03:40.169 UTC [708236] STATEMENT:  create extension pgaudit
        create extension pgaudit;
2022-03-18 14:04:32.982 UTC [708236] STATEMENT:  create extension pgaudit
        create extension pg_audit;
2022-03-18 14:06:12.121 UTC [708236] ERROR:  pgaudit must be loaded via shared_preload_libraries
2022-03-18 14:06:12.121 UTC [708236] STATEMENT:  CREATE EXTENSION pgaudit;
2022-03-18 14:36:07.860 UTC [708515] STATEMENT:  set pgaudit.log =  'write,ddl'
        SELECT name,setting FROM pg_settings WHERE name LIKE 'pgaudit%';
2022-03-18 14:36:09.261 UTC [708515] STATEMENT:  set pgaudit.log =  'write,ddl'
        SELECT name,setting FROM pg_settings WHERE name LIKE 'pgaudit%';
2022-03-18 14:37:36.105 UTC [708515] LOG:  AUDIT: SESSION,1,1,DDL,CREATE TABLE,TABLE,public.testaudit,"create table testaudit(name varchar(10),sign varchar(10));",<not logged>
2022-03-18 14:38:08.872 UTC [708515] STATEMENT:  insert into testaudit("Harish","hari");
2022-03-18 14:38:27.163 UTC [708515] STATEMENT:  insert into testaudit values("Harish","hari");
2022-03-18 14:38:43.308 UTC [708515] LOG:  AUDIT: SESSION,2,1,WRITE,INSERT,,,"insert into testaudit values('Harish','hari');",<not logged>
2022-03-18 14:39:40.616 UTC [708515] LOG:  AUDIT: SESSION,3,1,DDL,ALTER TABLE,TABLE,public.testaudit,alter table testaudit add column message varchar(50);,<not logged>
2022-03-18 14:40:29.850 UTC [708515] STATEMENT:  alter table testaudit alter column name varchar(20);
2022-03-18 14:41:34.340 UTC [708515] LOG:  AUDIT: SESSION,4,1,DDL,ALTER TABLE,TABLE,public.testaudit,alter table testaudit alter column name type varchar(20);,<not logged>
2022-03-18 14:42:19.541 UTC [708515] LOG:  AUDIT: SESSION,5,1,WRITE,INSERT,,,"insert into testaudit values('Sharath Shankar','Sharath S','To check value');",<not logged>
2022-03-18 14:43:02.221 UTC [708515] LOG:  AUDIT: SESSION,6,1,WRITE,UPDATE,,,update testaudit set sign='Sharath' where name='Sharath Shankar';,<not logged>
2022-03-18 14:43:43.253 UTC [708515] LOG:  AUDIT: SESSION,7,1,WRITE,INSERT,,,"insert into testaudit values('Mohan Rao','MohanR','To check deletion');",<not logged>
2022-03-18 14:44:10.118 UTC [708515] LOG:  AUDIT: SESSION,8,1,WRITE,DELETE,,,delete from testaudit where sign='MohanR';,<not logged>

 

************************************************************************************************************
-- ROUGHWORK
---------------
  339  2022-08-23 19:04:44 rpm -qa |grep postgres
  340  2022-08-23 19:05:05 yum remove postgresql-server-10.19-1.module_el8.6.0+1047+4202cf9a.x86_64
  341  2022-08-23 19:05:14 yum remove postgresql-10.19-1.module_el8.6.0+1047+4202cf9a.x86_64
  342  2022-08-23 19:05:17 rpm -qa |grep postgres
  343  2022-08-23 19:05:22 psql --version
  344  2022-08-23 19:05:46 sudo -u postgres psql
  345  2022-08-23 19:06:00 service postgresql-14 stop
  346  2022-08-23 19:06:11 yum reinstall postgres*
  347  2022-08-23 19:06:45 yum repo list \
  348  2022-08-23 19:06:48 yum repolist
  349  2022-08-23 19:07:12 cd /etc/yum.repos.d/
  350  2022-08-23 19:07:14 ls -lhrt
  351  2022-08-23 19:07:27 vi pgdg-redhat-all.repo
  352  2022-08-23 19:08:42 ls- lhrt
  353  2022-08-23 19:08:47 vi pgdg-redhat-all.repo
  354  2022-08-23 19:09:38 rpm -qa |grep postgres
  355  2022-08-23 19:09:52 rpm -qi postgresql14-server-14.5-1PGDG.rhel8.x86_64
  356  2022-08-23 19:11:06 yum reinstall --enablerepo=pgdg14,pgdg-common postgresql14-server-14.5-1PGDG.rhel8.x86_64 postgresql14-14.5-1PGDG.rhel8.x86_64postgresql14-14.5-1PGDG.rhel8.x86_64 postgresql14-libs-14.5-1PGDG.rhel8.x86_64
  357  2022-08-23 19:11:26 psql --version
  358  2022-08-23 19:11:57 yum install postgresql-14-client*
  359  2022-08-23 19:13:21 sudo yum install postgresql12
  360  2022-08-23 19:13:24 sudo yum install postgresql14
  361  2022-08-23 19:13:36 yum search postgresql
  362  2022-08-23 19:13:43 yum search postgresql |grep -i client
  363  2022-08-23 19:15:07 yum  install postgresql-14
  364  2022-08-23 19:16:10 psql --version
  365  2022-08-23 19:16:18 who /bin/psql
  366  2022-08-23 19:16:39 yum install postgresql-client
  367  2022-08-23 19:17:13 yum install postgresql*client
  368  2022-08-23 19:17:37 yum list postgresql
  369  2022-08-23 19:17:47 yum list postgresql-14
  370  2022-08-23 19:17:53 yum list postgres*
  371  2022-08-23 19:18:29 ls -lghrt
  372  2022-08-23 19:20:44 yum remove postgres
  373  2022-08-23 19:20:53 rpm -qa |grep postgres
  374  2022-08-23 19:21:13 yum remove postgresql14-14.5-1PGDG.rhel8.x86_64 postgresql14-server-14.5-1PGDG.rhel8.x86_64 postgresql14-libs-14.5-1PGDG.rhel8.x86_64
  375  2022-08-23 19:21:43 cd /etc/yum.repos.d/
  376  2022-08-23 19:21:43 ll
  377  2022-08-23 19:21:56 mv pgdg-redhat-all.repo pgdg-bkp
  378  2022-08-23 19:22:05 sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
  379  2022-08-23 19:22:29 yum remove pgdg-redhat-repo-42.0-25.noarch
  380  2022-08-23 19:22:33 sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
  381  2022-08-23 19:22:42 sudo dnf -qy module disable postgresql
  382  2022-08-23 19:22:46 sudo dnf install -y postgresql14-server
  383  2022-08-23 19:22:58 sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
  384  2022-08-23 19:23:13 psql --version
  385  2022-08-23 19:23:28 locate postgresql.
  386  2022-08-23 19:23:44 cat /var/lib/pgsql/14/data/postgresql.conf
  387  2022-08-23 19:23:48 df -h
  388  2022-08-23 19:24:02 cat /var/lib/pgsql/14/data/postgresql.conf |grep -i data


