# pnda bare metal

## Setting up the undercloud
Creating the stack user
```
sudo useradd stack
echo "cisco" | passwd stack --stdin
echo "stack ALL=(root) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/stack
sudo chmod 0440 /etc/sudoers.d/stack
su - stack
```
Setting the host name, replace the ```<undercloud_fqdn>``` with the appropriate hostname
```
sudo hostnamectl set-hostname <undercloud_fqdn>
sudo hostnamectl set-hostname --transient <undercloud_fqdn>
```
Updating hosts file
```
127.0.0.1   <undercloud_hostname> <undercloud_fqdn> localhost
```

```
sudo curl -L -o /etc/yum.repos.d/base.repo http://10.60.17.190/centos7/base.repo
sudo curl -L -o /etc/yum.repos.d/updates.repo http://10.60.17.190/centos7/updates.repo
sudo curl -L -o /etc/yum.repos.d/extras.repo http://10.60.17.190/centos7/extras.repo
sudo curl -L -o /etc/yum.repos.d/centosplus.repo http://10.60.17.190/centos7/centosplus.repo
```
A general recommendation is to work with a terminal multiplexer such as screen or tmux.
```
sudo yum -y install tmux
tmux
```
Setting up the required repositories
* Upstream Delorean
```
sudo curl -L -o /etc/yum.repos.d/delorean-mitaka.repo https://trunk.rdoproject.org/centos7-mitaka/current/delorean.repo
sudo curl -L -o /etc/yum.repos.d/delorean-deps-mitaka.repo http://trunk.rdoproject.org/centos7-mitaka/delorean-deps.repo
```
* Delorean mirror _(LAB ONLY)_
```
sudo curl -L -o /etc/yum.repos.d/delorean.repo http://10.60.17.190/dlrn/delorean.repo
sudo curl -L -o /etc/yum.repos.d/delorean-deps.repo http://10.60.17.190/dlrn/delorean-mitaka-testing.repo
```
Installing the tripleo client
```
sudo yum -y install yum-plugin-priorities
sudo yum install -y python-tripleoclient
```
Undercloud configuration, replace ```<undercloud_fqdn>``` and ```<provisioning_interface>``` with appropriate values
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
Edit the ```undercloud.conf``` file to replace the ```<undercloud_fqdn>``` and the ```<provisioning_interface>``` fields. The provisioning interface is the unnumbered one, ```ip a``` can be used to figure out which one.
```
ip a
vi ~/undercloud.conf
```

Undercloud deployment
```
export DIB_YUM_REPO_CONF="/etc/yum.repos.d/delorean-deps.repo /etc/yum.repos.d/delorean.repo"
export NODE_DIST=centos7
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
* CentOS & Delorean Mirror  _(LAB ONLY)_
```
export DIB_YUM_REPO_CONF="/etc/yum.repos.d/delorean-deps.repo /etc/yum.repos.d/delorean.repo /etc/yum.repos.d/base.repo /etc/yum.repos.d/extras.repo /etc/yum.repos.d/updates.repo"
```
```
export NODE_DIST=centos7
mkdir ~/images && cd ~/images
openstack overcloud image build --all
```
Second we create the pnda image
* Ubuntu Mirror _(LAB ONLY)_
```
export DIB_DISTRIBUTION_MIRROR="http://10.60.17.190/ubuntu/trusty/mirror/archive.ubuntu.com/ubuntu"
```

```
cd
git clone https://github.com/pndaproject/pnda-dib-elements.git
export NODE_DIST=ubuntu
export DIB_RELEASE=trusty
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
cd ~/images && disk-image-create -a amd64 -o pnda-image ubuntu $PUPPET_COMMON_ELEMENTS 2>&1 | tee dib-pnda-image.log
```
At this point it might be necessary to customize the images more. Adding some parameters to the kernel cmdline for example. For that purpose we can use guestfish from the libguestfs-tools package. This a convenient tool to modify qcow2 images filesystems in place.
```
sudo yum -y install libguestfs-tools
cd
guestfish -a images/pnda-image.qcow2

Welcome to guestfish, the guest filesystem shell for
editing virtual machine filesystems and disk images.

Type: 'help' for help on commands
      'man' to read the manual
      'quit' to quit the shell

><fs> run
 100% ⟦▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒⟧ 00:00
><fs> list-filesystems
/dev/sda: ext4
><fs> mount /dev/sda /
><fs> vi /etc/default/grub
[...]
><fs> quit
```
In the same spirit, we can setup a known root password using virt-customize.
```
virt-customize -a images/pnda-image.qcow2 --root-password password:cisco
```

Uploading the previously created/customized images into the undercloud's glance.
```
cd ~/images
openstack overcloud image upload
glance image-create  --name pnda-image-initrd --disk-format ari --container-format ari --file pnda-image.initrd --progress
glance image-create  --name pnda-image-vmlinuz --disk-format aki --container-format aki --file pnda-image.vmlinuz --progress
glance image-create  --name pnda-image --disk-format qcow2 --container-format bare --file pnda-image.qcow2 --progress
pnda_initrd_id=$(glance image-list|grep pnda-image-initrd|awk {'print $2'})
pnda_kernel_id=$(glance image-list|grep pnda-image-vmlinuz|awk {'print $2'})
glance image-update --property ramdisk_id=$pnda_initrd_id pnda-image
glance image-update --property kernel_id=$pnda_kernel_id pnda-image
```

## Setting up a virtualized environment

```
sudo yum -y install libvirt virt-install
cat << EOF > /etc/polkit-1/localauthority/50-local.d/50-libvirt-user-stack.pkla
[libvirt Management Access]
Identity=unix-user:stack
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF
sudo usermod -aG libvirt stack
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
ssh-copy-id 192.168.122.1
```
Retrieving the pnda heat templates repository
```
cd
git clone -b pnda-training https://github.com/krickwix/pnda-heat-templates.git
cd pnda-heat-templates
cd
```
Creating and setting up the virtual resources
```
sudo -i
cd /var/lib/libvirt/images
/home/stack/pnda-heat-templates/baremetal/kvm_helpers/create_vms.sh
exit
~/pnda-heat-templates/baremetal/kvm_helpers/create_json.sh
~/pnda-heat-templates/baremetal/kvm_helpers/create_flavors.sh
openstack baremetal import ~/instackenv.json
openstack baremetal configure boot
~/pnda-heat-templates/baremetal/kvm_helpers/tag_nodes.sh
```
```
sudo virsh list --all
```

```
openstack flavor list
```

```
openstack baremetal list
```

```
openstack overcloud profiles list
```

Starting nodes introspection
```
openstack baremetal introspection bulk start

[...]

Setting nodes for introspection to manageable...
Starting introspection of node: 3296dcfd-8417-40d1-ac49-105f2b63f5c1
Starting introspection of node: 9bbac7d8-afc4-434d-93c0-08ea37789176
Starting introspection of node: 978d96a6-455b-4641-a744-d2ad759552bd
Starting introspection of node: 3f78d68d-361a-45a9-9c05-cbf0b2cf0c5c
Starting introspection of node: cd6d0c72-d1a4-4418-9b8d-08e974d3230c
Starting introspection of node: aadeb6e8-937b-42e2-8524-697e9dbe8dd6
Starting introspection of node: bf840e76-c7bd-4be7-abae-10be5b4e5f15
Starting introspection of node: 3fecd5c3-9199-48d4-900c-e4d88ebae4fc
Starting introspection of node: 870bbdfa-6265-470f-8b0b-b75f277c96e8
Starting introspection of node: 9e168fb2-3e3c-465e-8b82-60c0e1bd83ed
Waiting for introspection to finish...
Introspection for UUID 3296dcfd-8417-40d1-ac49-105f2b63f5c1 finished successfully.
Introspection for UUID 9bbac7d8-afc4-434d-93c0-08ea37789176 finished successfully.
Introspection for UUID 978d96a6-455b-4641-a744-d2ad759552bd finished successfully.
Introspection for UUID cd6d0c72-d1a4-4418-9b8d-08e974d3230c finished successfully.
Introspection for UUID aadeb6e8-937b-42e2-8524-697e9dbe8dd6 finished successfully.
Introspection for UUID 3f78d68d-361a-45a9-9c05-cbf0b2cf0c5c finished successfully.
Introspection for UUID 3fecd5c3-9199-48d4-900c-e4d88ebae4fc finished successfully.
Introspection for UUID bf840e76-c7bd-4be7-abae-10be5b4e5f15 finished successfully.
Introspection for UUID 9e168fb2-3e3c-465e-8b82-60c0e1bd83ed finished successfully.
Introspection for UUID 870bbdfa-6265-470f-8b0b-b75f277c96e8 finished successfully.
Setting manageable nodes to available...
Node 3296dcfd-8417-40d1-ac49-105f2b63f5c1 has been set to available.
Node 9bbac7d8-afc4-434d-93c0-08ea37789176 has been set to available.
Node 978d96a6-455b-4641-a744-d2ad759552bd has been set to available.
Node 3f78d68d-361a-45a9-9c05-cbf0b2cf0c5c has been set to available.
Node cd6d0c72-d1a4-4418-9b8d-08e974d3230c has been set to available.
Node aadeb6e8-937b-42e2-8524-697e9dbe8dd6 has been set to available.
Node bf840e76-c7bd-4be7-abae-10be5b4e5f15 has been set to available.
Node 3fecd5c3-9199-48d4-900c-e4d88ebae4fc has been set to available.
Node 870bbdfa-6265-470f-8b0b-b75f277c96e8 has been set to available.
Node 9e168fb2-3e3c-465e-8b82-60c0e1bd83ed has been set to available.
Introspection completed.
```
Observe the results of introspection
```

```

# Deploying PNDA
Setting up the environment file
```
cd ~/pnda-heat-templates
cat > pnda_env.yaml <<EOF
parameter_defaults:
  public_net: 5982b761-802a-4af3-9c0b-c3b457559179
  private_net_name: 'HOTPndaNetwork'
  private_net_cidr: '192.168.10.0/24'
  private_net_pool_end: '192.168.10.250'
  private_net_pool_start: '192.168.10.10'
  private_net_gateway: '192.168.10.1'
  name_servers: [ "144.254.71.184", "173.38.200.100" ]
  image_id: pnda-image
  keystone_user: '$OS_USERNAME'
  keystone_password: '$OS_PASSWORD'
  keystone_tenant: '$OS_TENANT_NAME'
  keystone_auth_url: '$OS_AUTH_URL'
  keystone_region_name: 'regionOne'
  JavaMirror: 'http://10.60.17.100/NFS/repos/java/jdk/8u74-b02/jdk-8u74-linux-x64.tar.gz'
  ClouderaParcelsMirror: 'http://10.60.17.100/mirror/archive.cloudera.com/cdh5/parcels/5.5.2/'
  pnda_apps_container:  'pnda_apps'
  pnda_apps_folder:  'releases'
  pnda_archive_container:  'pnda_archive'
  packages_server_uri: 'http://173.39.246.113/'
  platform_git_repo_uri: 'https://github.com/krickwix/platform-salt.git'
  GitBranch: pnda-training
  git_private_key_file: deploy
  NtpServers: 'ntp.esl.cisco.com'
  signal_transport: TEMP_URL_SIGNAL
  software_config_transport: POLL_TEMP_URL
  package_repository_fs_type: 'swift'
EOF
touch deploy
touch pr_key
swift post pnda_apps
swift post pnda_archive
sudo yum -y install python-pip
sudo pip install jinja2 --upgrade
```
Create the stack
```
cd cli
./heat_cli.py -e barepnda -f pico -b PNDA-2271 -s default -bare true create
```

Updating the undercloud ```/etc/hosts``` file
```
openstack server list -c Networks -c Name | grep -v Networks|awk {'print $4,$2'}|cut -d\= -f2 - |sudo tee -a /etc/hosts
```
