#!/bin/bash -v

set -xe

for i in $(virsh list --all | awk ' /pnda/ {print $2} '); do virsh undefine $i;done

<<<<<<< HEAD
# SALTMASTER
qemu-img create -f qcow2 -o preallocation=metadata pnda-master.qcow2 10G
virt-install --accelerate --cpu SandyBridge,+vmx --name=pnda-master --file=pnda-master.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=1 --ram=2048 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-master.xml
virsh define pnda-master.xml

# ZOOKEPER
#for i in {1..1};do qemu-img create -f qcow2 -o preallocation=metadata pnda-zookeeper-$i.qcow2 20G;done
#for i in {1..1};do virt-install --accelerate --name=pnda-zookeeper-$i --file=pnda-zookeeper-$i.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=1 --ram=2048 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio  --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-zookeeper-$i.xml;done
#for i in {1..1};do virsh define pnda-zookeeper-$i.xml; done

# KAFKA
for i in {1..1};do qemu-img create -f qcow2 -o preallocation=metadata pnda-kafka-$i.qcow2 40G;done
for i in {1..1};do virt-install --accelerate --cpu SandyBridge,+vmx --name=pnda-kafka-$i --file=pnda-kafka-$i.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=2 --ram=2048 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio  --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-kafka-$i.xml;done
for i in {1..1};do virsh define pnda-kafka-$i.xml; done

qemu-img create -f qcow2 -o preallocation=metadata pnda-cdh-edge.qcow2 20G
virt-install --accelerate --cpu SandyBridge,+vmx --name=pnda-cdh-edge --file=pnda-cdh-edge.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=1 --ram=2048 --network bridge=br-ctlplane,virtualport_type=openvswitch  --network network=default --os-type=linux --boot hd --dry-run --print-xml > pnda-cdh-edge.xml
virsh define pnda-cdh-edge.xml

#qemu-img create -f qcow2 -o preallocation=metadata pnda-cdh-cm.qcow2 40G
#virt-install --accelerate --name=pnda-cdh-cm --file=pnda-cdh-cm.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=2 --ram=2048 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio  --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-cdh-cm.xml
#virsh define pnda-cdh-cm.xml

for i in {1..1};do \
qemu-img create -f qcow2 -o preallocation=metadata pnda-cdh-dn$i.qcow2 40G;\
done
for i in {1..1};do \
virt-install --accelerate --cpu SandyBridge,+vmx --name=pnda-cdh-dn$i --file=pnda-cdh-dn$i.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=2 --ram=2048 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio  --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-cdh-dn$i.xml; \
virsh define pnda-cdh-dn$i.xml; \
done

for i in {1..1};do \
qemu-img create -f qcow2 -o preallocation=metadata pnda-cdh-mgr$i.qcow2 40G;\
done
for i in {1..1};do \
virt-install --accelerate --cpu SandyBridge,+vmx --name=pnda-cdh-mgr$i --file=pnda-cdh-mgr$i.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=2 --ram=2048 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio  --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-cdh-mgr$i.xml; \
=======
qemu-img create -f qcow2 -o preallocation=metadata pnda-master.qcow2 10G
virt-install --accelerate --name=pnda-master --file=pnda-master.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=1 --ram=2048 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-master.xml
virsh define pnda-master.xml

for i in {1..3};do qemu-img create -f qcow2 -o preallocation=metadata pnda-zookeeper-$i.qcow2 20G;done
for i in {1..3};do virt-install --accelerate --name=pnda-zookeeper-$i --file=pnda-zookeeper-$i.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=1 --ram=2048 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio  --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-zookeeper-$i.xml;done
for i in {1..3};do virsh define pnda-zookeeper-$i.xml; done

for i in {1..2};do qemu-img create -f qcow2 -o preallocation=metadata pnda-kafka-$i.qcow2 40G;done
for i in {1..2};do virt-install --accelerate --name=pnda-kafka-$i --file=pnda-kafka-$i.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=2 --ram=4096 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio  --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-kafka-$i.xml;done
for i in {1..2};do virsh define pnda-kafka-$i.xml; done

#qemu-img create -f qcow2 -o preallocation=metadata pnda-tools.qcow2 10G
#virt-install --accelerate --name=pnda-tools --file=pnda-tools.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=1 --ram=2048 --network bridge=br-ctlplane,virtualport_type=openvswitch  --network network=default --os-type=linux --boot hd --dry-run --print-xml > pnda-tools.xml
#virsh define pnda-tools.xml

qemu-img create -f qcow2 -o preallocation=metadata pnda-logserver.qcow2 40G
virt-install --accelerate --name=pnda-logserver --file=pnda-logserver.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=2 --ram=32768 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio  --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-logserver.xml
virsh define pnda-logserver.xml

#qemu-img create -f qcow2 -o preallocation=metadata pnda-cdh-edge.qcow2 20G
#virt-install --accelerate --name=pnda-cdh-edge --file=pnda-cdh-edge.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=1 --ram=2048 --network bridge=br-ctlplane,virtualport_type=openvswitch  --network network=default --os-type=linux --boot hd --dry-run --print-xml > pnda-cdh-edge.xml
#virsh define pnda-cdh-edge.xml

qemu-img create -f qcow2 -o preallocation=metadata pnda-cdh-cm.qcow2 40G
virt-install --accelerate --name=pnda-cdh-cm --file=pnda-cdh-cm.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=2 --ram=32768 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio  --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-cdh-cm.xml
virsh define pnda-cdh-cm.xml

#qemu-img create -f qcow2 -o preallocation=metadata pnda-cdh-jupyter.qcow2 40G
#virt-install --accelerate --name=pnda-cdh-jupyter --file=pnda-cdh-jupyter.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=1 --ram=4096 --network bridge=br-ctlplane,virtualport_type=openvswitch  --network network=default --os-type=linux --boot hd --dry-run --print-xml > pnda-cdh-jupyter.xml
#virsh define pnda-cdh-jupyter.xml

#qemu-img create -f qcow2 -o preallocation=metadata pnda-cdh-opentsdb.qcow2 40G
#virt-install --accelerate --name=pnda-cdh-opentsdb --file=pnda-cdh-opentsdb.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=2 --ram=4096 --network bridge=br-ctlplane,virtualport_type=openvswitch  --network network=default --os-type=linux --boot hd --dry-run --print-xml > pnda-cdh-opentsdb.xml
#virsh define pnda-cdh-opentsdb.xml

for i in {1..3};do \
qemu-img create -f qcow2 -o preallocation=metadata pnda-cdh-dn$i.qcow2 40G;\
done
for i in {1..3};do \
virt-install --accelerate --name=pnda-cdh-dn$i --file=pnda-cdh-dn$i.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=2 --ram=8192 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio  --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-cdh-dn$i.xml; \
virsh define pnda-cdh-dn$i.xml; \
done

for i in {1..2};do \
qemu-img create -f qcow2 -o preallocation=metadata pnda-cdh-mgr$i.qcow2 40G;\
done
for i in {1..2};do \
virt-install --accelerate --name=pnda-cdh-mgr$i --file=pnda-cdh-mgr$i.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=2 --ram=32768 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio  --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-cdh-mgr$i.xml; \
>>>>>>> adding baremetal directory
virsh define pnda-cdh-mgr$i.xml; \
done

rm -f /tmp/nodes.txt && for i in $(virsh list --all | awk ' /pnda/ {print $2} ');do mac=$(virsh domiflist $i | awk ' /br-ctlplane/ {print $5} '); echo -e "$mac" >>/tmp/nodes.txt;done && cat /tmp/nodes.txt
rm -f /tmp/names.txt && for i in $(virsh list --all | awk ' /pnda/ {print $2} ');do echo -e "$i" >>/tmp/names.txt;done && cat /tmp/names.txt

virsh list --all
