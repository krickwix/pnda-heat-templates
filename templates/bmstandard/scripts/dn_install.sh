#!/bin/bash -v

set -e
export roles="$roles$"

cat >> /etc/hosts <<EOF
$master_ip$ saltmaster salt
EOF

export DEBIAN_FRONTEND=noninteractive
wget -O install_salt.sh https://bootstrap.saltstack.com
sh install_salt.sh -D -U stable 2015.8.11
hostname=`hostname` && echo "id: $hostname" > /etc/salt/minion && unset hostname
echo "log_level: debug" >> /etc/salt/minion
echo "log_level_logfile: debug" >> /etc/salt/minion

a="roles:\n";for i in $roles; do a="$a  - $i\n";done;echo $a
cat > /etc/salt/grains <<EOF
pnda:
  flavor: $flavor$
pnda_cluster: $pnda_cluster$
EOF

if [ "x$cloudera_role$" != "x$" ]; then
  cat >> /etc/salt/grains <<EOF
cloudera:
  role: $cloudera_role$
EOF
fi

if [ "x$brokerid$" != "x$" ]; then
  cat >> /etc/salt/grains <<EOF
broker_id: $brokerid$
EOF
fi

if [ "x$roles$" != "x$" ]; then
cat >> /etc/salt/grains <<EOF
`printf "%b" "$a"`
EOF
fi

service salt-minion restart

apt-get -y install xfsprogs

if [ -b "/dev/sdb" ]; then
umount /dev/sdb || echo "not mounted"
mkfs.xfs -f /dev/sdb
mkdir -p /data0
cat >> /etc/fstab <<EOF
/dev/sdb  /data0 xfs defaults  0 0
EOF
fi

cat /etc/fstab
mount -a
