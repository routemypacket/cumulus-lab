#!/bin/bash

check_state(){
if [ "$?" != "0" ]; then
    echo "ERROR Could not bring up last series of devices, there was an error of some kind!"
    exit 1
fi
}

cd ./sim-yahoojp
echo "Currently in directory: $(pwd)"

# Force Colored output for Vagrant when being run in CI Pipeline
export VAGRANT_FORCE_COLOR=true

echo "#####################################"
echo "#   Starting the MGMT Server...     #"
echo "#####################################"
vagrant up oob-mgmt-server oob-mgmt-switch netq-ts --no-parallel
check_state

echo "##########################################"
echo "#   Starting the network...     #"
echo "##########################################"
vagrant up leaf01 leaf02 spine01 spine02 exit01 exit02 --no-parallel
check_state

ip_address=$(vagrant ssh-config oob-mgmt-server | grep HostName | cut -d " " -f4)

echo "Detected $ip_address for the OOB-MGMT-SERVER"

vagrant scp ../automation oob-mgmt-server:/home/vagrant
vagrant scp ../tests oob-mgmt-server:/home/vagrant
vagrant ssh oob-mgmt-server -c "ls -lha /home/vagrant"
