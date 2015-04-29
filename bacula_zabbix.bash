#!/bin/bash

# Get Bacula's Job ID from parameter
baculaJobId="$1"

# Import configuration file
source bacula_zabbix.conf

# 
case $baculaDbSgdb in
  P) sql='/usr/bin/psql -U postgres -c' ;;
  M) sql='/usr/bin/mysql -NBe' ;;
  *) exit 1 ;;
esac

baculaJobType=$($sql "select Type from Job where JobId=$baculaJobId;" $baculaDbName)
if [ "$baculaJobType" != "B" ] ; then exit 2 ; fi
  
baculaJobLevel=$($sql "select Level from Job where JobId=$baculaJobId;" $baculaDbName)
case $baculaJobLevel in
  'F') level='full' ;;
  'D') level='diff' ;;
  'I') level='incr' ;;
  *)   exit 3 ;;
esac

baculaJobStatus=$($sql "select JobStatus from Job where JobId=$baculaJobId;" $baculaDbName)
case $baculaJobStatus in
  "T") status=0 ;;
  "W") status=1 ;;
  *)   status=2 ;;
esac

baculaClientName=$($sql "select Client.Name from Client,Job where Job.ClientId=Client.ClientId and Job.JobId=$baculaJobId;" $baculaDbName)

$zabbixSender -z $zabbixSrvAddr -p $zabbixSrvPort -s $baculaClientName -k "bacula.$level.job.status" -o $status
  
baculaJobBytes=$($sql "select JobBytes from Job where JobId=$baculaJobId;" $baculaDbName)
$zabbixSender -z $zabbixSrvAddr -p $zabbixSrvPort -s $baculaClientName -k "bacula.$level.job.bytes" -o $baculaJobBytes

baculaJobFiles=$($sql "select JobFiles from Job where JobId=$baculaJobId;" $baculaDbName)
$zabbixSender -z $zabbixSrvAddr -p $zabbixSrvPort -s $baculaClientName -k "bacula.$level.job.files" -o $baculaJobFiles

baculaJobTime=$($sql "select timestampdiff(second,StartTime,EndTime) from Job where JobId=$baculaJobId;" $baculaDbName)
$zabbixSender -z $zabbixSrvAddr -p $zabbixSrvPort -s $baculaClientName -k "bacula.$level.job.time" -o $baculaJobTime

baculaJobSpeed=$($sql "select round(JobBytes/timestampdiff(second,StartTime,EndTime)/1024,2) from Job where JobId=$baculaJobId;" $baculaDbName)
$zabbixSender -z $zabbixSrvAddr -p $zabbixSrvPort -s $baculaClientName -k "bacula.$level.job.speed" -o $baculaJobSpeed

baculaJobCompr=$($sql "select round(1-JobBytes/ReadBytes,2) from Job where JobId=$baculaJobId;" $baculaDbName)
$zabbixSender -z $zabbixSrvAddr -p $zabbixSrvPort -s $baculaClientName -k "bacula.$level.job.compr" -o $baculaJobCompr
