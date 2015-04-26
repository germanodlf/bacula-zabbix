#!/bin/bash

baculaClient="$1"
baculaJobType="$2"
baculaJobLevel="$3"
baculaJobExit="$4"

zabbixServ='127.0.0.1'
zabbixPort='10051'
zabbixSend='/usr/bin/zabbix_sender'

if [ "$baculaJobType" = "Backup" ] ; then

  case $baculaJobLevel in
    "Full")         level='full' ;;
    "Incremental")  level='incr' ;;
    "Differential") level='diff' ;;
    *)              level='erro' ;;
  esac

  case $baculaJobExit in
    "OK")                  code=0 ;;
    "OK -- with warnings") code=1 ;;
    *)                     code=2 ;;
  esac

  $zabbixSend -z $zabbixServ -p $zabbixPort -s $baculaClient -k "bacula.$level.exit" -o $code

fi
