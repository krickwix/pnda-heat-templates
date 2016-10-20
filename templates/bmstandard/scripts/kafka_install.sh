#!/bin/bash -v

set -e
export roles="$roles$"

cat >> /etc/hosts <<EOF
$master_ip$ saltmaster salt
EOF

export DEBIAN_FRONTEND=noninteractive
wget -O install_salt.sh https://bootstrap.saltstack.com
sh install_salt.sh -D -U stable 2015.8.10
hostname=`hostname` && echo "id: $hostname" > /etc/salt/minion && unset hostname
echo "log_level: debug" >> /etc/salt/minion
echo "log_level_logfile: debug" >> /etc/salt/minion

if [ "x$brokerid$" == "x0" ] || [ "x$brokerid$" == "x1" ]; then
  roles="$roles zookeeper"
fi

a="roles:\n";for i in $roles; do a="$a  - $i\n";done;echo $a
cat > /etc/salt/grains <<EOF
pnda:
  flavor: $flavor$
pnda_cluster: $pnda_cluster$
EOF

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

if [ -b $volume_dev$ ]; then
  umount $volume_dev$ || echo 'not mounted'
  mkfs.xfs $volume_dev$
  mkdir -p /var/log/pnda
  cat >> /etc/fstab <<EOF
  $volume_dev$  /var/log/pnda xfs defaults  0 0
EOF
fi
