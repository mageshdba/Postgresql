 
Step - 6 - Basic Testing Phase - 1 with Percona XtraDB Cluster

To test replication, lets
create a new database on second node,
create a table for that database on the third node, and add some records to the table on the first node.

(i)	Create a new database on the second node

mysql> system hostname percona-xtradb-2

mysql> show databases;
+	+
| Database	|
+	+
| information_schema |
| mysql	|
| performance_schema |
| sys	|
+	+
4	rows in set (0.01 sec)

mysql> CREATE DATABASE cluster_testing; Query OK, 1 row affected (0.01 sec)

mysql> show databases;
+	+
| Database	|
+	+
| cluster_testing	|
| information_schema |
| mysql	|
| performance_schema |
| sys	|
+	+
5	rows in set (0.00 sec)

(ii)	Create a table on the third node

mysql> system hostname percona-xtradb-3

mysql> USE cluster_testing;
Database changed

mysql> select database();
+	+
| database()	|
+	+
| cluster_testing |
+	+
1 row in set (0.00 sec)

mysql> CREATE TABLE verifying (node_id INT PRIMARY KEY, node_name VARCHAR(30)); Query OK, 0 rows affected (0.03 sec)
 
mysql> show tables;
+	+
| Tables_in_cluster_testing |
+	+
| verifying	|
+	+
1 row in set (0.00 sec)

mysql> show databases;
+	+
| Database	|
+	+
| cluster_testing	|
| information_schema |
| mysql	|
| performance_schema |
| sys	|
+	+
5 rows in set (0.00 sec)

(iii)	Insert records on the first node

mysql> system hostname percona-xtradb-1

mysql> INSERT INTO cluster_testing.verifying VALUES (1, 'server1'); Query OK, 1 row affected (0.01 sec)
(iv)	Retrieve all the rows from that table on the second node mysql> system hostname
percona-xtradb-2

mysql> SELECT * FROM cluster_testing.verifying;
+	+	+
| node_id | node_name |
+	+	+
|	1 | server1	|
+	+	+
1 row in set (0.00 sec)

mysql> show databases;
+	+
| Database	|
+	+
| cluster_testing	|
| information_schema |
| mysql	|
| performance_schema |
| sys	|
+	+
5	rows in set (0.00 sec)

This simple procedure should ensure that all nodes in the cluster are synchronized and working as intended.
 
Parameters Explannation :-
https://www.percona.com/doc/percona-xtradb-cluster/5.7/wsrep-status-index.html


Some Important information :-

What if the Nodes Have Diverged?

In certain circumstances, nodes can have diverged from each other. The state of all nodes might turn into Non-Primary due to network split between nodes, cluster crash, or if Galera hit an exception when determining the Primary Component. You will then need to select a node and promote it to be a Primary Component.

To determine which node needs to be bootstrapped, compare the wsrep_last_committed value on all DB nodes:

node1> SHOW STATUS LIKE 'wsrep_%';
+	+	+
| Variable_name	| Value	|
+	+	+
| wsrep_last_committed | 17	|
...
| wsrep_cluster_status | Primary	|
+	+	+

node2> SHOW STATUS LIKE 'wsrep_%';
+	+	+
| Variable_name	| Value	|
+	+	+
| wsrep_last_committed | 14	|
...
| wsrep_cluster_status | Primary	|
+	+	+

node3> SHOW STATUS LIKE 'wsrep_%';
+	+	+
| Variable_name	| Value	|
+	+	+
| wsrep_last_committed |	17	|
...
| wsrep_cluster_status | Primary	|
+	+	+

From above outputs, node1 and node3 has the most up-to-date data. In this case, all Galera nodes are already started, so you don’t necessarily need to bootstrap the cluster again. We just need to promote node1 to be a Primary Component:

node1> SET GLOBAL wsrep_provider_options="pc.bootstrap=1";

The remaining nodes will then reconnect to the Primary Component (node1) and resync their data based on this node.
 
 
Step - 7 Testing Phase - 2 [ --> shutdown mysql service in node 1
--> and creating the database in node 2
--> Start the mysql service in Node 1
--> Checking the created database in all 3 Nodes ]

Out of 3 Nodes , i am going to
--> shutdown mysql service in node 1
--> And creating the database in node 2
--> Start the mysql service in Node 1
--> Checking the created database in all 3 Nodes. Node 1 :-
[root@percona-xtradb-1 ~]# service mysql stop Redirecting to /bin/systemctl stop mysql.service
[root@percona-xtradb-1 ~]# systemctl stop mysql@bootstrap.service [root@percona-xtradb-1 ~]# ps -ef | grep -i mysql
root	4313	4231 0 04:42 pts/0	00:00:00 grep --color=auto -i mysql

Node 2 :-
[root@percona-xtradb-2 ~]# mysql -u root -p Enter password:

mysql> system hostname percona-xtradb-2

mysql> show databases;
+	+
| Database	|
+	+
| cluster_testing	|
| failover	|
| information_schema |
| mysql	|
| performance_schema |
| sys	|
+	+
6	rows in set (0.00 sec)

mysql> create database failover_2; Query OK, 1 row affected (0.01 sec)

mysql> exit Node 3 :-
mysql> system hostname percona-xtradb-3

mysql> show databases;
+	+
| Database	|
+	+
| cluster_testing	|
 
| failover	|
| information_schema |
| mysql	|
| performance_schema |
| sys	|
+	+
6 rows in set (0.00 sec)

mysql> exit Bye

Now we can check in Node 1 , start the service in Node 1 and run "SHOW DATABASES;"

[root@percona-xtradb-1 ~]# service mysql start Redirecting to /bin/systemctl start mysql.service

[root@percona-xtradb-1 ~]# ps -ef | grep -i mysql
mysql	4497	1 14 04:45 ?	00:00:04 /usr/sbin/mysqld -- wsrep_start_position=29ff2ba6-01db-11ec-8a50-7a82b8ebba59:20
root	5073	4231 0 04:46 pts/0	00:00:00 grep --color=auto -i mysql

[root@percona-xtradb-1 ~]# mysql -u root -p Enter password:

mysql> system hostname percona-xtradb-1

mysql> show databases;
+	+
| Database	|
+	+
| cluster_testing	|
| failover	|
| information_schema |
| mysql	|
| performance_schema |
| sys	|
+	+
6 rows in set (0.01 sec)

mysql> exit Bye

So , Percona XtraDB cluster is working fine..

Step - 8 Testing Phase - 3 [ --> First shutdown the mysql service in Node 1
--> Create the new database in Node 2
--> Stop the Node 3 mysql service
--> Stop the Node 2 mysql service
--> Start the mysql service with bootsrap command in Node 2
--> Start the mysql service by simple command in Node 3
--> Start the mysql service by simple command in Node 1 ]

Now out of all Nodes,
--> First shutdown the mysql service in Node 1
--> Create the new database in Node 2
 
--> Stop the Node 3 mysql service
--> Stop the Node 2 mysql service
--> Start the mysql service with bootsrap command in Node 2
--> Start the mysql service by simple command in Node 3
--> Start the mysql service by simple command in Node 1 In Node - 1 :-
[root@percona-xtradb-1 ~]# service mysql stop Redirecting to /bin/systemctl stop mysql.service
[root@percona-xtradb-1 ~]# systemctl stop mysql@bootstrap.service [root@percona-xtradb-1 ~]# mysql -u root -p
Enter password:
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/lib/mysql/mysql.sock' (2)

In Node - 2:-
[root@percona-xtradb-2 ~]# mysql -u root -p Enter password:
mysql> show databases;
+	+
| Database	|
+	+
| cluster_testing	|
| failover	|
| information_schema |
| mysql	|
| performance_schema |
| sys	|
+	+
6	rows in set (0.00 sec)

mysql> system hostname percona-xtradb-2

mysql> create database failover_2; Query OK, 1 row affected (0.01 sec)

mysql> exit Bye

In Node - 3 :-
[root@percona-xtradb-3 ~]# service mysql stop Redirecting to /bin/systemctl stop mysql.service [root@percona-xtradb-3 ~]#

In Node - 2 :-

[root@percona-xtradb-2 ~]# service mysql stop Redirecting to /bin/systemctl stop mysql.service [root@percona-xtradb-2 ~]#

Note :- Here all 3 Nodes are down. So we will get confuse in which node will run boot strap command .
 
To avoid this confusion , first we should get seqno from below path in all 3 servers.

[root@percona-xtradb-1 ~]# cat /var/lib/mysql/grastate.dat	=========> Node 1 # GALERA saved state
version: 2.1
uuid:	29ff2ba6-01db-11ec-8a50-7a82b8ebba59 seqno:	23
safe_to_bootstrap: 0

[root@percona-xtradb-2 ~]# cat /var/lib/mysql/grastate.dat	=========> Node 2 # GALERA saved state
version: 2.1
uuid:	29ff2ba6-01db-11ec-8a50-7a82b8ebba59 seqno:	26
safe_to_bootstrap: 1

[root@percona-xtradb-3 ~]# cat /var/lib/mysql/grastate.dat	=========> Node 3 # GALERA saved state
version: 2.1
uuid:	29ff2ba6-01db-11ec-8a50-7a82b8ebba59 seqno:	25
safe_to_bootstrap: 0

So , based on above information , we should consider which is higher value for " seqno " Now based on above output, consider Node 2 is high " seqno " , and run the bootstrap command in Node 2.

In Node - 2 :- Start the mysql service with bootsrap command

[root@percona-xtradb-2 ~]# systemctl start mysql@bootstrap.service [root@percona-xtradb-2 ~]# ps -ef | grep -i mysql
root	5199	5169 0 04:02 pts/0	00:00:00 mysql -u root -p
mysql	5582	1 30 04:52 ?	00:00:02 /usr/sbin/mysqld --wsrep-new-cluster
--wsrep_start_position=29ff2ba6-01db-11ec-8a50-7a82b8ebba59:26
root	5669	5356 0 04:52 pts/1	00:00:00 grep --color=auto -i mysql In Node - 3 :- Start the mysql service by simple command

[root@percona-xtradb-3 ~]# service mysql start Redirecting to /bin/systemctl start mysql.service [root@percona-xtradb-3 ~]#

In Node - 1 :-  Start the mysql service by simple command

[root@percona-xtradb-1 ~]# service mysql start Redirecting to /bin/systemctl start mysql.service [root@percona-xtradb-1 ~]#
So now all 3 Nodes are up and running..Remember mysql bootstrap service now in node 2... Now check Created Database is populating in all 3 Nodes or not :-

Here we have to check failover_2 database name in all 3 nodes.
 
[root@percona-xtradb-1 ~]# mysql -u root -p	==========> Node 1 Enter password:

mysql> system hostname percona-xtradb-1

mysql> show databases;
+	+
| Database	|
+	+
| cluster_testing	|
| failover	|
| failover_2	|
| information_schema |
| mysql	|
| performance_schema |
| sys	|
+	+
7	rows in set (0.01 sec)

mysql> SHOW GLOBAL STATUS LIKE 'wsrep_last_committed';
+	+	+
| Variable_name	| Value |
+	+	+
| wsrep_last_committed | 29	|
+	+	+
1 row in set (0.00 sec)


[root@percona-xtradb-2 ~]# mysql -u root -p	==========> Node 2 Enter password:

mysql> system hostname percona-xtradb-2

mysql> show databases;
+	+
| Database	|
+	+
| cluster_testing	|
| failover	|
| failover_2	|
| information_schema |
| mysql	|
| performance_schema |
| sys	|
+	+
7 rows in set (0.00 sec)

mysql> SHOW GLOBAL STATUS LIKE 'wsrep_last_committed';
+	+	+
| Variable_name	| Value |
+	+	+
| wsrep_last_committed | 29	|
+	+	+
1 row in set (0.00 sec)


[root@percona-xtradb-3 ~]# mysql -u root -p	==========> Node 3
 
Enter password:

mysql> system hostname; percona-xtradb-3

mysql> show databases;
+	+
| Database	|
+	+
| cluster_testing	|
| failover	|
| failover_2	|
| information_schema |
| mysql	|
| performance_schema |
| sys	|
+	+
7 rows in set (0.00 sec)

mysql> SHOW GLOBAL STATUS LIKE 'wsrep_last_committed';
+	+	+
| Variable_name	| Value |
+	+	+
| wsrep_last_committed | 29	|
+	+	+
1 row in set (0.00 sec)

Step - 9 Testing Phase - 4 [ --> Kill the mysql process in Node 2
--> Create the new database , table , insert some data in Node 1
--> Verify the new database , new table and data in Node 3
--> Start the Node 2 mysql service
--> Verify the new database ,new table and data in Node 2
--> Verify all nodes of /var/lib/mysql/grastate.dat ]
 	-

[root@percona-xtradb-1 ~]# ps -ef | grep -i mysql
mysql	5280	1 0 04:53 ?	00:00:12 /usr/sbin/mysqld -- wsrep_start_position=29ff2ba6-01db-11ec-8a50-7a82b8ebba59:23
root	6088	4231 0 05:52 pts/0	00:00:00 grep --color=auto -i mysql [root@percona-xtradb-1 ~]#


[root@percona-xtradb-2 ~]# ps -ef | grep -i mysql
root	5199	5169 0 04:02 pts/0	00:00:00 mysql -u root -p
mysql	5582	1 0 04:52 ?	00:00:10 /usr/sbin/mysqld --wsrep-new-cluster
--wsrep_start_position=29ff2ba6-01db-11ec-8a50-7a82b8ebba59:26
root	6197	5356 0 05:53 pts/1	00:00:00 grep --color=auto -i mysql [root@percona-xtradb-2 ~]#

[root@percona-xtradb-3 ~]# ps -ef | grep -i mysql
root	4534	4496 0 04:02 pts/0	00:00:00 mysql -u root -p
mysql	5261	1 0 04:52 ?	00:00:10 /usr/sbin/mysqld -- wsrep_start_position=29ff2ba6-01db-11ec-8a50-7a82b8ebba59:25
root	6490	4631 0 05:53 pts/1	00:00:00 grep --color=auto -i mysql [root@percona-xtradb-3 ~]#
 
Kill the mysql DB process in Node - 2 from OS level.. [root@percona-xtradb-2 ~]# kill -9 5582
[root@percona-xtradb-2 ~]# ps -ef | grep -i mysql
root	5199	5169 0 04:02 pts/0	00:00:00 mysql -u root -p
root	6239	5356 0 05:55 pts/1	00:00:00 grep --color=auto -i mysql [root@percona-xtradb-2 ~]#

Now Node 1 and Node 3 are up and running ....
Create new DB , Table and insert some data in Node 1 :- mysql> system hostname;
percona-xtradb-1

mysql> show databases;
+	+
| Database	|
+	+
| cluster_testing	|
| failover	|
| failover_2	|
| information_schema |
| mysql	|
| performance_schema |
| sys	|
+	+
7 rows in set (0.00 sec)

mysql> CREATE DATABASE killed_process; Query OK, 1 row affected (0.01 sec)

mysql> use killed_process;
Database changed

mysql> CREATE TABLE killed_pro (node_id INT PRIMARY KEY, node_name VARCHAR(30)); Query OK, 0 rows affected (0.07 sec)

mysql> show tables;
+	+
| Tables_in_killed_process |
+	+
| killed_pro	|
+	+
1 row in set (0.00 sec)

mysql> INSERT INTO killed_process.killed_pro VALUES (1, 'server1'); Query OK, 1 row affected (0.02 sec)

mysql> select * from killed_process.killed_pro;
+	+	+
| node_id | node_name |
+	+	+
|	1 | server1	|
+	+	+
1 row in set (0.00 sec)

Now verify the Database , Table and Data  in node 3 :-
 
 

mysql> system hostname percona-xtradb-3

mysql> show databases;
+	+
| Database	|
+	+
| cluster_testing	|
| failover	|
| failover_2	|
| information_schema |
| killed_process	|
| mysql	|
| performance_schema |
| sys	|
+	+
8 rows in set (0.01 sec)

mysql> use killed_process;
Database changed

mysql> show tables;
+	+
| Tables_in_killed_process |
+	+
| killed_pro	|
+	+
1 row in set (0.00 sec)

mysql> select * from killed_pro;
+	+	+
| node_id | node_name |
+	+	+
|	1 | server1	|
+	+	+
1 row in set (0.00 sec)


Now start the mysql service in Node - 2 :-

Node - 1
[root@percona-xtradb-1 ~]# cat /var/lib/mysql/grastate.dat # GALERA saved state
version: 2.1
uuid:	29ff2ba6-01db-11ec-8a50-7a82b8ebba59 seqno:	-1
safe_to_bootstrap: 0 [root@percona-xtradb-1 ~]#

Node - 2
[root@percona-xtradb-2 ~]# cat /var/lib/mysql/grastate.dat # GALERA saved state
version: 2.1
uuid:	29ff2ba6-01db-11ec-8a50-7a82b8ebba59
 
seqno:	29
safe_to_bootstrap: 0 [root@percona-xtradb-2 ~]#

Node - 3
[root@percona-xtradb-3 ~]# cat /var/lib/mysql/grastate.dat # GALERA saved state
version: 2.1
uuid:	29ff2ba6-01db-11ec-8a50-7a82b8ebba59 seqno:	-1
safe_to_bootstrap: 0 [root@percona-xtradb-3 ~]#

Now start the Node - 2 Service by using " service mysql start "

[root@percona-xtradb-2 ~]# service mysql start Redirecting to /bin/systemctl start mysql.service

[root@percona-xtradb-2 ~]# mysql -u root -p Enter password:

mysql> system hostname ; percona-xtradb-2

mysql> show databases;
+	+
| Database	|
+	+
| cluster_testing	|
| failover	|
| failover_2	|
| information_schema |
| killed_process	|
| mysql	|
| performance_schema |
| sys	|
+	+
8 rows in set (0.00 sec)

mysql> select * from killed_process.killed_pro;
+	+	+
| node_id | node_name |
+	+	+
|	1 | server1	|
+	+	+
1	row in set (0.00 sec)

So , newely created database , table and data is presented in Node - 2 which we killed the process in OS level.

Now verifying the seqno in all 3 nodes from the below file.

[root@percona-xtradb-1 ~]# cat /var/lib/mysql/grastate.dat # GALERA saved state
version: 2.1
uuid:	29ff2ba6-01db-11ec-8a50-7a82b8ebba59
 
seqno:	-1
safe_to_bootstrap: 0 [root@percona-xtradb-1 ~]#

[root@percona-xtradb-2 ~]# cat /var/lib/mysql/grastate.dat # GALERA saved state
version: 2.1
uuid:	29ff2ba6-01db-11ec-8a50-7a82b8ebba59 seqno:	-1
safe_to_bootstrap: 0 [root@percona-xtradb-2 ~]#

[root@percona-xtradb-3 ~]# cat /var/lib/mysql/grastate.dat # GALERA saved state
version: 2.1
uuid:	29ff2ba6-01db-11ec-8a50-7a82b8ebba59 seqno:	-1
safe_to_bootstrap: 0 [root@percona-xtradb-3 ~]#

So working fine ....

You check if we have any lagging in Cluster by using below command :-

mysql> system hostname percona-xtradb-1
mysql> SELECT * FROM performance_schema.global_status WHERE VARIABLE_NAME LIKE 'wsrep_flow_control_sent' OR VARIABLE_NAME LIKE 'wsrep_local_recv_queue_avg';
+	+	+
| VARIABLE_NAME	| VARIABLE_VALUE |
+	+	+
| wsrep_local_recv_queue_avg | 0	|
| wsrep_flow_control_sent	| 0	|
+	+	+
2	rows in set (0.00 sec)


mysql> system hostname percona-xtradb-2
mysql> SELECT * FROM performance_schema.global_status WHERE VARIABLE_NAME LIKE 'wsrep_flow_control_sent' OR VARIABLE_NAME LIKE 'wsrep_local_recv_queue_avg';
+	+	+
| VARIABLE_NAME	| VARIABLE_VALUE |
+	+	+
| wsrep_local_recv_queue_avg | 0	|
| wsrep_flow_control_sent	| 0	|
+	+	+
2 rows in set (0.00 sec)


mysql> system hostname percona-xtradb-3
mysql> SELECT * FROM performance_schema.global_status WHERE VARIABLE_NAME LIKE 'wsrep_flow_control_sent' OR VARIABLE_NAME LIKE 'wsrep_local_recv_queue_avg'
+	+	+
| VARIABLE_NAME	| VARIABLE_VALUE |
+	+	+
| wsrep_local_recv_queue_avg | 0	|
 
| wsrep_flow_control_sent	| 0	|
+	+	+
2 rows in set (0.00 sec) So all are in sync... if we have like this ,
+	+	+
| VARIABLE_NAME	| VARIABLE_VALUE |
+	+	+
| WSREP_LOCAL_RECV_QUEUE_AVG | 2.2	|
| WSREP_FLOW_CONTROL_SENT	| 5	|
+	+	+

If you have such values means it is slow ..It will display with seconds...


Step - 10 Start / Stop / Restart the Percona XtraDB Cluster
 


Percona XtraDB Cluster (Percona):
 

service mysql bootstrap-pxc # sysvinit
systemctl start mysql@bootstrap.service # systemd

systemctl stop mysql
systemctl start mysql@bootstrap 
systemctl status mysql@bootstrap
When the first node is live, run the following command on the subsequent nodes: systemctl stop mysql
systemctl start mysql

Warning: Never bootstrap when you want to reconnect a node to an existing cluster, and NEVER run bootstrap on more than one node.

MySQL Galera Cluster (Codership):
 

service mysql bootstrap # sysvinit galera_new_cluster # systemd
mysqld_safe --wsrep-new-cluster # command line

MariaDB Galera Cluster (MariaDB):
 

service mysql bootstrap # sysvinit
service mysql start --wsrep-new-cluster # sysvinit galera_new_cluster # systemd
mysqld_safe --wsrep-new-cluster # command line 

------------------------------------------------------------------------------
Step - 11 Additional information about binlog , read_only and gtid variables
------------------------------------------------------------------------------

mysql> system hostname
percona-xtradb-1

mysql> show variables like '%gtid%';
+----------------------------------+-----------+
| Variable_name                    | Value     |
+----------------------------------+-----------+
| binlog_gtid_simple_recovery      | ON        |
| enforce_gtid_consistency         | OFF       |
| gtid_executed                    |           |
| gtid_executed_compression_period | 0         |
| gtid_mode                        | OFF       |
| gtid_next                        | AUTOMATIC |
| gtid_owned                       |           |
| gtid_purged                      |           |
| session_track_gtids              | OFF       |
+----------------------------------+-----------+
9 rows in set (0.00 sec)

mysql> show variables like '%log_bin%';
+---------------------------------+-----------------------------+
| Variable_name                   | Value                       |
+---------------------------------+-----------------------------+
| log_bin                         | ON                          |
| log_bin_basename                | /var/lib/mysql/binlog       |
| log_bin_index                   | /var/lib/mysql/binlog.index |
| log_bin_trust_function_creators | OFF                         |
| log_bin_use_v1_row_events       | OFF                         |
| sql_log_bin                     | ON                          |
+---------------------------------+-----------------------------+
6 rows in set (0.01 sec)

mysql> show variables like 'read_only';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| read_only     | OFF   |
+---------------+-------+
1 row in set (0.00 sec)

mysql> status
--------------
mysql  Ver 8.0.23-14.1 for Linux on x86_64 (Percona XtraDB Cluster (GPL), Release rel14, Revision d3b9a1d, WSREP version 26.4.3)

Connection id:          21
Current database:
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.23-14.1 Percona XtraDB Cluster (GPL), Release rel14, Revision d3b9a1d, WSREP version 26.4.3
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    utf8mb4

Conn.  characterset:    utf8mb4
UNIX socket:            /var/lib/mysql/mysql.sock
Binary data as:         Hexadecimal
Uptime:                 25 min 35 sec

Threads: 12  Questions: 7047  Slow queries: 0  Opens: 212  Flush tables: 3  Open tables: 124  Queries per second avg: 4.590
--------------

mysql> show processlist;
+----+-----------------+-------------------------------------+------+---------+------+----
| Id | User            | Host                                | db   | Command | Time | State                    | Info             | Time_ms | Rows_sent | Rows_examined |
+----+-----------------+-------------------------------------+------+---------+------+----
|  1 | system user     |                                     | NULL | Sleep   | 1656 | wsrep aborter idle       | NULL             | 1655637 |         0 |             0 |
|  2 | system user     |                                     | NULL | Sleep   | 1656 | wsrep: applier idle      | NULL             | 1655637 |         0 |             0 |
|  8 | event_scheduler | localhost                           | NULL | Daemon  | 1652 | Waiting on empty queue   | NULL             | 1651760 |         0 |             0 |
| 11 | system user     |                                     | NULL | Sleep   | 1652 | innobase_commit_low (-1) | NULL             | 1651746 |         0 |             0 |
| 12 | system user     |                                     | NULL | Sleep   | 1652 | innobase_commit_low (-1) | NULL             | 1651746 |         0 |             0 |
| 13 | system user     |                                     | NULL | Sleep   | 1652 | innobase_commit_low (-1) | NULL             | 1651745 |         0 |             0 |
| 14 | system user     |                                     | NULL | Sleep   | 1652 | innobase_commit_low (-1) | NULL             | 1651745 |         0 |             0 |
| 15 | system user     |                                     | NULL | Sleep   | 1652 | wsrep: applier idle      | NULL             | 1651745 |         0 |             0 |
| 16 | system user     |                                     | NULL | Sleep   | 1652 | wsrep: applier idle      | NULL             | 1651745 |         0 |             0 |
| 17 | system user     |                                     | NULL | Sleep   | 1652 | wsrep: applier idle      | NULL             | 1651745 |         0 |             0 |
| 20 | maxscale        | ip-172-31-24-128.ec2.internal:59192 | NULL | Sleep   |    1 |                          | NULL             |    1065 |         0 |             0 |
| 21 | root            | localhost                           | NULL | Query   |    0 | init                     | show processlist |       0 |         0 |             0 |
+----+-----------------+-------------------------------------+------+---------+------+----
12 rows in set (0.00 sec)

mysql> system hostname
percona-xtradb-2

mysql> show variables like '%gtid%';
+----------------------------------+-----------+
| Variable_name                    | Value     |
+----------------------------------+-----------+
| binlog_gtid_simple_recovery      | ON        |
| enforce_gtid_consistency         | OFF       |
| gtid_executed                    |           |
| gtid_executed_compression_period | 0         |
| gtid_mode                        | OFF       |
| gtid_next                        | AUTOMATIC |
| gtid_owned                       |           |
| gtid_purged                      |           |
| session_track_gtids              | OFF       |
+----------------------------------+-----------+
9 rows in set (0.01 sec)

mysql> show variables like '%log_bin%';




+---------------------------------+-----------------------------+
| Variable_name                   | Value                       |
+---------------------------------+-----------------------------+
| log_bin                         | ON                          |
| log_bin_basename                | /var/lib/mysql/binlog       |
| log_bin_index                   | /var/lib/mysql/binlog.index |
| log_bin_trust_function_creators | OFF                         |
| log_bin_use_v1_row_events       | OFF                         |
| sql_log_bin                     | ON                          |
+---------------------------------+-----------------------------+
6 rows in set (0.01 sec)

mysql> show variables like 'read_only';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| read_only     | OFF   |
+---------------+-------+
1 row in set (0.00 sec)

mysql> status
--------------
mysql  Ver 8.0.23-14.1 for Linux on x86_64 (Percona XtraDB Cluster (GPL), Release rel14, Revision d3b9a1d, WSREP version 26.4.3)

Connection id:          26
Current database:

Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.23-14.1 Percona XtraDB Cluster (GPL), Release rel14, Revision d3b9a1d, WSREP version 26.4.3
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    utf8mb4
Conn.  characterset:    utf8mb4
UNIX socket:            /var/lib/mysql/mysql.sock
Binary data as:         Hexadecimal
Uptime:                 25 min 48 sec

Threads: 12  Questions: 7153  Slow queries: 0  Opens: 293  Flush tables: 3  Open tables: 205  Queries per second avg: 4.620
--------------

mysql> show processlist;
+----+-----------------+-------------------------------------+------+---------+------+----
| Id | User            | Host                                | db   | Command | Time | State                    | Info             | Time_ms | Rows_sent | Rows_examined |
+----+-----------------+-------------------------------------+------+---------+------+----
|  1 | system user     |                                     | NULL | Sleep   | 1671 | wsrep aborter idle       | NULL             | 1670561 |         0 |             0 |
|  2 | system user     |                                     | NULL | Sleep   | 1671 | innobase_commit_low (-1) | NULL             | 1670561 |         0 |             0 |
|  7 | event_scheduler | localhost                           | NULL | Daemon  | 1669 | Waiting on empty queue   | NULL             | 1669052 |         0 |             0 |
| 11 | system user     |                                     | NULL | Sleep   | 1669 | wsrep: applier idle      | NULL             | 1669012 |         0 |             0 |
| 12 | system user     |                                     | NULL | Sleep   | 1669 | wsrep: applier idle      | NULL             | 1669012 |         0 |             0 |

| 13 | system user     |                                     | NULL | Sleep   | 1669 | wsrep: applier idle      | NULL             | 1669012 |         0 |             0 |
| 14 | system user     |                                     | NULL | Sleep   | 1669 | wsrep: applier idle      | NULL             | 1669012 |         0 |             0 |
| 15 | system user     |                                     | NULL | Sleep   | 1669 | wsrep: applier idle      | NULL             | 1669012 |         0 |             0 |
| 16 | system user     |                                     | NULL | Sleep   | 1669 | wsrep: applier idle      | NULL             | 1669012 |         0 |             0 |
| 17 | system user     |                                     | NULL | Sleep   | 1669 | innobase_commit_low (-1) | NULL             | 1669011 |         0 |             0 |
| 19 | maxscale        | ip-172-31-24-128.ec2.internal:58912 | NULL | Sleep   |    0 |                          | NULL             |     411 |         0 |             0 |
| 26 | root            | localhost                           | NULL | Query   |    0 | init                     | show processlist |       0 |         0 |             0 |
+----+-----------------+-------------------------------------+------+---------+------+----
12 rows in set (0.00 sec)


mysql> system hostname
percona-xtradb-3
mysql> show variables like '%gtid%';
+----------------------------------+-----------+
| Variable_name                    | Value     |
+----------------------------------+-----------+
| binlog_gtid_simple_recovery      | ON        |
| enforce_gtid_consistency         | OFF       |
| gtid_executed                    |           |
| gtid_executed_compression_period | 0         |
| gtid_mode                        | OFF       |
| gtid_next                        | AUTOMATIC |
| gtid_owned                       |           |
| gtid_purged                      |           |
| session_track_gtids              | OFF       |
+----------------------------------+-----------+
9 rows in set (0.00 sec)

mysql> show variables like '%log_bin%';
+---------------------------------+-----------------------------+
| Variable_name                   | Value                       |
+---------------------------------+-----------------------------+
| log_bin                         | ON                          |
| log_bin_basename                | /var/lib/mysql/binlog       |
| log_bin_index                   | /var/lib/mysql/binlog.index |
| log_bin_trust_function_creators | OFF                         |
| log_bin_use_v1_row_events       | OFF                         |
| sql_log_bin                     | ON                          |
+---------------------------------+-----------------------------+
6 rows in set (0.00 sec)

mysql> show variables like 'read_only';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| read_only     | OFF   |
+---------------+-------+
1 row in set (0.00 sec)

mysql> status
--------------
mysql  Ver 8.0.23-14.1 for Linux on x86_64 (Percona XtraDB Cluster (GPL), Release rel14, Revision d3b9a1d, WSREP version 26.4.3)

Connection id:          21
Current database:

Current user:           root@localhost
SSL:                    Not in use

Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.23-14.1 Percona XtraDB Cluster (GPL), Release rel14, Revision d3b9a1d, WSREP version 26.4.3
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    utf8mb4
Conn.  characterset:    utf8mb4
UNIX socket:            /var/lib/mysql/mysql.sock
Binary data as:         Hexadecimal
Uptime:                 25 min 38 sec

Threads: 12  Questions: 7058  Slow queries: 0  Opens: 191  Flush tables: 3  Open tables: 103  Queries per second avg: 4.589
--------------

mysql> show processlist;
+----+-----------------+-------------------------------------+------+---------+------+----
| Id | User            | Host                                | db   | Command | Time | State                    | Info             | Time_ms | Rows_sent | Rows_examined |
+----+-----------------+-------------------------------------+------+---------+------+----
|  1 | system user     |                                     | NULL | Sleep   | 1663 | wsrep aborter idle       | NULL             | 1663240 |         0 |             0 |
|  2 | system user     |                                     | NULL | Sleep   | 1663 | wsrep: applier idle      | NULL             | 1663240 |         0 |             0 |
|  8 | event_scheduler | localhost                           | NULL | Daemon  | 1660 | Waiting on empty queue   | NULL             | 1660420 |         0 |             0 |
| 12 | system user     |                                     | NULL | Sleep   | 1660 | innobase_commit_low (-1) | NULL             | 1660404 |         0 |             0 |
| 13 | system user     |                                     | NULL | Sleep   | 1660 | innobase_commit_low (-1) | NULL             | 1660404 |         0 |             0 |
| 14 | system user     |                                     | NULL | Sleep   | 1660 | innobase_commit_low (-1) | NULL             | 1660404 |         0 |             0 |
| 15 | system user     |                                     | NULL | Sleep   | 1660 | innobase_commit_low (-1) | NULL             | 1660404 |         0 |             0 |
| 16 | system user     |                                     | NULL | Sleep   | 1660 | wsrep: applier idle      | NULL             | 1660403 |         0 |             0 |
| 17 | system user     |                                     | NULL | Sleep   | 1660 | wsrep: applier idle      | NULL             | 1660403 |         0 |             0 |
| 18 | system user     |                                     | NULL | Sleep   | 1660 | wsrep: applier idle      | NULL             | 1660403 |         0 |             0 |
| 20 | maxscale        | ip-172-31-24-128.ec2.internal:60622 | NULL | Sleep   |    0 |                          | NULL             |     184 |         0 |             0 |
| 21 | root            | localhost                           | NULL | Query   |    0 | init                     | show processlist |       0 |         0 |             0 |
+----+-----------------+-------------------------------------+------+---------+------+----
12 rows in set (0.00 sec)












------------------------------------------------------------------------------------------
Step - 12 All Servers are down , how to start the bootstrap or how to start Percona XtraDB Cluster...etc
------------------------------------------------------------------------------------------
Node – 1 :-
------------
[root@percona-xtradb-1 ~]# ps -ef | grep -i mysql
root        1539    1519  0 00:34 pts/0    00:00:00 grep --color=auto -i mysql

[root@percona-xtradb-1 ~]# cat /var/lib/mysql/grastate.dat
# GALERA saved state
version: 2.1
uuid:    29ff2ba6-01db-11ec-8a50-7a82b8ebba59
seqno:   63
safe_to_bootstrap: 0

[root@percona-xtradb-1 ~]# service mysql start
Redirecting to /bin/systemctl start mysql.service

[root@percona-xtradb-1 ~]# ps -ef | grep -i mysql
mysql       1648       1 29 00:36 ?        00:00:03 /usr/sbin/mysqld --wsrep_start_position=29ff2ba6-01db-11ec-8a50-7a82b8ebba59:63
root        2226    1519  0 00:36 pts/0    00:00:00 grep --color=auto -i mysql

[root@percona-xtradb-1 ~]# cat /var/lib/mysql/grastate.dat
# GALERA saved state
version: 2.1
uuid:    29ff2ba6-01db-11ec-8a50-7a82b8ebba59
seqno:   -1
safe_to_bootstrap: 0

Node – 2 :-
------------

[root@percona-xtradb-2 ~]# ps -ef | grep -i mysql
root        1555    1535  0 00:35 pts/0    00:00:00 grep --color=auto -i mysql

[root@percona-xtradb-2 ~]# cat /var/lib/mysql/grastate.dat
# GALERA saved state
version: 2.1
uuid:    29ff2ba6-01db-11ec-8a50-7a82b8ebba59
seqno:   65
safe_to_bootstrap: 1

[root@percona-xtradb-2 ~]# systemctl start mysql@bootstrap.service

[root@percona-xtradb-2 ~]# ps -ef | grep -i mysql
mysql       1652       1 20 00:36 ?        00:00:04 /usr/sbin/mysqld --wsrep-new-cluster --wsrep_start_position=29ff2ba6-01db-11ec-8a50-7a82b8ebba59:65
root        2522    1535  0 00:36 pts/0    00:00:00 grep --color=auto -i mysql

[root@percona-xtradb-2 ~]# cat /var/lib/mysql/grastate.dat
# GALERA saved state
version: 2.1
uuid:    29ff2ba6-01db-11ec-8a50-7a82b8ebba59
seqno:   -1
safe_to_bootstrap: 0

Node – 3 :-
------------

[root@percona-xtradb-3 ~]# ps -ef | grep -i mysql
root        1537    1517  0 00:35 pts/0    00:00:00 grep --color=auto -i mysql


[root@percona-xtradb-3 ~]# cat /var/lib/mysql/grastate.dat
# GALERA saved state
version: 2.1
uuid:    29ff2ba6-01db-11ec-8a50-7a82b8ebba59
seqno:   64
safe_to_bootstrap: 0

[root@percona-xtradb-3 ~]# service mysql start
Redirecting to /bin/systemctl start mysql.service

[root@percona-xtradb-3 ~]# ps -ef | grep -i mysql
mysql       1644       1 21 00:36 ?        00:00:03 /usr/sbin/mysqld --wsrep_start_position=29ff2ba6-01db-11ec-8a50-7a82b8ebba59:64
root        2221    1517  0 00:36 pts/0    00:00:00 grep --color=auto -i mysql

[root@percona-xtradb-3 ~]# cat /var/lib/mysql/grastate.dat
# GALERA saved state
version: 2.1
uuid:    29ff2ba6-01db-11ec-8a50-7a82b8ebba59
seqno:   -1
safe_to_bootstrap: 0


Here all Servers are down. So based on grastate.dat file or " seqno " value having high in Node 2 , so , i have ran bootstrap command in Node 2 .
Other Node 1 and Node 3 are i have started service with normal way..i.e " Service mysql start " . So after started all Nodes Services , i can see " seqno = -1 " That is all are in synch.

Now after started all services , i was checking in MaxScale Servers list . 

[root@maxscale ~]# maxscale --version
MaxScale 2.5.13

[root@maxscale ~]# maxctrl list servers
+-------------------------------------------------------------------------------+
¦ Server  ¦ Address       ¦ Port ¦ Connections ¦ State                   ¦ GTID ¦
+---------+---------------+------+-------------+-------------------------+------¦
¦ server1 ¦ 172.31.42.167 ¦ 3306 ¦ 0           ¦ Slave, Synced, Running  ¦      ¦
+---------+---------------+------+-------------+-------------------------+------¦
¦ server2 ¦ 172.31.38.74  ¦ 3306 ¦ 0           ¦ Master, Synced, Running ¦      ¦
+---------+---------------+------+-------------+-------------------------+------¦
¦ server3 ¦ 172.31.35.40  ¦ 3306 ¦ 0           ¦ Slave, Synced, Running  ¦      ¦
+-------------------------------------------------------------------------------+

[root@maxscale ~]# maxctrl list sessions
+-----------------------------------------------+
¦ Id ¦ User ¦ Host ¦ Connected ¦ Idle ¦ Service ¦
+-----------------------------------------------+

Here you can observe , Node - 2 is poitning to Master now. Why Because , we have ran bootstrap in Node - 2 in above steps. That'y it wis poiniting to Master . 

Other Reference Links :-

https://www.percona.com/doc/percona-xtradb-cluster/LATEST/howtos/centos_howto.html ===> 1st Preferences ....

https://ittutorial.org/installing-percona-xtradb-cluster-on-centos-7/	===> 2nd Preferences ....

https://www.percona.com/doc/percona-xtradb-cluster/5.7/howtos/3nodesec2.html	===>
This is for EC2 Setup

https://www.percona.com/doc/percona-server/8.0/installation/yum_repo.html https://www.percona.com/doc/percona-xtradb-cluster/LATEST/install/yum.html#yum
