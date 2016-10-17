#!/bin/bash -v

#set -xe

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 269a960... Correcting rebase issues
openstack flavor delete pnda-micro
openstack flavor delete pico-kafka
openstack flavor delete pico-edge
openstack flavor delete pico-dn
openstack flavor delete pico-mgr
openstack flavor create --id auto --ram 2048 --disk 9 --vcpus 1 pnda-micro
<<<<<<< HEAD
<<<<<<< HEAD
openstack flavor create --id auto --ram 2048 --disk 39 --vcpus 2 pico-kafka
openstack flavor create --id auto --ram 8192 --disk 19 --vcpus 1 pico-edge
openstack flavor create --id auto --ram 4096 --disk 39 --vcpus 2 pico-dn
=======
openstack flavor create --id auto --ram 2048 --disk 19 --vcpus 1 pnda-zookeeper
openstack flavor create --id auto --ram 2048 --disk 39 --vcpus 2 pico-kafka
openstack flavor create --id auto --ram 8192 --disk 19 --vcpus 1 pico-edge
openstack flavor create --id auto --ram 2048 --disk 39 --vcpus 2 pico-dn
<<<<<<< HEAD
>>>>>>> 8f901ca... update kvm_helpers
openstack flavor create --id auto --ram 4096 --disk 39 --vcpus 2 pico-mgr
=======
openstack flavor create --id auto --ram 8192 --disk 39 --vcpus 2 pico-mgr
>>>>>>> 72768b3... machines sizes
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="master" pnda-micro
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="kafka" pico-kafka
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="edge" pico-edge
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="dn" pico-dn
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="mgr" pico-mgr
=======

=======
>>>>>>> 52eea9c... adding baremetal directory
openstack flavor delete pnda-micro
openstack flavor delete pnda-zookeeper
openstack flavor delete pico-kafka
openstack flavor delete pico-edge
openstack flavor delete pico-dn
openstack flavor delete pico-mgr
openstack flavor create --id auto --ram 2048 --disk 9 --vcpus 1 pnda-micro
openstack flavor create --id auto --ram 2048 --disk 19 --vcpus 1 pnda-zookeeper
openstack flavor create --id auto --ram 2048 --disk 39 --vcpus 2 pico-kafka
openstack flavor create --id auto --ram 2048 --disk 19 --vcpus 1 pico-edge
openstack flavor create --id auto --ram 2048 --disk 39 --vcpus 2 pico-dn
=======
openstack flavor create --id auto --ram 2048 --disk 39 --vcpus 2 pico-kafka
openstack flavor create --id auto --ram 8192 --disk 19 --vcpus 1 pico-edge
openstack flavor create --id auto --ram 4096 --disk 39 --vcpus 2 pico-dn
>>>>>>> 269a960... Correcting rebase issues
openstack flavor create --id auto --ram 4096 --disk 39 --vcpus 2 pico-mgr
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="master" pnda-micro
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="kafka" pico-kafka
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="edge" pico-edge
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="dn" pico-dn
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="mgr" pico-mgr
<<<<<<< HEAD
<<<<<<< HEAD

>>>>>>> e373714... adding baremetal directory
=======
>>>>>>> 52eea9c... adding baremetal directory
=======
>>>>>>> 269a960... Correcting rebase issues
