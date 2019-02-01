#!/bin/bash

echo "#################################"
echo "  Running config_server.sh"
echo "#################################"
sudo su

echo " ### Overwriting /etc/netplan/01-netcfg.yaml ###"
cat <<EOT > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
      dhcp6: false
      optional: true
      nameservers:
        addresses: [4.2.2.1, 4.2.2.2, 208.67.220.220]
    eth1:
      addresses:
        - 10.0.3.123/25

EOT
netplan apply

# Configure AWX

sh -c 'echo "deb http://archive.ubuntu.com/ubuntu bionic main universe" >> /etc/apt/sources.list'
sh -c 'echo "deb http://archive.ubuntu.com/ubuntu bionic-security main universe" >> /etc/apt/sources.list'
sh -c 'echo "deb http://archive.ubuntu.com/ubuntu bionic-updates main universe" >> /etc/apt/sources.list'
apt update
apt-add-repository --yes --update ppa:ansible/ansible
apt install ansible -y
apt install docker.io -y
apt install python-pip -y
pip install docker
apt install nodejs npm -y
npm install npm --global
git clone https://github.com/ansible/awx.git; cd awx/installer
ansible-playbook -i inventory install.yml

useradd cumulus -m -s /bin/bash
echo "cumulus:CumulusLinux!" | chpasswd
sed "s/PasswordAuthentication no/PasswordAuthentication yes/" -i /etc/ssh/sshd_config

## Convenience code. This is normally done in ZTP.
echo "cumulus ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/10_cumulus
mkdir /home/cumulus/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzH+R+UhjVicUtI0daNUcedYhfvgT1dbZXgY33Ibm4MOo+X84Iwuzirm3QFnYf2O3uyZjNyrA6fj9qFE7Ekul4bD6PCstQupXPwfPMjns2M7tkHsKnLYjNxWNql/rCUxoH2B6nPyztcRCass3lIc2clfXkCY9Jtf7kgC2e/dmchywPV5PrFqtlHgZUnyoPyWBH7OjPLVxYwtCJn96sFkrjaG9QDOeoeiNvcGlk4DJp/g9L4f2AaEq69x8+gBTFUqAFsD8ecO941cM8sa1167rsRPx7SK3270Ji5EUF3lZsgpaiIgMhtIB/7QNTkN9ZjQBazxxlNVN6WthF8okb7OSt" >> /home/cumulus/.ssh/authorized_keys
chmod 700 -R /home/cumulus
chown -R cumulus:cumulus /home/cumulus
chmod 600 /home/cumulus/.ssh/*
chmod 700 /home/cumulus/.ssh


# Other stuff
ping 8.8.8.8 -c2
if [ "$?" == "0" ]; then
  apt-get update -qy
  apt-get install lldpd ntp ntpdate -qy
  echo "configure lldp portidsubtype ifname" > /etc/lldpd.d/port_info.conf
fi

# Set Timezone
cat << EOT > /etc/timezone
Etc/UTC
EOT

# Apply Timezone Now
# dpkg-reconfigure -f noninteractive tzdata

# Write NTP Configuration
cat << EOT > /etc/ntp.conf
# /etc/ntp.conf, configuration for ntpd; see ntp.conf(5) for help

driftfile /var/lib/ntp/ntp.drift

statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable

server 192.168.0.254 iburst

# By default, exchange time with everybody, but don't allow configuration.
restrict -4 default kod notrap nomodify nopeer noquery
restrict -6 default kod notrap nomodify nopeer noquery

# Local users may interrogate the ntp server more closely.
restrict 127.0.0.1
restrict ::1

# Specify interfaces, don't listen on switch ports
interface listen eth0
EOT

sudo systemctl enable ntp.service
sudo systemctl start ntp.service

echo "#################################"
echo "   Finished"
echo "#################################"
