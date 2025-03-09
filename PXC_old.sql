Install Cluster
--------------------------------
sudo percona-release enable pxc-80

Install Cluster
--------------------------------
yum install percona-xtradb-cluster-full-8.0.22-13.1.el8.x86_64.rpm
or 
yum install percona-xtradb-cluster-shared-8.0.22-13.1.el8.x86_64.rpm --skip-broken

 Problem: conflicting requests
  - nothing provides percona-xtradb-cluster-client = 8.0.22-13.1.el8 needed by percona-xtradb-cluster-full-8.0.22-13.1.el8.x86_64
  - nothing provides percona-xtradb-cluster-debuginfo = 8.0.22-13.1.el8 needed by percona-xtradb-cluster-full-8.0.22-13.1.el8.x86_64
  - nothing provides percona-xtradb-cluster-devel = 8.0.22-13.1.el8 needed by percona-xtradb-cluster-full-8.0.22-13.1.el8.x86_64
  - nothing provides percona-xtradb-cluster-garbd = 8.0.22-13.1.el8 needed by percona-xtradb-cluster-full-8.0.22-13.1.el8.x86_64
  - nothing provides percona-xtradb-cluster-server = 8.0.22-13.1.el8 needed by percona-xtradb-cluster-full-8.0.22-13.1.el8.x86_64
  - nothing provides percona-xtradb-cluster-test = 8.0.22-13.1.el8 needed by percona-xtradb-cluster-full-8.0.22-13.1.el8.x86_64

Install in the order of dependencies
---------------------------
yum install percona-xtradb-cluster-client-8.0.22-13.1.el8.x86_64.rpm -y
yum install percona-xtradb-cluster-debuginfo-8.0.22-13.1.el8.x86_64.rpm -y
yum install percona-xtradb-cluster-devel-8.0.22-13.1.el8.x86_64.rpm -y
yum install percona-xtradb-cluster-garbd-8.0.22-13.1.el8.x86_64.rpm -y
yum install percona-xtradb-cluster-server-debuginfo-8.0.22-13.1.el8.x86_64.rpm -y
yum install percona-xtradb-cluster-test-debuginfo-8.0.22-13.1.el8.x86_64.rpm -y
yum install percona-xtradb-cluster-shared-*  -y
yum install percona-xtradb-cluster-server-8.0.22-13.1.el8.x86_64.rpm -y
yum install percona-xtradb-cluster-test-* -y
yum install percona-xtradb-cluster-full-8.0.22-13.1.el8.x86_64.rpm -y

Xtrabackup 
-----------
yum install percona-xtrabackup-80 -y

LIST
---------------------------
yum list all | grep "percona"
or
rpm -qa |grep -i percona-xtra-*

To Remove
---------------------------
yum remove percona-xtradb-*

START on All 3 Nodes
---------------------------
service mysqld status

service mysqld start
service mysqld status
sudo grep 'temporary password' /var/log/mysqld.log
yZFauXO:z7d#
xw>d0g;IWeP?

mysql -u root -p
ALTER USER 'root'@'localhost' IDENTIFIED BY 'M@PS0luti0ns';

service mysqld stop
service mysqld status

BKP CNF
---------------------------
cp /etc/my.cnf /etc/my.cnf_`date +%Y_%m_%d.%H.%M.%S`

Node 1: 172.123.7.63
------
vi /etc/my.cnf
#####PXC
wsrep_provider=/usr/lib64/galera4/libgalera_smm.so
wsrep_cluster_name=pxc-cluster
wsrep_cluster_address=gcomm://172.123.7.63,172.123.8.160,172.123.9.227
wsrep_node_name=pxc1
wsrep_node_address=172.123.7.63

pxc_strict_mode=ENFORCING

Set up node 2 and node 3 in the same way: Stop the server and update the configuration file applicable to your system. All settings are the same except for wsrep_node_name and wsrep_node_address.

Node 2: 172.123.8.160
------
vi /etc/my.cnf
#####PXC
wsrep_provider=/usr/lib64/galera4/libgalera_smm.so
wsrep_cluster_name=pxc-cluster
wsrep_cluster_address=gcomm://172.123.7.63,172.123.8.160,172.123.9.227
wsrep_node_name=pxc2 
wsrep_node_address=172.123.8.160
pxc_strict_mode=ENFORCING


Node 3: 172.123.9.227
------
vi /etc/my.cnf
#####PXC
wsrep_provider=/usr/lib64/galera4/libgalera_smm.so
wsrep_cluster_name=pxc-cluster
wsrep_cluster_address=gcomm://172.123.7.63,172.123.8.160,172.123.9.227
wsrep_node_name=pxc3
wsrep_node_address=172.123.9.227

pxc_strict_mode=ENFORCING

Sample CNF
----------
cat /etc/my.cnf |egrep -i "wsrep_|pxc_strict"

wsrep_provider=/usr/lib64/galera4/libgalera_smm.so
wsrep_cluster_name=pxc-cluster
wsrep_cluster_address=gcomm://172.123.7.63,172.123.8.160,172.123.9.227
wsrep_node_name=pxc1
1=172.123.7.63
######## wsrep ###############
wsrep_provider=/usr/lib64/galera4/libgalera_smm.so
wsrep_cluster_address=gcomm://
wsrep_slave_threads=8
wsrep_log_conflicts
#wsrep_node_address=192.168.70.63
wsrep_cluster_name=pxc-cluster
#If wsrep_node_name is not specified,  then system hostname will be used
wsrep_node_name=pxc-cluster-node-1
wsrep_sst_method=xtrabackup-v2


SSL optional
---------
>TO turn on

[mysqld]
wsrep_provider_options=”socket.ssl_key=server-key.pem;socket.ssl_cert=server-cert.pem;socket.ssl_ca=ca.pem”

[sst]
encrypt=4
ssl-key=server-key.pem
ssl-ca=ca.pem
ssl-cert=server-cert.pem

>To turn off
pxc_encrypt_cluster_traffic = OFF



Bootstrapping the First Node¶
---------------------------
service mysql@bootstrap.service status 
service mysql@bootstrap.service start 

mysql -u m2p331 -p
show status like 'wsrep%';


Starting the Second Node¶
---------------------------

service mysqld start 

Redirecting to /bin/systemctl status mysql@bootstrap.service
● mysql@bootstrap.service - Percona XtraDB Cluster with config /etc/sysconfig/mysql.bootstrap
   Loaded: loaded (/usr/lib/systemd/system/mysql@.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2021-10-08 11:42:26 UTC; 23s ago
  Process: 26051 ExecStartPost=/usr/bin/mysql-systemd start-post $MAINPID (code=exited, status=0/SUCCESS)
  Process: 26050 ExecStartPost=/bin/sh -c systemctl unset-environment _WSREP_START_POSITION (code=exited, status=0/SUCCESS)
  Process: 25944 ExecStartPre=/bin/sh -c VAR=`bash /usr/bin/mysql-systemd galera-recovery`; [ $? -eq 0 ] && systemctl set-environment _WSREP_STA>
  Process: 25942 ExecStartPre=/bin/sh -c systemctl unset-environment _WSREP_START_POSITION (code=exited, status=0/SUCCESS)
  Process: 25901 ExecStartPre=/usr/bin/mysql-systemd start-pre (code=exited, status=0/SUCCESS)
 Main PID: 25994 (mysqld)
   Status: "Server is operational"
    Tasks: 51 (limit: 23363)
   Memory: 379.1M
   CGroup: /system.slice/system-mysql.slice/mysql@bootstrap.service
           └─25994 /usr/sbin/mysqld --wsrep-new-cluster --wsrep_start_position=c544ac2e-2738-11ec-817d-ea811590f170:4

[mysqld]
wsrep_provider_options=”socket.ssl_key=server-key.pem;socket.ssl_cert=server-cert.pem;socket.ssl_ca=ca.pem”

[sst]
encrypt=4
ssl-key=server-key.pem
ssl-ca=ca.pem
ssl-cert=server-cert.pem



ii) Start MySQL to join the cluster
# systemctl start mysql
# systemctl status mysql

# tail -f /var/log/mysqld.log

On Node 1
-------
[root@ip-172-160-0-177 centos]# mysql -u root -p


Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

show status like 'wsrep%';
+-----------------------------+-----------------------------------+
| Variable_name               | Value                             |
+-----------------------------+-----------------------------------+
| wsrep_cluster_capabilities  |                                   |
| wsrep_cluster_conf_id       | 18446744073709551615              |
| wsrep_cluster_size          | 0                                 |
| wsrep_cluster_state_uuid    |                                   |
| wsrep_cluster_status        | Disconnected                      |
| wsrep_connected             | OFF                               |
| wsrep_local_bf_aborts       | 0                                 |
| wsrep_local_index           | 18446744073709551615              |
| wsrep_provider_capabilities |                                   |
| wsrep_provider_name         | none                              |
| wsrep_provider_vendor       | Codership Oy <info@codership.com> |
| wsrep_provider_version      | 26                                |
| wsrep_ready                 | OFF                               |
| wsrep_thread_count          | 0                                 |
+-----------------------------+-----------------------------------+
14 rows in set (0.01 sec)




iii) Bouncing MySQL database server on first node
The first node was started in bootstrap mode, you can stop it and start the first node in normal mode.

systemctl stop mysql@bootstrap.service
systemctl start mysql
systemctl status mysql

select * from mysql.wsrep_cluster_members;

mysql> select * from mysql.wsrep_cluster_members;
+--------------------------------------+--------------------------------------+-----------+-----------------------+
| node_uuid                            | cluster_uuid                         | node_name | node_incoming_address |
+--------------------------------------+--------------------------------------+-----------+-----------------------+
| 5ae36b87-290d-11ec-8135-b608ef66d627 | c544ac2e-2738-11ec-817d-ea811590f170 | pxc1      | 172.123.7.63    |
| 708548b7-290d-11ec-bd88-57cec01528dc | c544ac2e-2738-11ec-817d-ea811590f170 | pxc2      | 172.123.8.160    |
| fe25991d-290d-11ec-b7f8-5e976bf45d40 | c544ac2e-2738-11ec-817d-ea811590f170 | pxc3      | 172.123.9.227    |
+--------------------------------------+--------------------------------------+-----------+-----------------------+
3 rows in set (0.00 sec)

mysql> SHOW GLOBAL STATUS LIKE 'wsrep_cluster_status';
+----------------------+---------+
| Variable_name        | Value   |
+----------------------+---------+
| wsrep_cluster_status | Primary |
+----------------------+---------+


==================================================================================================================


Load balancing with ProxySQL
------------------------
ProxySQL is a high-performance SQL proxy. ProxySQL runs as a daemon watched by a monitoring process. The process monitors the daemon and restarts it in case of a crash to minimize downtime.

The daemon accepts incoming traffic from MySQL clients and forwards it to backend MySQL servers.

The proxy is designed to run continuously without needing to be restarted. Most configuration can be done at runtime using queries similar to SQL statements in the ProxySQL admin interface. These include runtime parameters, server grouping, and traffic-related settings.

See also

More information about ProxySQL.

ProxySQL v2 natively supports Percona XtraDB Cluster. With this version, proxysql-admin tool does not require any custom scripts to keep track of Percona XtraDB Cluster status.

Important

In version 8.0, Percona XtraDB Cluster does not support ProxySQL v1.

Manual Configuration
This section describes how to configure ProxySQL with three Percona XtraDB Cluster nodes.

Node	Host Name	IP address
Node 1	pxc1	172.123.7.63
Node 2	pxc2	172.123.8.160
Node 3	pxc3	
Node 4	proxysql	172.123.9.227
ProxySQL can be configured either using the /etc/proxysql.cnf file or through the admin interface. Using the admin interface is preferable, because it allows you to change the configuration dynamically without having to restart the proxy.

To connect to the ProxySQL admin interface, you need a mysql client. You can either connect to the admin interface from Percona XtraDB Cluster nodes that already have the mysql client installed (Node 1, Node 2, Node 3) or install the client on Node 4 and connect locally. For this tutorial, install Percona XtraDB Cluster on Node 4:

Changes in the installation procedure

In Percona XtraDB Cluster 8.0, ProxySQL is not installed automatically as a dependency of the percona-xtradb-cluster-client-8.0 package. You should install the proxysql package separately.

On Debian or Ubuntu:

root@proxysql:~# apt-get install percona-xtradb-cluster-client
root@proxysql:~# apt-get install proxysql2
On Red Hat Enterprise Linux or CentOS:

[root@proxysql ~]# yum install Percona-XtraDB-Cluster-client-80
[root@proxysql ~]# yum install proxysql2
To connect to the admin interface, use the credentials, host name and port specified in the global variables.

Warning

Do not use default credentials in production!

The following example shows how to connect to the ProxySQL admin interface with default credentials:

root@proxysql:~# mysql -u admin -padmin -h 127.0.0.1 -P 6032

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.5.30 (ProxySQL Admin Module)

Copyright (c) 2009-2020 Percona LLC and/or its affiliates
Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql@proxysql>
To see the ProxySQL databases and tables use the following commands:

mysql@proxysql> SHOW DATABASES;
+-----+---------+-------------------------------+
| seq | name    | file                          |
+-----+---------+-------------------------------+
| 0   | main    |                               |
| 2   | disk    | /var/lib/proxysql/proxysql.db |
| 3   | stats   |                               |
| 4   | monitor |                               |
+-----+---------+-------------------------------+
4 rows in set (0.00 sec)
mysql@proxysql> SHOW TABLES;
+--------------------------------------+
| tables                               |
+--------------------------------------+
| global_variables                     |
| mysql_collations                     |
| mysql_query_rules                    |
| mysql_replication_hostgroups         |
| mysql_servers                        |
| mysql_users                          |
| runtime_global_variables             |
| runtime_mysql_query_rules            |
| runtime_mysql_replication_hostgroups |
| runtime_mysql_servers                |
| runtime_scheduler                    |
| scheduler                            |
+--------------------------------------+
12 rows in set (0.00 sec)
For more information about admin databases and tables, see Admin Tables

Note

ProxySQL has 3 areas where the configuration can reside:

MEMORY (your current working place)
RUNTIME (the production settings)
DISK (durable configuration, saved inside an SQLITE database)
When you change a parameter, you change it in MEMORY area. That is done by design to allow you to test the changes before pushing to production (RUNTIME), or save them to disk.

Adding cluster nodes to ProxySQL
To configure the backend Percona XtraDB Cluster nodes in ProxySQL, insert corresponding records into the mysql_servers table.

Note

ProxySQL uses the concept of hostgroups to group cluster nodes. This enables you to balance the load in a cluster by routing different types of traffic to different groups. There are many ways you can configure hostgroups (for example source and replicas, read and write load, etc.) and a every node can be a member of multiple hostgroups.

This example adds three Percona XtraDB Cluster nodes to the default hostgroup (0), which receives both write and read traffic:

mysql@proxysql> INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (0,'172.123.7.63',2201);
mysql@proxysql> INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (0,'172.123.8.160',2201);
To see the nodes:

mysql@proxysql> SELECT * FROM mysql_servers;

+--------------+---------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
| hostgroup_id | hostname      | port | status | weight | compression | max_connections | max_replication_lag | use_ssl | max_latency_ms | comment |
+--------------+---------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
| 0            | 172.123.7.63 | 2201 | ONLINE | 1      | 0           | 1000            | 0                   | 0       | 0              |         |
| 0            | 172.123.8.160 | 2201 | ONLINE | 1      | 0           | 1000            | 0                   | 0       | 0              |         |
+--------------+---------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
3 rows in set (0.00 sec)
Creating ProxySQL Monitoring User
To enable monitoring of Percona XtraDB Cluster nodes in ProxySQL, create a user with USAGE privilege on any node in the cluster and configure the user in ProxySQL.

The following example shows how to add a monitoring user on Node 2:

mysql@pxc2> CREATE USER 'proxysql'@'%' IDENTIFIED WITH mysql_native_password by '$3Kr$t';
mysql@pxc2> GRANT USAGE ON *.* TO 'proxysql'@'%';
The following example shows how to configure this user on the ProxySQL node:

mysql@proxysql> UPDATE global_variables SET variable_value='proxysql'
              WHERE variable_name='mysql-monitor_username';
mysql@proxysql> UPDATE global_variables SET variable_value='Open@123'
              WHERE variable_name='mysql-monitor_password';
To load this configuration at runtime, issue a LOAD command. To save these changes to disk (ensuring that they persist after ProxySQL shuts down), issue a SAVE command.

mysql@proxysql> LOAD MYSQL VARIABLES TO RUNTIME;
mysql@proxysql> SAVE MYSQL VARIABLES TO DISK;
To ensure that monitoring is enabled, check the monitoring logs:

mysql@proxysql> SELECT * FROM monitor.mysql_server_connect_log ORDER BY time_start_us DESC LIMIT 6; --paakanum
+---------------+------+------------------+----------------------+---------------+
| hostname      | port | time_start_us    | connect_success_time | connect_error |
+---------------+------+------------------+----------------------+---------------+
| 172.123.7.63 | 2201 | 1469635762434625 | 1695                 | NULL          |
| 172.123.8.160 | 2201 | 1469635762434625 | 1779                 | NULL          |
|  | 2201 | 1469635762434625 | 1627                 | NULL          |
| 172.123.7.63 | 2201 | 1469635642434517 | 1557                 | NULL          |
| 172.123.8.160 | 2201 | 1469635642434517 | 2737                 | NULL          |
|  | 2201 | 1469635642434517 | 1447                 | NULL          |
+---------------+------+------------------+----------------------+---------------+
6 rows in set (0.00 sec)
mysql> SELECT * FROM monitor.mysql_server_ping_log ORDER BY time_start_us DESC LIMIT 6;
+---------------+------+------------------+-------------------+------------+
| hostname      | port | time_start_us    | ping_success_time | ping_error |
+---------------+------+------------------+-------------------+------------+
| 172.123.7.63 | 2201 | 1469635762416190 | 948               | NULL       |
| 172.123.8.160 | 2201 | 1469635762416190 | 803               | NULL       |
|  | 2201 | 1469635762416190 | 711               | NULL       |
| 172.123.7.63 | 2201 | 1469635702416062 | 783               | NULL       |
| 172.123.8.160 | 2201 | 1469635702416062 | 631               | NULL       |
|  | 2201 | 1469635702416062 | 542               | NULL       |
+---------------+------+------------------+-------------------+------------+
6 rows in set (0.00 sec)
The previous examples show that ProxySQL is able to connect and ping the nodes you added.

To enable monitoring of these nodes, load them at runtime:

mysql@proxysql> LOAD MYSQL SERVERS TO RUNTIME;

----------------------------------------------
Creating ProxySQL Client User
ProxySQL must have users that can access backend nodes to manage connections.

To add a user, insert credentials into mysql_users table:

mysql@proxysql> INSERT INTO mysql_users (username,password) VALUES ('sbuser','sbpass');
Query OK, 1 row affected (0.00 sec)
Note

ProxySQL currently doesn’t encrypt passwords.

Load the user into runtime space and save these changes to disk (ensuring that they persist after ProxySQL shuts down):

mysql@proxysql> LOAD MYSQL USERS TO RUNTIME;
mysql@proxysql> SAVE MYSQL USERS TO DISK;
To confirm that the user has been set up correctly, you can try to log in:

root@proxysql:~# mysql -u sbuser -psbpass -h 127.0.0.1 -P 6033

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1491
Server version: 5.5.30 (ProxySQL)

Copyright (c) 2009-2020 Percona LLC and/or its affiliates
Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
To provide read/write access to the cluster for ProxySQL, add this user on one of the Percona XtraDB Cluster nodes:

mysql@pxc3> CREATE USER 'sbuser'@'172.123.9.227' IDENTIFIED BY 'sbpass';
Query OK, 0 rows affected (0.01 sec)

mysql@pxc3> GRANT ALL ON *.* TO 'sbuser'@'172.123.9.227';
Query OK, 0 rows affected (0.00 sec)
Testing Cluster with sysbench
You can install sysbench from Percona software repositories:

For Debian or Ubuntu:

root@proxysql:~# apt-get install sysbench
For Red Hat Enterprise Linux or CentOS

[root@proxysql ~]# yum install sysbench -y
Note

sysbench requires ProxySQL client user credentials that you creted in Creating ProxySQL Client User.

Create the database that will be used for testing on one of the Percona XtraDB Cluster nodes:

mysql@pxc1> CREATE DATABASE sbtest;
Populate the table with data for the benchmark on the ProxySQL node:

root@proxysql:~# sysbench --report-interval=5 --num-threads=4 \
--num-requests=0 --max-time=20 \
--test=/usr/share/doc/sysbench/tests/db/oltp.lua \
--mysql-user='sbuser' --mysql-password='sbpass' \
--oltp-table-size=10000 --mysql-host=127.0.0.1 --mysql-port=6033 \
prepare
Run the benchmark on the ProxySQL node:

root@proxysql:~# sysbench --report-interval=5 --num-threads=4 \
  --num-requests=0 --max-time=20 \
  --test=/usr/share/doc/sysbench/tests/db/oltp.lua \
  --mysql-user='sbuser' --mysql-password='sbpass' \
  --oltp-table-size=10000 --mysql-host=127.0.0.1 --mysql-port=6033 \
  run
ProxySQL stores collected data in the stats schema:

mysql@proxysql> SHOW TABLES FROM stats;
+--------------------------------+
| tables                         |
+--------------------------------+
| stats_mysql_query_rules        |
| stats_mysql_commands_counters  |
| stats_mysql_processlist        |
| stats_mysql_connection_pool    |
| stats_mysql_query_digest       |
| stats_mysql_query_digest_reset |
| stats_mysql_global             |
+--------------------------------+
For example, to see the number of commands that run on the cluster:

mysql@proxysql> SELECT * FROM stats_mysql_commands_counters;
+---------------------------+---------------+-----------+-----------+-----------+---------+---------+----------+----------+-----------+-----------+--------+--------+---------+----------+
| Command                   | Total_Time_us | Total_cnt | cnt_100us | cnt_500us | cnt_1ms | cnt_5ms | cnt_10ms | cnt_50ms | cnt_100ms | cnt_500ms | cnt_1s | cnt_5s | cnt_10s | cnt_INFs |
+---------------------------+---------------+-----------+-----------+-----------+---------+---------+----------+----------+-----------+-----------+--------+--------+---------+----------+
| ALTER_TABLE               | 0             | 0         | 0         | 0         | 0       | 0       | 0        | 0        | 0         | 0         | 0      | 0      | 0       | 0        |
| ANALYZE_TABLE             | 0             | 0         | 0         | 0         | 0       | 0       | 0        | 0        | 0         | 0         | 0      | 0      | 0       | 0        |
| BEGIN                     | 2212625       | 3686      | 55        | 2162      | 899     | 569     | 1        | 0        | 0         | 0         | 0      | 0      | 0       | 0        |
| CHANGE_REPLICATION_SOURCE | 0             | 0         | 0         | 0         | 0       | 0       | 0        | 0        | 0         | 0         | 0      | 0      | 0       | 0        |
| COMMIT                    | 21522591      | 3628      | 0         | 0         | 0       | 1765    | 1590     | 272      | 1         | 0         | 0      | 0      | 0       | 0        |
| CREATE_DATABASE           | 0             | 0         | 0         | 0         | 0       | 0       | 0        | 0        | 0         | 0         | 0      | 0      | 0       | 0        |
| CREATE_INDEX              | 0             | 0         | 0         | 0         | 0       | 0       | 0        | 0        | 0         | 0         | 0      | 0      | 0       | 0        |
...
| DELETE                    | 2904130       | 3670      | 35        | 1546      | 1346    | 723     | 19       | 1        | 0         | 0         | 0      | 0      | 0       | 0        |
| DESCRIBE                  | 0             | 0         | 0         | 0         | 0       | 0       | 0        | 0        | 0         | 0         | 0      | 0      | 0       | 0        |
...
| INSERT                    | 19531649      | 3660      | 39        | 1588      | 1292    | 723     | 12       | 2        | 0         | 1         | 0      | 1      | 2       | 0        |
...
| SELECT                    | 35049794      | 51605     | 501       | 26180     | 16606   | 8241    | 70       | 3        | 4         | 0         | 0      | 0      | 0       | 0        |
| SELECT_FOR_UPDATE         | 0             | 0         | 0         | 0         | 0       | 0       | 0        | 0        | 0         | 0         | 0      | 0      | 0       | 0        |
...
| UPDATE                    | 6402302       | 7367      | 75        | 2503      | 3020    | 1743    | 23       | 3        | 0         | 0         | 0      | 0      | 0       | 0        |
| USE                       | 0             | 0         | 0         | 0         | 0       | 0       | 0        | 0        | 0         | 0         | 0      | 0      | 0       | 0        |
| SHOW                      | 19691         | 2         | 0         | 0         | 0       | 0       | 1        | 1        | 0         | 0         | 0      | 0      | 0       | 0        |
| UNKNOWN                   | 0             | 0         | 0         | 0         | 0       | 0       | 0        | 0        | 0         | 0         | 0      | 0      | 0       | 0        |
+---------------------------+---------------+-----------+-----------+-----------+---------+---------+----------+----------+-----------+-----------+--------+--------+---------+----------+
45 rows in set (0.00 sec)
Automatic failover
ProxySQL will automatically detect if a node is not available or not synced with the cluster.

You can check the status of all available nodes by running:

mysql@proxysql> SELECT hostgroup_id,hostname,port,status FROM mysql_servers;
+--------------+---------------+------+--------+
| hostgroup_id | hostname      | port | status |
+--------------+---------------+------+--------+
| 0            | 172.123.7.63 | 2201 | ONLINE |
| 0            | 172.123.8.160 | 2201 | ONLINE |
+--------------+---------------+------+--------+
3 rows in set (0.00 sec)
To test problem detection and fail-over mechanism, shut down Node 3:

root@pxc3:~# service mysql stop
ProxySQL will detect that the node is down and update its status to OFFLINE_SOFT:

mysql@proxysql> SELECT hostgroup_id,hostname,port,status FROM mysql_servers;
+--------------+---------------+------+--------------+
| hostgroup_id | hostname      | port | status       |
+--------------+---------------+------+--------------+
| 0            | 172.123.7.63 | 2201 | ONLINE       |
| 0            | 172.123.8.160 | 2201 | ONLINE       |
+--------------+---------------+------+--------------+
3 rows in set (0.00 sec)
Now start Node 3 again:

root@pxc3:~# service mysql start
The script will detect the change and mark the node as ONLINE:

mysql@proxysql> SELECT hostgroup_id,hostname,port,status FROM mysql_servers;
+--------------+---------------+------+--------+
| hostgroup_id | hostname      | port | status |
+--------------+---------------+------+--------+
| 0            | 172.123.7.63 | 2201 | ONLINE |
| 0            | 172.123.8.160 | 2201 | ONLINE |
+--------------+---------------+------+--------+
3 rows in set (0.00 sec)
Assisted Maintenance Mode
Usually, to take a node down for maintenance, you need to identify that node, update its status in ProxySQL to OFFLINE_SOFT, wait for ProxySQL to divert traffic from this node, and then initiate the shutdown or perform maintenance tasks. Percona XtraDB Cluster includes a special maintenance mode for nodes that enables you to take a node down without adjusting ProxySQL manually. The mode is controlled using the pxc_maint_mode variable, which is monitored by ProxySQL and can be set to one of the following values:

DISABLED: This is the default state that tells ProxySQL to route traffic to the node as usual.

SHUTDOWN: This state is set automatically when you initiate node shutdown.

You may need to shut down a node when upgrading the OS, adding resources, changing hardware parts, relocating the server, etc.

When you initiate node shutdown, Percona XtraDB Cluster does not send the signal immediately. Intead, it changes the state to pxc_maint_mode=SHUTDOWN and waits for a predefined period (10 seconds by default). When ProxySQL detects that the mode is set to SHUTDOWN, it changes the status of this node to OFFLINE_SOFT, which stops creation of new connections for the node. After the transition period, any long-running transactions that are still active are aborted.

MAINTENANCE: You can change to this state if you need to perform maintenace on a node without shutting it down.

You may need to isolate the node for some time, so that it does not receive traffic from ProxySQL while you resize the buffer pool, truncate the undo log, defragment or check disks, etc.

To do this, manually set pxc_maint_mode=MAINTENANCE. Control is not returned to the user for a predefined period (10 seconds by default). When ProxySQL detects that the mode is set to MAINTENANCE, it stops routing traffic to the node. Once control is returned, you can perform maintenance activity.

Note

Any data changes will still be replicated across the cluster.

After you finish maintenance, set the mode back to DISABLED. When ProxySQL detects this, it starts routing traffic to the node again.

You can increase the transition period using the pxc_maint_transition_period variable to accomodate for long-running transactions. If the period is long enough for all transactions to finish, there should hardly be any disruption in cluster workload.

During the transition period, the node continues to receive existing write-set replication traffic, ProxySQL avoids openning new connections and starting transactions, but the user can still open conenctions to monitor status.

Note

If you increase the transition period, the packaging script may determine it as a server stall.

===========================================================================================================
METHOD 2 


Satya's DBA Blog

September 1, 2021
ProxySQL 2 configuration/installation
ProxySQL Installation/Setup - Percona XtraDB Cluster Part 2

ProxySQL, is an open-source high-performance MySQL/MariaDB proxy server, it serves as an intermediary between MySQL database nodes and the applications.
ProxySQL, a SQL-compatible proxy server, can improve performance by routing traffic among a pool of multiple MySQL/MariaDB/Percona Server database (cluster) nodes and improve availability by automatically failing over to standby if one (or more) of the database node fails.

ProxySQL can be used for
  ✓	Load balancing
  ✓	Query caching
  ✓	Query routing/redirection
  ✓	Query rewriting
  ✓	Database firewall
  ✓	Sharding
  ✓    Data masking
  ✓    Zero-downtime changes

Step I. Installing ProxySQL
Most of the time, ProxySQL is configured on a separate server, and all the connections are routed from the application to the ProxySQL server. ProxySQL in turn directs all the connections to the database server depending on the query rules configured.

ProxySQL 2 is the latest major release of ProxySQL and it is recommended for new installations.

To install ProxySQL on RPM-based distributions, run:
yum list all | grep "proxysql"
yum install proxysql2 -y

yum list all | grep percona
yum install percona-xtradb-cluster-client* -y

cat /etc/proxysql.cnf
proxysql --version

The daemon accepts incoming traffic from MySQL clients and forwards it to backend MySQL servers.
service proxysql start
service proxysql stop
service proxysql status

tail -100f /var/lib/proxysql/proxysql.log

Step II. Setting the ProxySQL Administrator Password
ProxySQL’s internals can be reconfigured using the standard SQL ProxySQL Admin interface, accessible via MySQL command-line utility available by default on port 6032.
Configuration is stored in an SQLite database.

Connect to the ProxySQL administration interface with the default password 'admin'
mysql -u admin -padmin -h 127.0.0.1 -P6032 --prompt='ProxySQLAdmin> '

If you want to change ProxySQL administration password,
ProxySQLAdmin> UPDATE global_variables SET variable_value='admin:password' WHERE variable_name='admin-admin_credentials';
ProxySQLAdmin> LOAD ADMIN VARIABLES TO RUNTIME;     to copy the memory settings to the runtime
ProxySQLAdmin> SAVE ADMIN VARIABLES TO DISK;       save variables to disk to make them persist

Verify that the configuration is empty by checking that there are no entries in the mysql_servers, my_users, mysql_replication_hostgroups and mysql_query_rules tables.
ProxySQLAdmin> SELECT * FROM mysql_servers;
ProxySQLAdmin> SELECT * FROM mysql_users;
ProxySQL has native support for Galera Cluster and Group Replication.
ProxySQLAdmin> SELECT * from mysql_replication_hostgroups;
Query rules are very useful to control traffic passing through ProxySQL and are configured in the mysql_query_rules table.
ProxySQLAdmin> SELECT * from mysql_query_rules;

Step III. Add backend database nodes to the ProxySQL Server Pool
3 Percona XtraDB Cluster (PXC)/MySQL servers will be configured by adding them to the mysql_servers table.
ProxySQLAdmin> INSERT INTO mysql_servers (hostname,hostgroup_id,port,weight) VALUES ('172.123.7.63',10,2201,1000);
ProxySQLAdmin> INSERT INTO mysql_servers (hostname,hostgroup_id,port,weight) VALUES ('172.123.8.160',10,2201,1000);
ProxySQLAdmin> INSERT INTO mysql_servers (hostname,hostgroup_id,port,weight) VALUES ('<NULL>',10,2201,1000);

ProxySQLAdmin> INSERT INTO mysql_galera_hostgroups (writer_hostgroup, backup_writer_hostgroup, reader_hostgroup, offline_hostgroup, active, max_writers, writer_is_also_reader,max_transactions_behind) VALUES (10, 12, 11, 13, 1, 1, 2, 100);
ProxySQLAdmin> LOAD MYSQL SERVERS TO RUNTIME;    Activate current in-memory MySQL server and replication hostgroup configuration
ProxySQLAdmin> SAVE MYSQL SERVERS TO DISK;       Save the current in-memory MySQL server and replication hostgroup configuration to disk

Modifying the config at runtime is done through the ProxySQL Admin port of ProxySQL.
Changes will NOT be activated until they are loaded to RUNTIME and any changes which are NOT saved to DISK will NOT be available after a ProxySQL restart.

ProxySQL considers backend instances with a read_only = 0 as WRITER instances so this should only be set on primary MySQL servers or all primaries in the case of Percona XtraDB Cluster (PXC)/Group (multi-primary) replication. The backend MySQL servers have read_only = 1 configured on all replicas.

ProxySQLAdmin> SELECT hostgroup_id, hostname, status FROM runtime_mysql_servers;

Step IV. MySQL Users
After configuring the MySQL server backends in mysql_servers the next step is to configure mysql users,  add users to specify the username, password and default_hostgroup for basic configuration.
ProxySQLAdmin> INSERT INTO mysql_users (username,password,default_hostgroup) VALUES ('sbuser','sbpass',10);
ProxySQLAdmin> LOAD MYSQL USERS TO RUNTIME;      Activate current in-memory MySQL user configuration
ProxySQLAdmin> SAVE MYSQL USERS TO DISK;         Save the current in-memory MySQL user configuration to disk

ProxySQL Admin (proxysql-admin) is a powerful tool for configuring Percona XtraDB Cluster nodes into ProxySQL. ProxySQL v2 natively supports Percona XtraDB Cluster.
The proxysql-admin tool comes with the ProxySQL package from Percona apt/yum repositories.

Step V. Configure monitoring in MySQL
ProxySQL constantly monitors the MySQL backend nodes configured to identify the health status.
The credentials for monitoring the backend database servers need to be created in MySQL and also configured in ProxySQL along with the environment-specific check intervals.
ProxySQL runs as a daemon watched by a monitoring process, restarts it in case of a crash to minimize downtime.

To create the user in MySQL connect to the PRIMARY and execute:
ProxySQLAdmin> UPDATE global_variables SET variable_value='proxysql' WHERE variable_name in ('mysql-monitor_username','mysql-monitor_password');

To allow ProxySQL access to the MySQL database, we need to create a user on MySQL database with the same credentials mentioned on the ProxySQL server.

On Percona XtraDB Cluster (PXC) nodes, create monitoring user, grant privileges,
mysql> CREATE USER 'proxysql'@'%' IDENTIFIED BY 'Open@123';
mysql> GRANT USAGE ON *.* TO 'proxysql'@'%';
mysql> select user, host, super_priv, password_expired, plugin from mysql.user;

On Percona XtraDB Cluster (PXC) nodes or MySQL cluster servers, create ProxySQL client user
mysql> CREATE DATABASE sbtest;
mysql> CREATE USER 'sbuser'@'172.123.9.227' IDENTIFIED WITH mysql_native_password BY 'sbpass';
mysql> GRANT ALL ON *.* TO 'sbuser'@'172.123.9.227';

Step VI. Configuring Monitoring in ProxySQL
ProxySQLAdmin> UPDATE GLOBAL_VARIABLES SET variable_value='8.0' WHERE variable_name='mysql-server_version';
ProxySQLAdmin> UPDATE global_variables SET variable_value='2000' WHERE variable_name IN ('mysql-monitor_connect_interval','mysql-monitor_ping_interval','mysql-monitor_read_only_interval');
ProxySQLAdmin> UPDATE GLOBAL_VARIABLES SET variable_value='true' WHERE variable_name='admin-web_enabled';

ProxySQLAdmin> SELECT * FROM global_variables WHERE variable_name LIKE 'mysql-monitor_%';

Changes made to the MySQL Monitor in table global_variables will be applied after executing the LOAD MYSQL VARIABLES TO RUNTIME statement.
To persist the configuration changes across restarts the SAVE MYSQL VARIABLES TO DISK must also be executed.
ProxySQLAdmin> LOAD MYSQL VARIABLES TO RUNTIME;  
ProxySQLAdmin> SAVE MYSQL VARIABLES TO DISK;     

Step VII. Backend’s health check
Once the configuration is active verify the status of the MySQL backends in the monitor database tables in ProxySQL Admin:

ProxySQLAdmin> SELECT * FROM monitor.mysql_server_connect_log ORDER BY time_start_us DESC limit 10;
ProxySQLAdmin> SELECT * FROM monitor.mysql_server_ping_log ORDER BY time_start_us DESC limit 10;

ProxySQL is ready to serve traffic on port 6033 (by default), the reverse of MySQL default port 2201.
mysql -usbuser -psbpass -h 127.0.0.1 -P6033 --prompt='ProxySQLClient> '
mysql -usbuser -psbpass -h 127.0.0.1 -P6033 --prompt='ProxySQLClient> ' -e 'select @@hostname,@@port';

If needed, allow ProxySQL service port 6033/tcp in Linux Firewall.
firewall-cmd --permanent --add-port=6033/tcp
firewall-cmd --reload

Step VIII. Functional tests / Testing Cluster with sysbench
Sysbench is a useful tool to verify that ProxySQL is functional and benchmark system performance.

On ProxySQL node:
yum list all | grep sysbench
yum install sysbench -y

On ProxySQL node:
mysql -uproxysql -pOpen@123 -h172.123.7.63 -P2201 -e"SELECT @@hostname,@@port"
mysql -usbuser -psbpass -h172.123.8.160 -P2201 -e"SELECT @@hostname,@@port"

sysbench /usr/share/sysbench/oltp_insert.lua --mysql-db=sbtest --mysql-host=127.0.0.1 --mysql-port=6033 --mysql-user='sbuser' --mysql-password='sbpass' --db-driver=mysql --threads=4 --tables=20 --table-size=15 prepare

sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-db=sbtest --mysql-host=127.0.0.1 --mysql-port=6033 --mysql-user='sbuser' --mysql-password='sbpass' --db-driver=mysql --threads=4 --tables=20 --table-size=15 --time=200 --report-interval=20 run

sysbench /usr/share/sysbench/oltp_point_select.lua --mysql-db=sbtest --mysql-host=127.0.0.1 --mysql-port=6033 --mysql-user='sbuser' --mysql-password='sbpass' --db-driver=mysql --threads=4 --tables=20 --table-size=15 --time=200 --report-interval=20 run

sysbench /usr/share/sysbench/oltp_update_index.lua --mysql-db=sbtest --mysql-host=127.0.0.1 --mysql-port=6033 --mysql-user='sbuser' --mysql-password='sbpass' --db-driver=mysql --threads=4 --tables=20 --table-size=15 --time=200 --report-interval=20 run

Step IX. Verifying the ProxySQL Configuration/Automatic failover
From the command line of one of the MySQL servers, stop the MySQL process to simulate a failure.
systemctl stop mysql

We can check that by querying the runtime_mysql_servers table from the ProxySQL administration prompt.
ProxySQLAdmin> SELECT hostgroup_id, hostname, status FROM runtime_mysql_servers;

The node we stopped is now shunned, which means it’s temporarily deemed inaccessible, so all traffic will be distributed across the two remaining online nodes.

Switch back to the MySQL server and bring the node back up.
systemctl start mysql

Wait a moment, then query the runtime_mysql_servers table from the ProxySQL administration prompt again.
ProxySQLAdmin> SELECT hostgroup_id, hostname, status FROM runtime_mysql_servers;

Step X. Query statistics
ProxySQL collects a lot of real time statistics in the stats schema, each table provides specific information about the behavior of ProxySQL and the workload being processed:

SELECT * FROM stats_mysql_global;
SELECT * FROM stats_mysql_connection_pool order by hostgroup,srv_host ;
SELECT * FROM stats_mysql_processlist;
SELECT * FROM stats_mysql_query_digest;
SELECT * FROM stats_mysql_commands_counters ORDER BY Total_cnt DESC;

SELECT * FROM monitor.mysql_server_connect_log ORDER BY time_start_us DESC LIMIT 6;
SELECT * FROM monitor.mysql_server_ping_log ORDER BY time_start_us DESC LIMIT 6;


ProxySQL is a high performance, high availability, protocol aware proxy for MySQL database clusters and its forks like Percona Server and MariaDB.
ProxySQL supports thousands of concurrent connections.

====

select * from global_variables where variable_name="mysql-connect_timeout_server_max";
select * from global_variables where variable_name="mysql-free_connections_pct";
select * from stats_mysql_connection_pool;
select * from runtime_mysql_servers;

=============================================================================================

TEST /BENCHMARK

After ACS restore
create new table and lock table 
try update from other cluster

locking same object and new connection trying to update the same data

bring down one of hte nodes and try to see if connection keeps going to the other node and marks it as unhealthy in the table

bring up the node and try to see how long does it take to start taking connections

monitor replication

add this to pmm

--------------------------
open 2 mysql client session.


USE sbtest;
desc sbtest1;
+-------+-----------+------+-----+---------+----------------+
| Field | Type      | Null | Key | Default | Extra          |
+-------+-----------+------+-----+---------+----------------+
| id    | int       | NO   | PRI | NULL    | auto_increment |
| k     | int       | NO   | MUL | 0       |                |
| c     | char(120) | NO   |     |         |                |
| pad   | char(60)  | NO   |     |         |                |
+-------+-----------+------+-----+---------+----------------+
4 rows in set (0.00 sec)

>>on session 1:

start transaction;
SELECT * FROM sbtest.sbtest1 WHERE id=1 FOR UPDATE;

... (result here) ...

1 row in set (0.00 sec)

>>on session 2:

start transaction;
SELECT * FROM sbtest.sbtest1 ;
SELECT * FROM sbtest.sbtest1 WHERE id=1 FOR UPDATE;


... (no result yet, will wait for the lock to be released) ...

>>on session 1:
back to session 1, to update selected record (and release the lock):

UPDATE sbtest.sbtest1 SET k='99' WHERE id='1';

commit;

>>back to session 2:

1) either showing lock timeout error

ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
2) or showing result

... (result here) ...

1 row in set (0.00 sec)
3) or showing no result (because corresponding record has been modified, so specified condition was not met)

Empty set (0.00 sec)

==============
Session 1

show session variables LIKE '%commit%';
SET autocommit=0;
show session variables LIKE '%isolation%';
SET session TRANSACTION isolation level READ committed;

Session 2
show session variables LIKE '%commit%';
SET autocommit=0;
show session variables LIKE '%isolation%';
SET session TRANSACTION isolation level READ committed;

Session 1
lock TABLE sbtest.sbtest1 write;
Session 2
UPDATE sbtest.sbtest1 SET k='99' WHERE id='1';