#!/bin/bash -v

rm -rf /tmp/intro_data
mkdir -p /tmp/intro_data && cd /tmp/intro_data

for i in $(openstack baremetal list |grep -v UUID|awk {'print $2'});do 
  openstack baremetal introspection data save $i | jq . | tee $i.json;
done

for i in *.json; do
  echo -n `echo $i|cut -d\. -f1 -`; 
  echo -n " " ; 
  jq '.cpus, .memory_mb, .extra.disk.sdb.size'  < $i | while read j; do 
    echo -n "$j "; 
  done;
  echo;
done | tee /tmp/int.tmp

small=`grep "16 131072 477" /tmp/int.tmp | awk {'print $1'}`
large=`grep "16 262144 10790" /tmp/int.tmp | awk {'print $1'}`
medium1=`grep "8 262144 1200" /tmp/int.tmp | awk {'print $1'}`
medium2=`grep "16 131072 4795" /tmp/int.tmp | awk {'print $1'}`

for i in $small; do
  ironic node-update $i add properties/capabilities=profile:s1.small,boot_option:local;
done

for i in $medium1; do
  ironic node-update $i add properties/capabilities=profile:s1.medium,boot_option:local;
done

for i in $medium2; do
  ironic node-update $i add properties/capabilities=profile:s2.medium,boot_option:local;
done

for i in $large; do
  ironic node-update $i add properties/capabilities=profile:s1.large,boot_option:local;
done

openstack overcloud profiles list

