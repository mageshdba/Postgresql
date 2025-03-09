select * from pg_stat_activity;

SELECT * FROM pg_stat_activity where state ='active' and user not like '%postgres%';

--for locks
select pid,usename,pg_blocking_pids(pid) as blocked_by, query as blocked_query from pg_stat_activity where cardinality(pg_blocking_pids(pid)) > 0;

--to kill
select pg_terminate_backend(139664);
select pg_cancel_backend(139664); (no FOR v14)

SELECT * FROM pg_stat_activity where state ='active' and user not like '%postgres%';

SELECT pg_cancel_backend('24689');

select * from pg_settings where name like '%effective_cache_size%';
select * from pg_settings where name like '%mem%';
SELECT * FROM pg_user;
select * from pg_available_extensions;
SELECT relname, has_table_privilege('rds_superuser',relname,'SELECT') as SELECT,has_table_privilege('rds_superuser',relname,'UPDATE') as UPDATE,has_table_privilege('rds_superuser',relname,'INSERT') as INSERT,has_table_privilege('rds_superuser',relname,'TRUNCATE') as TRUNCATE FROM pg_class c , pg_namespace n where n.oid = c.relnamespace  and n.nspname in ('pg_catalog')  and relkind='r';
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
--NETMAGIC STOP - settlement

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