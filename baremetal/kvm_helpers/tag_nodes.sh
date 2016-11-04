#!/bin/bash -v

for i in $(ironic node-list|grep -v UUID|grep zookeeper|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:zookeeper,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep kafka|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:kafka,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep master|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:master,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep edge|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:edge,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep dn|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:dn,boot_option:local;done
for i in $(ironic node-list|grep -v UUID|grep mgr|awk {'print $2'});do ironic node-update $i add properties/capabilities=profile:mgr,boot_option:local;done

for i in $(ironic node-list|grep -v UUID|awk {'print $2'});do ironic node-show $i|grep -A1 properties;done

