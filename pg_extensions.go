===================================
ALL THE EXTENSIONS IN THE WORLD:
===================================

--Sample CNF 
shared_preload_libraries = 'pgcrypto,pg_cron,pg_stat_statements,dblink,pgaudit,pgauditlogtofile,timescaledb,pg_stat_monitor'    # (change requires restart)



--Create in psql

  select * from pg_extension;


	create extension plpgsql;
	CREATE EXTENSION dblink;
	create extension pgcrypto;
	create extension pg_stat_statements;
	create extension pg_cron;

  
	create extension timescaledb;
	CREATE EXTENSION timescaledb_toolkit;
	create extension pgaudit;
	create extension pgauditlogtofile;
  create extension pg_stat_monitor;



select * from pg_extension;


===================================
//PGCRYPTO
===================================
download CONTRIB 
yum install postgresql14-contrib -y

create extension pgcrypto;
select pgp_sym_encrypt('postgres','recon360')::text


===================================
//PGCRON
===================================
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

===================================
//TIMESCALEDB
===================================

https://packagecloud.io/app/timescale/timescaledb/search?dist=el%2F9&filter=all&page=2&q=
curl -s https://packagecloud.io/install/repositories/timescale/timescaledb/script.rpm.sh | sudo bash

wget --content-disposition "https://packagecloud.io/timescale/timescaledb/packages/el/9/timescaledb-2-postgresql-14-2.12.0-0.el9.x86_64.rpm/download.rpm?distro_version_id=240"

yum install timescaledb-2-loader-postgresql-14-2.12.2-0.el9.x86_64.rpm

--Install REPO

yum install https://download.postgresql.org/pub/repos/yum/reporpms/EL-$(rpm -E %{rhel})-x86_64/pgdg-redhat-repo-latest.noarch.rpm -y

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
yum install timescaledb-2-postgresql-14

--Create ext 
CREATE EXTENSION timescaledb;

--TO UPGRADE 
ALTER EXTENSION timescaledb UPDATE;

ls -lhrt /usr/lib64/timescaledb-pg14/ |grep -i 'timescaledb-2.12'
ls -lhrt /usr/pgsql-14/lib/ |grep -i 'timescaledb-2.12'

SELECT extname, extversion, datname FROM pg_database CROSS JOIN pg_extension WHERE extname = 'timescaledb';

--ERRORS and FIXES
ERROR:  could not load library "/usr/pgsql-14/lib/timescaledb-tsl-2.12.0.so": /usr/pgsql-14/lib/timescaledb-tsl-2.12.0.so: cannot open shared object file: Permission denied

/usr/local/bin/aws s3 ls

aws s3 rm --profile backup s3://007005984739-db-backup/Rough/timescale/lib/ --recursive 
aws s3 rm --profile backup s3://007005984739-db-backup/Rough/timescale/lib64/ --recursive 


--SYNC Selective
aws s3 sync  /usr/pgsql-14/lib/ --profile backup s3://007005984739-db-backup/Rough/timescale/lib/ --exclude "*" --include "timescaledb*"
aws s3 sync  /usr/lib64/timescaledb-pg14/ --profile backup s3://007005984739-db-backup/Rough/timescale/lib64/ --exclude "*" --include "timescaledb*"


//FRM 

set search_path to case_management;

CREATE TABLE "db2dba" (
    "created_datetime" TIMESTAMP ,
    "amount" DOUBLE PRECISION ,
    "risktransstatus" VARCHAR ,
    "frm_tran_id" VARCHAR(255),
    "caserequired" BOOLEAN ,
    "originalamount" DOUBLE PRECISION ,
    "productcode" VARCHAR(255),
    "actdescription" VARCHAR(255),
    "frmversion" VARCHAR(255),
    "riskproductcode" VARCHAR(255),
    "riskvendorcode" VARCHAR(255),
    "riskchannel" VARCHAR(255),
    "rulesetname" VARCHAR(255),
    "caseno" VARCHAR(255),
    "actreceivedtime" VARCHAR(255),
    "frmtranid" VARCHAR(255),
    "identificationdata" VARCHAR(255),
    "responsetime" VARCHAR(255),
    "processtime" VARCHAR(255),
    "bankcode" VARCHAR(255),
    "riskchanneltype" VARCHAR(255),
    "rulesetid" VARCHAR(255),
    "receivedtime" VARCHAR(255),
    "riskproductname" VARCHAR(255),
    "breresult" VARCHAR(255),
    "maskeddata" VARCHAR(255),
    "priority" VARCHAR(255),
    "ruledetails" TEXT ,
    "ruledetailslist" TEXT ,
    "declinedrules" VARCHAR(255),
    "riskscore" VARCHAR(255),
    "casedefinition" VARCHAR(255),
    "brerulesetid" VARCHAR(255),
    "actstatuscode" VARCHAR(255),
    "deviceid" VARCHAR(255),
    "country" VARCHAR(255),
    "billingamount" VARCHAR(255),
    "currencycode" VARCHAR(255),
    "customerid" VARCHAR(255),
    "mcc" VARCHAR(255),
    "cardacceptorterminalid" VARCHAR(255),
    "transactioncurrencycode" VARCHAR(255),
    "type" VARCHAR(255),
    "receivercustomerid" VARCHAR(255),
    "availablebalance" DOUBLE PRECISION ,
    "terminalid" VARCHAR ,
    PRIMARY KEY(created_datetime)
)
;

create INDEX db2dba_created_datetime_idx1 on db2dba(created_datetime);

set search_path to public;

SELECT "public.create_hypertable"('case_management.db2dba', 'created_datetime');


CREATE MATERIALIZED VIEW case_management."db2dba_mqt" WITH (timescaledb.continuous) AS SELECT customerid,type,time_bucket('240 hour',created_datetime) as timebucket,count(customerid) as count FROM case_management."db2dba" WHERE created_datetime>NOW() - INTERVAL '24 hour' GROUP BY timebucket,customerid,type WITH NO DATA ;


INSERT INTO "case_management.db2dba" ("created_datetime", "amount", "risktransstatus", "frm_tran_id", "caserequired", "originalamount", "productcode", "actdescription", "frmversion", "riskproductcode", "riskvendorcode", "riskchannel", "rulesetname", "caseno", "actreceivedtime", "frmtranid", "identificationdata", "responsetime", "processtime", "bankcode", "riskchanneltype", "rulesetid", "receivedtime", "riskproductname", "breresult", "maskeddata", "priority", "ruledetails", "ruledetailslist", "declinedrules", "riskscore", "casedefinition", "brerulesetid", "actstatuscode", "deviceid", "country", "billingamount", "currencycode", "customerid", "mcc", "cardacceptorterminalid", "transactioncurrencycode", "type", "receivercustomerid", "availablebalance", "terminalid") VALUES (now(), NULL, NULL, '505f08d7-25cc-4364-9320-c16d846caff8', 'false', NULL, NULL, 'GENUINE', 'Cards Transaction', '05', 'FRM000', 'Cards', 'Cards Transaction', '402188066653', NULL, '505f08d7-25cc-4364-9320-c16d846caff8', '6abABVr5/XGdHBACYrQmnASqeE3q1FuNLWBp41av6Qo=', 'Sun Jan 21 10:01:36 AST 2024', '70', '10054', 'transaction', '1702697373534', 'Sun Jan 21 10:01:36 AST 2024', 'multi', '{action=BRE-000, information=Approve Rule, rulesetsID=1702698015352, ruleexecutedID=1702698037008}', 'kisXok4', 'LOW', '[{rulesResults=[((SKIP<3)||100<100000)=((true)||true)=true], ruleName=TXN_COUNT_GTE_3_AND_AMT_GT_1000, ruleScore=0, ruleID=1702696106062, rulesCondition=[((customerid<ONETOMANY|1702696572240|3|currentobject)||billingamount<100000)]}, {rulesResults=[((SKIP<3))=((true))=true], ruleName=APPROVED_TXN_SAME_TERMINAL_COUNT_GTE_3, ruleScore=0, ruleID=1702696949377, rulesCondition=[((customerid<ONETOMANY|1702697261432|3))]}]', '{"ruleDetails":[{"rulesResults":["((SKIP<3)||100<100000)=((true)||true)=true"],"ruleName":"TXN_COUNT_GTE_3_AND_AMT_GT_1000","ruleScore":"0","ruleID":1702696106062,"rulesCondition":["((customerid<ONETOMANY|1702696572240|3|currentobject)||billingamount<100000)"]},{"rulesResults":["((SKIP<3))=((true))=true"],"ruleName":"APPROVED_TXN_SAME_TERMINAL_COUNT_GTE_3","ruleScore":"0","ruleID":1702696949377,"rulesCondition":["((customerid<ONETOMANY|1702697261432|3))"]}]}', NULL, '0', NULL, NULL, '00', NULL, NULL, '100', '682', 'kishok4', NULL, NULL, NULL, 'CARD_TXN', NULL, NULL, '123456');



--------------------

select * from timescaledb_information.continuous_aggregates;
this table you get the select query used to... by Sharath Sankar
Sharath Sankar
this table you get the select query used to create the mqt
-[ RECORD 1 ]---------------------+--------... by Sharath Sankar
Sharath Sankar
-[ RECORD 1 ]---------------------+--------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------
hypertable_schema                 | case_management
hypertable_name                   | acs10031_01
view_schema                       | case_management
view_name                         | acs10031_01_1672836167661
view_owner                        | frmappusr
materialized_only                 | f
compression_enabled               | f
materialization_hypertable_schema | _timescaledb_internal
materialization_hypertable_name   | _materialized_hypertable_1005
view_definition                   |  SELECT acs10031_01.cardnumber,
 
                                                           +
                                  |     public.time_bucket('02:30:00'::interval, acs10031_01.created_datetime) AS timebuc
ket,
                                                           +
                                  |     count(acs10031_01.cardnumber) AS count
 
                                                           +
                                  |    FROM case_management.acs10031_01
 
                                                           +
                                  |   WHERE (acs10031_01.created_datetime > (now() - '00:15:00'::interval))
 
                                                           +
                                  |   GROUP BY (public.time_bucket('02:30:00'::interval, acs10031_01.created_datetime)),
acs10031_01.cardnumber;

just an fyi  by Sharath Sankar
Sharath Sankar
just an fyi 
frm=# select count(*) from multi10054_05_17... by Sharath Sankar
Sharath Sankar
frm=# select count(*) from multi10054_05_17026958189339;
count
-------
     3
(1 row)
 
frm=# ALTER MATERIALIZED VIEW multi10054_05_17026958189339 set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW
frm=# select count(*) from multi10054_05_17026958189339;
count
-------
     4


frm=# ALTER MATERIALIZED VIEW case_management.db2dba_mqt set (timescaledb.materialized_only = false);
ERROR:  functionality not supported under the current "apache" license. Learn more at https://timescale.com/.
HINT:  To access all features and the best time-series experience, try out Timescale Cloud.

frm=# show timescaledb.license;
timescaledb.license
---------------------
apache
(1 row)
 
frm=# ALTER SYSTEM SET timescaledb.license = 'timescale';
frm=# SELECT pg_reload_conf();
pg_reload_conf
----------------
t

frm=# show timescaledb.license;
 timescaledb.license
---------------------
 timescale
(1 row)


frm=# ALTER MATERIALIZED VIEW case_management.db2dba_mqt set (timescaledb.materialized_only = false);


//txnaggregator

SELECT create_hypertable('transaction','created_date', chunk_time_interval => INTERVAL '90 days');
SELECT create_hypertable('transaction_new','created_date', chunk_time_interval => INTERVAL '1 year');

drop MATERIALIZED VIEW txn_aggregation_entityid_overall_daily;

CREATE MATERIALIZED VIEW txn_aggregation_entityid_overall_daily
  WITH (timescaledb.continuous) AS
  SELECT
  time_bucket('1 day', "created_date") AS bucket,
  t.entity_id,
  t.txn_origin,
  t.transaction_type AS txn_type,
  t.cr_dr,
  t.mcc,
  t.kit_no,
  t.account_number,
  t.international,
  t.merchant,
  t.on_us,
  t.metro,
  SUM(t.amount) AS daily_sum,
  SUM(t.effective_count) AS daily_count
FROM transaction t
GROUP BY bucket, t.entity_id, t.txn_origin, t.transaction_type, t.mcc, t.merchant, t.kit_no, t.account_number,
t.international, t.cr_dr, t.on_us, t.metro WITH NO DATA;


SELECT view_name , *   FROM timescaledb_information.continuous_aggregates;
SELECT set_chunk_time_interval('_timescalccdedb_internal._materialized_hypertable_22', INTERVAL '30 days');
SELECT set_chunk_time_interval('transaction', INTERVAL '1 year');

ALTER TABLE transaction SET (timescaledb.chunk_time_interval = '30 days');

SELECT h.table_name, c.interval_length  FROM _timescaledb_catalog.dimension c  JOIN _timescaledb_catalog.hypertable h    ON h.id = c.hypertable_id;



===================================
//TOOLKIT
===================================

--Install TimescaleDB Toolkit:
yum install timescaledb-toolkit-postgresql-14 -y

yum install timescaledb-toolkit-postgresql-16 -y

--Create the Toolkit extension in the database:
CREATE EXTENSION timescaledb_toolkit;

/usr/pgsql-16/lib/timescaledb_toolkit-1.11.0.so
timescaledb-toolkit-postgresql-14-1.11.0-0.x86_64

===================================
//STAT MONITOR
===================================
sudo yum -y install curl
sudo yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
sudo percona-release setup ppg14


yum repolist enabled
sudo dnf module disable postgresql llvm-toolset
sudo percona-release setup ppg14


yum module disable ppg14


yum install percona-pg-stat-monitor14 -y
(or)
yum install https://download.postgresql.org/pub/repos/yum/14/redhat/rhel-8-x86_64/pg_stat_monitor_14-1.0.0-1.rhel8.x86_64.rpm
yum install https://download.postgresql.org/pub/repos/yum/14/redhat/rhel-8-x86_64/pg_stat_monitor_14-1.0.0-1.rhel8.x86_64.rpm

rpm -qa |grep -i pg_stat_monitor

create extension pg_stat_monitor;
select * from pg_extension;

SELECT pg_stat_monitor_version();
SELECT DISTINCT userid::regrole, pg_stat_monitor.datname, substr(query,0, 50) AS query, calls, bucket, bucket_start_time, queryid, client_ip FROM pg_stat_monitor, pg_database WHERE pg_database.oid = oid;



===================================
//DBLINK
===================================

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


create extension dblink;

SELECT dblink_connect('otherdb','host=localhost port=5432 dbname=otherdb user=postgres password=???? options=-csearch_path=');

SELECT * FROM dblink('otherdb', 'select field1, field2 from public.tablex')
AS t(field1 text, field2 text);



Select * from
dblink( 'host=yappgresdb.cfzdwmybtrx8.ap-south-1.rds.amazonaws.com user=m2pappdb2 password=M@PS0luti0ns dbname=postgres',
' select count(*) from recon.b_process_dtls ') as (Total_log integer) ;

CREATE EXTENSION postgres_fdw;

CREATE SERVER localsrv
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', dbname 'otherdb', port '5432');

CREATE USER MAPPING FOR <local_user>
SERVER localsrv
OPTIONS (user 'ohterdb_user', password 'ohterdb_user_password');

IMPORT FOREIGN SCHEMA public
FROM SERVER localsrv 
INTO public;

===========================================
//PGAUDIT 
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
yum install pgauditlogtofile_14.x86_64 -y

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


