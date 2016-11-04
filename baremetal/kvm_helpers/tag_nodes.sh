#!/bin/bash -v

<<<<<<< HEAD
<<<<<<< HEAD
for i in $(ironic node-list|grep -v UUID|grep zookeeper|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:zookeeper,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep kafka|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:kafka,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep master|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:master,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep edge|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:edge,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep dn|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:dn,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep mgr|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:mgr,boot_option:local;done
=======
for i in $(ironic node-list|grep -v UUID|grep zookeeper|awk {'print $2'});do ironic node-update $i replace properties/capabilities=profile:zookeeper,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep kafka|awk {'print $2'});do ironic node-update $i replace properties/capabilities=profile:kafka,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep master|awk {'print $2'});do ironic node-update $i replace properties/capabilities=profile:master,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep tools|awk {'print $2'});do ironic node-update $i replace properties/capabilities=profile:tools,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep logserver|awk {'print $2'});do ironic node-update $i replace properties/capabilities=profile:logserver,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep edge|awk {'print $2'});do ironic node-update $i replace properties/capabilities=profile:edge,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep cm|awk {'print $2'});do ironic node-update $i replace properties/capabilities=profile:cm,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep dn|awk {'print $2'});do ironic node-update $i replace properties/capabilities=profile:dn,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep jupyter|awk {'print $2'});do ironic node-update $i replace properties/capabilities=profile:jupyter,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep mgr|awk {'print $2'});do ironic node-update $i replace properties/capabilities=profile:mgr,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep opentsdb|awk {'print $2'});do ironic node-update $i replace properties/capabilities=profile:opentsdb,boot_option:local;done
>>>>>>> adding baremetal directory
=======
for i in $(ironic node-list|grep -v UUID|grep zookeeper|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:zookeeper,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep kafka|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:kafka,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep master|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:master,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep edge|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:edge,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep dn|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:dn,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep mgr|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:mgr,boot_option:local;done
<<<<<<< HEAD
for i in $(ironic node-list|grep -v UUID|grep opentsdb|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:opentsdb,boot_option:local;done
>>>>>>> ngena
=======
>>>>>>> kvm helpers for pico

for i in $(ironic node-list|grep -v UUID|awk {'print $2'});do ironic node-show $i|grep -A1 properties;done

