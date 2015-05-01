# Zabbix monitoring of Bacula's backup jobs and its processes

This project is mainly composed by a bash script and a Zabbix template. The bash script reads values from Bacula Catalog and sends it to Zabbix Server. While the Zabbix template has items and other configurations that receive this values, start alerts and generate graphs and screens. This material was created using Bacula at 7.0.5 version and Zabbix at 2.4.5 version in a GNU/Linux CentOS 7 operational system.

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

- **Items**

  - *Backup Full Bytes*: Receives the value of bytes transferred by full jobs
  - *Backup Full Compression*: Receives the value of full jobs' compression
  - *Backup Full Files*: Receives the value of files transferred by full jobs
  - *Backup Full OK*: Receives the value of full jobs' exit status
  - *Backup Full Speed*: Receives the value of full jobs' transfer rate in KB/s
  - *Backup Full Time*: Receives the value of full jobs' compression rate in %
  - *Backup Differential Bytes*: Receives the value of bytes transferred by differential jobs
  - *Backup Differential Compression*: Receives the value of differential jobs' compression
  - *Backup Differential Files*: Receives the value of files transferred by differential jobs
  - *Backup Differential OK*: Receives the value of differential jobs' exit status
  - *Backup Differential Speed*: Receives the value of differential jobs' transfer rate in KB/s
  - *Backup Differential Time*: Receives the value of differential jobs' compression rate in %
  - *Backup Incremental Bytes*: Receives the value of bytes transferred by incremental jobs
  - *Backup Incremental Compression*: Receives the value of incremental jobs' compression
  - *Backup Incremental Files*: Receives the value of files transferred by incremental jobs
  - *Backup Incremental OK*: Receives the value of incremental jobs' exit status
  - *Backup Incremental Speed*: Receives the value of incremental jobs' transfer rate in KB/s
  - *Backup Incremental Time*: Receives the value of incremental jobs' compression rate in %
  - *Bacula Director is running*: Get the bacula-dir process status
  - *Bacula Storage is running*: Get the bacula-sd process status
  - *Bacula File is running*: Get the bacula-fd process status

- **Triggers**

  - *Backup Full FAIL in {HOST.NAME}*: Starts a high severity alert when a full backup job fails
  - *Backup Differential FAIL in {HOST.NAME}*: Starts a average severity alert when a differential backup job fails
  - *Backup Incremental FAIL in {HOST.NAME}*: Starts a warning severity alert when a incremental backup job fails
  - *Bacula Director is DOWN in {HOST.NAME}*: Starts a disaster severity alert when the bacula-dir process goes down
  - *Bacula Storage is DOWN in {HOST.NAME}*: Starts a disaster severity alert when the bacula-sd process goes down
  - *Bacula File is DOWN in {HOST.NAME}*: Starts a high severity alert when the bacula-fd process goes down

- **Graphs**

  - *Backup Full - Bytes transferred*: Displays a graph with the variation of the bytes transferred by full jobs, faced with the variation of the exit status of these jobs
  - *Backup Full - Compression rate*: Displays a graph with the variation of the compression rate by full jobs, faced with the variation of the exit status of these jobs
  - *Backup Full - Elapsed time*: Displays a graph with the variation of the elapsed time by full jobs, faced with the variation of the exit status of these jobs
  - *Backup Full - Files transferred*: Displays a graph with the variation of the files transferred by full jobs, faced with the variation of the exit status of these jobs
  - *Backup Full - Transfer rate*: Displays a graph with the variation of the transfer rate by full jobs, faced with the variation of the exit status of these jobs
  - *Backup Differential - Bytes transferred*: Displays a graph with the variation of the bytes transferred by differential jobs, faced with the variation of the exit status of these jobs
  - *Backup Differential - Compression rate*: Displays a graph with the variation of the compression rate by differential jobs, faced with the variation of the exit status of these jobs
  - *Backup Differential - Elapsed time*: Displays a graph with the variation of the elapsed time by differential jobs, faced with the variation of the exit status of these jobs
  - *Backup Differential - Files transferred*: Displays a graph with the variation of the files transferred by differential jobs, faced with the variation of the exit status of these jobs
  - *Backup Differential - Transfer rate*: Displays a graph with the variation of the transfer rate by differential jobs, faced with the variation of the exit status of these jobs
  - *Backup Incremental - Bytes transferred*: Displays a graph with the variation of the bytes transferred by incremental jobs, faced with the variation of the exit status of these jobs
  - *Backup Incremental - Compression rate*: Displays a graph with the variation of the compression rate by incremental jobs, faced with the variation of the exit status of these jobs
  - *Backup Incremental - Elapsed time*: Displays a graph with the variation of the elapsed time by incremental jobs, faced with the variation of the exit status of these jobs
  - *Backup Incremental - Files transferred*: Displays a graph with the variation of the files transferred by incremental jobs, faced with the variation of the exit status of these jobs
  - *Backup Incremental - Transfer rate*: Displays a graph with the variation of the transfer rate by incremental jobs, faced with the variation of the exit status of these jobs

- **Screens**

  - *Backup Full*: Displays a screen with the five graphs of the full jobs
  - *Backup Differential*: Displays a screen with the five graphs of the differential jobs
  - *Backup Incremental*: Displays a screen with the five graphs of the incremental jobs

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
