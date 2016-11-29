#!/bin/bash


openstack flavor delete s1.small
openstack flavor delete s1.medium
openstack flavor delete s1.large
openstack flavor delete s2.medium
openstack flavor delete master

openstack flavor create --id auto --ram 131071 --disk 109 --vcpus 8 s1.small
openstack flavor create --id auto --ram 131071 --disk 109 --vcpus 8 s2.medium
openstack flavor create --id auto --ram 131071 --disk 109 --vcpus 16 s1.medium
openstack flavor create --id auto --ram 262144 --disk 109 --vcpus 16 s1.large
openstack flavor create --id auto --ram 2048 --disk 9 --vcpus 1 master

openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="master" master
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="s1.small" s1.small
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="s2.medium" s2.medium
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="s1.medium" s1.medium
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="s1.large" s1.large

