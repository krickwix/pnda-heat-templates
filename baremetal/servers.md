
```instackenv.json``` for physical servers. ```pxe_ipmitool``` ironic driver is used to manage the power states and pxe boot. The MAC address is the one of the interface attached to the provisioning network.
```
{
  "nodes": [
    {
      "arch": "x86_64",
      "disk": "10",
      "name": "server15",
      "pm_addr": "10.60.6.198",
      "pm_password": "pirladmin",
      "pm_user": "pirladmin",
      "pm_type": "pxe_ipmitool",
      "mac": [
        "00:25:b5:42:01:24"
      ],
      "cpu": "1",
      "memory": "1024"
    },
    {
      [...]
    }
  ]
}
```

Retrieving the introspection results
```
for i in $(openstack baremetal list |grep -v UUID|awk {'print $2'});do openstack baremetal introspection data save $i | jq . | tee $i.json;done
```

```
for i in *.json ; do echo -n "$i:"; jq .extra.disk.sdb.size < $i;done

20745085-fa9e-4a28-aade-556ace7341a3.json:477
4ecfd111-b66c-47ca-8389-5c78021aae10.json:4795
85885f43-d5ed-4f5a-b2cc-eaff7c903f96.json:477
b1c63eb8-5930-4db3-b6b7-e61c8871a4ef.json:11989
b2140cd9-e160-4b93-b086-ddaa43f5c5e6.json:5994
b61204d2-7d66-4019-b9ad-9541dfc5444f.json:477
b9ef0474-3ed1-409e-8598-01d40af6aa0e.json:11989
bdc794a8-1c48-4391-8962-1b5ba36df4bb.json:5994
cdb69493-4390-4566-85db-4f820e7d666a.json:477
cf03029d-919b-4e44-836b-6d2311e75892.json:null
d1cd6f8d-9733-4165-b16e-4b1ba6012b9c.json:477
dd7c3f6d-abe2-421b-843d-d28ff415cfad.json:5994
e95482f7-1750-44c0-8ef9-27367f9c85f5.json:11989
```
We have 3 different type of servers discriminated by their second raid size (477GB, 4795GB, 11989GB). we call them respectively small, medium, large.

```
small=$(for i in *.json ; do echo -n "$i:"; jq .extra.disk.sdb.size < $i;done|grep 477|awk -F. {'print $1'})
medium=$(for i in *.json ; do echo -n "$i:"; jq .extra.disk.sdb.size < $i;done|grep 5994|awk -F. {'print $1'})
large=$(for i in *.json ; do echo -n "$i:"; jq .extra.disk.sdb.size < $i;done|grep 11989|awk -F. {'print $1'})
master=$(for i in *.json ; do echo -n "$i:"; jq .extra.disk.sdb.size < $i;done|grep null|awk -F. {'print $1'})

for i in $small; do ironic node-update $i replace properties/capabilities=profile:small,boot_option:local;done
for i in $medium; do ironic node-update $i replace properties/capabilities=profile:medium,boot_option:local;done
for i in $large; do ironic node-update $i replace properties/capabilities=profile:large,boot_option:local;done
for i in $master; do ironic node-update $i replace properties/capabilities=profile:master,boot_option:local;done

openstack flavor create --ram 2048 --disk 10 --vcpus 1 s1.small
openstack flavor create --ram 2048 --disk 10 --vcpus 1 s1.medium
openstack flavor create --ram 2048 --disk 10 --vcpus 1 s1.large
openstack flavor create --ram 2048 --disk 9 --vcpus 1 master

openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="small" s1.small
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="medium" s1.medium
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="large" s1.large
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="master" master
```

Creating the stack
```
./heat_cli.py -e ngena -f bmstandard --bare true -b PNDA-2271 -s default create
```

* Changing a node's MAC address
```
ironic node-port-list <node_uuid>
ironic port-update  <node_uuid> replace address=<new_mac>
```
* Managing node's provision states
```
ironic node-set-provision-state <node_uuid> provide
```
