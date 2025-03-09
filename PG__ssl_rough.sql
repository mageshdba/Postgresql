EN

BLOG
Cybertec Logo

Services
Support
Products
Training
PostgreSQL
Data Science
Contact
SETTING UP SSL AUTHENTICATION FOR POSTGRESQL
Posted on 2021-03-18 by Hans-Jürgen Schönig
encryption openssl postgres postgresql ssl
PostgreSQL is a secure database and we want to keep it that way. It makes sense, then, to consider SSL to encrypt the connection between client and server. This posting will help you to set up SSL authentication for PostgreSQL properly, and hopefully also to understand some background information to make your database more secure.

SSL authetication with PostgreSQL

At the end of this post, you should be able to configure PostgreSQL and handle secure client server connections in the easiest way possible.

Configuring PostgreSQL for OpenSSL
The first thing we have to do to set up OpenSSL is to change postgresql.conf. There are a couple of parameters which are related to encryption:


ssl = on
#ssl_ca_file = ''
#ssl_cert_file = 'server.crt'
#ssl_crl_file = ''
#ssl_key_file = 'server.key'
#ssl_ciphers = 'HIGH:MEDIUM:+3DES:!aNULL' # allowed SSL ciphers
#ssl_prefer_server_ciphers = on
#ssl_ecdh_curve = 'prime256v1'
#ssl_min_protocol_version = 'TLSv1.2'
#ssl_max_protocol_version = ''
#ssl_dh_params_file = ''
#ssl_passphrase_command = ''
#ssl_passphrase_command_supports_reload = off
Once ssl = on, the server will negotiate SSL connections in case they are possible. The remaining parameters define the location of key files, the strength of the ciphers and so on. Please note that turning SSL on does not require a database restart. The variable can be set with a plain reload. However, you will still need a restart otherwise PostgreSQL will not accept SSL connections. This is an important point causing problems quite frequently for some users:

postgres=# SELECT pg_reload_conf();
  pg_reload_conf
----------------
  t
(1 row)
 
postgres=# SHOW ssl;
  ssl
-----
  on
(1 row)
The SHOW command is an easy way to make sure that the setting has indeed been changed. Technically, pg_reload_conf() is not needed at this stage. It is necessary to restart later anyway. We just reloaded to show the effect on the variable.

In the next step we have to adjust pg_hba.conf to ensure that PostgreSQL will handle our connections in a secure way:

# TYPE    DATABASE     USER      ADDRESS           METHOD
 
# "local" is for Unix domain socket connections only
local     all          all                         peer
host      all          all       127.0.0.1/32      scram-sha-256
host      all          all       ::1/128           scram-sha-256
hostssl   all          all       10.0.3.0/24       scram-sha-256
Then restart the database instance to make sure SSL is enabled.

The next thing you have to do is to create certificates. In order to keep things simple, we will simply create self-signed certificates here. However, it is of course also possible with other certificates are. Here is how it works:


[postgres@node1 data]$ openssl req -new -x509 -days 365 \
     -nodes -text -out server.crt \
     -keyout server.key \
     -subj "/CN=cybertec-postgresql.com"

Generating a RSA private key
.......+++++
....................................................+++++
writing new private key to 'server.key'
-----
This certificate will be valid for 365 days. 
Next we have to set permissions to ensure the certificate can be used. 
If those permissions are too relaxed, the server will not accept the certificate:

1
[postgres@node1 data]$ chmod og-rwx server.key
Self-signed certificates are nice. 
However, to create a server certificate whose identity and origin can be validated by clients, first create a certificate signing request and a public/private key file:

[postgres@node1 data]$ openssl req -new -nodes -text \
     -out root.csr \
     -keyout root.key \
     -subj "/CN=cybertec-postgresql.com"
Generating a RSA private key
.................................+++++
....................+++++
writing new private key to 'root.key'
-----

Again, we have to make sure that those permissions are exactly the way they should be:

1
[postgres@node1 data]$ chmod og-rwx root.key
Then we sign the request. To do that with OpenSSL, we first have to find out where openssl.cnf can be found. We have seen that it is not always in the same place – so make sure you are using the right path:


[postgres@node1 data]$ find / -name openssl.cnf \
     2> /dev/null
/etc/pki/tls/openssl.cnf
/etc/pki/tls/openssl.cnf
We use this path when we sign the request:


[postgres@node1 data]$ openssl x509 -req -in root.csr \
     -text \
     -days 3650 \
     -extfile /etc/pki/tls/openssl.cnf \
     -extensions v3_ca \
     -signkey root.key -out root.crt
Signature ok
subject=CN = cybertec-postgresql.com
Getting Private key
Let’s create the certificate with the new root authority:

[postgres@node1 data]$ openssl req -new -nodes -text \
     -out server.csr \
     -keyout server.key \
     -subj "/CN=cybertec-postgresql.com"
Generating a RSA private key
.....................+++++
...........................+++++
writing new private key to 'server.key'
[postgres@node1 data]$ chmod og-rwx server.key
[postgres@node1 data]$ openssl x509 -req \
     -in server.csr -text -days 365 \
     -CA root.crt -CAkey root.key -CAcreateserial \
     -out server.crt
Signature ok
subject=CN = cybertec-postgresql.com

Getting CA Private Key
server.crt and server.key should be stored on the server in your data directory as configured on postgresql.conf.

But there is more: root.crt should be stored on the client so the client can verify that the server’s certificate was signed by the certification authority. root.key should be stored offline for use in creating future certificates.


 chown -R postgres:postgres root.crt root.csr root.key root.srl server.crt server.csr server.key
 chmod og-rwx root.crt root.csr root.key root.srl server.crt server.csr server.key

The following files are needed:

File name	Purpose of the file	Remarks
ssl_cert_file ($PGDATA/server.crt)	server certificate	sent to client to indicate server’s identity
ssl_key_file ($PGDATA/server.key)	server private key	proves server certificate was sent by the owner; does not indicate certificate owner is trustworthy
ssl_ca_file	trusted certificate authorities	checks that client certificate is signed by a trusted certificate authority
ssl_crl_file	certificates revoked by certificate authorities	client certificate must not be on this list
Checking your setup
Now that all the certificates are in place it is time to restart the servers:

1
[root@node1 ~]# systemctl restart postgresql-13
Without a restart, the connection would fail with an error message (“psql: error: FATAL: no pg_hba.conf entry for host "10.0.3.200", user "postgres", database "test", SSL off”).

However, after the restart, the process should work as expected:


[root@node1 ~]# su - postgres
[postgres@node1 ~]$ psql test -h 10.0.3.200
Password for user postgres:
psql (13.2)
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.
 
test=#
psql indicates that the connection is encrypted. To figure out if the connection is indeed encrypted, we need to check the content of pg_stat_ssl:

postgres=# \d pg_stat_ssl
 
View "pg_catalog.pg_stat_ssl"
Column          | Type    | Collation | Nullable | Default
----------------+---------+-----------+----------+---------
pid             | integer |           |          |
ssl             | boolean |           |          |
version         | text    |           |          |
cipher          | text    |           |          |
bits            | integer |           |          |
compression     | boolean |           |          |
client_dn       | text    |           |          |
client_serial   | numeric |           |          |
issuer_dn       | text    |           |          |
Let us query the system view and see what it contains:

test=# \x
Expanded display is on.
test=# SELECT * FROM pg_stat_ssl;
-[ RECORD 1 ]-+-----------------------
pid           | 16378
ssl           | t
version       | TLSv1.3
cipher        | TLS_AES_256_GCM_SHA384
bits          | 256
compression   | f
client_dn     |
client_serial |
issuer_dn     |
The connection has been successfully encrypted. If “ssl = true”, then we have succeeded.

Different levels of SSL supported by PostgreSQL
Two SSL setups are not necessarily identical. There are various levels which allow you to control the desired level of security and protection. The following table outlines those SSL modes as supported by PostgreSQL:


sslmode	
Eavesdropping protection	
MITM (= man in the middle) protection	
Statement
disable	No	No	No SSL, no encryption and thus no overhead.
allow	Maybe	No	The client attempts an unencrypted connection, but uses an encrypted connection if the server insists.
prefer	Maybe	No	The reverse of the “allow” mode: the client attempts an encrypted connection, but uses an unencrypted connection if the server insists.
require	Yes	No	Data should be encrypted and the overhead of doing so is accepted. The network is trusted and will send me to the desired server.
verify-ca	Yes	Depends on CA policy	Data must be encrypted. Systems must be doubly sure that the connection to the right server is established.
verify-full	Yes	Yes	Strongest protection possible. Full encryption and full validation of the desired target server.
 

The overhead really depends on the mode you are using. First let’s take a look at the general mechanism:

 SSL authentication with postgresql

The main question now is: How does one specify the mode to be used? The answer is: It has to be hidden as part of the connect string as shown in the next example:

1
2
3
[postgres@node1 data]$ psql "dbname=test host=10.0.3.200 user=postgres password=1234 sslmode=verify-ca"
psql: error: root certificate file "/var/lib/pgsql/.postgresql/root.crt" does not exist
Either provide the file or change sslmode to disable server certificate verification.
In this case, verify-ca does not work because to do that the root.* files have to be copied to the client, and the certificates have to be ones which allow for proper validation of the target server.

Encrypting your entire server: PostgreSQL TDE
So far, you have learned how to encrypt the connection between client and server. However, sometimes it is necessary to encrypt the entire server, including storage. PostgreSQL TDE does exactly that:

Transparent Data Encryption of PostgreSQL 

To find out more, check out our website about PostgreSQL TDE. We offer a fully encrypted stack to help you achieve maximum security. PostgreSQL TDE is available for free (Open Source).

What might also interest you …
Materialized views are an important feature in most databases, including PostgreSQL. They can help to speed up large calculations, or at least to cache them.

=======
