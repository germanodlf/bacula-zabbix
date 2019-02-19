#!/bin/bash

# Import configuration file
source /etc/bacula/bacula-zabbix.conf
# start tee logging
LOG="tee -a ${scriptLogFile}"

# Get Job ID from parameter
baculaJobId="$1"
echo "[$baculaJobId] START@ $(date +"%F %T")" | ${LOG} > /dev/null
if [ -z $baculaJobId ] ; then exit 3 ; fi

# Test if zabbix_sender exists and execute permission is granted, if not, exit
if [ ! -x $zabbixSender ] ; then exit 5 ; fi

# Chose which database command to use
case $baculaDbSgdb in
  P)
    # alternative if used with traditional -h/-p/-U/-d parameters
    #export PGPASSWORD=$baculaDbPass;
    # use -X to ignore any .psqlrc and only return data no headers (-t) in blank output format (-A)
    # also use --dbname to get full command with password in one line
    sql="/usr/bin/psql -A -t -X --dbname=postgresql://$baculaDbUser:$baculaDbPass@$baculaDbAddr:$baculaDbPort/$baculaDbName -c"
    timestampdiff="EXTRACT(EPOCH FROM endtime - starttime)"
    speed="ROUND((JobBytes / ${timestampdiff} / 1024)::NUMERIC, 2)"
    compression="ROUND(1 - JobBytes::NUMERIC / ReadBytes::NUMERIC, 2)"
  ;;
  M)
    sql="/usr/bin/mysql -NB -h$baculaDbAddr -P$baculaDbPort -u$baculaDbUser -p$baculaDbPass -D$baculaDbName -e"
    timestampdiff="timestampdiff(second, StartTime, EndTime)"
    speed="round(JobBytes / ${timestampdiff} / 1024, 2)"
    compression="round(1 - JobBytes / ReadBytes, 2)"
  ;;
  *) exit 7 ;;
esac
echo "[$baculaJobId] SQL Type: $baculaDbSgdb" | ${LOG} > /dev/null

# Get Job type from database, then if it is a backup job, proceed, if not, exit
baculaJobType=$($sql "select Type from Job where JobId=$baculaJobId;" 2>/dev/null)
echo "[$baculaJobId] Job Type: ${baculaJobType}" | ${LOG} > /dev/null
if [ "$baculaJobType" != "B" ] ; then exit 9 ; fi

# Get Job level from database and classify it as Full, Differential, or Incremental
baculaJobLevel=$($sql "select Level from Job where JobId=$baculaJobId;" 2>/dev/null)
case $baculaJobLevel in
  'F') level='full' ;;
  'D') level='diff' ;;
  'I') level='incr' ;;
  *)   exit 11 ;;
esac
echo "[$baculaJobId] Job Level: ${baculaJobLevel} => ${level}" | ${LOG} > /dev/null

# Get Job exit status from database and classify it as OK, OK with warnings, or Fail
baculaJobStatus=$($sql "select JobStatus from Job where JobId=$baculaJobId;" 2>/dev/null)
if [ -z $baculaJobStatus ] ; then exit 13 ; fi
case $baculaJobStatus in
  "T") status=0 ;;
  "W") status=1 ;;
  *)   status=2 ;;
esac
echo "[$baculaJobId] Job Status: ${baculaJobStatus} => ${status}" | ${LOG} > /dev/null

# Get client's name from database
baculaClientName=$($sql "select Client.Name from Client,Job where Job.ClientId=Client.ClientId and Job.JobId=$baculaJobId;" 2>/dev/null)
if [ -z $baculaClientName ] ; then exit 15 ; fi
echo "[$baculaJobId] Client Name: ${baculaClientName}" | ${LOG} > /dev/null

# Initialize return as zero
return=0

# Send Job exit status to Zabbix server
$zabbixSender -c $zabbixAgentConfig -k "bacula.$level.job.status" -o $status >/dev/null 2>&1
if [ $? -ne 0 ] ; then return=$(($return+1)) ; fi

# Get from database the number of bytes transferred by the Job and send it to Zabbix server
baculaJobBytes=$($sql "select JobBytes from Job where JobId=$baculaJobId;" 2>/dev/null)
echo "[$baculaJobId] Job Bytes: ${baculaJobBytes}" | ${LOG} > /dev/null
$zabbixSender -c $zabbixAgentConfig -k "bacula.$level.job.bytes" -o $baculaJobBytes >/dev/null 2>&1
if [ $? -ne 0 ] ; then return=$(($return+2)) ; fi

# Get from database the number of files transferred by the Job and send it to Zabbix server
baculaJobFiles=$($sql "select JobFiles from Job where JobId=$baculaJobId;" 2>/dev/null)
echo "[$baculaJobId] Job Files: ${baculaJobFiles}" | ${LOG} > /dev/null
$zabbixSender -c $zabbixAgentConfig -k "bacula.$level.job.files" -o $baculaJobFiles >/dev/null 2>&1
if [ $? -ne 0 ] ; then return=$(($return+4)) ; fi

# Get from database the time spent by the Job and send it to Zabbix server
baculaJobTime=$($sql "select ${timestampdiff} from Job where JobId=$baculaJobId;" 2>/dev/null)
echo "[$baculaJobId] Job Time: ${baculaJobTime}" | ${LOG} > /dev/null
$zabbixSender -c $zabbixAgentConfig -k "bacula.$level.job.time" -o $baculaJobTime >/dev/null 2>&1
if [ $? -ne 0 ] ; then return=$(($return+8)) ; fi

# Get Job speed from database and send it to Zabbix server
baculaJobSpeed=$($sql "select ${speed} from Job where JobId=$baculaJobId;" 2>/dev/null)
echo "[$baculaJobId] Job Speed: ${baculaJobSpeed}" | ${LOG} > /dev/null
$zabbixSender -c $zabbixAgentConfig -k "bacula.$level.job.speed" -o $baculaJobSpeed >/dev/null 2>&1
if [ $? -ne 0 ] ; then return=$(($return+16)) ; fi

# Get Job compression rate from database and send it to Zabbix server
baculaJobCompr=$($sql "select ${compression} from Job where JobId=$baculaJobId;" 2>/dev/null)
echo "[$baculaJobId] Job Compression: ${baculaJobCompr}" | ${LOG} > /dev/null
$zabbixSender -c $zabbixAgentConfig -k "bacula.$level.job.compr" -o $baculaJobCompr >/dev/null 2>&1
if [ $? -ne 0 ] ; then return=$(($return+32)) ; fi

echo "[$baculaJobId] END@ $(date +"%F %T") RETURN: ${return}" | ${LOG} > /dev/null

# Exit with return status
exit $return
