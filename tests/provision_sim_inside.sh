#!/bin/bash

function error() {
  echo -e "\e[0;33mERROR: Provisioning if the simulation failed while running the command $BASH_COMMAND at line $BASH_LINENO.\e[0m" >&2
  exit 1
}

trap error ERR

cd ./automation

set -x

# Enable Colored Output when Running Ansible in the CI pipeline
export ANSIBLE_FORCE_COLOR=true

echo "#### Pinging all nodes... ###"
ansible all -m ping

echo "#### Deploying Dataplane... ###"
ansible-playbook ./automate.yml

