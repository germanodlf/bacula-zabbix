#!/bin/bash

# wrapper for sending mail and running zabbix sender script

# just parse for each command line option
job_type="${1}"; # %t
job_exit_status="${2}"; # %e
client_name="${3}"; # %c
job_name="${4}"; # %n
job_level="${5}"; # %l
recipients="${6}"; # %r
job_id="${7}"; # %i

/usr/sbin/bsmtp -h localhost -f "(Bacula) <bacula@backup-bacula.tokyo.tequila.jp>" -s "Bacula: ${job_type} ${job_exit_status} of ${client_name} (${job_name}) ${job_level}" ${recipients};
/var/spool/bacula/bacula-zabbix.bash ${job_id};

exit;
