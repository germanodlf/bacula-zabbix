#!/bin/bash

# Import configuration file
source bacula_zabbix.conf

# Chose which database command to use
case $baculaDbSgdb in
  P) sql="PGPASSWORD=$baculaDbPass /usr/bin/psql -h$baculaDbAddr -p$baculaDbPort -U$baculaDbUser -d$baculaDbName -c" ;;
  M) sql="/usr/bin/mysql -NB -h$baculaDbAddr -P$baculaDbPort -u$baculaDbUser -p$baculaDbPass -D$baculaDbName -e" ;;
  *) exit 1 ;;
esac

# Get Job ID from parameter
baculaJobId="$1"

# Get Job type from database, then if it is a backup job, proceed, if not, exit
baculaJobType=$($sql "select Type from Job where JobId=$baculaJobId;")
if [ "$baculaJobType" != "B" ] ; then exit 2 ; fi

# Get Job level from database and classify it as Full, Differential, or Incremental
baculaJobLevel=$($sql "select Level from Job where JobId=$baculaJobId;")
case $baculaJobLevel in
  'F') level='full' ;;
  'D') level='diff' ;;
  'I') level='incr' ;;
  *)   exit 3 ;;
esac

# Get Job exit status from database and classify it as OK, OK with warnings, or Fail
baculaJobStatus=$($sql "select JobStatus from Job where JobId=$baculaJobId;")
case $baculaJobStatus in
  "T") status=0 ;;
  "W") status=1 ;;
  *)   status=2 ;;
esac

# Get client's name from database
baculaClientName=$($sql "select Client.Name from Client,Job where Job.ClientId=Client.ClientId and Job.JobId=$baculaJobId;")

# Send Job exit status to Zabbix server
$zabbixSender -z $zabbixSrvAddr -p $zabbixSrvPort -s $baculaClientName -k "bacula.$level.job.status" -o $status

# Get from database the number of bytes transferred by the Job and send it to Zabbix server
baculaJobBytes=$($sql "select JobBytes from Job where JobId=$baculaJobId;")
$zabbixSender -z $zabbixSrvAddr -p $zabbixSrvPort -s $baculaClientName -k "bacula.$level.job.bytes" -o $baculaJobBytes

# Get from database the number of files transferred by the Job and send it to Zabbix server
baculaJobFiles=$($sql "select JobFiles from Job where JobId=$baculaJobId;")
$zabbixSender -z $zabbixSrvAddr -p $zabbixSrvPort -s $baculaClientName -k "bacula.$level.job.files" -o $baculaJobFiles

# Get from database the time spent by the Job and send it to Zabbix server
baculaJobTime=$($sql "select timestampdiff(second,StartTime,EndTime) from Job where JobId=$baculaJobId;")
$zabbixSender -z $zabbixSrvAddr -p $zabbixSrvPort -s $baculaClientName -k "bacula.$level.job.time" -o $baculaJobTime

# Get Job speed from database and send it to Zabbix server
baculaJobSpeed=$($sql "select round(JobBytes/timestampdiff(second,StartTime,EndTime)/1024,2) from Job where JobId=$baculaJobId;")
$zabbixSender -z $zabbixSrvAddr -p $zabbixSrvPort -s $baculaClientName -k "bacula.$level.job.speed" -o $baculaJobSpeed

# Get Job compression rate from database and send it to Zabbix server
baculaJobCompr=$($sql "select round(1-JobBytes/ReadBytes,2) from Job where JobId=$baculaJobId;")
$zabbixSender -z $zabbixSrvAddr -p $zabbixSrvPort -s $baculaClientName -k "bacula.$level.job.compr" -o $baculaJobCompr
