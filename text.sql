172.179.10.75
172.179.11.44
172.179.12.157

/dbdata01/mongo
/dberrlog/mongo


auditLog:
  destination: file
  format: JSON
  path: /dberrlog/mongo/audit/audit.json


rs.initiate(
{
_id: "mongo-cluster",
version: 1,
members: [
{ _id: 0, host : "172.179.10.75:22000" },
{ _id: 1, host : "172.179.11.44:22000" },
{ _id: 2, host : "172.179.12.157:22000" }
]
}
)






#KOTAK_BNPL
#!/bin/bash
TIMESTAMP=$(date +"%F")
DATE=$(date  --date="yesterday" +"%Y-%m-%d")
TODAY=`date +"%d%b%Y_%I:%M:%S%p"`
ALL_BACKUPS="/dbbackup/daily_backup/"
BACKUP_DIR="/dbbackup/daily_backup/$TIMESTAMP"
MONGO=/usr/bin/mongo
MONGODUMP=/usr/bin/mongodump
MONGO_USER="db2dba"
MONGO_PASSWORD="Smhnn@123"
PORT=22000

mkdir $BACKUP_DIR

cd $BACKUP_DIR

#databases=`$MONGO -h $HOST --user=$MYSQL_USER -p$MONGO_USER -pMONGO_PASSWORD -e "SHOW DATABASES;"`

#$MONGODUMP --user=$MONGO_USER -p$MONGO_PASSWORD -h $HOST --authenticationDatabase admin > "$BACKUP_DIR"
$MONGODUMP --host $HOST --username $MONGO_USER --password $MONGO_PASSWORD --authenticationDatabase admin --port $PORT --out $BACKUP_DIR

#tar -cvzf $BACKUP_DIR/$db.tar.gz $db.sql
#rm -rf $BACKUP_DIR/$db.sql
aws s3 sync $ALL_BACKUPS s3://m2p-s3-prd-db-bkp/DB-BACKUP/PROD/mongo/FRM/
rm -rf $ALL_BACKUPS/$DATE
