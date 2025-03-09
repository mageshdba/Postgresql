
--REPLICATION STATUS CHECK
-------------------------

//On master:
select * from pg_stat_replication;

//On Standby
select * from pg_stat_wal_receiver;


// [Tuesday 15:05] Sharath Sankar
select pg_is_in_recovery(),pg_is_wal_replay_paused(), pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn(), pg_last_xact_replay_timestamp();

// [Tuesday 15:06] Mohan Rao NK
select now()-pg_last_xact_replay_timestamp() as replication_lag;

SELECT pg_last_xlog_receive_location() AS receive_location, pg_last_xlog_replay_location() AS replay_location, pg_xlog_location_dif (pg_last_xlog_receive_location(), pg_last_xlog_replay_location()) AS replication_lag;

SELECT abs(pg_xlog_location_diff(pg_last_xlog_receive_location(),pg_last_xlog_replay_location())) AS replication_delay_bytes;


// I use following SQL queries to check status on Postgres v11 usually.


CREATE OR REPLACE FUNCTION public.pg_current_xlog_location() RETURNS pg_lsn AS $$
SELECT pg_current_wal_lsn();
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION public.pg_last_xlog_receive_location() RETURNS pg_lsn AS $$
SELECT pg_last_wal_receive_lsn();
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION public.pg_last_xlog_replay_location()
RETURNS pg_lsn AS
$BODY$
SELECT pg_last_wal_replay_lsn();
$BODY$
LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION pg_xlog_location_diff(pg_lsn,pg_lsn)
RETURNS NUMERIC AS
$BODY$
SELECT pg_wal_lsn_diff($1, $2);
$BODY$
LANGUAGE SQL STABLE;




========================================



Step 9: For Switchover
-----------------------------
-- Create a recovery conf on Old Primary server on the data directory path
hot_standby = on
standby_mode = 'on'
primary_conninfo = 'user=replusr port=5665 host=174.1.0.7 application_name=174.1.0.6.replusr'
primary_slot_name = 'pg01_repl_slot'
recovery_target_timeline = 'latest'

--(Optional) Recovery File
vi /dbdata01/postgresql/recovery.conf
standby_mode = 'on'
primary_conninfo = 'host=174.1.0.7 port=5665 user=replusr password=Repl@123'
trigger_file= '/var/lib/pgsql/trigger_file'

--(Optional) Trigger File
trigger_file = '/tmp/postgresql.trigger.5665'
The trigger_file path that you specify is the location where you can add a file when you want the system to fail over to the standby server. The presence of the file "triggers" the failover. Alternatively, you can use the pg_ctl promote command to trigger failover.


primary_conninfo = 'user=replusr port=5665 host=172.28.7.4 application_name=172.29.7.6.replusr'
primary_slot_name = 'pg02_repl_slot'


Setup Standby/Replica Servers
It is likely you dont want any activity on the primary server (db01) while we set up the replicas.

Install PostgreSQL et al on db02, but do not run "initdb". In fact, if the postgres/data directory has anything in it from the install, it needs to be moved/removed. The "pg_basebackup" command wont run unless it looks like there is no data in that directory.

We need to sync the postgres/data directory. The PostgreSQL way is to run pg_basebackup which syncs it over the replication slot. Here is a basic command to run on each standby server, modify for your system.

sudo -u postgres pg_basebackup --pgdata /dbdata/pgsql/data/ --format=p
  --write-recovery-conf --checkpoint=fast --label=mffb --progress
  --host=db01 --port=5665 --username=replusr
When complete, it copies over the complete PGDATA directory from the primary, including configuration files. It also creates a "standby.signal" file in the replicas PGDATA directory to signal to PostgreSQL this is a standby server. Add the following to the "postgresql.conf" file on the replica, adjusting naming for your server.

# Standby
primary_conninfo = 'user=replusr port=5665 host=172.28.7.4 application_name=172.29.7.6.replusr'
primary_slot_name = 'pg02_repl_slot'
Thats it! Now start the postgres server.

Instead of pg_basebackup, you can copy the files from the primary server to the replicas using things like ZFS snapshots, rsync, etc. Make sure permissions are identical as well afterwards. Manually create the "standby.signal" file in the PGDATA directory and apply the above configuration. That should be good to go!

Try it out
Lets create user (role), database, table and row in the primary and see it in the standby/replica.

createuser -h db01 -U postgres -d testuser
createdb -h db01 -U testuser testdb
psql -h db01 -U testuser testdb
testdb=# create table test_table (id int);
testdb=# insert into test_table values (1);
testdb=# select * from test_table;
Now lets connect to our replica and try.

psql -h db02 -U testuser testdb
testdb=# select * from test_table;
You should see the row "1" you created in db01. Since the replica is read-only, we can only select data from it, no creates, inserts, updates, deletes, etc.

psql -h db02 -U testuser testdb
testdb=# insert into test_table values (2);
ERROR:  cannot execute INSERT in a read-only transaction
DNS and Failover
As an application or user, how do we know which is the current primary or replica servers? Things change. Things break. I use a DNS CNAME to point to the correct server. Lets name our new cluster "dbc1" which uses db01 as primary and db02 as the standby/replica. We need to identify the cluster primary (p) and standby (s) servers.

dbc1p --> db01
dbc1s --> db02
At this point, assume something happens to db01 and it goes offline. We need to "promote" the replica to become the new primary with read-write ability. Log into db02, then as the postgres user, run

/usr/pgsql-14/bin/pg_ctl promote -D /dbdata/pgsql/data/

An easier alternative can be done from a postgres superuser (postgres) psql session


psql -h db02 -U postgres template1
testdb=# select pg_promote();
Now, we need to switch "dbc1p" to point to "db02" as well. Applications can continue/retry to run pointing to the dbc1p to perform writes. At this point you may need to build another replica or restore the primary server database.

There are more formal methods to manage replication and failover of your PostgreSQL clusters. Check out repmgr for one such solution.

High Availability
High Availability is outside the scope of this article, as it is a large field and everything "depends" on your own needs. However there are a couple options for you to explore

PgPool - In load balancing mode, the connection pooler can send read operation (selects) to multiple standby/replicas and write operations to the primary server. This allows you to leverage your standby servers to serve read requests and offload work from the primary. It monitors "replication lag" and not send requests to standby servers if the lag to too long, preventing your users from seeing data that is too out of date.

Odyssey is a newer connection pool offering modern scalability features and configuration. I have not had an opportunity to explore it yet.

HAProxy - Set up a pair of PGProxy load balancers between your applications and your cluster nodes.

Logical Replication
PostgreSQL has many different replication solutions and models. Replication is not a "one size fits all" solution. A common alternative to streaming replication is "Logical Replication", which transmits data updates as SQL statements instead of the low-level WAL that streaming replication uses.

Logical Replication is ideal for migrating data between major version of PostgreSQL, which would require downtime to reload the data or execute a "pg_upgrade" process. Data pages change between major versions and cant be mixed without doing this. When PG15 comes out, we can create a new DB cluster running PG15, then side-load the data to it using logical replication. Once caught up, you can switch over to the new cluster.

Another use for Logical Replication is Multi-Master (Primary?) mode. Multi-Master comes with its own set of conditions and methods for reliable usage, but could be the solution you may need.

pglogical is a PostgreSQL extension to provide logical replication.

© 2021 Allen Fair. All rights reserved.

=========================================================================================================================================



CREATE TABLE guestbook (visitor_email text, vistor_id serial, date timestamp, message text);
INSERT INTO guestbook (visitor_email, date, message) VALUES ( 'jim@gmail.com', current_date, 'This is a test.');
INSERT INTO guestbook (visitor_email, date, message) VALUES ( 'nalinkumar_dba@gmail.com', current_date, 'hot standby');
