

Open Source - Object relational database management
ACID - Atomicity , consistency , Isolation and Durability
Multiversion concurrency control


Version
Winodows and Mac - 11.8,12.3 
All OS - 9.4.26 , 9.5.22, 9.6.18, 10.13 , 12
Port - 5432
Port - 5432

INSTALLATION - WINDOWS
search postgress in services 
Open psql command prompt
\l
Edit environment variable -PATH -> include postgres bin path, PGDATA -> data path



POSTMASTER - Checks authen and authorization and validates connections - monitors , start/restart proessses
POSTGRES - Postmaster spawns this posgres processs like threads 
SHARED BUFFER -uncommited changes writes / inserts /deleetes will be present before sending it to wal buffer
WAL WRITER - Writes from walbuffer to WAL FILES after commit 
BGWRITER - Periodically writes dirty buffer to data file 
CHECKPOINTER - Runs every 5 min - signals bgwriter to write the dirty buffer in sharedbuffer to data file - ensures all in sync
STATS COLLECTOR - runstats 
LOGGING COLLECTOR - diaglog
AUTO VACCUM LAUNCHER - reorg 
SHARED BUFFER :
The amount of ram that can be allocated to shared buffers. Default 128MB 
Ideally contains pages being modified or read. Rreduces DISK IO
Shared Buffers uses LRU algorithm to flush the pages from this area.
Pg_buffercache extension shows what is inside shared_buffers.
Pg_stat_statements shows the block hit and read for each sql.
pg_statio_user_tables and pg_statio_user_indexes views to see what is in the cache.
--------------------
WAL BUFFER :
 The amount of shared memory used for WAL data that has not yet been written to disk.
PostgreSQL writes its WAL (write ahead log) record into the buffers and then these buffers are flushed to disk. 
The contents of the WAL buffers are written out to disk at every transaction commit,
Default Size is 16MB. Higher value is ideal for concurrent connections.
--------------------
CLOG BUFFERS:
CLOG stands for ""commit log"", and the CLOG buffers is an area in operating system RAM dedicated to hold commit log pages. The commit logs have commit status of all transactions and indicate whether or not a transaction has been completed (committed).
"
"EFFECTIVE CACHE SIZE-  provides an estimate of the memory available for disk caching.
 It is just an estimate, no exact actual memory is allocated.
It instruct the optimizer the amount of cache available in the kernel.
Lower value will discourage the query planner to use indexes, even if they are helpful.
Default value is 4GB. lower value prefers sequence scans over index scans."
"FILE LAYOUT 

•	GLobal - Metadata files 
•	Data Files: It is a file which is use to store data. It does not contain any instructions or code to be executed.
•	Wal Files: Write ahead log file, where all transactions are written first before commit happens.
•	Log Files: All server messages, including stderr, csvlog and syslog are logged in log files.
•	Archive Logs(Optional): Data from wal segments are written on to archive log files to be used for recovery purpose.
pg_wal - WAL files
pg_xact - Transaction commit status  


DEFAULT DBS 

Postgres
template 0
template 1
INSTALLATION - LINUX
V12 - yum repository - linux 8
rpm -ivh <filename.rpm>
For Redhat 8 inbuilt postres diable
dnf -qy module disable postgresql 
yum list module postgresql*
Yum install postgresql12-server.x86_64 postgresql12-contrib.X86_64
passwd postgres 
systemctl status postgresql-12
su - postgres
Set env variables in vi bash_profile (For each USER accout)
"DATA path = /var/lib/pgsql/12/   ---------------- already set
BIN path /usr/pgsql-12/bin
PATH=$PATH:HOME/bin/
export PATH
export PATH=/usr/pgsql-12/bin:$PATH"


"VARIABLES
shared_buffer 
wal_buffer
work_mem, maintenance_work_mem, temp_buffers"

Database Cluster:
• Database cluster is a collection of databases that is managed by a single instance on a server.
• Initdb creates a new PostgreSQL database cluster.
"• Creating a database cluster consists of creating the directories in which the data is store. 
We call this the” data directory”."
• We have to first initialize the storage area on the disk before we begin any operation on the database.
• Location of Data Directory:
              Linux:  /var/lib/pgsql/data (Not mandatory)
Windows: C:\Program Files\PostgreSQL\12\data (Not mandatory)

Initdb:
• We have to be logged in as PostgreSQL user (Linux) to execute the below commands.
• There are two way to initialize database.
• Syntax:  
              initdb -D /usr/local/pgsql/data(Linux)
initdb -D -U postgres /usr/local/pgsql/data(Windows) 
pg_ctl -D -U postgres /usr/local/pgsql/data initdb
• -D = refers to the data directory location.
• -W = we can use this option to force the super user to provide password before initialize db

Start\Stop\Enable Cluster:
NOTE : User pg_ctl for postgress user and systemctl for ROOT user 

Linux: systemctl start postgresql-12 
Linux: systemctl stop postgresql-12
Windows: pg_ctl –D “C:\Program Files\PostgreSQL\12\data” start
Windows: pg_ctl stop -D “C:\Program Files\Postgresql \12\data” –m shutdown mode
pg_clt status ; pg_ctl start;

systemctl enable postgresql-12
systemctl disable postgresql-12

Types of Shutdown: 
"• Smart: the server disallows new connections, but let's existing sessions end their work normally. 
It shuts down only after all of the sessions terminate"
• Fast :( Default): The server disallows new connections and abort their current transactions and exits gracefully.
• Immediate: Quits/aborts without proper shutdown which lead to recovery on next startup.
• 
Difference between Reload and Restart.
• When we make changes to server parameters, we need to reload the configuration for them to take effect.
• Reload will just reload the new configurations, without restarting the service. 
• Few configuration changes in server parameters, Do not get reflected until we restart the service.
• Restart gracefully shutdown all activity, relinquishes the resource, close all open files and start again with new conf.
Reload\Restart Cluster:
• Syntax for Reload of Cluster:
   On Linux: system reload posgresql-11
   On windows: pg_ctl reload
• Syntax for Restart of Cluster:
   On Linux: systemctl restart postgresql-11
   On Windows: pg_ctl restart
• On Shell:
SELECT pg_reload_conf(); (Irrespective of Env)
select pending_restart,name,setting from pg_settings where pending_restart='t' ;


Pg_Controldata:
•   Pg_controldata – Information about cluster.
       Syntax:/pg_controldata /var/lib/pgsql/12/data/ 


//QUERIES 

$PSQL -h $HOST -p $PORT -U$PSQL_USER postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;" | grep -Ev rdsadmin


[root@aws-prd-recon360-db01 ~]# sudo -u postgres psql --port 5665 -E
could not change directory to "/root": Permission denied
psql (14.2)
Type "help" for help.

postgres=# \
invalid command \
Try \? for help.
postgres=# \l
********* QUERY **********
SELECT d.datname as "Name",
       pg_catalog.pg_get_userbyid(d.datdba) as "Owner",
       pg_catalog.pg_encoding_to_char(d.encoding) as "Encoding",
       d.datcollate as "Collate",
       d.datctype as "Ctype",
       pg_catalog.array_to_string(d.datacl, E'\n') AS "Access privileges"
FROM pg_catalog.pg_database d
ORDER BY 1;
**************************

                                     List of databases
     Name     |   Owner   | Encoding |   Collate   |    Ctype    |    Access privileges
--------------+-----------+----------+-------------+-------------+--------------------------
 keycloak     | keycloak  | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 livquik      | m2pappdb2 | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 pmm_db       | m2p331    | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 postgres     | postgres  | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =Tc/postgres            +
              |           |          |             |             | postgres=CTc/postgres   +
              |           |          |             |             | read_only_all=c/postgres+
              |           |          |             |             | write_recon=c/postgres
 recon        | m2pappdb2 | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 recon_master | m2pappdb2 | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 sbm          | postgres  | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 template0    | postgres  | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres             +
              |           |          |             |             | postgres=CTc/postgres
 template1    | postgres  | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres             +
              |           |          |             |             | postgres=CTc/postgres
 test         | postgres  | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 yesbank      | postgres  | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =Tc/postgres            +
              |           |          |             |             | postgres=CTc/postgres   +
              |           |          |             |             | write_users=c/postgres  +
              |           |          |             |             | m2p469=c/postgres
(11 rows)

postgres=# \du+
********* QUERY **********
SELECT r.rolname, r.rolsuper, r.rolinherit,
  r.rolcreaterole, r.rolcreatedb, r.rolcanlogin,
  r.rolconnlimit, r.rolvaliduntil,
  ARRAY(SELECT b.rolname
        FROM pg_catalog.pg_auth_members m
        JOIN pg_catalog.pg_roles b ON (m.roleid = b.oid)
        WHERE m.member = r.oid) as memberof
, pg_catalog.shobj_description(r.oid, 'pg_authid') AS description
, r.rolreplication
, r.rolbypassrls
FROM pg_catalog.pg_roles r
WHERE r.rolname !~ '^pg_'
ORDER BY 1;

postgres=# \dt+
********* QUERY **********
SELECT n.nspname as "Schema",
  c.relname as "Name",
  CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special' WHEN 't' THEN 'TOAST table' WHEN 'f' THEN 'foreign table' WHEN 'p' THEN 'partitioned table' WHEN 'I' THEN 'partitioned index' END as "Type",
  pg_catalog.pg_get_userbyid(c.relowner) as "Owner",
  CASE c.relpersistence WHEN 'p' THEN 'permanent' WHEN 't' THEN 'temporary' WHEN 'u' THEN 'unlogged' END as "Persistence",
  am.amname as "Access method",
  pg_catalog.pg_size_pretty(pg_catalog.pg_table_size(c.oid)) as "Size",
  pg_catalog.obj_description(c.oid, 'pg_class') as "Description"
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
     LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
WHERE c.relkind IN ('r','p','')
      AND n.nspname <> 'pg_catalog'
      AND n.nspname !~ '^pg_toast'
      AND n.nspname <> 'information_schema'
  AND pg_catalog.pg_table_is_visible(c.oid)
ORDER BY 1,2;

	
postgres=# \dn+
********* QUERY **********
SELECT n.nspname AS "Name",
  pg_catalog.pg_get_userbyid(n.nspowner) AS "Owner",
  pg_catalog.array_to_string(n.nspacl, E'\n') AS "Access privileges",
  pg_catalog.obj_description(n.oid, 'pg_namespace') AS "Description"
FROM pg_catalog.pg_namespace n
WHERE n.nspname !~ '^pg_' AND n.nspname <> 'information_schema'
ORDER BY 1;

postgres=# \df+
********* QUERY **********
SELECT n.nspname as "Schema",
  p.proname as "Name",
  pg_catalog.pg_get_function_result(p.oid) as "Result data type",
  pg_catalog.pg_get_function_arguments(p.oid) as "Argument data types",
 CASE p.prokind
  WHEN 'a' THEN 'agg'
  WHEN 'w' THEN 'window'
  WHEN 'p' THEN 'proc'
  ELSE 'func'
 END as "Type",
 CASE
  WHEN p.provolatile = 'i' THEN 'immutable'
  WHEN p.provolatile = 's' THEN 'stable'
  WHEN p.provolatile = 'v' THEN 'volatile'
 END as "Volatility",
 CASE
  WHEN p.proparallel = 'r' THEN 'restricted'
  WHEN p.proparallel = 's' THEN 'safe'
  WHEN p.proparallel = 'u' THEN 'unsafe'
 END as "Parallel",
 pg_catalog.pg_get_userbyid(p.proowner) as "Owner",
 CASE WHEN prosecdef THEN 'definer' ELSE 'invoker' END AS "Security",
 pg_catalog.array_to_string(p.proacl, E'\n') AS "Access privileges",
 l.lanname as "Language",
 COALESCE(pg_catalog.pg_get_function_sqlbody(p.oid), p.prosrc) as "Source code",
 pg_catalog.obj_description(p.oid, 'pg_proc') as "Description"
FROM pg_catalog.pg_proc p
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
     LEFT JOIN pg_catalog.pg_language l ON l.oid = p.prolang
WHERE pg_catalog.pg_function_is_visible(p.oid)
      AND n.nspname <> 'pg_catalog'
      AND n.nspname <> 'information_schema'
ORDER BY 1, 2, 4;
**************************
                                                                                                                                                                | job_id integer, schedule_interval interval DEFAULT NULL::interval, max_runtime interval DE
postgres=# \dv+
********* QUERY **********
SELECT n.nspname as "Schema",
  c.relname as "Name",
  CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special' WHEN 't' THEN 'TOAST table' WHEN 'f' THEN 'foreign table' WHEN 'p' THEN 'partitioned table' WHEN 'I' THEN 'partitioned index' END as "Type",
  pg_catalog.pg_get_userbyid(c.relowner) as "Owner",
  CASE c.relpersistence WHEN 'p' THEN 'permanent' WHEN 't' THEN 'temporary' WHEN 'u' THEN 'unlogged' END as "Persistence",
  pg_catalog.pg_size_pretty(pg_catalog.pg_table_size(c.oid)) as "Size",
  pg_catalog.obj_description(c.oid, 'pg_class') as "Description"
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('v','')
      AND n.nspname <> 'pg_catalog'
      AND n.nspname !~ '^pg_toast'
      AND n.nspname <> 'information_schema'
  AND pg_catalog.pg_table_is_visible(c.oid)
ORDER BY 1,2;
**************************

                                   List of relations
 Schema |          Name           | Type | Owner  | Persistence |  Size   | Description
--------+-------------------------+------+--------+-------------+---------+-------------
 public | pg_stat_statements      | view | m2p331 | permanent   | 0 bytes |
 public | pg_stat_statements_info | view | m2p331 | permanent   | 0 bytes |
(2 rows)

postgreyesbank=# \d fileprocess.r_visa_summary_sheet_hist;
********* QUERY **********
SELECT c.oid,
  n.nspname,
  c.relname
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relname OPERATOR(pg_catalog.~) '^(r_visa_summary_sheet_hist)$' COLLATE pg_catalog.default
  AND n.nspname OPERATOR(pg_catalog.~) '^(fileprocess)$' COLLATE pg_catalog.default
ORDER BY 2, 3;
**************************

********* QUERY **********
SELECT c.relchecks, c.relkind, c.relhasindex, c.relhasrules, c.relhastriggers, c.relrowsecurity, c.relforcerowsecurity, false AS relhasoids, c.relispartition, '', c.reltablespace, CASE WHEN c.reloftype = 0 THEN '' ELSE c.reloftype::pg_catalog.regtype::pg_catalog.text END, c.relpersistence, c.relreplident, am.amname
FROM pg_catalog.pg_class c
 LEFT JOIN pg_catalog.pg_class tc ON (c.reltoastrelid = tc.oid)
LEFT JOIN pg_catalog.pg_am am ON (c.relam = am.oid)
WHERE c.oid = '945288';
**************************

********* QUERY **********
SELECT a.attname,
  pg_catalog.format_type(a.atttypid, a.atttypmod),
  (SELECT pg_catalog.pg_get_expr(d.adbin, d.adrelid, true)
   FROM pg_catalog.pg_attrdef d
   WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef),
  a.attnotnull,
  (SELECT c.collname FROM pg_catalog.pg_collation c, pg_catalog.pg_type t
   WHERE c.oid = a.attcollation AND t.oid = a.atttypid AND a.attcollation <> t.typcollation) AS attcollation,
  a.attidentity,
  a.attgenerated
FROM pg_catalog.pg_attribute a
WHERE a.attrelid = '945288' AND a.attnum > 0 AND NOT a.attisdropped
ORDER BY a.attnum;
**************************

********* QUERY **********
SELECT pol.polname, pol.polpermissive,
  CASE WHEN pol.polroles = '{0}' THEN NULL ELSE pg_catalog.array_to_string(array(select rolname from pg_catalog.pg_roles where oid = any (pol.polroles) order by 1),',') END,
  pg_catalog.pg_get_expr(pol.polqual, pol.polrelid),
  pg_catalog.pg_get_expr(pol.polwithcheck, pol.polrelid),
  CASE pol.polcmd
    WHEN 'r' THEN 'SELECT'
    WHEN 'a' THEN 'INSERT'
    WHEN 'w' THEN 'UPDATE'
    WHEN 'd' THEN 'DELETE'
    END AS cmd
FROM pg_catalog.pg_policy pol
WHERE pol.polrelid = '945288' ORDER BY 1;
**************************

********* QUERY **********
SELECT oid, stxrelid::pg_catalog.regclass, stxnamespace::pg_catalog.regnamespace::pg_catalog.text AS nsp, stxname,
pg_catalog.pg_get_statisticsobjdef_columns(oid) AS columns,
  'd' = any(stxkind) AS ndist_enabled,
  'f' = any(stxkind) AS deps_enabled,
  'm' = any(stxkind) AS mcv_enabled,
stxstattarget
FROM pg_catalog.pg_statistic_ext
WHERE stxrelid = '945288'
ORDER BY nsp, stxname;
**************************

********* QUERY **********
SELECT pubname
FROM pg_catalog.pg_publication p
JOIN pg_catalog.pg_publication_rel pr ON p.oid = pr.prpubid
WHERE pr.prrelid = '945288'
UNION ALL
SELECT pubname
FROM pg_catalog.pg_publication p
WHERE p.puballtables AND pg_catalog.pg_relation_is_publishable('945288')
ORDER BY 1;
**************************

********* QUERY **********
SELECT c.oid::pg_catalog.regclass
FROM pg_catalog.pg_class c, pg_catalog.pg_inherits i
WHERE c.oid = i.inhparent AND i.inhrelid = '945288'
  AND c.relkind != 'p' AND c.relkind != 'I'
ORDER BY inhseqno;
**************************

********* QUERY **********
SELECT c.oid::pg_catalog.regclass, c.relkind, inhdetachpending, pg_catalog.pg_get_expr(c.relpartbound, c.oid)
FROM pg_catalog.pg_class c, pg_catalog.pg_inherits i
WHERE c.oid = i.inhrelid AND i.inhparent = '945288'
ORDER BY pg_catalog.pg_get_expr(c.relpartbound, c.oid) = 'DEFAULT', c.oid::pg_catalog.regclass::pg_catalog.text;
**************************
s=#


========================================================================================================================================
CONNECT REMOTE
psql -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5440 -Uyapuser settlement

psql -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5440 -Uyapuser postgres -c "SELECT datname FROM pg_database WHERE datistemplate = false;"
 psql -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5440 -Uyapuser postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;"
psql -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5440 -Uyapuser -PR3dr0ck! postgres


PGPASSWORD='R3dr0ck!' psql -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5440 -Uyapuser postgres


BACKUP 

pg_dump -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5440 -Uyapuser --format plain --verbose --file "<abstract_file_path>" --table public.tablename dbname
pg_dump -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5440 -Uyapuser -d reports -t card_expiry_tb > card_expiry_tb.sql
pg_dump -h yap-prd-aws-postgresql01.q.ap-south-1.rds.amazonaws.com -p 5432 -Umyuser  -s orchestration -t card_expiry_tb -d reportdb -f table1.sql
pg_dump -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5440 -Uyapuser  -s orchestration -t card_expiry_tb > orchestration_card_expiry_tb.sql

pg_dump -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5440 -Uyapuser  -n orchestration -t card_expiry_tb -d reports -f orchestration_card_expiry_tb.sql
pg_dump -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5440 -Uyapuser  -n schema -t table -d reportdb -f table1.sql

LOGICAL 
pg_dump -d test_db > /backup/pg-backup
REMOTE

pg_dump -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5440 -Uyapuser -Fc reports > /backup/postgres-backup/reports.dump
pg_dump -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5440 -Uyapuser -Fc -o test_db > /backup/postgres-backup/test_db.dump

pg_dump -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -Fc -o -U yapuser test_db > /backup/pg-backup/test_db.dump
pg_dump -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5432 -Fc -o -U yapuser test_db > /backup/pg-backup/test_db.dump
pg_dump -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5432 -Fc -o -U myuser mydb > mydb_backup.dump


export EXCLUDETABLE=$(psql -t -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -Uyapuser d template1 -c "select '--exclude-table=' || string_agg(pg_authid,' --exclude-table=') FROM pg_catalog.pg_tables WHERE tableowner NOT LIKE 'yapuser';" )


pg_dumpall > PATH
pg_dumpall -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5440 -Uyapuser > /backup/postgres-backup/clusterall.sql
pg_dumpall -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5440 -Uyapuser --no-role-password --globals-only -s -Fc > /backup/postgres-backup/clusterall.sql

pg_dumpall -h yap-prd-aws-postgresql01.cihhrmsghyvq.ap-south-1.rds.amazonaws.com -p 5440 -Uyapuser --no-role-password --globals-only -s --f /backup/postgres-backup/clusterall.sql

pg_dump -U postgres -d test1 > /var/lib/pgsql/12/backups/test1backup
pg_dumpall -U postgres > /var/lib/pgsql/12/backups/clusterall.sql
pg_dump -U postgres -Fc > nano.dump


pg_dumpall -h &lt;> -U &lt;> -l &lt;> --no-role-password --globals-only -s -f


Compress
pg_dump test1 | gzip >/var/lib/pgsql/11/backups/test1backup.gz
pg_dumpall |gzip  > cluster_backup.gz
Split
pg_dump test1 | split -b 1k - /var/lib/pgsql/11/backups/test1backup
PHYSICAL 
OFFLINE
FILESYSTEM
pg_ctl stop
tar –cvzf backup.tar /usr/local/pgsql/data

ENABLE ARCHIVE MODE
show archive_mode ;
On postgresql.conf - Enable wal_level , archive_mode=on , archive_command = 'cp -i %p <PATH>', 
Generate archive logs (WAL files )
select pg_start_backup('test1')
select pg_stop_backup()
ONLINE 
LOW LEVEL API
select pg_start_backup('LABEL','NOHUP','LOCK')    ;     select pg_stop_backup('f') --------- achives logs
tar -czvf backup.tar  /usr/local/pgsql/data ------------ actual backup
PG_BASEBACKUP
pg_basebackup –D <backup directory location>
pg_basebackup -U postgres -D <PATH> -Fp -P -Xs 
pg_basebackup -h localhost -p 5432 -U postgres -D <PATH> -Ft -z -P -Xs 


RESTORE
PSQL
psql -U test1  -d test1 </var/lib/pgsql/11/backups/test1backup
psql DBNAME < db_backup.sql
psql -f cluster_backup.sql postgres
psql -c db_backup.gz | test1

PG_RESTORE (CUSTOM)
pg_dump -Fc test1 > test1.dmp
pg_restore -t employee -d test1 -U postgres test1.dmp 
[10:26] Balasubramaniam Alagarsamy
pg_restore --verbose --no-acl --no-owner -U m2pappdb2 -h localhost -p 5432 -d teamdb < local.dump
pg_restore --verbose --no-acl --no-owner -U m2p331 -h localhost -p 5432 -d mydb < local.dump


PIT
restore_command = 'cp /mnt/server/archivedir/%f "%p“'  # Linux
restore_command = 'copy "C:\\server\\archivedir\\%f" "%p"'  # Windows
Recovery_Target = immediate ( This parameter specifies the recovery should end as soon as a consistent state is reached).
Recover_Target_Lsn – This parameter specifies the LSN pf the wrote-ahead log location up to which the recovery will proceed

•Recovery_Target_Name = This parameter specifies the named restore point(create with pg_create_restore_point)) to which recovery will proceed.
•Recovery_Target_Time = This parameter specifies the time stamp up to which recovery will proceed. 
•Recovery_Target_Xid = The parameter specifies the transaction ID upto which recovery will proceed.
•Recovery_Target_Inclusive = Specifies whether to stop the recovery just after the target is reached(on) or just before the recover target(off). Default is On.





MAINTENANCE
If Auto_vaccum is turned off
Check COUNT 
select count (*) from tel_directory 
Check CARD
select relname, reltuples, relpages, from pg_class where relname='tel_directory'
Run EXPLAIN 
Explain select * from tel_directory 
Do ANALYZE
Analyze tel_directory 
Run EXPLAIN again
Explain select * from tel_directory 

COST Calculation = (no.of.pages*seq_page_cost)+(no.of.rows*cpu_tuple_cost)
No of pages -> select relpages from pg_class from relname = 'tel_dir'
show seq_page_cost
select count (*) from tel_dir
show cpu_tuple_cost;

DATA FRAGMENATION - BLOAT (HVM )
Auto Vacuum
Turn on/off
alter table tel_dir set (autovacuum_enabled=true);
select reloptions from pg_class where relname='tel_dir';
Vacuum
Vacuum -> No locks - removes bloating from a table
vacuum(verbose) tel_dir;
Vacummdb -U postgres -d postgres     # DB level
Vacuum Full
Vacuumfull -> exclusive locks - reclaims space - reads the entire data to disk again- replace like 
vacuumfull (full,verbose) tel_dir;
Vacummdb -f -v -U postgres -d postgres     # DB levvel 

MVCC - Multiversion Concurrency control - provides concurrent access to db
Has transaction ID numbers - transaction ID size 32bits 
Cluster running more than 4 billion transaction would suffer transaction ID wraparound 
select datname,age(datfrozenxid),current_settings('autovacuum_freeze_max_age') from pg_database order by 2 desc;

V FREEZE
Makes rows as frozen - postgres reserves special XID called Frozen transaction ID



ROUTINE REINDEXING
Index fragments over period of time - degrade query performance - Index rebuiting required 
Check if pgstattuple is installed 
select * form pg_available_extensions;
create extension pgstattuple;
di;
select * from pgstatindex ('telidx');
reindex index telidx;

UPGRADE
pg_dumpall
pg_upgrade
upgrade over replication


Psql Commands

Connect to Psql

• Connect to Specific Database with user and password
Syntax: psql -d database -U user –W (-d =Database, -U = User, -W = Password)
• Connect to Database on a different host/machine.
 Syntax: psql -h host -d database -U user –W
• Connect using SSL Mode
   Syntax: psql -U user -h host "dbname=db sslmode=require"

Psql Commands

• Switch connection to a new database
 postgres=# \c test1
 You are now connected to database "test1" as user "postgres".
• List available databases
 postgres=# \l
 
      List of schemas
 postgres=> \dn
 set schema 'orchestration';
 postgres=# \ dt orchestration


SHOW search_path;
SET search_path TO

• List available tables
 postgres=# \ dt
• List users and their roles(+ to get more info)
    postgres=# \du
• List available sequence(+ to get more info) 
   postgres=# \ds
• Execute the previous command 
    postgres=# \g
• Command history
    postgres=# \s

• Save Command History to file:
   postgres=# \s filename
• Get help on psql commands
    postgres=# \?
• Turn on\off query execution time
    postgres=# \timing
• Edit statements in editor
   postgres=# \e
• Edit Functions in editor
   postgres=# \ef
• set output from non-aligned to aligned column output.
     postgres=# \a
• Formats output to HTML format.
     postgres=# \H
• Connection Information 
    postgres=# \conninfo
• Quit psql 
    postgres=# \q
	
	
Psql File Operations

• Run sql statements from a file.
   psql -d test1 -U test1 -f test1.sql ( command line)
• Send the output to a file.
   postgres=# \o <filename>
• Save query buffer to filename.
   postgres=# \w filename
• Turn off auto commit on session level
  \set AUTOCOMMIT off
============


CREATE USER readme WITH PASSWORD 'Open@123';
GRANT CONNECT ON DATABASE postgres TO readme;
GRANT USAGE ON SCHEMA public TO readme;
grant all privileges on database postgres to readme;

create database mydb;
create user myuser with encrypted password 'mypass';
grant all privileges on database mydb to myuser;

>Grant SELECT for a specific table:
GRANT SELECT ON table_name TO readme;
>Grant SELECT for multiple tables:
GRANT SELECT ON ALL TABLES IN SCHEMA schema_name TO readme;
If you want to grant access to the new table in the future automatically, you have to alter default:
ALTER DEFAULT PRIVILEGES IN SCHEMA schema_name
GRANT SELECT ON TABLES TO readme;


GRANT CONNECT ON DATABASE postgres TO m2pappdb2;
grant all privileges on schema recon to m2pappdb2;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA recon TO m2pappdb2;


-- Create a group
CREATE ROLE readaccess;

-- Grant access to existing tables
GRANT USAGE ON SCHEMA orchestration TO readaccess;
GRANT SELECT ON ALL TABLES IN SCHEMA orchestration TO readaccess;

-- Grant access to future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA orchestration GRANT SELECT ON TABLES TO readaccess;

-- Create a final user with password
CREATE USER readme WITH PASSWORD 'Open@123';
GRANT readaccess TO readme;
===========================================================================
/*QUERIES*/

select * from pg_stat_activity;
SELECT * FROM pg_stat_activity where state ='active' and user not like '%postgres%';
SELECT query,current_timestamp - query_start,wait_event_type,pid,* FROM pg_stat_activity WHERE state = 'active' and datname = 'livquik';
 SELECT query,current_timestamp - query_start,wait_event_type,pid,* FROM pg_stat_activity WHERE pid=4001502;
--for lockss
	select pid,usename,pg_blocking_pids(pid) as blocked_by, query as blocked_query from pg_stat_activity where cardinality(pg_blocking_pids(pid)) > 0;
select relation::regclass, * from pg_locks where not granted;

--History
SELECT psa.query_start
     , psa.backend_Start
     , psa.state
     , pss.query AS SQLQuery
     , pss.rows  AS TotalRowCount
FROM pg_stat_statements AS pss
         INNER JOIN pg_database AS pd
                    ON pss.dbid = pd.oid
         inner join pg_stat_activity as psa
                    on pd.datname = psa.datname
                        and psa.client_addr = '3.109.11.152'
                        and psa.datname = 'postgres';

--Long Running
SELECT pid, age(clock_timestamp(), query_start), usename, query
FROM pg_stat_activity
WHERE query != '<IDLE>' AND query NOT ILIKE '%pg_stat_activity%'
ORDER BY query_start desc;


CREATE VIEW lock_monitor AS(
SELECT
  COALESCE(blockingl.relation::regclass::text,blockingl.locktype) as locked_item,
  now() - blockeda.query_start AS waiting_duration, blockeda.pid AS blocked_pid,
  blockeda.query as blocked_query, blockedl.mode as blocked_mode,
  blockinga.pid AS blocking_pid, blockinga.query as blocking_query,
  blockingl.mode as blocking_mode
FROM pg_catalog.pg_locks blockedl
JOIN pg_stat_activity blockeda ON blockedl.pid = blockeda.pid
JOIN pg_catalog.pg_locks blockingl ON(
  ( (blockingl.transactionid=blockedl.transactionid) OR
  (blockingl.relation=blockedl.relation AND blockingl.locktype=blockedl.locktype)
  ) AND blockedl.pid != blockingl.pid)
JOIN pg_stat_activity blockinga ON blockingl.pid = blockinga.pid
  AND blockinga.datid = blockeda.datid
WHERE NOT blockedl.granted
AND blockinga.datname = current_database()
);

SELECT * from lock_monitor;


--to kill
select pg_terminate_backend(2641166);

SELECT pg_terminate_backend(pid) FROM pg_stat_activity
WHERE datname = 'm2p331' AND pid <> pg_backend_pid()
AND state in ('idle');

SELECT * FROM pg_stat_activity where state ='active' and user not like '%postgres%';


select * from pg_stat_activity;
SELECT * FROM pg_stat_activity where state ='active' and user not like '%postgres%';
select * from pg_settings where name like '%effective_cache_size%';
select * from pg_settings where name like '%mem%';
SELECT * FROM pg_user;
select * from pg_available_extensions;
SELECT relname, has_table_privilege('rds_superuser',relname,'SELECT') as SELECT,has_table_privilege('rds_superuser',relname,'UPDATE') as UPDATE,has_table_privilege('rds_superuser',relname,'INSERT') as INSERT,has_table_privilege('rds_superuser',relname,'TRUNCATE') as TRUNCATE FROM pg_class c , pg_namespace n where n.oid = c.relnamespace  and n.nspname in ('pg_catalog')  and relkind='r';
--DB Size
select t1.datname AS db_name,pg_size_pretty(pg_database_size(t1.datname)) as db_size from pg_database t1 order by pg_database_size(t1.datname) desc;
select datname,oid from pg_database;
select name, source,boot_val,sourcefile, pending_restart from pg_settings where name ='shared_buffers';
select * from pg_file_settings;
select * from pg_settings where name='shared_preload_libraries';
SELECT max(now() -xact_start) FROM pg_stat_activity WHERE state IN ('idle in transaction','active');
grant all privileges on schema recon to m2pappdb2;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA recon TO m2pappdb2;
grant alter ON ALL TABLES IN SCHEMA recon TO m2pappdb2;
ALTER DATABASE postgres OWNER TO m2pappdb2;
select * from pg_tables where tableschema = 'recon';
select * from pg_tables where tableowner= 'postgres';


SELECT format(
  'ALTER TABLE %I.%I.%I OWNER TO %I;',
  table_catalog,
  table_schema,
  table_name,
  postgres
)
FROM information_schema.tables
WHERE table_schema = 'recon';

SELECT 'ALTER TABLE '||schemaname||'.'||tablename||' \
                                      OWNER TO new_owner;' \
                                      FROM pg_tables \
                                      WHERE schemaname = 'myschema'";


select * from information_schema.tables


----------
Reports database
Executable SCHEMA

--Disable Data System
update executable.job_submission_tb set value = 0 where key = 'job.submission.check';
update executable.activities_tb set status = 0 where id in (22,23,24);

--Enable Data System
update executable.job_submission_tb set value = 1 where key = 'job.submission.check';
update executable.activities_tb set status = 1 where id in (22,23,24);


SELECT value FROM  executable.job_submission_tb where key = 'job.submission.check';
SELECT status FROM executable.activities_tb  where id in (22,23,24);


SELECT relname, has_table_privilege('rds_superuser',relname,'SELECT') as SELECT,has_table_privilege('rds_superuser',relname,'UPDATE') as UPDATE,has_table_privilege('rds_superuser',relname,'INSERT') as INSERT,has_table_privilege('rds_superuser',relname,'TRUNCATE') as TRUNCATE FROM pg_class c , pg_namespace n where n.oid = c.relnamespace  and n.nspname in ('pg_catalog')  and relkind='r';

SELECT relname, has_table_privilege('yapuser',relname,'SELECT') as SELECT,has_table_privilege('yapuser',relname,'UPDATE') as UPDATE,has_table_privilege('yapuser',relname,'INSERT') as INSERT,has_table_privilege('yapuser',relname,'TRUNCATE') as TRUNCATE FROM pg_class c , pg_namespace n where n.oid = c.relnamespace  and n.nspname in ('pg_catalog')  and relkind='r';


SELECT table_schema || '.' || table_name FROM information_schema.tables
WHERE table_type = 'BASE TABLE' AND table_schema NOT IN ('pg_catalog', 'information_schema');


 GRANT ALL PRIVILEGES ON TABLE pg_authid TO yapuser;

SELECT datname FROM pg_database WHERE datistemplate = false;
SELECT * FROM pg_database WHERE datistemplate = false;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA orchestration TO yapuser;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA orchestration TO yapuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA orchestration TO yapuser;

LIST CONNECTIONS 

SELECT pid
    ,datname
    ,usename
    ,application_name
    ,client_hostname
    ,client_port
    ,backend_start
    ,query_start
    ,query
    ,state FROM pg_stat_activity WHERE state = 'active';

SELECT * FROM pg_stat_activity WHERE state = 'active';

SELECT * FROM pg_stat_activity WHERE datname = 'dbname' and state = 'active';

select * from pg_settings where name in ('...', '...');


SELECT max(now() -xact_start) FROM pg_stat_activity WHERE state IN ('idle in transaction','active');

--CHECK DB
current_database()

--TABLE LIST 
SELECT table_name from INFORMATION_SCHEMA.tables where  table_schema='recon';
select tablename from pg_catalog.pg_tables where schemaname='recon';

--DB size 
select t1.datname AS db_name,pg_size_pretty(pg_database_size(t1.datname)) as db_size from pg_database t1 order by pg_database_size(t1.datname) desc;
select datname , pg_size_pretty(pg_database_size(datname)) from pg_database order by pg_database_size(datname) desc;

SELECT nspname || '.' || relname AS ""relation"", pg_size_pretty(pg_relation_size(C.oid)) AS ""size"" FROM pg_class C LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) WHERE nspname NOT IN ('pg_catalog', 'information_schema') ORDER BY pg_relation_size(C.oid) DESC LIMIT 20;"

--TABLE SIZE /RELATION SIZE
select table_schema, table_name, pg_relation_size('"'||table_schema||'"."'||table_name||'"') from information_schema.tables order by 3 desc ;

--DESC
SELECT table_catalog,COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH,column_default,is_nullable from INFORMATION_SCHEMA.COLUMNS where table_schema='recon' and table_name = 't_visa_cbs_stage'  ;
--RENAME TABLE 
create table recon.transaction_old as select *  from recon.transaction; ;
--Drop null
ALTER TABLE person ALTER COLUMN phone DROP NOT NULL;

--Connection details
select backend_start from pg_stat_activity where client_addr='172.150.6.131' order by 1 desc;
select backend_start from pg_stat_activity where client_addr='172.150.6.131' ;
select  datname,count(datid) from pg_stat_activity where client_addr='172.150.6.131' group by 1;
select distinct datname from pg_stat_activity where client_addr='172.150.6.131';

select  client_addr,count(datid) from pg_stat_activity group by 1 order by 2 desc;
--db level
select datname,client_addr,count(datid) from pg_stat_activity group by datname,client_addr order by count(datname) desc WHERE state like '%idle%';;

--Force Idle
SELECT pg_terminate_backend(pid)
    FROM pg_stat_activity
    WHERE datname = 'postgres'
      AND pid <> pg_backend_pid()
      AND state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled')
      AND application_name !~ '(?:psql)|(?:pgAdmin.+)'
      AND state_change < current_timestamp - INTERVAL '5' MINUTE;
      
      SELECT pg_terminate_backend(pid)
    FROM pg_stat_activity
    WHERE 
      AND pid <> pg_backend_pid()
      AND state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled')
      AND application_name !~ '(?:psql)|(?:pgAdmin.+)'
      AND state_change < current_timestamp - INTERVAL '5' MINUTE;
      
select (EXTRACT(EPOCH FROM (current_timestamp - state_change)))/60 from pg_stat_activity where state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled') order by 1 desc;

================================================================
Tablespace



Create tablespace:

• Syntax for creating tablespace: (ensure the location exist)
     create tablespace hrd location '/opt/app/hrd/';
• Syntax for creating a table on a newly created tablespace
      create table test1(studid int,stuname varchar(50))  tablespace hrd;
• Query to find which tablespace the table belong to
      select * from pg_tables where tablespace='hrd';
                      or
      select * from pg_tables where tablename='test1'; 

Move Table between tablespaces:

• Move tables from one tablespace to another
 Syntax:
 alter table test1 set tablespace pg_default
• Check whether the table is moved successfully to another tablespace
 Syntax: select * from pg_tables where tablename='test1'
• Find physical location of the table
Syntax: select pg_relation_filepath('test1');
• Find physical location of the tablespace
Syntax: postgres#/dt


Drop Tablespace:
• We cannot drop a tablespace which is not empty.
• Find objects associate with the tablespace
Syntax: select * from pg_tables where tablespace = 'hrd';
• Drop tablespace 
Syntax: drop tablespace hrd;
• Query pg system catalog view to check the tablespace is dropped.
Syntax: select * from pg_tablespace;


Temporary tablespace:
• How to create temporary tablespace
Syntax : CREATE TABLESPACE temp01 OWNER ownername LOCATION '\opt\app\hrd\'
• Set temp_tablespaces=temp01 in postgresql.conf and reloaded configuration.




"CATALOG TABLES 
""pg_database			-  Stores general database info
pg_tablespace		-  Contains Tablespace information
pg_operator			-  Contains all operator information
pg_available_extensions -	List all available extensions
pg_shadow			- List of all database users
pg_stats			- Planner stats
pg_timezone_names	- Time Zone names
pg_locks			- Currently held locks
pg_tables	 		- All tables in the database
pg_settings			- Parameter Settings
pg_user_mappings	- All user mappings
pg_indexes			- All indexes in the database
pg_views	 		- All views in the database.
"""
MONITOR 
"LOCKS & RUNNING QUERIES
SELECT
  S.pid,
  age(clock_timestamp(), query_start),
  usename,
  query,
  L.mode,
  L.locktype,
  L.granted
FROM pg_stat_activity S
inner join pg_locks L on S.pid = L.pid 
order by L.granted, L.pid DESC"

"CANCEL QUERY 
SELECT pg_cancel_backend(pid);
"

Page Header 
24 byte
Information about free space and page size - During insert record - db checks header on avaialbility
Item ID data
Array of pairs pointing to Tuple / Item / row
Free space
Inserts from bottom 
Tuple
Actual Item or row
Special
Index access method specific data - Empty if no index
=

"OTHER BUFFERS
•	Work Memory is a memory reserved for either a single sort or hash table (Parameter: Work_mem)
•	Maintenance Work Memory is allocated for Maintenance work (Parameter: maintenance_work_mem).
•	Temp Buffers are used for access to temporary tables in a user session during large sort and hash table. (Parameter: temp_buffers).
-----------------------------
WORK MEM:
Used for Complex Sorting or hash tables.
In-memory sorts are much faster than sorts spilling to disk.
Default Value is 4MB.
Memory allocated for each sort operations(ORDER BY,DISTINCT) and merge joins.Setting this parameter globally can cause very high memory usage as this parameter is used by per user sort operation.
      Work Mem * Total Sort Operations for all sort operations
--------------------
MAINTENANCE_WORK_MEM -
 is a memory setting used for maintenance tasks. Default value is  64MB.
Setting a large value helps in tasks like :
            VACUUM, RESTORE, CREATE INDEX, ADD FOREIGN KEY & ALTER TABLE."
"CHECKPOINT TIMEOUT - Maximum time between automatic WAL checkpoints, in seconds
Default value is 5 Minutes.
Increasing this parameter can increase the amount of time needed for crash recovery.Frequent checkpointing results in continuous writes to disk.
More volume of data written to wal logs when checkpoint interval are less.
Shutdown may take more time when this value is increased"
"CONFIG FILES 

postgresql.conf,
Postgresql.conf file contains parameters to help configure and manage performance of the database server.

postgresql.auto.conf - 
This file hold settings provided through Alter system command.Settings in postgresql.auto.conf overrides the settings in postgresql.conf.
”Alter system” command provides a SQL-accessible means of changing global defaults.
Syntax : ALTER SYSTEM SET configuration_parameter = 'value'
Syntax to reset : ALTER SYSTEM RESET configuration_parameter;
Syntax to reset all : ALTER SYSTEM RESET ALL;

pg_ident.conf -
Operating system user that initiated the connection might not be the same as the database user.
User name map can be applied to map the operating system user name to a database user.

pg_hba.conf - 
Enables client authentication between the PostgreSQL server and the client application.
HBA means host based authentication.

# TYPE              DATABASE        USER            ADDRESS                 METHOD
    host                    all                        all              127.0.0.1/32                    md5
    host                    all                        all              127.0.0.1/32                    crypt/reject/krb

# replication privilege.
   host               replication               all             127.0.0.1/32                    trust

recovery.signal - (before v12)"

pg_ctl status 
psql -u postgres

select datname,oid from pg_database;
create database employees owner postgres;
drop database employees;
\d pg_settings
 


show max_connections;
select * from pg_stat_activity;
max_connections = LEAST({DBInstanceClassMemory/9531392},5000)


select name, source,boot_val,sourcefile, pending_restart from pg_settings where name ='max_connections';
show shared_buffers;
select name, source,boot_val,sourcefile, pending_restart from pg_settings where name ='shared_buffers';
select * from pc_reload_conf();

alter system set work_mem='10MB';
select * from pg_file_settings;
show work_mem
Alter system reset all ;
select * from pc_reload_conf();
show work_mem

Create database <> owner <>
select pg_current_wal_lsn(),pg_walfile_name(pg_current_wal_lsn());
select pg_wal_switch();

select datname, oid from pg_database;


shared_buffer 
wal_buffer
work_mem, maintenance_work_mem, temp_buffers

From Surya P

Checkpoint timeout (if it is 5min please set it to 30 min).
Max_val_size (please set it >4GB or the best possible value)
Work_mem (>=2GB)
Max_parallel_workers (pls set to 8 or above)
max_worker_processes (pls set to 8 or above)
Max_parallel_workers_per_gather (pls set to 6 or above)

Allocated space for development db
As per your expertise, if you can suggest any other settings to optimize, it would be helpful as well.

Regards 



Create database Psql / createdb utility:

• Syntax from psql: Create database databasename owner ownername;
• Syntax from command line: Createdb <dbname>.
• Syntax for help: createdb --help

Drop database – Psql/ dropdb utility:

• We cant drop the database which we are connected.
• Example:
   scott=# drop database scott;
        ERROR:  cannot drop the currently open database
• Syntax from psql: Drop database <dbname>. 
• Syntax from command line: dropdb <dbname>.
• Syntax for dropdb help: dropdb –help

DROP DATABASE mydb WITH (FORCE);


GRANT USAGE ON SCHEMA public TO <user>;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO <user>;

Create user – Psql/ createuser utility/ Interactive:

• Syntax from psql: create user m2pdba login superuser password 'M@PS0luti0ns';
• Syntax from command line: createuser <username>
• Syntax for interactive user creation from command line:
•  Example:
•   createuser --interactive joe
  Shall the new role be a superuser? (y/n) n
  Shall the new role be allowed to create databases? (y/n) y
       Shall the new role be allowed to create more new roles? (y/n) y
• Syntax for createuser help: createuser --help


Drop user - Psql/ dropuser utility:

• Syntax from psql: drop user <username>
• Syntax from command line: dropuser <username>
• Dropping a user with objects or privileges will return an error.
Example:
     postgres=# drop user test1;
     ERROR:  role "test1" cannot be dropped because some objects depend on it
• Assign the user privileges to another user before dropping the user.
Example:
    REASSIGN OWNED BY user to postgres;re
    Drop role username;

Grant:
• Grant CONNECT to the database:
     GRANT CONNECT ON DATABASE database_name TO username;
• Grant USAGE on schema:
     GRANT USAGE ON SCHEMA schema_name TO username;
• Grant on all tables for DML statements: SELECT, INSERT, UPDATE, DELETE
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA schema_name TO username;
• Grant all privileges on all tables in the schema:
     GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA schema_name TO username;
• Grant all privileges on all sequences in the schema:
     GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA schema_name TO username;
• Grant permission to create database:
     ALTER USER username CREATEDB;
• Make a user superuser:
    ALTER USER myuser WITH SUPERUSER;
• Remove superuser status:
     ALTER USER username WITH NOSUPERUSER;
• Column Level access:
    GRANT SELECT (col1), UPDATE (col1) ON mytable TO user;

--Cols Only
GRANT update(blueprints_tb, uosCode) ON blueprints_tb TO m2p331

Revoke Examples

• Revoke Delete/update privilege on table from user
  REVOKE DELETE, UPDATE ON products FROM user;
• Revoke all privilege on table from user
  REVOKE ALL ON products FROM user;
• Revoke select privilege on table from all users (Public)
 REVOKE SELECT ON products FROM PUBLIC;

Create & Drop Schema
• Create Schema
CREATE schema <schema_name>;
• Create Schema for a user, the schema will also be named as the user
Create schema authorization <username>;
• Create Schema named John, that will be owned by brett
CREATE schema IF NOT EXISTS john AUTHORIZATION brett;
• Drop a Schema
 Drop schema <schema_name>;
(We cannot drop schema if there are any object associate with it.)  
• Drop a Schema and its tables 
 Drop schema <schema_name> cascade;
Schema Search Path:
• Show search path can be used to find the current search path.
Example:
      postgres=# show search_path;
 search_path
 -----------------
 "$user", public
 ( 1 row)
• Default"$user"is a special option that says if there is a schema that matches the current user (i.eSELECT SESSION_USER;), then search within that schema.
• Search path can be set at session level, user level, database level and cluster level
Example:
Test1=# SET search_path TO postgres;
Test1=# \dt
     List of relations
     Schema |  Name   | Type  |  Owner
      --------+---------+-------+----------
       test1  | abc     | table | test1
    (1 rows)


    select pg_reload_conf();



[12:25] Sharath Sankar
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL_pg_cron.html
Scheduling maintenance with the PostgreSQL pg_cron extension - Amazon Relational Database Service
You can use the PostgreSQL pg_cron extension to schedule maintenance commands within a PostgreSQL database. For a complete description, see What is pg_cron? in the pg_cron documentation.
docs.aws.amazon.com


select * from pg_settings where name='shared_preload_libraries';


SELECT cron.schedule('0 */2 * * *', $$ update monitor.file_handling_tb d set status = 2 where d.status = 3 and date(d.created) = date(now()) and d.p_key in( select distinct f.p_key from monitor.file_handling_tb f inner join monitor.exception_tb e on f.req_id = e.reqid where f.status = 3 and f.delivery_mode = 'email' and date(f.created) = date(now()) - 1 and e.stack_trace like 'com.sun.mail.smtp.SMTPSendFailedException: 454 Throttling failure: Maximum sending rate exceeded.%')$$);

--ON VM

su - postgres

yum install postgis* -y

yum lisr  postgis

yum install postgis32_14.x86_64
yum install postgis32_14.x86_64 --skip-broken
yum list gdal34-libs-3.4.1-3.rhel8.x86
yum list gdal34-*
yum install gdal34-libs.x86_64
sudo yum install postgresql10-contrib
y
sudo yum install postgresql10-contrib
sudo yum install postgresql10-contrib -y
su - postres
su - postgres
yum install install postgresql11-contrib
yum install postgresql11-contrib
yum install postgresql14-contrib
su - postgres


CREATE EXTENSION pg_cron
	SCHEMA "public"
	VERSION 1.3
	
	
SELECT max(now() -xact_start) FROM pg_stat_activity WHERE state IN ('idle in transaction','active');


SELECT
    relname AS "relation",
    pg_size_pretty (
        pg_total_relation_size (C .oid)
    ) AS "total_size"
FROM
    pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C .relnamespace)
WHERE
    nspname NOT IN (
        'pg_catalog',
        'information_schema'
    )
AND C .relkind <> 'i'
AND nspname !~ '^pg_toast'
ORDER BY
    pg_total_relation_size (C .oid) DESC
LIMIT 5;




==============


[13-10-2021 13:18] Harish Jayaprakash
invalid input syntax for type bigint: "nextval('card_expiry_seq'::regclass)"

[13-10-2021 13:19] Harish Jayaprakash
nope




================
Select * from
dblink( 'host=yappgresdb.cfzdwmybtrx8.ap-south-1.rds.amazonaws.com user=m2pappdb2 password=M@PS0luti0ns dbname=postgres',
' select count(*) from recon.b_process_dtls ') as (Total_log integer) ;
==============

--EXPIRATION POLICY

CREATE USER miriam WITH PASSWORD 'jw8s0F4' VALID UNTIL '2005-01-01';


SELECT rolname FROM pg_authid WHERE rolvaliduntil IS NOT NULL;
select * from pg_catalog.pg_roles where rolvaliduntil IS NOT NULL;


 UPDATE pg_authid
SET rolvaliduntil = NULL
WHERE rolname IN (
  SELECT rolname
  FROM pg_authid
  WHERE rolvaliduntil IS NOT NULL
);



 UPDATE pg_authid
SET 	 = NULL
WHERE rolname IN (
  SELECT rolname
  FROM pg_authid
  WHERE rolvaliduntil IS NOT NULL
);


=====================
--REMOVE CONSTRAINTS

My PostgreSQL is 9.6.8.

set session_replication_role to replica;
work for me but I need permission.

I login psql with super user.

sudo -u postgres psql
Then connect to my database

\c myDB
And run:

set session_replication_role to replica;
Now I can delete from table with constraint.

Share
Follow	 
=========================

-- Restart time 
 SELECT pg_postmaster_start_time();
SELECT date_trunc('second', current_timestamp - pg_postmaster_start_time()) as uptime;
\conninfo
=========================

--OIDS

SELECT 'ALTER TABLE "' || n.nspname || '"."' || c.relname || '" SET WITHOUT OIDS;'
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE 1=1
  AND c.relkind = 'r'
  AND c.relhasoids = true
  AND n.nspname <> 'pg_catalog' 
order by n.nspname, c.relname;



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




[21:07] Anandhu Vijay




SELECT create_hypertable('transaction','created_date', chunk_time_interval => INTERVAL '1 day');



GRANT SELECT, INSERT, UPDATE, CREATE, PROCESS, ALTER, EXECUTE, SHOW VIEW ON *.* TO 'm2p481'@'%'





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