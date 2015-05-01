# Zabbix monitoring of Bacula's backup jobs and its processes

Mainly composed by:
- A bash script that reads values from Bacula Catalog and sends to Zabbix;
- A Zabbix template with items and other configurations to receive the values, start alerts and generate graphs.

Versions used:
- Bacula 7.0.5
- Zabbix 2.4.5

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
