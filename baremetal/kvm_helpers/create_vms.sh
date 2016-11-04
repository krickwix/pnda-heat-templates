#!/bin/bash -v

set -xe

for i in $(virsh list --all | awk ' /pnda/ {print $2} '); do virsh undefine $i;done

# SALTMASTER
qemu-img create -f qcow2 -o preallocation=metadata pnda-master.qcow2 10G
virt-install --accelerate --cpu SandyBridge,+vmx --name=pnda-master --file=pnda-master.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=1 --ram=2048 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-master.xml
virsh define pnda-master.xml

# ZOOKEPER
# for i in {1..1};do qemu-img create -f qcow2 -o preallocation=metadata pnda-zookeeper-$i.qcow2 20G;done
# for i in {1..1};do virt-install --accelerate --name=pnda-zookeeper-$i --file=pnda-zookeeper-$i.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=1 --ram=2048 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio  --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-zookeeper-$i.xml;done
# for i in {1..1};do virsh define pnda-zookeeper-$i.xml; done

# KAFKA
for i in {1..1};do qemu-img create -f qcow2 -o preallocation=metadata pnda-kafka-$i.qcow2 40G;done
for i in {1..1};do virt-install --accelerate --cpu SandyBridge,+vmx --name=pnda-kafka-$i --file=pnda-kafka-$i.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=2 --ram=2048 --network bridge=br-ctlplane,virtualport_type=openvswitch,model=virtio  --network network=default,model=virtio --os-type=linux --boot hd --dry-run --print-xml > pnda-kafka-$i.xml;done
for i in {1..1};do virsh define pnda-kafka-$i.xml; done

qemu-img create -f qcow2 -o preallocation=metadata pnda-cdh-edge.qcow2 20G
virt-install --accelerate --cpu SandyBridge,+vmx --name=pnda-cdh-edge --file=pnda-cdh-edge.qcow2 --graphics vnc,listen=0.0.0.0 --vcpus=1 --ram=2048 --network bridge=br-ctlplane,virtualport_type=openvswitch  --network network=default --os-type=linux --boot hd --dry-run --print-xml > pnda-cdh-edge.xml
virsh define pnda-cdh-edge.xml

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
virsh define pnda-cdh-mgr$i.xml; \
done

rm -f /tmp/nodes.txt && for i in $(virsh list --all | awk ' /pnda/ {print $2} ');do mac=$(virsh domiflist $i | awk ' /br-ctlplane/ {print $5} '); echo -e "$mac" >>/tmp/nodes.txt;done && cat /tmp/nodes.txt
rm -f /tmp/names.txt && for i in $(virsh list --all | awk ' /pnda/ {print $2} ');do echo -e "$i" >>/tmp/names.txt;done && cat /tmp/names.txt

virsh list --all
