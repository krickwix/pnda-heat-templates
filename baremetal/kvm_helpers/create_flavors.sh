#!/bin/bash -v

#set -xe

<<<<<<< HEAD

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> kvm helpers for pico
=======
>>>>>>> adding baremetal directory
openstack flavor delete pnda-micro
openstack flavor delete pnda-zookeeper
openstack flavor delete pico-kafka
openstack flavor delete pico-edge
openstack flavor delete pico-dn
openstack flavor delete pico-mgr
openstack flavor create --id auto --ram 2048 --disk 9 --vcpus 1 pnda-micro
openstack flavor create --id auto --ram 2048 --disk 19 --vcpus 1 pnda-zookeeper
<<<<<<< HEAD
<<<<<<< HEAD
openstack flavor create --id auto --ram 2048 --disk 39 --vcpus 2 pico-kafka
openstack flavor create --id auto --ram 2048 --disk 19 --vcpus 1 pico-edge
openstack flavor create --id auto --ram 2048 --disk 39 --vcpus 2 pico-dn
openstack flavor create --id auto --ram 4096 --disk 39 --vcpus 2 pico-mgr
=======
openstack flavor create --id auto --ram 4096 --disk 39 --vcpus 2 pico-kafka
openstack flavor create --id auto --ram 2048 --disk 19 --vcpus 1 pico-edge
openstack flavor create --id auto --ram 8192 --disk 39 --vcpus 2 pico-dn
openstack flavor create --id auto --ram 32768 --disk 39 --vcpus 2 pico-mgr
>>>>>>> kvm helpers for pico
=======
openstack flavor create --id auto --ram 2048 --disk 39 --vcpus 2 pico-kafka
openstack flavor create --id auto --ram 2048 --disk 19 --vcpus 1 pico-edge
openstack flavor create --id auto --ram 2048 --disk 39 --vcpus 2 pico-dn
openstack flavor create --id auto --ram 4096 --disk 39 --vcpus 2 pico-mgr
>>>>>>> update kvm_helpers
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="master" pnda-micro
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="zookeeper" pnda-zookeeper
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="kafka" pico-kafka
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="edge" pico-edge
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="dn" pico-dn
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="mgr" pico-mgr
<<<<<<< HEAD
<<<<<<< HEAD
=======
openstack flavor delete p.master
openstack flavor delete p.tools
openstack flavor delete p.zookeeper
openstack flavor delete p.kafka
openstack flavor delete p.logserver
openstack flavor delete p.edge
openstack flavor delete p.cm
openstack flavor delete p.jupyter
openstack flavor delete p.dn
openstack flavor delete p.mgr
openstack flavor delete p.opentsdb
openstack flavor create --id auto --ram 2048 --disk 9 --vcpus 1 p.master
openstack flavor create --id auto --ram 2048 --disk 19 --vcpus 1 p.zookeeper
openstack flavor create --id auto --ram 4096 --disk 39 --vcpus 2 p.kafka
openstack flavor create --id auto --ram 32768 --disk 39 --vcpus 2 p.logserver
openstack flavor create --id auto --ram 2048 --disk 19 --vcpus 1 p.edge
openstack flavor create --id auto --ram 32768 --disk 39 --vcpus 2 p.cm
openstack flavor create --id auto --ram 8192 --disk 39 --vcpus 2 p.dn
openstack flavor create --id auto --ram 32768 --disk 39 --vcpus 2 p.mgr
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="master" p.master
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="zookeeper" p.zookeeper
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="kafka" p.kafka
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="logserver" p.logserver
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="edge" p.edge
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="cm" p.cm
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="dn" p.dn
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="mgr" p.mgr
>>>>>>> adding baremetal directory
=======
>>>>>>> kvm helpers for pico

=======
>>>>>>> adding baremetal directory
