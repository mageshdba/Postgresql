
Service     Actual  NonProd
etcd        2379    4114
etcd        2380    4115
Patroni     8008    4343
Postgres    5432    4554
Bouncer     6432    4004
haproxy(Pr) 5000    6007 - NLB healthcheck Primary
haproxy(Sc) 5001    6008 - NLB healthcheck Replica
haproxy(Bn) 7000    8228




~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Installation 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
percona-release setup ppg16
yum install python3-pip python3-devel binutils
yum install percona-patroni etcd python3-python-etcd


systemctl stop {etcd,patroni}
systemctl disable {etcd,patroni}


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/etc/hosts - entries on all 3 nodes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
171.2.137.48 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com saas-uat-pgsql01
171.2.137.89 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com saas-uat-pgsql02
171.2.137.118 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com saas-uat-pgsql03





~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node 01 : /etc/etcd/etcd.conf.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
name: 'saas-uat-pgsql01'
initial-cluster-token: PostgreSQL_HA_Cluster_1
initial-cluster-state: new
initial-cluster: saas-uat-pgsql01=http://171.2.137.48:4115
data-dir: /var/lib/etcd
initial-advertise-peer-urls: http://171.2.137.48:4115
listen-peer-urls: http://171.2.137.48:4115,http://localhost:4115
advertise-client-urls: http://171.2.137.48:4114
listen-client-urls: http://171.2.137.48:4114,http://localhost:4114


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node 01 : Enable and verify ETCD status
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
systemctl enable --now etcd
systemctl status etcd


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node 01 : list members
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 etcd]# etcdctl --endpoints=http://171.2.137.48:4114 endpoint status --write-out=table
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT         |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://171.2.137.48:4114 | c2deeb18c5e30791 |  3.5.15 |   20 kB |      true |      false |         3 |          6 |                  6 |        |
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Adding Node 02 from Node 01
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 etcd]# etcdctl --endpoints=http://171.2.137.48:4114 member add saas-uat-pgsql02 --peer-urls=http://171.2.137.89:4115
Member fad6f777e8e7b895 added to cluster 387db5b1c8e83a91

ETCD_NAME="saas-uat-pgsql02"
ETCD_INITIAL_CLUSTER="saas-uat-pgsql01=http://171.2.137.48:4115,saas-uat-pgsql02=http://171.2.137.89:4115"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://171.2.137.89:4115"
ETCD_INITIAL_CLUSTER_STATE="existing"



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node 02 : etcd.conf.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
name: 'saas-uat-pgsql02'
initial-cluster-token: PostgreSQL_HA_Cluster_1
initial-cluster-state: existing
initial-cluster: saas-uat-pgsql01=http://171.2.137.48:4115,saas-uat-pgsql02=http://171.2.137.89:4115
data-dir: /var/lib/etcd
initial-advertise-peer-urls: http://171.2.137.89:4115
listen-peer-urls: http://171.2.137.89:4115,http://localhost:4115
advertise-client-urls: http://171.2.137.89:4114
listen-client-urls: http://171.2.137.89:4114,http://localhost:4114

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node 02 : Enable and verify ETCD status
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
systemctl enable --now etcd
systemctl status etcd


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node 01 : list members
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 etcd]# etcdctl --endpoints=http://171.2.137.48:4114,http://171.2.137.89:4114 endpoint status --write-out=table
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT         |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://171.2.137.48:4114 | c2deeb18c5e30791 |  3.5.15 |   20 kB |      true |      false |         4 |          9 |                  9 |        |
| http://171.2.137.89:4114 | fad6f777e8e7b895 |  3.5.15 |   20 kB |     false |      false |         4 |          9 |                  9 |        |
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Adding Node 03 from Node 01
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 etcd]# etcdctl --endpoints=http://171.2.137.48:4114 member add saas-uat-pgsql03 --peer-urls=http://171.2.137.118:4115
Member 9ff3ee256a82a482 added to cluster 387db5b1c8e83a91

ETCD_NAME="saas-uat-pgsql03"
ETCD_INITIAL_CLUSTER="saas-uat-pgsql03=http://171.2.137.118:4115,saas-uat-pgsql01=http://171.2.137.48:4115,saas-uat-pgsql02=http://171.2.137.89:4115"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://171.2.137.118:4115"
ETCD_INITIAL_CLUSTER_STATE="existing"

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node 03 : etcd.conf.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

name: 'saas-uat-pgsql03'
initial-cluster-token: PostgreSQL_HA_Cluster_1
initial-cluster-state: existing
initial-cluster: saas-uat-pgsql01=http://171.2.137.48:4115,saas-uat-pgsql03=http://171.2.137.118:4115,saas-uat-pgsql02=http://171.2.137.89:4115
data-dir: /var/lib/etcd
initial-advertise-peer-urls: http://171.2.137.118:4115
listen-peer-urls: http://171.2.137.118:4115,http://localhost:4115
advertise-client-urls: http://171.2.137.118:4114
listen-client-urls: http://171.2.137.118:4114,http://localhost:4114

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node 01 : list members
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[root@aws-ind-aps1-m2p-saas-uat-pgsql01 etcd]# etcdctl --endpoints=http://171.2.137.48:4114,http://171.2.137.89:4114,http://171.2.137.118:4114 endpoint status --write-out=table
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|  http://171.2.137.48:4114 | c2deeb18c5e30791 |  3.5.15 |   20 kB |      true |      false |         4 |         11 |                 11 |        |
|  http://171.2.137.89:4114 | fad6f777e8e7b895 |  3.5.15 |   20 kB |     false |      false |         4 |         11 |                 11 |        |
| http://171.2.137.118:4114 | 9ff3ee256a82a482 |  3.5.15 |   20 kB |     false |      false |         4 |         11 |                 11 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>>>>>>>>>>>> create a super user for patroni <<<<<<<<<<<<<<<<<<<<<<<<
create role patsuper superuser encrypted password 'Patroni@1234';
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>>>>>>>>>>>> pg_hba.conf entries on all 3 nodes <<<<<<<<<<<<<<<<<<<<<<<<
local   all             all                                     peer
host    all             all             0.0.0.0/0              scram-sha-256
host    all             all             ::1/128                scram-sha-256
# replusr specific replication connections
host    replication     replusr        171.2.137.48/32        scram-sha-256
host    replication     replusr        171.2.137.89/32        scram-sha-256
host    replication     replusr        171.2.137.118/32       scram-sha-256
host    replication     replusr        127.0.0.1/32           scram-sha-256
host    replication     replusr        ::1/128                scram-sha-256

# patsuper specific replication connections
host    all     patsuper       171.2.137.48/32        scram-sha-256
host    all     patsuper       171.2.137.89/32        scram-sha-256
host    all     patsuper       171.2.137.118/32       scram-sha-256
host    all     patsuper       127.0.0.1/32           scram-sha-256
host    all     patsuper       ::1/128                scram-sha-256

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- Once patroni service is configured, verify the pg_hba path by logging into the secondary servers
- Check if all the ports users are allowed in the pg_hba.conf
- Before starting patroni in secondary, stop the postgres services there and start the patroni.service
- In "another window run journalctl -u patroni.service -n 100 -f" command to check the errors
- Whatever the changes that had happened in the primary should be applied to Secondary
- If you check postgresql service status, it will be shown as dead as patroni takes care of starting / starting 
    postgres in the backend.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>>>>>>>>>>>>>>>>>>>>>>  patroni.service on all 3 servers >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
/etc/systemd/system/patroni.service

[Unit]
Description=PostgreSQL high-availability manager
After=syslog.target
# Patroni needs to shut down before network interfaces. According to SystemD documentation
# specifying network.target should be sufficient, but experiments show that this is not the case.
After=network-online.target

[Service]
Type=simple

User=postgres
Group=postgres

# Location of Patroni configuration
Environment=PATRONI_CONFIG_LOCATION=/dbdata/patroni/patroni.yml

#Authentication
Environment="PATRONI_SUPERUSER_PASSWORD=Patroni@1234"
Environment="PATRONI_REPLICATION_PASSWORD=Replusr@123"

# Disable OOM kill on the postmaster
OOMScoreAdjust=-1000

ExecStart=/usr/bin/patroni ${PATRONI_CONFIG_LOCATION}
ExecReload=/bin/kill -HUP $MAINPID

# Give a reasonable amount of time for the server to start up/shut down
TimeoutSec=30
TimeoutStopSec=120s

# only kill the patroni process, not it's children, so it will gracefully stop postgres
KillSignal=SIGINT
KillMode=process

[Install]
WantedBy=multi-user.target

<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


Create patroni.yml file in Primary Node with the following contents, followed by patroni.service
Please note that the patroni.yml on Node2 under tags section, nofailover should be set as true to avoid
making it as primary by automatic failover

mkdir /dbdata/patroni/
cd /dbdata/patroni/

Following are mandatory for creating patroni.yml

Node Name : saas-uat-pgsql01
IP : 171.2.137.48
Data directory : /dbdata/pgsql
bin directory : /usr/bin/psql
Patroni config : /dbdata/patroni/patroni.yml
Archived directory : /dblog/archive/pgsql/ -- Recommended not to use inside data path as recovery on Secondary node may fail stating data directory is not empty.
Provide ownership to postgres for patroni, datapath and archive location

>>>>>>>>>>>>>>>>>>>>>> Node 01 patroni.yml >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

namespace: percona_pg_cluster
scope: cluster_1
name: saas-uat-pgsql01

restapi:
    listen: 0.0.0.0:4343
    connect_address: 171.2.137.48:4343

etcd3:
  hosts:
      - 171.2.137.48:4114
      - 171.2.137.118:4114
      - 171.2.137.89:4114

bootstrap:
  dcs:
      ttl: 30
      loop_wait: 10
      retry_timeout: 10
      maximum_lag_on_failover: 1048576

      postgresql:
          use_pg_rewind: true
          use_slots: true
          parameters:
              shared_preload_libraries: "pg_cron,pgcrypto,pg_stat_statements,timescaledb,pgaudit,dblink,pg_stat_monitor"
              wal_level: replica
              hot_standby: "on"
              wal_keep_segments: 10
              max_wal_senders: 10
              max_connections: 10000
              max_replication_slots: 10
              wal_log_hints: "on"
              logging_collector: 'on'
              max_wal_size: '10GB'
              archive_mode: "on"
              archive_timeout: 600s
              archive_command: "cp -f %p /dblog/archive/pgsql/%f"

  initdb:
      - encoding: UTF8
      - data-checksums

postgresql:
    cluster_name: cluster_1
    listen: 0.0.0.0:4554
    connect_address: 171.2.137.48:4554
    data_dir: /dbdata/pgsql
    bin_dir: /usr/pgsql-16/bin
    pgpass: /tmp/pgpass0
    authentication:
        replication:
            username: replusr
            password: ${PATRONI_REPLICATION_PASSWORD}
        superuser:
            username: patsuper
            password: ${PATRONI_SUPERUSER_PASSWORD}
    parameters:
        unix_socket_directories: "/var/run/postgresql/"
    create_replica_methods:
        - basebackup
    basebackup:
        checkpoint: 'fast'

tags:
    nofailover: false
    noloadbalance: false
    clonefrom: false
    nosync: false


<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Start the patroni
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Before starting patroni, ensure you have copied the pg_hba.conf to the postgres data directory. Patroni will
pick the pg_hba.conf from that path only. 

service patroni start

Monitor it using : journalctl -u patroni.service -n 100 -f

Once patroni is started, then we should see the successful messages as below:

Feb 25 13:44:32 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[4024265]: 2025-02-25 13:44:32,001 INFO: no action. I am (saas-uat-pgsql02), the leader with the lock
Feb 25 13:44:42 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[4024265]: 2025-02-25 13:44:42,001 INFO: no action. I am (saas-uat-pgsql02), the leader with the lock
Feb 25 13:44:52 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[4024265]: 2025-02-25 13:44:52,044 INFO: no action. I am (saas-uat-pgsql02), the leader with the lock
Feb 25 13:45:02 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[4024265]: 2025-02-25 13:45:02,001 INFO: no action. I am (saas-uat-pgsql02), the leader with the lock
Feb 25 13:45:12 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[4024265]: 2025-02-25 13:45:12,000 INFO: no action. I am (saas-uat-pgsql02), the leader with the lock
Feb 25 13:45:22 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[4024265]: 2025-02-25 13:45:22,000 INFO: no action. I am (saas-uat-pgsql02), the leader with the lock
Feb 25 13:45:32 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[4024265]: 2025-02-25 13:45:32,000 INFO: no action. I am (saas-uat-pgsql02), the leader with the lock
Feb 25 13:45:42 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[4024265]: 2025-02-25 13:45:42,000 INFO: no action. I am (saas-uat-pgsql02), the leader with the lock
Feb 25 13:45:52 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[4024265]: 2025-02-25 13:45:52,000 INFO: no action. I am (saas-uat-pgsql02), the leader with the lock
Feb 25 13:46:02 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[4024265]: 2025-02-25 13:46:02,000 INFO: no action. I am (saas-uat-pgsql02), the leader with the lock
Feb 25 13:46:12 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[4024265]: 2025-02-25 13:46:12,000 INFO: no action. I am (saas-uat-pgsql02), the leader with the lock
Feb 25 13:46:22 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[4024265]: 2025-02-25 13:46:22,000 INFO: no action. I am (saas-uat-pgsql02), the leader with the lock
Feb 25 13:46:32 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[4024265]: 2025-02-25 13:46:32,000 INFO: no action. I am (saas-uat-pgsql02), the leader with the lock
Feb 25 13:46:42 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[4024265]: 2025-02-25 13:46:42,002 INFO: no action. I am (saas-uat-pgsql02), the leader with the lock

Once Patroni is started on Node 01, then proceed to Node 02

>>>>>>>>>>>>>>>>>>>>>> Node 02 patroni.yml >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

namespace: percona_pg_cluster
scope: cluster_1
name: saas-uat-pgsql02

restapi:
    listen: 0.0.0.0:4343
    connect_address: 171.2.137.89:4343

etcd3:
  hosts:
      - 171.2.137.48:4114
      - 171.2.137.118:4114
      - 171.2.137.89:4114

bootstrap:
  dcs:
      ttl: 30
      loop_wait: 10
      retry_timeout: 10
      maximum_lag_on_failover: 1048576

      postgresql:
          use_pg_rewind: true
          use_slots: true
          parameters:
              shared_preload_libraries: "pg_cron,pgcrypto,pg_stat_statements,timescaledb,pgaudit,dblink,pg_stat_monitor"
              wal_level: replica
              hot_standby: "on"
              wal_keep_segments: 10
              max_wal_senders: 10
              max_connections: 10000
              max_replication_slots: 10
              wal_log_hints: "on"
              logging_collector: 'on'
              max_wal_size: '10GB'
              archive_mode: "on"
              archive_timeout: 600s
              archive_command: "cp -f %p /dblog/archive/pgsql/%f"

  initdb:
      - encoding: UTF8
      - data-checksums

postgresql:
    cluster_name: cluster_1
    listen: 0.0.0.0:4554
    connect_address: 171.2.137.89:4554
    data_dir: /dbdata/pgsql
    bin_dir: /usr/pgsql-16/bin
    pgpass: /tmp/pgpass0
    authentication:
        replication:
            username: replusr
            password: ${PATRONI_REPLICATION_PASSWORD}
        superuser:
            username: patsuper
            password: ${PATRONI_SUPERUSER_PASSWORD}
    parameters:
        unix_socket_directories: "/var/run/postgresql/"
    create_replica_methods:
        - basebackup
    basebackup:
        checkpoint: 'fast'

tags:
    nofailover: true
    noloadbalance: false
    clonefrom: false
    nosync: false

<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

>>>>>>>>>>>>>>>>>>>>>> Node 03 patroni.yml >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
namespace: percona_pg_cluster
scope: cluster_1
name: saas-uat-pgsql03

restapi:
    listen: 0.0.0.0:4343
    connect_address: 171.2.137.118:4343

etcd3:
  hosts:
      - 171.2.137.48:4114
      - 171.2.137.118:4114
      - 171.2.137.89:4114

bootstrap:
  dcs:
      ttl: 30
      loop_wait: 10
      retry_timeout: 10
      maximum_lag_on_failover: 1048576

      postgresql:
          use_pg_rewind: true
          use_slots: true
          parameters:
              shared_preload_libraries: "pg_cron,pgcrypto,pg_stat_statements,timescaledb,pgaudit,dblink,pg_stat_monitor"
              wal_level: replica
              hot_standby: "on"
              wal_keep_segments: 10
              max_wal_senders: 10
              max_connections: 10000
              max_replication_slots: 10
              wal_log_hints: "on"
              logging_collector: 'on'
              max_wal_size: '10GB'
              archive_mode: "on"
              archive_timeout: 600s
              archive_command: "cp -f %p /dblog/archive/pgsql/%f"

  initdb:
      - encoding: UTF8
      - data-checksums

postgresql:
    cluster_name: cluster_1
    listen: 0.0.0.0:4554
    connect_address: 171.2.137.118:4554
    data_dir: /dbdata/pgsql
    bin_dir: /usr/pgsql-16/bin
    pgpass: /tmp/pgpass0
    authentication:
        replication:
            username: replusr
            password: ${PATRONI_REPLICATION_PASSWORD}
        superuser:
            username: patsuper
            password: ${PATRONI_SUPERUSER_PASSWORD}
    parameters:
        unix_socket_directories: "/var/run/postgresql/"
    create_replica_methods:
        - basebackup
    basebackup:
        checkpoint: 'fast'

tags:
    nofailover: false
    noloadbalance: false
    clonefrom: false
    nosync: false


<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

>>>>>>>>>>>>>>>>>>>>>>>>> HA PRoxy >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
[root@saas-uat-pgsql03 ~]# cat /etc/haproxy/haproxy.cfg
global
    maxconn 10000

defaults
    log global
    mode tcp
    retries 2
    timeout client 30m
    timeout connect 4s
    timeout server 30m
    timeout check 5s

listen stats
    mode http
    bind *:8228
    stats enable
    stats uri /

listen primary
    bind *:6007
    option httpchk /primary
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server saas-uat-pgsql01 saas-uat-pgsql01:4554 maxconn 100 check port 4343
    server saas-uat-pgsql02 saas-uat-pgsql02:4554 maxconn 100 check port 4343
    server saas-uat-pgsql03 saas-uat-pgsql03:4554 maxconn 100 check port 4343

listen standbys
    balance roundrobin
    bind *:6008
    option httpchk /replica
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server saas-uat-pgsql01 saas-uat-pgsql01:4554 maxconn 100 check port 4343
    server saas-uat-pgsql02 saas-uat-pgsql02:4554 maxconn 100 check port 4343
    server saas-uat-pgsql03 saas-uat-pgsql03:4554 maxconn 100 check port 4343


<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##NOTE
Once building the Patroni cluster completely, we need to ensure the old slots are not in use in 
any of the configuration and also ensure the hba_conf on both /dbdata/pgsql is as same as the one
in the /var/lib/pgsql/16/data path. Patroni uses the configurations from /dbdata path only




Troubleshooting issues :

1)
While starting the etcd service if we get error in the status as below and on journalctl if you see clusterid mismatch, it may be due the node was having etcd already with different cluster ID whereas the while adding newly, the cluster ID will be generated differently.


[root@saas-uat-pgsql03 ~]# service etcd status
Redirecting to /bin/systemctl status etcd.service
○ etcd.service - Etcd Server
     Loaded: loaded (/usr/lib/systemd/system/etcd.service; enabled; preset: disabled)
     Active: inactive (dead) since Thu 2024-08-29 12:11:02 IST; 17s ago
   Duration: 11ms
    Process: 199723 ExecStart=/bin/bash -c GOMAXPROCS=$(nproc) /usr/bin/etcd --config-file /etc/etcd/etcd.conf.yaml (code=exited, status=0/SUCCESS)
   Main PID: 199723 (code=exited, status=0/SUCCESS)
        CPU: 3.435s

Aug 29 12:11:02 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com bash[199723]: {"level":"info","ts":"2024-08-29T12:11:02.000562+0530","caller":"rafthttp/stream.go:294","msg":"stopped TCP streaming connection with remote peer","str>
Aug 29 12:11:02 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com bash[199723]: {"level":"info","ts":"2024-08-29T12:11:02.000643+0530","caller":"rafthttp/pipeline.go:85","msg":"stopped HTTP pipelining with remote peer","local-membe>
Aug 29 12:11:02 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com bash[199723]: {"level":"info","ts":"2024-08-29T12:11:02.000734+0530","caller":"rafthttp/stream.go:442","msg":"stopped stream reader with remote peer","stream-reader->
Aug 29 12:11:02 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com bash[199723]: {"level":"info","ts":"2024-08-29T12:11:02.000793+0530","caller":"rafthttp/stream.go:442","msg":"stopped stream reader with remote peer","stream-reader->
Aug 29 12:11:02 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com bash[199723]: {"level":"info","ts":"2024-08-29T12:11:02.000818+0530","caller":"rafthttp/peer.go:335","msg":"stopped remote peer","remote-peer-id":"79fc0ef6f46cb051"}
Aug 29 12:11:02 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com bash[199723]: {"level":"info","ts":"2024-08-29T12:11:02.00674+0530","caller":"etcdmain/main.go:44","msg":"notifying init daemon"}
Aug 29 12:11:02 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com bash[199723]: {"level":"info","ts":"2024-08-29T12:11:02.00693+0530","caller":"etcdmain/main.go:50","msg":"successfully notified init daemon"}
Aug 29 12:11:02 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com systemd[1]: Started Etcd Server.
Aug 29 12:11:02 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com systemd[1]: etcd.service: Deactivated successfully.
Aug 29 12:11:02 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com systemd[1]: etcd.service: Consumed 3.435s CPU time.


journalctl -u etcd.service -n 100 -f

Aug 29 12:11:00 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com bash[199723]: {"level":"warn","ts":"2024-08-29T12:11:00.519728+0530","caller":"rafthttp/stream.go:653","msg":"request sent was ignored by remote peer due to cluster ID mismatch","remote-peer-id":"12ff5a891fde60fb","remote-peer-cluster-id":"856f01373436629c","local-member-id":"ba47d2efed423514","local-member-cluster-id":"36701ea896742325","error":"cluster ID mismatch"}
Aug 29 12:11:00 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com bash[199723]: {"level":"info","ts":"2024-08-29T12:11:00.521506+0530","caller":"embed/etcd.go:277","msg":"now serving peer/client/metrics","local-member-id":"ba47d2efed423514","initial-advertise-peer-urls":["http://localhost:4115"],"listen-peer-urls":["http://localhost:4115"],"advertise-client-urls":["http://localhost:4114"],"listen-client-urls":["http://localhost:4114"],"listen-metrics-urls":[]}

***** FIX ***** Remove all the existing Wal files
cd /var/lib/etcd/default.etcd/wal/
rm -rvf *

[root@saas-uat-pgsql03 wal]# systemctl enable --now etcd
[root@saas-uat-pgsql03 wal]# service etcd status
shell-init: error retrieving current directory: getcwd: cannot access parent directories: No such file or directory
chdir: error retrieving current directory: getcwd: cannot access parent directories: No such file or directory
Redirecting to /bin/systemctl status etcd.service
● etcd.service - Etcd Server
     Loaded: loaded (/usr/lib/systemd/system/etcd.service; enabled; preset: disabled)
     Active: active (running) since Thu 2024-08-29 12:12:07 IST; 13s ago
   Main PID: 199829 (etcd)
      Tasks: 10 (limit: 101199)
     Memory: 6.7M
        CPU: 107ms
     CGroup: /system.slice/etcd.service
             └─199829 /usr/bin/etcd --config-file /etc/etcd/etcd.conf.yaml


2) Unable start postgres using patroni and getting following error in journalctl

Sep 05 17:12:19 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344048]: 2024-09-05 17:12:19,445 INFO: Lock owner: None; I am aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com
Sep 05 17:12:19 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344048]: 2024-09-05 17:12:19,446 INFO: starting as a secondary
Sep 05 17:12:19 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344048]: 2024-09-05 17:12:19,451 INFO: max_connections value in pg_controldata: 10000, in the global configuration: 100. pg_controldata value will be used. Setting 'Pending restart' flag
Sep 05 17:12:19 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344048]: 2024-09-05 17:12:19,451 INFO: max_wal_senders value in pg_controldata: 10, in the global configuration: 5. pg_controldata value will be used. Setting 'Pending restart' flag
Sep 05 17:12:20 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344313]: 2024-09-05 11:42:20.135 GMT [1344313] LOG:  skipping missing configuration file "/data/pgsql/postgresql.auto.conf"
Sep 05 17:12:20 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344313]: 2024-09-05 17:12:20.136 IST [1344313] FATAL:  data directory "/data/pgsql" does not exist
Sep 05 17:12:20 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344048]: 2024-09-05 17:12:20,159 INFO: postmaster pid=1344313
Sep 05 17:12:29 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344328]: localhost:4554 - no response
Sep 05 17:12:29 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344048]: 2024-09-05 17:12:29,439 INFO: Lock owner: None; I am aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com
Sep 05 17:12:29 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344048]: 2024-09-05 17:12:29,483 INFO: failed to start postgres

***** FIX ***** Update the data directory path in postgresql.base.conf file. 

vi /data/dbdata/pgsql/postgresql.base.conf

Change from:

# option or PGDATA environment variable, represented here as ConfigDir.
data_directory = '/data/pgsql'          # use data in another directory


to:
# option or PGDATA environment variable, represented here as ConfigDir.
data_directory = '/data/dbdata/pgsql'           # use data in another directory

Restarting the patroni service will start the postgres and you can check the patroni log as below once successful.

Sep 05 17:12:59 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344387]: 2024-09-05 17:12:59,057 INFO: postmaster pid=1344406
Sep 05 17:12:59 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344407]: localhost:4554 - no response
Sep 05 17:12:59 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344406]: 2024-09-05 17:12:59.255 IST [1344406] LOG:  redirecting log output to logging collector process
Sep 05 17:12:59 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344406]: 2024-09-05 17:12:59.255 IST [1344406] HINT:  Future log output will appear in directory "log".
Sep 05 17:13:00 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344412]: localhost:4554 - accepting connections
Sep 05 17:13:00 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344414]: localhost:4554 - accepting connections
Sep 05 17:13:00 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344387]: 2024-09-05 17:13:00,117 INFO: establishing a new patroni heartbeat connection to postgres
Sep 05 17:13:00 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344387]: 2024-09-05 17:13:00,206 WARNING: Could not activate Linux watchdog device: Can't open watchdog device: [Errno 2] No such file or directory: '/dev/watchdog' -- '
Sep 05 17:13:00 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344387]: 2024-09-05 17:13:00,282 INFO: promoted self to leader by acquiring session lock
Sep 05 17:13:00 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344420]: server promoting
Sep 05 17:13:01 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344387]: 2024-09-05 17:13:01,496 INFO: no action. I am (aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com), the leader with the lock
Sep 05 17:13:11 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344387]: 2024-09-05 17:13:11,349 INFO: no action. I am (aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com), the leader with the lock
Sep 05 17:13:21 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1344387]: 2024-09-05 17:13:21,440 INFO: no action. I am (aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com), the leader with the lock


3) Secondary node unable to connect to Primary Node while initializing patroni by getting following error:

Sep 05 23:49:37 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[532557]: 2024-09-05 23:49:37,599 ERROR: Error when fetching backup: pg_basebackup exited with code=1
Sep 05 23:49:37 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[532557]: 2024-09-05 23:49:37,600 ERROR: failed to bootstrap from leader 'saas-uat-pgsql01'
Sep 05 23:49:37 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[532557]: 2024-09-05 23:49:37,600 INFO: Removing data directory: /dbdata/pgsql
Sep 05 23:49:42 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[532557]: 2024-09-05 23:49:42,571 INFO: Lock owner: saas-uat-pgsql01; I am saas-uat-pgsql02
Sep 05 23:49:42 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[532557]: 2024-09-05 23:49:42,616 INFO: trying to bootstrap from leader 'saas-uat-pgsql01'
Sep 05 23:49:42 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[533900]: pg_basebackup: error: connection to server at "171.2.137.48", port 4554 failed: FATAL:  no pg_hba.conf entry for replication connection from host "171.2.137.89", user "replusr", no encryption
Sep 05 23:49:42 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[532557]: 2024-09-05 23:49:42,630 ERROR: Error when fetching backup: pg_basebackup exited with code=1
Sep 05 23:49:42 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[532557]: 2024-09-05 23:49:42,631 WARNING: Trying again in 5 seconds
Sep 05 23:49:47 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[533901]: pg_basebackup: error: connection to server at "171.2.137.48", port 4554 failed: FATAL:  no pg_hba.conf entry for replication connection from host "171.2.137.89", user "replusr", no encryption

***** FIX ***** Find the pg_hba conf used by Primary and make neccessary modifications. The default path /var/lib/pgsql/16/data/pg_hba.conf will not be considered while building via patroni.

Node 01 :
postgres=# show hba_file;
            hba_file
--------------------------------
 /data/dbdata/pgsql/pg_hba.conf
(1 row)


[root@saas-uat-pgsql01 ~]# cat /data/dbdata/pgsql/pg_hba.conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     peer
host    all             all            0.0.0.0/0            scram-sha-256
host    replication     bkpadmin       0.0.0.0/0            scram-sha-256
host    replication     replusr        171.2.137.118/32     scram-sha-256
host    postgres        postgres       127.0.0.1/32         scram-sha-256
host    replication     replusr        171.2.137.48/32      scram-sha-256
host    replication     replusr        171.2.137.89/32     scram-sha-256
host    replication     replusr        127.0.0.1/32         scram-sha-256


Node 02 :
Verify data path postgresql.base.conf
data_directory = '/data/dbdata/pgsql'

Change it to :
data_directory = '/dbdata/pgsql'

Start the patroni service and the output should look like following :

Sep 06 12:25:39 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[556736]: localhost:4554 - accepting connections
Sep 06 12:25:39 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[556738]: localhost:4554 - accepting connections
Sep 06 12:25:39 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[556699]: 2024-09-06 12:25:39,114 INFO: Lock owner: saas-uat-pgsql01; I am saas-uat-pgsql02
Sep 06 12:25:39 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[556699]: 2024-09-06 12:25:39,114 INFO: establishing a new patroni heartbeat connection to postgres
Sep 06 12:25:39 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[556699]: 2024-09-06 12:25:39,191 INFO: no action. I am (saas-uat-pgsql02), a secondary, and following a leader (saas-uat-pgsql01)
Sep 06 12:25:49 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[556699]: 2024-09-06 12:25:49,662 INFO: no action. I am (saas-uat-pgsql02), a secondary, and following a leader (saas-uat-pgsql01)
Sep 06 12:25:59 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[556699]: 2024-09-06 12:25:59,615 INFO: no action. I am (saas-uat-pgsql02), a secondary, and following a leader (saas-uat-pgsql01)
Sep 06 12:26:09 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[556699]: 2024-09-06 12:26:09,661 INFO: no action. I am (saas-uat-pgsql02), a secondary, and following a leader (saas-uat-pgsql01)
Sep 06 12:26:19 aws-ind-aps1-m2p-saas-uat-pgsql02.m2pfintech.com patroni[556699]: 2024-09-06 12:26:19,616 INFO: no action. I am (saas-uat-pgsql02), a secondary, and following a leader (saas-uat-pgsql01)


4) Issue with different congiruations between pg_controldata and global configuration
Sep 06 13:18:05 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1392397]: 2024-09-06 13:18:04,982 INFO: Lock owner: saas-uat-pgsql02; I am saas-uat-pgsql01
Sep 06 13:18:05 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1392397]: 2024-09-06 13:18:05,030 INFO: starting as a secondary
Sep 06 13:18:05 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1392397]: 2024-09-06 13:18:05,043 INFO: max_connections value in pg_controldata: 10000, in the global configuration: 100. pg_controldata value will be used. Setting 'Pending restart' flag
Sep 06 13:18:05 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[1392397]: 2024-09-06 13:18:05,043 INFO: max_wal_senders value in pg_controldata: 10, in the global configuration: 5. pg_controldata value will be used. Setting 'Pending restart' flag


[root@saas-uat-pgsql01 ~]# patronictl -c /data/patroni/patroni.yml list
+ Cluster: cluster_1 (7395832102472264106) -----+---------+-----------+----+-----------+-----------------+-----------------------------+
| Member                   | Host               | Role    | State     | TL | Lag in MB | Pending restart | Pending restart reason      |
+--------------------------+--------------------+---------+-----------+----+-----------+-----------------+-----------------------------+
| saas-uat-pgsql02 | 171.2.137.89:4554 | Replica | streaming |  9 |         0 | *               | max_connections: 10000->100 |
|                          |                    |         |           |    |           |                 | max_wal_senders: 10->5      |
+--------------------------+--------------------+---------+-----------+----+-----------+-----------------+-----------------------------+
| saas-uat-pgsql01              | 171.2.137.48:4554  | Leader  | running   |  9 |           | *               | max_connections: 10000->100 |
|                          |                    |         |           |    |           |                 | max_wal_senders: 10->5      |
+--------------------------+--------------------+---------+-----------+----+-----------+-----------------+-----------------------------+



***** FIX ***** Change the patroni configuration (not directly in patroni.yml) rather use patronictl utility
[root@saas-uat-pgsql01 pgsql]# patronictl -c /data/patroni/patroni.yml edit-config
---
+++
@@ -8,7 +8,8 @@
     hot_standby: 'on'
     logging_collector: 'on'
     max_replication_slots: 10
+    max_connections: 10000
-    max_wal_senders: 5
+    max_wal_senders: 10
     max_wal_size: 10GB
     wal_keep_segments: 10
     wal_level: replica

Apply these changes? [y/N]: y
Configuration changed

+ Cluster: cluster_1 (7395832102472264106) -----+---------+-----------+----+-----------+-----------------+-----------------------------+
| Member                   | Host               | Role    | State     | TL | Lag in MB | Pending restart | Pending restart reason      |
+--------------------------+--------------------+---------+-----------+----+-----------+-----------------+-----------------------------+
| saas-uat-pgsql02 | 171.2.137.89:4554 | Leader  | running   | 10 |           | *               | max_connections: 10000->100 |
|                          |                    |         |           |    |           |                 | max_wal_senders: 10->5      |
+--------------------------+--------------------+---------+-----------+----+-----------+-----------------+-----------------------------+
| saas-uat-pgsql01              | 171.2.137.48:4554  | Replica | streaming | 10 |         0 | *               | max_connections: 10000->100 |
|                          |                    |         |           |    |           |                 | max_wal_senders: 10->5      |
+--------------------------+--------------------+---------+-----------+----+-----------+-----------------+-----------------------------+
+ Cluster: cluster_1 (7395832102472264106) -----+---------+-----------+----+-----------+
| Member                   | Host               | Role    | State     | TL | Lag in MB |
+--------------------------+--------------------+---------+-----------+----+-----------+
| saas-uat-pgsql02 | 171.2.137.89:4554 | Leader  | running   | 10 |           |
| saas-uat-pgsql01              | 171.2.137.48:4554  | Replica | streaming | 10 |         0 |
+--------------------------+--------------------+---------+-----------+----+-----------+


5) Etcdctl shows as running but member list shows error:

Service status :
● etcd.service - Etcd Server
     Loaded: loaded (/usr/lib/systemd/system/etcd.service; enabled; preset: disabled)
     Active: active (running) since Thu 2024-10-10 14:15:33 IST; 4s ago
   Main PID: 2679015 (etcd)
      Tasks: 10 (limit: 98188)
     Memory: 7.3M
        CPU: 44ms
     CGroup: /system.slice/etcd.service
             └─2679015 /usr/bin/etcd --config-file /etc/etcd/etcd.conf.yaml


Error :
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# etcdctl member list
{"level":"warn","ts":"2024-10-10T14:16:54.444547+0530","logger":"etcd-client","caller":"v3@v3.5.15/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc000504000/127.0.0.1:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest balancer error: last connection error: connection error: desc = \"transport: Error while dialing: dial tcp 127.0.0.1:2379: connect: connection refused\""}
Error: context deadline exceeded


**** NO FIX NEEDED 

Just try to use the actual endpoints and list

[root@aws-ind-aps1-m2p-saas-uat-pgsql01 etcd]# etcdctl --endpoints=http://171.2.137.48:4114 member list
c2deeb18c5e30791, started, saas-uat-pgsql01, http://171.2.137.48:4115, http://171.2.137.48:4114, false




Oct 30 14:24:11 aws-ind-aps1-m2p-saas-uat-pgsql01.m2pfintech.com patroni[3014730]: psycopg2.OperationalError: connection to server at "localhost" (::1), port 4554 failed: FATAL:  no pg_hba.conf entry for host "::1", user "${SUPR_USER}", database "postgres", no encryption




6) Starting patroni shows the following error :
Dec 03 11:33:29 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150602]: Available implementations: etcd, etcd3, kubernetes, raft
Dec 03 11:33:29 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com systemd[1]: patroni.service: Main process exited, code=exited, status=1/FAILURE
Dec 03 11:33:29 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com systemd[1]: patroni.service: Failed with result 'exit-code'.
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com systemd[1]: Started PostgreSQL high-availability manager.
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]: 2024-12-03 11:35:24,621 INFO: Failed to import patroni.dcs.consul
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]: 2024-12-03 11:35:24,666 INFO: Failed to import patroni.dcs.exhibitor
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]: 2024-12-03 11:35:24,680 INFO: Failed to import patroni.dcs.zookeeper
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]: Traceback (most recent call last):
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]:   File "/usr/bin/patroni", line 33, in <module>
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]:     sys.exit(load_entry_point('patroni==3.3.2', 'console_scripts', 'patroni')())
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]:   File "/usr/lib/python3.9/site-packages/patroni/__main__.py", line 344, in main
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]:     return patroni_main(args.configfile)
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]:   File "/usr/lib/python3.9/site-packages/patroni/__main__.py", line 232, in patroni_main
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]:     abstract_main(Patroni, configfile)
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]:   File "/usr/lib/python3.9/site-packages/patroni/daemon.py", line 172, in abstract_main
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]:     controller = cls(config)
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]:   File "/usr/lib/python3.9/site-packages/patroni/__main__.py", line 63, in __init__
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]:     self.dcs = get_dcs(self.config)
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]:   File "/usr/lib/python3.9/site-packages/patroni/dcs/__init__.py", line 141, in get_dcs
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]:     raise PatroniFatalException("Can not find suitable configuration of distributed configuration store\n"
Dec 03 11:35:24 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com patroni[1150686]: patroni.exceptions.PatroniFatalException: Can not find suitable configuration of distributed configuration store


*** FIX ****
Verify if the patroni.yml file is with correct ownership and in the patroni.service the correct path is mentioned for patroni.yml


7) When starting the haproxy service, the status showing as following :

Dec 03 15:15:51 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com haproxy[1170697]: [WARNING]  (1170697) : Server primary/saas-uat-pgsql02 is DOWN, reason: Layer7 wrong status, code: 503, info: "Service Unavailable", check duration: 56ms. 2 active and 0 backup servers left. 0 sessions active, 0 requeued, 0 remaining in queue.
Dec 03 15:15:52 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com haproxy[1170697]: [WARNING]  (1170697) : Server primary/saas-uat-pgsql03 is DOWN, reason: Layer7 wrong status, code: 503, info: "Service Unavailable", check duration: 54ms. 1 active and 0 backup servers left. 0 sessions active, 0 requeued, 0 remaining in queue.
Dec 03 15:15:52 aws-ind-aps1-m2p-saas-uat-pgsql03.m2pfintech.com haproxy[1170697]: [WARNING]  (1170697) : Server standbys/saas-uat-pgsql01 is DOWN, reason: Layer7 wrong status, code: 503, info: "Service Unavailable", check duration: 2ms. 2 active and 0 backup servers left. 0 sessions active, 0 requeued, 0 remaining in queue.


*** NO NEED TO FIX ***
If you read the above status, it shows as 02 and 03 server as primary it is down and 01 as standby is down. This is because 01 is primary. It means our haproxy is working m2pfintech


8) If you notice SYSTEM ID Mismatch on the patroni log file like below, then it may be due to the name change in the cluster

Feb 25 13:28:32 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103027]: 2025-02-25 13:28:32,918 INFO: Reloading PostgreSQL configuration.
Feb 25 13:28:32 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103040]: server signaled
Feb 25 13:28:33 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103027]: 2025-02-25 13:28:33,982 CRITICAL: system ID mismatch, node pp-shared-uat-pgsql01 belongs to a different cluster: 7473759809225777705 != 7473759811283411618
Feb 25 13:28:34 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com systemd[1]: patroni.service: Main process exited, code=exited, status=1/FAILURE
Feb 25 13:28:34 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com systemd[1]: patroni.service: Failed with result 'exit-code'.

*** FIX ****
[root@aws-ind-aps1-m2p-pp-shared-uat01 pgsql]# patronictl -c /dbdata/patroni/patroni.yml remove -f pretty cluster_1
+ Cluster: cluster_1 (7473759809225777705) -----+
| Member | Host | Role | State | TL | Lag in MB |
+--------+------+------+-------+----+-----------+
+--------+------+------+-------+----+-----------+
Please confirm the cluster name to remove: cluster_1
You are about to remove all information in DCS for cluster_1, please type: "Yes I am aware":
You are about to remove all information in DCS for cluster_1, please type: "Yes I am aware":
You are about to remove all information in DCS for cluster_1, please type: "Yes I am aware": Yes I am aware
[root@aws-ind-aps1-m2p-pp-shared-uat01 pgsql]# patronictl -c /dbdata/patroni/patroni.yml list
+ Cluster: cluster_1 (uninitialized) -----------+
| Member | Host | Role | State | TL | Lag in MB |
+--------+------+------+-------+----+-----------+
+--------+------+------+-------+----+-----------+
[root@aws-ind-aps1-m2p-pp-shared-uat01 pgsql]# service patroni start
Redirecting to /bin/systemctl start patroni.service

Feb 25 13:39:41 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]:   Mock authentication nonce: e889f7801da2d347755fbd1303888ce7a39235e2e5330993f49384f18e18cfd7
Feb 25 13:39:41 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:39:41,035 INFO: Lock owner: None; I am pp-shared-uat-pgsql01
Feb 25 13:39:41 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:39:41,036 INFO: starting as a secondary
Feb 25 13:39:41 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103321]: 2025-02-25 13:39:41.623 IST [103321] LOG:  pgaudit extension initialized
Feb 25 13:39:41 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:39:41,642 INFO: postmaster pid=103321
Feb 25 13:39:41 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103322]: localhost:4554 - no response
Feb 25 13:39:42 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103321]: 2025-02-25 13:39:42.209 IST [103321] LOG:  redirecting log output to logging collector process
Feb 25 13:39:42 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103321]: 2025-02-25 13:39:42.209 IST [103321] HINT:  Future log output will appear in directory "log".
Feb 25 13:39:42 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:39:42,654 ERROR: postmaster is not running
Feb 25 13:39:51 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:39:51,014 INFO: Lock owner: None; I am pp-shared-uat-pgsql01
Feb 25 13:39:51 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:39:51,058 INFO: failed to start postgres
Feb 25 13:40:01 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:40:01,014 INFO: establishing a new patroni heartbeat connection to postgres
Feb 25 13:40:01 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:40:01,198 WARNING: Could not activate Linux watchdog device: Can't open watchdog device: [Errno 2] No such file or directory: '/dev/watchdog''
Feb 25 13:40:01 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:40:01,244 INFO: promoted self to leader by acquiring session lock
Feb 25 13:40:01 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103358]: server promoting
Feb 25 13:40:02 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:40:02,308 INFO: Lock owner: pp-shared-uat-pgsql01; I am pp-shared-uat-pgsql01
Feb 25 13:40:02 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:40:02,461 INFO: Dropped unknown replication slot 'slot_1'
Feb 25 13:40:02 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:40:02,505 INFO: no action. I am (pp-shared-uat-pgsql01), the leader with the lock
Feb 25 13:40:12 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:40:12,352 INFO: no action. I am (pp-shared-uat-pgsql01), the leader with the lock
Feb 25 13:40:22 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:40:22,307 INFO: no action. I am (pp-shared-uat-pgsql01), the leader with the lock
Feb 25 13:40:32 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:40:32,307 INFO: no action. I am (pp-shared-uat-pgsql01), the leader with the lock
Feb 25 13:40:42 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:40:42,307 INFO: no action. I am (pp-shared-uat-pgsql01), the leader with the lock
Feb 25 13:40:52 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:40:52,307 INFO: no action. I am (pp-shared-uat-pgsql01), the leader with the lock
Feb 25 13:41:02 aws-ind-aps1-m2p-pp-shared-uat01.m2pfintech.com patroni[103290]: 2025-02-25 13:41:02,307 INFO: no action. I am (pp-shared-uat-pgsql01), the leader with the lock


9) Patroni state shows as "Start Failed"

[root@aws-ind-aps1-m2p-pp-shared-uat01 ~]# patronictl -c /dbdata/patroni/patroni.yml list
+ Cluster: cluster_1 (7473759811283411618) -+--------+--------------+----+-----------+
| Member                | Host              | Role   | State        | TL | Lag in MB |
+-----------------------+-------------------+--------+--------------+----+-----------+
| pp-shared-uat-pgsql01 | 171.2.13.118:4554 | Leader | start failed |    |           |
+-----------------------+-------------------+--------+--------------+----+-----------+

**** FIX ****
The issue may be due to postgres checkpoint service and postmaster service started in different times or postgres service is started after patroni
1. Stop patroni
2. Start Postgres and validate
3. Start patroni and validate the status

[root@aws-ind-aps1-m2p-pp-shared-uat01 ~]# service patroni stop
Redirecting to /bin/systemctl stop patroni.service
[root@aws-ind-aps1-m2p-pp-shared-uat01 ~]# service postgresql-16 start
Redirecting to /bin/systemctl start postgresql-16.service
[root@aws-ind-aps1-m2p-pp-shared-uat01 ~]# service patroni start
Redirecting to /bin/systemctl start patroni.service
[root@aws-ind-aps1-m2p-pp-shared-uat01 ~]# patronictl -c /dbdata/patroni/patroni.yml list common
+ Cluster: common (uninitialized) --+-----------+
| Member | Host | Role | State | TL | Lag in MB |
+--------+------+------+-------+----+-----------+
+--------+------+------+-------+----+-----------+
[root@aws-ind-aps1-m2p-pp-shared-uat01 ~]# patronictl -c /dbdata/patroni/patroni.yml list
+ Cluster: cluster_1 (7473759811283411618) -+--------+---------+----+-----------+
| Member                | Host              | Role   | State   | TL | Lag in MB |
+-----------------------+-------------------+--------+---------+----+-----------+
| pp-shared-uat-pgsql01 | 171.2.13.118:4554 | Leader | running |  4 |           |
+-----------------------+-------------------+--------+---------+----+-----------+

10) SYSTEM ID Mismatch while starting Patroni

Feb 26 15:40:41 aws-ind-aps1-m2p-pp-shared-uat02.m2pfintech.com systemd[1]: patroni.service: Main process exited, code=exited, status=1/FAILURE
Feb 26 15:40:41 aws-ind-aps1-m2p-pp-shared-uat02.m2pfintech.com systemd[1]: patroni.service: Failed with result 'exit-code'.
Feb 26 15:59:19 aws-ind-aps1-m2p-pp-shared-uat02.m2pfintech.com systemd[1]: Started PostgreSQL high-availability manager.
Feb 26 15:59:20 aws-ind-aps1-m2p-pp-shared-uat02.m2pfintech.com patroni[112610]: 2025-02-26 15:59:20,611 INFO: Selected new etcd server http://171.2.13.116:4114
Feb 26 15:59:20 aws-ind-aps1-m2p-pp-shared-uat02.m2pfintech.com patroni[112610]: 2025-02-26 15:59:20,620 INFO: No PostgreSQL configuration items changed, nothing to reload.
Feb 26 15:59:20 aws-ind-aps1-m2p-pp-shared-uat02.m2pfintech.com patroni[112610]: 2025-02-26 15:59:20,681 CRITICAL: system ID mismatch, node pp-shared-uat-pgsql02 belongs to a different cluster: 7473759811283411618 != 7473759809225777705


**** FIX ****

Stop the Patroni service and then postgres service
Rename the existing postgres data directory
Create a new directory on the same name and provide ownership to postgres
Start the postgres service and then Patroni service

Feb 27 12:02:36 aws-ind-aps1-m2p-pp-shared-uat02.m2pfintech.com systemd[1]: Started PostgreSQL high-availability manager.
Feb 27 12:02:37 aws-ind-aps1-m2p-pp-shared-uat02.m2pfintech.com patroni[120232]: 2025-02-27 12:02:37,386 INFO: Selected new etcd server http://171.2.13.104:4114
Feb 27 12:02:37 aws-ind-aps1-m2p-pp-shared-uat02.m2pfintech.com patroni[120232]: 2025-02-27 12:02:37,397 INFO: No PostgreSQL configuration items changed, nothing to reload.
Feb 27 12:02:37 aws-ind-aps1-m2p-pp-shared-uat02.m2pfintech.com patroni[120241]: localhost:4554 - accepting connections
Feb 27 12:02:37 aws-ind-aps1-m2p-pp-shared-uat02.m2pfintech.com patroni[120232]: 2025-02-27 12:02:37,425 INFO: establishing a new patroni heartbeat connection to postgres
Feb 27 12:02:37 aws-ind-aps1-m2p-pp-shared-uat02.m2pfintech.com patroni[120248]: server signaled
Feb 27 12:02:37 aws-ind-aps1-m2p-pp-shared-uat02.m2pfintech.com patroni[120232]: 2025-02-27 12:02:37,594 INFO: no action. I am (pp-shared-uat-pgsql02), a secondary, and following a leader (
  




=============================================================
etcdctl and patronictl commands

 To list the REST API config keys
[root@saas-uat-pgsql01 ~]# etcdctl --endpoints=http://171.2.137.48:4114,http://171.2.137.118:4114,http://171.2.137.89:4114 get / --prefix --keys-only
/percona_pg_cluster/cluster_1/config

/percona_pg_cluster/cluster_1/history

/percona_pg_cluster/cluster_1/initialize

/percona_pg_cluster/cluster_1/leader

/percona_pg_cluster/cluster_1/members/saas-uat-pgsql02

/percona_pg_cluster/cluster_1/members/saas-uat-pgsql01

/percona_pg_cluster/cluster_1/status

========================================================================================================
Check health status of endpoints:
========================================================================================================
etcdctl --endpoints=http://171.2.137.48:4114,http://171.2.137.118:4114,http://171.2.137.89:4114 endpoint health --write-out=table
+---------------------------+--------+------------+-------+
|         ENDPOINT          | HEALTH |    TOOK    | ERROR |
+---------------------------+--------+------------+-------+
|  http://171.2.137.48:4114 |   true | 2.046648ms |       |
| http://171.2.137.118:4114 |   true | 2.806013ms |       |
|  http://171.2.137.89:4114 |   true | 4.384403ms |       |
+---------------------------+--------+------------+-------+

========================================================================================================
Check status of endpoints:
========================================================================================================
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# etcdctl --endpoints=http://171.2.137.48:4114,http://171.2.137.118:4114,http://171.2.137.89:4114 endpoint status --write-out=table
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|  http://171.2.137.48:4114 | c2deeb18c5e30791 |  3.5.15 |  180 kB |      true |      false |         6 |        751 |                751 |        |
| http://171.2.137.118:4114 | 9ff3ee256a82a482 |  3.5.15 |  180 kB |     false |      false |         6 |        751 |                751 |        |
|  http://171.2.137.89:4114 | fad6f777e8e7b895 |  3.5.15 |  180 kB |     false |      false |         6 |        751 |                751 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

========================================================================================================
Check performance of the cluster via etcdctl:
========================================================================================================
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# etcdctl --endpoints=http://171.2.137.48:4114,http://171.2.137.118:4114,http://171.2.137.89:4114 check perf
 59 / 60 Booooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooom  !  98.33%PASS: Throughput is 151 writes/s
PASS: Slowest request took 0.012829s
PASS: Stddev is 0.000767s
PASS

To view the configuration settings of PostgreSQL via patronictl
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# patronictl -c /dbdata/patroni/patroni.yml show-config
loop_wait: 10
maximum_lag_on_failover: 1048576
postgresql:
  parameters:
    archive_command: cp -f %p /dbdata/archive/%f
    archive_mode: 'on'
    archive_timeout: 600s
    hot_standby: 'on'
    logging_collector: 'on'
    max_connections: 10000
    max_replication_slots: 10
    max_wal_senders: 10
    max_wal_size: 10GB
    wal_keep_segments: 10
    wal_level: replica
    wal_log_hints: 'on'
  use_pg_rewind: true
  use_slots: true
retry_timeout: 10
ttl: 30

========================================================================================================
To edit the PG config via patronictl
========================================================================================================
patronictl -c /dbdata/patroni/patroni.yml edit-config

========================================================================================================
To list the members of cluster:
========================================================================================================
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# patronictl -c /dbdata/patroni/patroni.yml list
+ Cluster: cluster_1 (7423827110618237317) -------+-----------+----+-----------+
| Member           | Host               | Role    | State     | TL | Lag in MB |
+------------------+--------------------+---------+-----------+----+-----------+
| saas-uat-pgsql01 | 171.2.137.48:4554  | Leader  | running   | 13 |           |
| saas-uat-pgsql02 | 171.2.137.89:4554  | Replica | streaming | 13 |         0 |
| saas-uat-pgsql03 | 171.2.137.118:4554 | Replica | streaming | 13 |         0 |
+------------------+--------------------+---------+-----------+----+-----------+

========================================================================================================
To check if any change happened in Primary role:
========================================================================================================
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# patronictl -c /dbdata/patroni/patroni.yml history
+----+-----------+------------------------------+----------------------------------+------------------+
| TL |       LSN | Reason                       | Timestamp                        | New Leader       |
+----+-----------+------------------------------+----------------------------------+------------------+
|  1 | 167772320 | no recovery target specified | 2024-10-30T15:48:58.087386+05:30 | saas-uat-pgsql01 |
|  2 | 285212832 | no recovery target specified | 2024-12-01T22:41:07.032674+05:30 | saas-uat-pgsql01 |
|  3 | 301990048 | no recovery target specified | 2024-12-01T22:49:29.556527+05:30 | saas-uat-pgsql01 |
|  4 | 318767264 | no recovery target specified | 2024-12-01T22:52:18.710944+05:30 | saas-uat-pgsql01 |
|  5 | 335544480 | no recovery target specified | 2024-12-01T22:53:49.815866+05:30 | saas-uat-pgsql01 |
|  6 | 352321696 | no recovery target specified | 2024-12-01T22:56:08.459763+05:30 | saas-uat-pgsql01 |
|  7 | 369098912 | no recovery target specified | 2024-12-01T22:59:24.171824+05:30 | saas-uat-pgsql01 |
|  8 | 385876128 | no recovery target specified | 2024-12-01T23:00:52.314642+05:30 | saas-uat-pgsql01 |
|  9 | 402653344 | no recovery target specified | 2024-12-01T23:03:34.525039+05:30 | saas-uat-pgsql01 |
| 10 | 419430560 | no recovery target specified | 2024-12-01T23:13:34.722688+05:30 | saas-uat-pgsql01 |
| 11 | 520093856 | no recovery target specified | 2024-12-02T12:01:11.846800+05:30 | saas-uat-pgsql01 |
| 12 | 587202720 | no recovery target specified | 2024-12-02T12:17:47.923990+05:30 | saas-uat-pgsql01 |
+----+-----------+------------------------------+----------------------------------+------------------+

========================================================================================================
To failover the primary role from one node to another with manual intervention
========================================================================================================
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# patronictl -c /dbdata/patroni/patroni.yml list
+ Cluster: cluster_1 (7423827110618237317) -------+-----------+----+-----------+
| Member           | Host               | Role    | State     | TL | Lag in MB |
+------------------+--------------------+---------+-----------+----+-----------+
| saas-uat-pgsql01 | 171.2.137.48:4554  | Leader  | running   | 13 |           |
| saas-uat-pgsql02 | 171.2.137.89:4554  | Replica | streaming | 13 |         0 |
| saas-uat-pgsql03 | 171.2.137.118:4554 | Replica | streaming | 13 |         0 |
+------------------+--------------------+---------+-----------+----+-----------+
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# patronictl -c /dbdata/patroni/patroni.yml failover
Current cluster topology
+ Cluster: cluster_1 (7423827110618237317) -------+-----------+----+-----------+
| Member           | Host               | Role    | State     | TL | Lag in MB |
+------------------+--------------------+---------+-----------+----+-----------+
| saas-uat-pgsql01 | 171.2.137.48:4554  | Leader  | running   | 13 |           |
| saas-uat-pgsql02 | 171.2.137.89:4554  | Replica | streaming | 13 |         0 |
| saas-uat-pgsql03 | 171.2.137.118:4554 | Replica | streaming | 13 |         0 |
+------------------+--------------------+---------+-----------+----+-----------+
Candidate ['saas-uat-pgsql02', 'saas-uat-pgsql03'] []: saas-uat-pgsql02
Are you sure you want to failover cluster cluster_1, demoting current leader saas-uat-pgsql01? [y/N]: y
2024-12-03 13:50:06.23776 Successfully failed over to "saas-uat-pgsql02"

[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# patronictl -c /dbdata/patroni/patroni.yml list
+ Cluster: cluster_1 (7423827110618237317) -------+-----------+----+-----------+
| Member           | Host               | Role    | State     | TL | Lag in MB |
+------------------+--------------------+---------+-----------+----+-----------+
| saas-uat-pgsql01 | 171.2.137.48:4554  | Replica | running   | 13 |         0 |
| saas-uat-pgsql02 | 171.2.137.89:4554  | Leader  | running   | 14 |           |
| saas-uat-pgsql03 | 171.2.137.118:4554 | Replica | streaming | 14 |         0 |
+------------------+--------------------+---------+-----------+----+-----------+

========================================================================================================
To failover the primary role from one node to another by mentioning the member
========================================================================================================
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# patronictl -c /dbdata/patroni/patroni.yml switchover --candidate saas-uat-pgsql01
Current cluster topology
+ Cluster: cluster_1 (7423827110618237317) -------+-----------+----+-----------+
| Member           | Host               | Role    | State     | TL | Lag in MB |
+------------------+--------------------+---------+-----------+----+-----------+
| saas-uat-pgsql01 | 171.2.137.48:4554  | Replica | running   | 13 |         0 |
| saas-uat-pgsql02 | 171.2.137.89:4554  | Leader  | running   | 14 |           |
| saas-uat-pgsql03 | 171.2.137.118:4554 | Replica | streaming | 14 |         0 |
+------------------+--------------------+---------+-----------+----+-----------+
Primary [saas-uat-pgsql02]:
When should the switchover take place (e.g. 2024-12-03T14:55 )  [now]: now
Are you sure you want to switchover cluster cluster_1, demoting current leader saas-uat-pgsql02? [y/N]: y
2024-12-03 13:55:31.00840 Successfully switched over to "saas-uat-pgsql01"
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# patronictl -c /dbdata/patroni/patroni.yml list
+ Cluster: cluster_1 (7423827110618237317) -------+---------+----+-----------+
| Member           | Host               | Role    | State   | TL | Lag in MB |
+------------------+--------------------+---------+---------+----+-----------+
| saas-uat-pgsql01 | 171.2.137.48:4554  | Leader  | running | 14 |           |
| saas-uat-pgsql02 | 171.2.137.89:4554  | Replica | running | 14 |         0 |
| saas-uat-pgsql03 | 171.2.137.118:4554 | Replica | running | 14 |         0 |
+------------------+--------------------+---------+---------+----+-----------+

========================================================================================================
To check history after failover 
========================================================================================================
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# patronictl -c /dbdata/patroni/patroni.yml history
+----+-----------+------------------------------+----------------------------------+------------------+
| TL |       LSN | Reason                       | Timestamp                        | New Leader       |
+----+-----------+------------------------------+----------------------------------+------------------+
|  1 | 167772320 | no recovery target specified | 2024-10-30T15:48:58.087386+05:30 | saas-uat-pgsql01 |
|  2 | 285212832 | no recovery target specified | 2024-12-01T22:41:07.032674+05:30 | saas-uat-pgsql01 |
|  3 | 301990048 | no recovery target specified | 2024-12-01T22:49:29.556527+05:30 | saas-uat-pgsql01 |
|  4 | 318767264 | no recovery target specified | 2024-12-01T22:52:18.710944+05:30 | saas-uat-pgsql01 |
|  5 | 335544480 | no recovery target specified | 2024-12-01T22:53:49.815866+05:30 | saas-uat-pgsql01 |
|  6 | 352321696 | no recovery target specified | 2024-12-01T22:56:08.459763+05:30 | saas-uat-pgsql01 |
|  7 | 369098912 | no recovery target specified | 2024-12-01T22:59:24.171824+05:30 | saas-uat-pgsql01 |
|  8 | 385876128 | no recovery target specified | 2024-12-01T23:00:52.314642+05:30 | saas-uat-pgsql01 |
|  9 | 402653344 | no recovery target specified | 2024-12-01T23:03:34.525039+05:30 | saas-uat-pgsql01 |
| 10 | 419430560 | no recovery target specified | 2024-12-01T23:13:34.722688+05:30 | saas-uat-pgsql01 |
| 11 | 520093856 | no recovery target specified | 2024-12-02T12:01:11.846800+05:30 | saas-uat-pgsql01 |
| 12 | 587202720 | no recovery target specified | 2024-12-02T12:17:47.923990+05:30 | saas-uat-pgsql01 |
| 13 | 788529312 | no recovery target specified | 2024-12-03T13:50:05.655694+05:30 | saas-uat-pgsql02 |
+----+-----------+------------------------------+----------------------------------+------------------+


========================================================================================================
To obtain primary node status using curl command 
========================================================================================================
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# curl -s -o /dev/null -w "%{http_code} - %{url_effective}\n" http://saas-uat-pgsql03:4343/replica
200 - http://saas-uat-pgsql03:4343/replica
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# curl -s -o /dev/null -w "%{http_code} - %{url_effective}\n" http://saas-uat-pgsql02:4343/replica
503 - http://saas-uat-pgsql02:4343/replica
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# curl -s -o /dev/null -w "%{http_code} - %{url_effective}\n" http://saas-uat-pgsql01:4343/replica
200 - http://saas-uat-pgsql01:4343/replica
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# curl -s -o /dev/null -w "%{http_code} - %{url_effective}\n" http://saas-uat-pgsql01:4343/primary
503 - http://saas-uat-pgsql01:4343/primary
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# curl -s -o /dev/null -w "%{http_code} - %{url_effective}\n" http://saas-uat-pgsql02:4343/primary
200 - http://saas-uat-pgsql02:4343/primary
[root@aws-ind-aps1-m2p-saas-uat-pgsql01 ~]# curl -s -o /dev/null -w "%{http_code} - %{url_effective}\n" http://saas-uat-pgsql03:4343/primary
503 - http://saas-uat-pgsql03:4343/primary




[root@saas-uat-pgsql01 ~]# etcdctl --endpoints=http://171.2.137.48:4114 get /percona_pg_cluster/cluster_1/config
/percona_pg_cluster/cluster_1/config
{"loop_wait":10,"maximum_lag_on_failover":1048576,"postgresql":{"parameters":{"archive_command":"cp -f %p /dbdata/archive/%f","archive_mode":"on","archive_timeout":"600s","hot_standby":"on","logging_collector":"on","max_replication_slots":10,"max_connections":10000,"max_wal_senders":10,"max_wal_size":"10GB","wal_keep_segments":10,"wal_level":"replica","wal_log_hints":"on"},"use_pg_rewind":true,"use_slots":true},"retry_timeout":10,"ttl":30}

[root@saas-uat-pgsql01 ~]# etcdctl --endpoints=http://171.2.137.48:4114,http://171.2.137.118:4114,http://171.2.137.89:4114 get /percona_pg_cluster/cluster_1/members/saas-uat-pgsql02
/percona_pg_cluster/cluster_1/members/saas-uat-pgsql02
{"conn_url":"postgres://171.2.137.89:4554/postgres","api_url":"http://171.2.137.89:4343/patroni","state":"running","role":"master","version":"3.3.0","xlog_location":285212672,"timeline":12}

[root@saas-uat-pgsql01 ~]# etcdctl --endpoints=http://171.2.137.48:4114,http://171.2.137.118:4114,http://171.2.137.89:4114 get /percona_pg_cluster/cluster_1/members/saas-uat-pgsql01
/percona_pg_cluster/cluster_1/members/saas-uat-pgsql01
{"conn_url":"postgres://171.2.137.48:4554/postgres","api_url":"http://171.2.137.48:4343/patroni","state":"running","role":"replica","version":"3.3.0","xlog_location":285212672,"replication_state":"streaming","timeline":12}


[root@saas-uat-pgsql01 ~]# etcdctl --endpoints=http://171.2.137.48:4114,http://171.2.137.118:4114,http://171.2.137.89:4114 get /percona_pg_cluster/cluster_1/members/saas-uat-pgsql01
/percona_pg_cluster/cluster_1/members/saas-uat-pgsql01
{"conn_url":"postgres://171.2.137.48:4554/postgres","api_url":"http://171.2.137.48:4343/patroni","state":"running","role":"master","version":"3.3.0","xlog_location":301990328,"timeline":13}

[root@saas-uat-pgsql01 ~]# etcdctl --endpoints=http://171.2.137.48:4114,http://171.2.137.118:4114,http://171.2.137.89:4114 get /percona_pg_cluster/cluster_1/members/saas-uat-pgsql02
/percona_pg_cluster/cluster_1/members/saas-uat-pgsql02
{"conn_url":"postgres://171.2.137.89:4554/postgres","api_url":"http://171.2.137.89:4343/patroni","state":"running","role":"replica","version":"3.3.0","xlog_location":301990328,"replication_state":"streaming","timeline":13}


-- To verify HA Proxy configuration

[root@saas-uat-pgsql03 ~]# haproxy -c -f /etc/haproxy/haproxy.cfg
Configuration file is valid

-- To schedule failover
[root@saas-uat-pgsql01 ~]# patronictl -c /data/patroni/patroni.yml switchover --candidate saas-uat-pgsql01
Current cluster topology
+ Cluster: cluster_1 (7395832102472264106) -----+---------+-----------+----+-----------+
| Member                   | Host               | Role    | State     | TL | Lag in MB |
+--------------------------+--------------------+---------+-----------+----+-----------+
| saas-uat-pgsql02 | 171.2.137.89:4554 | Replica | streaming | 16 |         0 |
| saas-uat-pgsql03 | 171.2.137.118:4554 | Leader  | running   | 16 |           |
| saas-uat-pgsql01              | 171.2.137.48:4554  | Replica | streaming | 16 |         0 |
+--------------------------+--------------------+---------+-----------+----+-----------+
Primary [saas-uat-pgsql03]: saas-uat-pgsql03
When should the switchover take place (e.g. 2024-09-06T23:45 )  [now]: 2024-09-06T23:48
Are you sure you want to schedule switchover of cluster cluster_1 at 2024-09-06T23:48:00+05:30, demoting current leader saas-uat-pgsql03? [y/N]: n
Error: Aborting scheduled switchover



