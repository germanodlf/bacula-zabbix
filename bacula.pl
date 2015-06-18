#!/usr/bin/perl

$baculaDbUser='bareos';
$baculaDbName='bareos';

#@qq=`/usr/bin/psql -U$User_Preferences{'bareosDbUser'} -d$User_Preferences{'bareosDbName'} -t -A -c "select job.name,client.name from job left join client on job.clientid=client.clientid group by job.name,client.name;"`;
@qq=`/usr/bin/psql -U$baculaDbUser -d$baculaDbName -t -A -c "select job.name,client.name from job left join client on job.clientid=client.clientid group by job.name,client.name having client.name='$ARGV[0]';"`;

$first = 1;
  
print "{\n";
print "\t\"data\":[\n\n";
   
foreach $arg(@qq)
{
  $arg=~s/\n//; 
  @jobs=split(/\|/, $arg);

  print "\t,\n" if not $first;
	$first = 0;
	
	print "\t{\n";
  print "\t\t\"{#JOBNAME}\":\"$jobs[0]\",\n";
  print "\t\t\"{#CLIENTNAME}\":\"$jobs[1]\"\n";
  print "\t}\n";
        
}
print "\n\t]\n";
print "}\n";
