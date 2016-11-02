# pnda bare metal

## Setting up the undercloud
Creating the stack user
```
sudo useradd stack
sudo passwd stack  # specify a password
echo "stack ALL=(root) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/stack
sudo chmod 0440 /etc/sudoers.d/stack
su - stack
```
Setting the host name, replace the <undercloud_fqdn> with the appropriate hostname
```
sudo hostnamectl set-hostname <undercloud_fqdn>
sudo hostnamectl set-hostname --transient <undercloud_fqdn>
```
Updating hosts file
```
127.0.0.1   <undercloud_fqdn> <hostname> localhost
```
Setting up the required repositories
```
sudo curl -L -o /etc/yum.repos.d/delorean-mitaka.repo https://trunk.rdoproject.org/centos7-mitaka/current/delorean.repo
sudo curl -L -o /etc/yum.repos.d/delorean-deps-mitaka.repo http://trunk.rdoproject.org/centos7-mitaka/delorean-deps.repo
```
```
sudo yum -y install yum-plugin-priorities
sudo yum install -y python-tripleoclient
```
Undercloud configuration, replace <undercloud_fqdn> and <provisioning_interface>
```
cat > ~/undercloud.conf <<EOF
[DEFAULT]
undercloud_hostname = <undercloud_fqdn>
local_ip = 192.0.3.1/24
network_gateway = 192.0.3.1
undercloud_public_vip = 192.0.3.2
undercloud_admin_vip = 192.0.3.3
local_interface = <provisioning_interface>
network_cidr = 192.0.3.0/24
masquerade_network = 192.0.3.0/24
dhcp_start = 192.0.3.5
dhcp_end = 192.0.3.24
inspection_interface = br-ctlplane
inspection_iprange = 192.0.3.100,192.0.3.120
inspection_runbench = false
undercloud_debug = true
enable_mistral = false
enable_zaqar = false
ipxe_deploy = false
enable_monitoring = false
store_events = false
[auth]
EOF
```
Undercloud deployment
```
export DIB_YUM_REPO_CONF="/etc/yum.repos.d/delorean-deps-mitaka.repo /etc/yum.repos.d/delorean-mitaka.repo"
export NODE_DIST=centos7
export DELOREAN_TRUNK_REPO="http://trunk.rdoproject.org/centos7-mitaka/current/"
openstack undercloud install

[…]

#############################################################################`
Undercloud install complete.

The file containing this installation's passwords is at
/home/stack/undercloud-passwords.conf.

There is also a stackrc file at /home/stack/stackrc.

These files are needed to interact with the OpenStack services, and should be
secured.

#############################################################################
```
From now on, one can authenticate using the credentials from the ```stackrc``` file
```
. stackrc
openstack service list
+----------------------------------+------------+---------------+
| ID                               | Name       | Type          |
+----------------------------------+------------+---------------+
| 0216b22ec85b437d9cc80b3a34ff2da6 | ceilometer | metering      |
| 16b7cfa2f8f64484902c8d7c7c832597 | neutron    | network       |
| 228290231a9d48f09b6f801641a773c8 | glance     | image         |
| 3493e5ad8f3e4e14a9f91dc10849540d | novav3     | computev3     |
| 56cce03fd1b74a8c833650f8fe83639a | heat       | orchestration |
| 8a8be34a81e74aa5ad522c20c447d647 | nova       | compute       |
| a97775a728344d3db3fa655ba39bd16d | keystone   | identity      |
| a9f7e037e49b4e068015263e99d0ae21 | ironic     | baremetal     |
| bc0aaf1a1de941018eff9637c879a2ca | swift      | object-store  |
+----------------------------------+------------+---------------+
```
## Building the overcloud images
There are two types of images:
*	deployment and discovery images
*	the pnda image itself

First we create the deployment and discovery images
```
export DIB_YUM_REPO_CONF="/etc/yum.repos.d/delorean-deps-mitaka.repo /etc/yum.repos.d/delorean-mitaka.repo"
export NODE_DIST=centos7
export DELOREAN_TRUNK_REPO="http://trunk.rdoproject.org/centos7-mitaka/current/"
mkdir ~/images && cd ~/images
openstack overcloud image build --all
```
Second we create the pnda image
```
cd
git clone https://github.com/pndaproject/pnda-dib-elements.git
export NODE_DIST=ubuntu
export ELEMENTS_PATH="/usr/share/tripleo-image-elements:/usr/share/openstack-heat-templates/:/usr/share/openstack-heat-templates/software-config/elements:/usr/share/instack-undercloud:/usr/share/tripleo-puppet-elements:/home/stack/pnda-dib-elements/elements"
export PUPPET_COMMON_ELEMENTS="\
    sysctl \
    hosts \
    baremetal \
    dhcp-all-interfaces \
    os-collect-config \
    heat-config-puppet \
    heat-config-script \
    puppet-modules \
    hiera \
    os-net-config \
    stable-interface-names \
    grub2 \
    cloud-init-pnda"
cd images && disk-image-create -a amd64 -o pnda-image ubuntu $PUPPET_COMMON_ELEMENTS 2>&1 | tee dib-pnda-image.log
```
At this point it might be necessary to customize the images more. Adding some parameters to the kernel cmdline for example.
```
openstack overcloud image upload
glance image-create  --name pnda-image-initrd --disk-format ari --container-format ari --file pnda-image.initrd --progress
glance image-create  --name pnda-image-vmlinuz --disk-format aki --container-format aki --file pnda-image.vmlinuz --progress
glance image-create  --name pnda-image --disk-format qcow2 --container-format bare --file pnda-image.qcow2 --progress
pnda_initrd_id=$(glance image-list|grep pnda-image-initrd|awk {'print $2'})
pnda_kernel_id=$(glance image-list|grep pnda-image-vmlinuz|awk {'print $2'})
glance image-update --property ramdisk_id=$pnda_initrd_id pnda-image
glance image-update --property kernel_id=$pnda_kernel_id pnda-image
```
