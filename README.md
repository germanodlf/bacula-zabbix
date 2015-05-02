# Zabbix monitoring of Bacula's backup jobs and its processes

This project is mainly composed by a bash script and a Zabbix template. The bash script reads values from Bacula Catalog and sends it to Zabbix Server. While the Zabbix template has items and other configurations that receive this values, start alerts and generate graphs and screens. This material was created using Bacula at 7.0.5 version and Zabbix at 2.4.5 version in a GNU/Linux CentOS 7 operational system.

### Abilities

- Customizable and easy to set up
- Separate monitoring for each backup job
- Different job levels have different severities
- Monitoring of Bacula Director, Storage and File processes
- Generates graphs to follow the data evolution
- Screens with graphs ready for display
- Works with MySQL and PostgreSQL used by Bacula Catalog

### Features

##### Data collected by script and sent to Zabbix

- Job exit status
- Number of bytes transferred by the job
- Number of files transferred by the job
- Time elapsed by the job
- Job transfer rate
- Job compression rate

##### Zabbix template configuration

Link this Zabbix template to each host that has a Bacula's backup job implemented. Each host configured in Zabbix with this template linked needs to have its name equals to the name configured in Bacula's Client resource. Otherwise the data collected by the bash script will not be received by Zabbix server.

- **Items**

  This Zabbix template has two types of items, the items to receive data of backup jobs, and the itens to receive data of Bacula's processes. The items that receive data of Bacula's processes are described below:
  
  - *Bacula Director is running*: Get the Bacula Director process status. The process name is defined by the variable {$BACULA.DIR}, and has its default value as 'bacula-dir'. This item needs to be disabled in hosts that are Bacula's clients only.
  - *Bacula Storage is running*: Get the Bacula Storage process status. The process name is defined by the variable {$BACULA.SD}, and has its default value as 'bacula-sd'. This item needs to be disabled in hosts that are Bacula's clients only.
  - *Bacula File is running*: Get the Bacula File process status. The process name is defined by the variable {$BACULA.FD}, and has its default value as 'bacula-fd'.

  The items that receive data of backup jobs are divided into the three backup's levels: Full, Differential and Incremental. For each level there are six items as described below:

  - *Bytes*: Receives the value of bytes transferred by each backup job
  - *Compression*: Receives the value of compression rate of each backup job
  - *Files*: Receives the value of files transferred by each backup job
  - *OK*: Receives the value of exit status of each backup job
  - *Speed*: Receives the value of transfer rate of each backup job
  - *Time*: Receives the value of elapsed time of each backup job

- **Triggers**

  The triggers are configured to identify the host that started the trigger through the variable {HOST.NAME}. In the same way as the items, the triggers has two types too. The triggers that are related to Bacula's processes:

  - *Bacula Director is DOWN in {HOST.NAME}*: Starts a disaster severity alert when the Bacula Director process goes down
  - *Bacula Storage is DOWN in {HOST.NAME}*: Starts a disaster severity alert when the Bacula Storage process goes down
  - *Bacula File is DOWN in {HOST.NAME}*: Starts a high severity alert when the Bacula File process goes down

  And the triggers that are related to backup jobs:

  - *Backup Full FAIL in {HOST.NAME}*: Starts a high severity alert when a full backup job fails
  - *Backup Differential FAIL in {HOST.NAME}*: Starts a average severity alert when a differential backup job fails
  - *Backup Incremental FAIL in {HOST.NAME}*: Starts a warning severity alert when a incremental backup job fails

- **Graphs**

  Again, in the same way as the items related to backup jobs, the graphs are divided into the three backup's levels: Full, Differential and Incremental. For each level there are five graphs as described below:

  - *Bytes transferred*: Displays a graph with the variation of the bytes transferred by backup jobs, faced with the variation of the exit status of these jobs
  - *Compression rate*: Displays a graph with the variation of the compression rate by backup jobs, faced with the variation of the exit status of these jobs
  - *Elapsed time*: Displays a graph with the variation of the elapsed time by backup jobs, faced with the variation of the exit status of these jobs
  - *Files transferred*: Displays a graph with the variation of the files transferred by backup jobs, faced with the variation of the exit status of these jobs
  - *Transfer rate*: Displays a graph with the variation of the transfer rate by backup jobs, faced with the variation of the exit status of these jobs

- **Screens**

  There are three screens, one for each backup level, that displays the five graphs previously configured for that level.

### Requirements

- Bacula's implemented infrastructure and knowledge about it
- Zabbix's implemented infrastructure and knowledge about it
- Knowledge about MySQL or PostgreSQL databases

### Installation



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

### Feedback
