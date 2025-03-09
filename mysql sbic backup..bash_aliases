#! /bin/bash

TIMESTAMP=$(date +"%F")
TODAY=`date +"%d%b%Y_%I:%M:%S%p"`
ALL_BACKUPS="/backup/dailybkp/"
HOST=`hostname`
BACKUP_DIR="/backup/dailybkp/$TIMESTAMP"
S3_DIR="s3://073279529465-db-backup/DB-BACKUP/MYSQL/${HOST}/"
>/tmp/bkp_sync-succ.txt
>/tmp/bkp_sync-err.txt
MYSQL=/bin/mysql
MYSQLDUMP=/bin/mysqldump
MYSQL_USER="bkpadmin"
MYSQL_PASSWORD=`cat /backup/scripts/secret1.txt | openssl enc -aes-256-cbc -md sha512 -a -d -salt -pass pass:Secret@123#`
HOST="127.0.0.1"
PORT="2201"

if [ -d $BACKUP_DIR ]
  then
    mv $BACKUP_DIR ${BACKUP_DIR}_$TODAY
    mkdir -p $BACKUP_DIR
    cd $BACKUP_DIR
  else
    mkdir -p $BACKUP_DIR
    cd $BACKUP_DIR
fi

touch ${BACKUP_DIR}/Backup-Report.txt
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> ${BACKUP_DIR}/Backup-Report.txt
echo "Backed-up started at : `date`" >> ${BACKUP_DIR}/Backup-Report.txt

databases=`$MYSQL -h $HOST --port=$PORT --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;"| grep -Ev "(Database|information_schema|performance_schema|sys)"`

for db in $databases

        do
                $MYSQLDUMP --user=$MYSQL_USER -p$MYSQL_PASSWORD -h $HOST --port=$PORT -q --single-transaction=TRUE --skip-column-statistics --log-error=${BACKUP_DIR}/dump_logs.out --set-gtid-purged=OFF --f
orce --opt --databases $db |gzip > "$BACKUP_DIR/$db.gz"
                if [ $? -ne 0 ]; then
           /bin/aws ses send-email --from sbic-backup@m2pfintech.com --to database.engineering@m2pfintech.com --text "Backup Failure on SBIC Prod FRM MySQL Server"  --subject "SBIC Prod FRM MySQL Backup er
ror" --profile backup --region ap-south-1
           exit 1
        fi
        echo "backup successful for : $db"
        done

echo "Backed-up ended at : `date`" >> ${BACKUP_DIR}/Backup-Report.txt
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> ${BACKUP_DIR}/Backup-Report.txt
echo "Backup file synch started at : `date`" >> ${BACKUP_DIR}/Backup-Report.txt
/bin/aws s3 sync $ALL_BACKUPS $S3_DIR >>/tmp/bkp_sync-succ.txt 2>/tmp/bkp_sync-err.txt --profile backup
     if [ $? -eq 0 ]; then
        cat /tmp/bkp_sync-succ.txt >> ${BACKUP_DIR}/Backup-Report.txt
        echo "Backup file synch ended   at : `date`" >> ${BACKUP_DIR}/Backup-Report.txt
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> ${BACKUP_DIR}/Backup-Report.txt
        find $ALL_BACKUPS -mtime +2 -exec rm -rvf {} \; >> ${BACKUP_DIR}/Backup-Report.txt
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> ${BACKUP_DIR}/Backup-Report.txt
     else
          cat /tmp/bkp_sync-err.txt >> ${BACKUP_DIR}/Backup-Report.txt
          /bin/aws ses send-email --from sbic-backup@m2pfintech.com --to database.engineering@m2pfintech.com --text "Backup image S3 sync error"  --subject "SBIC Prod FRM MySQL Backup S3 Sync error" --prof
ile backup --region ap-south-1
      fi

cat ${BACKUP_DIR}/Backup-Report.txt > /backup/Reports/My_FRM_Backup-Report_$TIMESTAMP.txt
chmod 644 /backup/Reports/My_FRM_Backup-Report_$TIMESTAMP.txt