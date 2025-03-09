
Streaming Replication
PostgreSQL’s built-in streaming replication creates a cluster of servers for your database. The primary server is the sole read/write database. It streams updated data (the WAL or “write ahead logs”) out to one or more standby servers, which can operate in read-only mode for scaling database operations, and can be promoted to be the new primary node in the case the original primary node fails or goes offline. (Historically, there were called master and slave nodes, but we have better names now.)

Since streaming replication is low-level data, you must have the same version of PostgreSQL on each node in your cluster. If you want to replicate between versions, you will need “logical replication” instead. More on this later.

Create a primary and as many standby servers as you need. A server node can be anything from bare-metal servers, virtual cloud servers, virtual machines, containers or jails. Ensure they are provisioned with ample CPU cores, RAM, and storage devices for your needs. I’ll name the primary db01 and standby servers db02 through dbNN.

You’ll also need a client computer: your workstation, application server, etc. to access your database.

Install PostgreSQL on each server, including the server, contrib and client packages. They are usually packaged separately. Optional tools I also install include pglogical, pg_repack, and repmgr

Setup Primary (Read/Write) Server
Now, if this is a new installation, we need to create the data directory. Skip this step otherwise as it will destroy your data! Also, some package installers will have already done this for you.

initdb -E UTF-8 /dbdata/pgsql/data/
There are several web site that run a PostgreSQL Configurator page, such as this one or this one. Use it to guide the settings in your postgresql.conf file.



Step 1:  Login TO Postgres
=========================
Run PSQL as user postgres and access the database named postgres:

sudo -u postgres psql postgres

CREATE TABLE guestbook (visitor_email text, vistor_id serial, date timestamp, message text);
INSERT INTO guestbook (visitor_email, date, message) VALUES ( 'jim@gmail.com', current_date, 'This is a test.');
INSERT INTO guestbook (visitor_email, date, message) VALUES ( 'nalinkumar_dba@gmail.com', current_date, 'hot standby');


Step 2: Create a user for REPLICATION wih REPLICATION role
=========================
create user replusr with REPLICATION password 'Repl@123' login;
Repl@123
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

Step 2: Create the archive directory (IN DATADIR)
=========================
mkdir -p /dblog/pgsql/archive
chown -R postgres:postgres /dblog/pgsql/archive


Step 3: Edit Config files - primary
=========================
/*Add and adjust these settings to that file to enable replication*/

--postgresql.conf
vi /var/lib/pgsql/14/data/postgresql.conf

port=5665
wal_level = replica/hot_standby
max_wal_senders = 10
wal_keep_size = '1GB'
wal_compression = ON

archive_mode = on
archive_command = 'test ! -f /dblog/pgsql/archive/%f && cp %p /dblog/pgsql/archive/%f'

#wal_keep_size = '1GB'
#wal_compression = ON

cat  /var/lib/pgsql/14/data/postgresql.conf |grep -i listen_add
cat  /var/lib/pgsql/14/data/postgresql.conf |grep -i data_dir
cat  /var/lib/pgsql/14/data/postgresql.conf |grep -i wal_level
cat  /var/lib/pgsql/14/data/postgresql.conf |grep -i max_wal_
cat  /var/lib/pgsql/14/data/postgresql.conf |grep -i wal_keep_
cat  /var/lib/pgsql/14/data/postgresql.conf |grep -i archive_mode


cat /var/lib/pgsql/14/data/postgresql.conf |egrep -i "wal_level|max_wal_senders|wal_keep_size|wal_compression"

--pg_hba.conf
vi /var/lib/pgsql/14/data/pg_hba.conf	

# Allow replication connections
host     replication     replusr         172.29.7.6/32        md5
--or
host    all          all   192.168.1.1/24     trust
host    replication  replusr  192.168.1.xxx/30   trust


sudo -u postgres psql --port 5665

Step 4: CREATE Slots
=========================

--On PR
select slot_name, slot_type, active, wal_status from pg_replication_slots;
select * from pg_create_physical_replication_slot('pg02_repl_slot');

--On DR

select slot_name, slot_type, active, wal_status from pg_replication_slots;
select * from pg_create_physical_replication_slot('pg01_repl_slot');

--to drop
select pg_drop_replication_slot('pg02_repl_slot');



Step 6: Restart the primary server
=========================
service postgresql-14 restart
service postgresql-14 status

STANDBY
=======

Step 7 : Stop postgres AND clear data 
=========================
service postgresql-14 stop

mv /dbdata01/postgresql  /dbdata01/postgresql_old
OR 
cd /dbdata01/postgresql
rm -rvf * 

chown -R  postgres:postgres postgresql

--OR
initdb -E UTF-8 /dbdata01/postgresql

Step 8: Run the backup utility
=========================
VERSION 14
sudo -u postgres pg_basebackup --pgdata /dbdata01/postgresql/data --format=p --write-recovery-conf --checkpoint=fast --label=mffb --progress --host=172.178.10.240 --port=5665 --username=replusr

OR

sudo -u postgres pg_basebackup -h 174.1.0.6 -D /dbdata01/postgresql/ -U replication -v -P --xlog-method=stream 
pg_basebackup -h 174.1.0.6 -D /dbdata01/postgresql/ -U replication -v -P --xlog-method=stream 
pg_basebackup -h 174.1.0.6 -U replication -D /dbdata01/postgresql/
pg_basebackup -h 174.1.0.6 -U replication --checkpoint=fast \ -D /dbdata01/postgresql/ -R --slot=some_name -C
pg_basebackup -h 174.1.0.6 -U replication -D /dbdata01/postgresql/ --checkpoint=fast -R --slot=some_name -C

cd /dbdata01/postgresql
sudo -u   
pg_basebackup --pgdata /dbdata01/postgresql --format=p --write-recovery-conf --checkpoint=fast --label=mffb --progress --host=174.1.0.6 --port=5665 --username=replusr

Node 3
pg_basebackup -h 174.1.0.6 -U replication -D /dbdata01/postgresql/ --checkpoint=fast -R --slot=some_name2 -C



Step 9: For Switchover
=========================
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
It is likely you don’t want any activity on the primary server (db01) while we set up the replicas.

Install PostgreSQL et al on db02, but do not run “initdb”. In fact, if the postgres/data directory has anything in it from the install, it needs to be moved/removed. The “pg_basebackup” command won’t run unless it looks like there is no data in that directory.

We need to sync the postgres/data directory. The PostgreSQL way is to run pg_basebackup which syncs it over the replication slot. Here is a basic command to run on each standby server, modify for your system.

sudo -u postgres pg_basebackup --pgdata /dbdata/pgsql/data/ --format=p
  --write-recovery-conf --checkpoint=fast --label=mffb --progress
  --host=db01 --port=5665 --username=replusr
When complete, it copies over the complete PGDATA directory from the primary, including configuration files. It also creates a “standby.signal” file in the replica’s PGDATA directory to signal to PostgreSQL this is a standby server. Add the following to the “postgresql.conf” file on the replica, adjusting naming for your server.

# Standby
primary_conninfo = 'user=replusr port=5665 host=172.28.7.4 application_name=172.29.7.6.replusr'
primary_slot_name = 'pg02_repl_slot'
That’s it! Now start the postgres server.

Instead of pg_basebackup, you can copy the files from the primary server to the replicas using things like ZFS snapshots, rsync, etc. Make sure permissions are identical as well afterwards. Manually create the “standby.signal” file in the PGDATA directory and apply the above configuration. That should be good to go!

Try it out
Let’s create user (role), database, table and row in the primary and see it in the standby/replica.

createuser -h db01 -U postgres -d testuser
createdb -h db01 -U testuser testdb
psql -h db01 -U testuser testdb
testdb=# create table test_table (id int);
testdb=# insert into test_table values (1);
testdb=# select * from test_table;
Now let’s connect to our replica and try.

psql -h db02 -U testuser testdb
testdb=# select * from test_table;
You should see the row “1” you created in db01. Since the replica is read-only, we can only select data from it, no creates, inserts, updates, deletes, etc.

psql -h db02 -U testuser testdb
testdb=# insert into test_table values (2);
ERROR:  cannot execute INSERT in a read-only transaction
DNS and Failover
As an application or user, how do we know which is the current primary or replica servers? Things change. Things break. I use a DNS CNAME to point to the correct server. Let’s name our new cluster “dbc1” which uses db01 as primary and db02 as the standby/replica. We need to identify the cluster primary (p) and standby (s) servers.

dbc1p --> db01
dbc1s --> db02
At this point, assume something happens to db01 and it goes offline. We need to “promote” the replica to become the new primary with read-write ability. Log into db02, then as the postgres user, run

/usr/pgsql-14/bin/pg_ctl promote -D /dbdata/pgsql/data/

An easier alternative can be done from a postgres superuser (postgres) psql session


psql -h db02 -U postgres template1
testdb=# select pg_promote();
Now, we need to switch “dbc1p” to point to “db02” as well. Applications can continue/retry to run pointing to the dbc1p to perform writes. At this point you may need to build another replica or restore the primary server database.

There are more formal methods to manage replication and failover of your PostgreSQL clusters. Check out repmgr for one such solution.

High Availability
High Availability is outside the scope of this article, as it is a large field and everything “depends” on your own needs. However there are a couple options for you to explore

PgPool - In load balancing mode, the connection pooler can send read operation (selects) to multiple standby/replicas and write operations to the primary server. This allows you to leverage your standby servers to serve read requests and offload work from the primary. It monitors “replication lag” and not send requests to standby servers if the lag to too long, preventing your users from seeing data that is too out of date.

Odyssey is a newer connection pool offering modern scalability features and configuration. I have not had an opportunity to explore it yet.

HAProxy - Set up a pair of PGProxy load balancers between your applications and your cluster nodes.

Logical Replication
PostgreSQL has many different replication solutions and models. Replication is not a “one size fits all” solution. A common alternative to streaming replication is “Logical Replication”, which transmits data updates as SQL statements instead of the low-level WAL that streaming replication uses.

Logical Replication is ideal for migrating data between major version of PostgreSQL, which would require downtime to reload the data or execute a “pg_upgrade” process. Data pages change between major versions and can’t be mixed without doing this. When PG15 comes out, we can create a new DB cluster running PG15, then side-load the data to it using logical replication. Once caught up, you can switch over to the new cluster.

Another use for Logical Replication is Multi-Master (Primary?) mode. Multi-Master comes with it’s own set of conditions and methods for reliable usage, but could be the solution you may need.

pglogical is a PostgreSQL extension to provide logical replication.

© 2021 Allen Fair. All rights reserved.

=============================
--REPLICATION LAG
----------------
SELECT abs(pg_xlog_location_diff(pg_last_xlog_receive_location(),
pg_last_xlog_replay_location())) AS replication_delay_bytes;

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