# Zabbix monitoring of Bacula's backup jobs and its processes

Mainly composed by:
- A bash script that reads values from Bacula Catalog and sends to Zabbix;
- A Zabbix template with items and other configurations to receive the values, start alerts and generate graphs.

Versions used:
- Bacula 7.0.5
- Zabbix 2.4.5

### Abilities

- Customizable and easy to set up
- Separate monitoring for each backup job
- Different job levels have different severities
- Monitoring of bacula-dir, bacula-sd and bacula-fd processes
- Generates graphs to follow the data evolution
- Screens with graphs ready for display
- Works with MySQL and PostgreSQL used by Bacula Catalog

### Features

##### Data collected by script and sent to Zabbix

- Job exit status
- Number of bytes transferred by the job
- Number of files transferred by the job
- Time spent by the job
- Job transfer rate
- Job compression rate

##### Zabbix template configuration

- Items
  - Backup Full Bytes: Receives the value of bytes transferred by full jobs
  - Backup Full Compression: Receives the value of full jobs' compression
  - Backup Full Files: Receives the value of files transferred by full jobs
  - Backup Full OK: Receives the value of full jobs' exit status
  - Backup Full Speed: Receives the value of full jobs' transfer rate in KB/s
  - Backup Full Time: Receives the value of full jobs' compression rate in %
  - Backup Differential Bytes: Receives the value of bytes transferred by differential jobs
  - Backup Differential Compression: Receives the value of differential jobs' compression
  - Backup Differential Files: Receives the value of files transferred by differential jobs
  - Backup Differential OK: Receives the value of differential jobs' exit status
  - Backup Differential Speed: Receives the value of differential jobs' transfer rate in KB/s
  - Backup Differential Time: Receives the value of differential jobs' compression rate in %
  - Backup Incremental Bytes: Receives the value of bytes transferred by incremental jobs
  - Backup Incremental Compression: Receives the value of incremental jobs' compression
  - Backup Incremental Files: Receives the value of files transferred by incremental jobs
  - Backup Incremental OK: Receives the value of incremental jobs' exit status
  - Backup Incremental Speed: Receives the value of incremental jobs' transfer rate in KB/s
  - Backup Incremental Time: Receives the value of incremental jobs' compression rate in %
  - Bacula Director is running: 
  - Bacula File is running:
  - Bacula Storage is running:
- Triggers
  - 

### Requirements

```
vim /var/spool/bacula/bacula-zabbix.bash
chown bacula:bacula /var/spool/bacula/bacula-zabbix.bash
chmod 700 /var/spool/bacula/bacula-zabbix.bash
```

```
vim /etc/bacula/bacula-zabbix.conf
chown root:bacula /etc/bacula/bacula-zabbix.conf
chmod 640 /etc/bacula/bacula-zabbix.conf
```

```
vim /etc/bacula/bacula-dir.conf
  Messages {
    Name = Standard
    mailcommand = "/var/spool/bacula/bacula-zabbix.bash %i"
    mail = 127.0.0.1 = all, !skipped
    ...
  }
systemctl restart bacula-dir
```
