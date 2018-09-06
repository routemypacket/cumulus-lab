#!/bin/bash

# Error out if anything fails.
set -e
set -x

wait_oob_mgmt_server ()
{ # Wait function for oob-mgmt-server
  limit=10
  iter=0
  vagrant ssh oob-mgmt-server -c "echo 'ssh successful'"
  while [ $? -gt 0 ] && [ $iter -lt $limit ]
  do
    sleep 5
    echo "Trying to ssh on oob-mgmt-server"
    ((iter++))
    vagrant ssh oob-mgmt-server -c "echo 'ssh successful'"
  done
}


echo "Vagrant version is: $(/usr/bin/vagrant --version)"

echo "Libvirt version is: $(/usr/sbin/libvirtd --version)"

echo "Check that the machine supports virtualization..."
/usr/sbin/kvm-ok

echo "Installing Vagrant Plugins..."
vagrant plugin install vagrant-libvirt vagrant-mutate vagrant-scp

echo "Check for NetQ Image..."
vagrant box list | grep netq130 | grep libvirt

#script to clean up libvirt simulations
echo "Cleaning pre-existing simulations"
vms=$(virsh list --all | grep sim-yahoojp | grep -e '^ [1-9]' | awk '{print $2}')

for item in $vms; do
  echo "$item"
    virsh destroy $item
    virsh undefine $item
    virsh vol-delete --pool default $item".img"
done

echo "Removing Vagrant machine indexes..."
rm -rfv ./.vagrant/
rm -fv ~/.vagrant.d/data/machine-index/index

