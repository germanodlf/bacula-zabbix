#!/usr/bin/perl

#for (`cat /etc/bareos/bareos-zabbix.conf`) {
#      chomp;                  # no newline
#      s/#.*//;                # no comments
#      s/^\s+//;               # no leading white
#      s/\s+$//;               # no trailing white
#      s/\'//g;                
#      my ($var, $value) = split(/\s*=\s*/, $_, 2);
#
#      $User_Preferences{$var} = $value;
#} 

$baculaDbUser='bareos';
$baculaDbName='bareos';

#@qq=`/usr/bin/psql -U$User_Preferences{'bareosDbUser'} -d$User_Preferences{'bareosDbName'} -t -A -c "select job.name,client.name from job left join client on job.clientid=client.clientid group by job.name,client.name;"`;
@qq=`/usr/bin/psql -U$baculaDbUser -d$baculaDbName -t -A -c "select name from client;"`;

$first = 1;
  
print "{\n";
print "\t\"data\":[\n\n";
   
foreach $arg(@qq)
{
  $arg=~s/\n//; 
#  @jobs=split(/\|/, $arg);

  print "\t,\n" if not $first;
	$first = 0;
	
	print "\t{\n";
 # print "\t\t\"{#JOBNAME}\":\"$jobs[0]\",\n";
  print "\t\t\"{#CLIENTNAME}\":\"$arg\"\n";
  print "\t}\n";
        
}
print "\n\t]\n";
print "}\n";
