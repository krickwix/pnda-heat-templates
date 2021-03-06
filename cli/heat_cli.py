#!/usr/bin/env python

import argparse
from argparse import RawTextHelpFormatter
import subprocess
import sys
import re
import os
import json
import uuid
import shutil
import yaml
import glob

name_regex = "^[\.a-zA-Z0-9-]+$"

CREATE_INFO = """
Please wait while your PNDA cluster is being created.

This process can last for 1 or 2 hours.
"""

def name_string(v):
    try:
        return re.match(name_regex, v).group(0)
    except:
        raise argparse.ArgumentTypeError("String '%s' may contain only  a-z 0-9 and '-'"%v)

def banner():
    print r"    ____  _   ______  ___ "
    print r"   / __ \/ | / / __ \/   |"
    print r"  / /_/ /  |/ / / / / /| |"
    print r" / ____/ /|  / /_/ / ___ |"
    print r"/_/   /_/ |_/_____/_/  |_|"
    print r""

def os_cmd(cmdline, print_output=False, verbose=False):
    if verbose:
        print(cmdline)

    try:
        if print_output:
            ret = subprocess.check_call(cmdline, shell=True)
        else:
            ret = subprocess.check_output(cmdline, shell=True)
        return ret
    except subprocess.CalledProcessError as e:
        print >>sys.stderr, "Command '{}' failed".format(cmdline)
        sys.exit(1)

def get_args():
    epilog = """examples:
  - create cluster
    $ ./heat_cli.py create -e squirrel-land -f standard -n 5 -o 1 -k 2 -z 3 -s pnda -y

  - destroy existing cluster:
    $ ./heat_cli.py destroy -e squirrel-land

  - view clusters statuses
    $ ./heat_cli.py status

  - view logs output of a deployed PNDA cluster
    $ ./heat_cli.py logs -e squirrel-land"""

    parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter, description='PNDA CLI', epilog=epilog)
    banner()

    parser.add_argument('command', help='Mode of operation', choices=['create', 'resize', 'destroy', 'status', 'logs'])
    parser.add_argument('-y', action='store_true', help='Do not prompt for confirmation before creating or destroying VMs')
    parser.add_argument('-e','--pnda-cluster', type=name_string, help='Namespaced environment for machines in this cluster')
    parser.add_argument('-n','--datanodes', type=int, help='How many datanodes for the hadoop cluster')
    parser.add_argument('-o','--opentsdb-nodes', type=int, help='How many Open TSDB nodes for the hadoop cluster')
    parser.add_argument('-k','--kafka-nodes', type=int, help='How many kafka nodes for the databus cluster')
    parser.add_argument('-z','--zk-nodes', type=int, help='How many zookeeper nodes for the databus cluster')
    parser.add_argument('-f','--flavor', help='PNDA flavor: e.g. "standard"', choices=['pico', 'standard'])
    parser.add_argument('-b','--branch', help='Git branch to use (defaults to master)')
    parser.add_argument('-s','--keypair', help='keypair name for ssh to the bastion server')
    parser.add_argument('-v','--verbose', help='Be more verbose')

    args = parser.parse_args()
    return args

def merge_dicts(base, mergein):
    for element in mergein:
        if element not in base:
            base[element] = mergein[element]
        else:
            for child in mergein[element]:
                base[element][child] = mergein[element][child]

def setup_flavor_templates(flavor, cname):
    resources_dir = '_resources_{}-{}'.format(flavor, cname)
    if os.path.isdir(resources_dir):
        shutil.rmtree(resources_dir)
    os.makedirs(resources_dir)
    os.chdir(resources_dir)
    for yaml_file in glob.glob('../../templates/%s/*.yaml' % flavor):
        shutil.copy(yaml_file, './')
    with open('../../templates/%s/pnda.yaml' % flavor, 'r') as infile:
        pnda_flavor = yaml.load(infile)
    with open('../../templates/pnda.yaml', 'r') as infile:
        pnda_common = yaml.load(infile)
    merge_dicts(pnda_common, pnda_flavor)
    with open('pnda.yaml', 'w') as outfile:
        yaml.dump(pnda_common, outfile, default_flow_style=False)
    with open('../../pnda_env.yaml', 'r') as infile:
        pnda_env = yaml.load(infile)
    with open('../../templates/%s/resource_registry.yaml' % flavor, 'r') as infile:
        resource_registry = yaml.load(infile)
    with open('../../templates/%s/instance_flavors.yaml' % flavor, 'r') as infile:
        instance_flavors = yaml.load(infile)
    merge_dicts(pnda_env, resource_registry)
    merge_dicts(pnda_env, instance_flavors)
    with open('pnda_env.yaml', 'w') as outfile:
        yaml.dump(pnda_env, outfile, default_flow_style=False)
    shutil.copytree('../../scripts', './scripts')
    shutil.copy('../../deploy', './')

def create_cluster(args):
    pnda_cluster = args.pnda_cluster
    datanodes = args.datanodes
    tsdbnodes = args.opentsdb_nodes
    kafkanodes = args.kafka_nodes
    zknodes = args.zk_nodes
    branch = args.branch
    flavor = args.flavor
    keypair = args.keypair
    command = args.command

    if flavor == 'standard':
        if datanodes == None:
            datanodes = 3
        if tsdbnodes == None:
            tsdbnodes = 1
        if kafkanodes == None:
            kafkanodes = 2
        if zknodes == None:
            zknodes = 3
    elif flavor == 'pico':
        if datanodes == None:
            datanodes = 1
        if tsdbnodes == None:
            tsdbnodes = 0
        if kafkanodes == None:
            kafkanodes = 1
        if zknodes == None:
            zknodes = 0

    stack_params = []

    stack_params.append('--parameter ZookeeperNodes={}'.format(zknodes))
    stack_params.append('--parameter KafkaNodes={}'.format(kafkanodes))
    stack_params.append('--parameter DataNodes={}'.format(datanodes))
    stack_params.append('--parameter OpentsdbNodes={}'.format(tsdbnodes))
    stack_params.append('--parameter PndaFlavor={}'.format(flavor))
    stack_params.append('--parameter KeyName={}'.format(keypair))
    if branch:
        stack_params.append('--parameter GitBranch={}'.format(branch))
    if command == 'resize':
        an_id = uuid.uuid4()
        stack_params.append('--parameter DeploymentID={}'.format(an_id))

    stack_params.append(pnda_cluster)
    stack_params_string = ' '.join(stack_params)

    if command == 'create':
        print CREATE_INFO
        setup_flavor_templates(flavor, pnda_cluster)
        cmdline = 'openstack stack create --timeout 120 --wait --template {} --environment {} {}'.format('pnda.yaml',
                                                                                    'pnda_env.yaml',
                                                                                    stack_params_string)
    elif command == 'resize':
        os.chdir('_resources_{}-{}'.format(flavor, pnda_cluster))
        stack_params_string = ' '.join(stack_params)
        cmdline = 'openstack stack update --timeout 120 --wait --template {} --environment {} {}'.format('pnda.yaml',
                                                                                    'pnda_env.yaml',
                                                                                    stack_params_string)
    print cmdline
    os_cmd(cmdline, print_output=True)
    console_info = subprocess.check_output(['nova','list', '--name', "%s-cdh-edge" % pnda_cluster, '--fields', 'networks'])
    console_ip = re.search('([0-9]*\\.[0-9]*\\.[0-9]*\\.[0-9]*)', console_info)
    if console_ip:
        print 'Use the PNDA console to get started: http://%s' % console_ip.group(1)
    else:
        print 'Could not find IP address for PNDA console'

def destroy_cluster(args):
    pnda_cluster = args.pnda_cluster

    os_cmd('openstack stack delete --yes --wait {}'.format(pnda_cluster), print_output=True)

def get_pnda_cluster_info(cluster_name):
    hosts = os_cmd('openstack server list --format json --name "{}"'.format(cluster_name))
    hosts = json.loads(hosts)
    # bastion informations
    bastion = next(h for h in hosts if h['Name'] == '{}-bastion'.format(cluster_name))
    bastion_ip = bastion['Networks'].split(',')[-1]

    # edge node informations
    edge = next(h for h in hosts if h['Name'] == '{}-cdh-edge'.format(cluster_name))
    edge_ip = edge['Networks'].split(',')[0].split('=')[-1]

    return { 'bastion' : {'public-ip': bastion_ip},
             'edge'    : {'private-ip': edge_ip} }


def get_salt_highstate_output(stack):
    return os_cmd('openstack stack output show {} salt_highstate --format value --column output_value'.format(stack))

def get_salt_orchestrate_output(stack):
    return os_cmd('openstack stack output show {} salt_orchestrate --format value --column output_value'.format(stack))


def print_pnda_cluster_status(stack, verbose=False):
    stack_name = stack['Stack Name']
    stack_status = stack['Stack Status']

    print '[P] {} - {}'.format(stack_name, stack_status)
    if stack_status in ['CREATE_COMPLETE', 'UPDATE_COMPLETE']:
        info = get_pnda_cluster_info(stack_name)
        print "    |- Bastion public IP: {}".format(info['bastion']['public-ip'])
        print "    |- Edge node private IP: {}".format(info['edge']['private-ip'])

def clusters_status(args):
    stacks = os_cmd('openstack stack list --format json', print_output=False)
    stacks = json.loads(stacks)

    for stack in stacks:
        print_pnda_cluster_status(stack, verbose=args.verbose)

def print_pnda_cluster_logs(args):
    stack_name = args.pnda_cluster

    print get_salt_highstate_output(stack_name)
    print get_salt_orchestrate_output(stack_name)

def main():
    args = get_args()

    if args.command in ['create', 'resize']:
        create_cluster(args)
    elif args.command == 'destroy':
        destroy_cluster(args)
    elif args.command == 'status':
        clusters_status(args)
    elif args.command == 'logs':
        print_pnda_cluster_logs(args)

if __name__ == "__main__":
    main()
