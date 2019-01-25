#!/bin/bash

echo "################################################"
echo "  Running Management Server Setup (config_oob_server.sh)..."
echo "################################################"
echo -e "\n This script was written for CumulusCommunity/vx_oob_server"
echo " Detected vagrant user is: $username"

echo " ### Overwriting /etc/network/interfaces ###"
cat <<EOT > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    alias Connects (via NAT) To the Internet

auto eth1
iface eth1
    alias Faces the Internal Management Network
    address 10.0.3.126/25

EOT

cat << EOT > /etc/ntp.conf
# /etc/ntp.conf, configuration for ntpd; see ntp.conf(5) for help

driftfile /var/lib/ntp/ntp.drift

statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable

server 0.cumulusnetworks.pool.ntp.org iburst
server 1.cumulusnetworks.pool.ntp.org iburst
server 2.cumulusnetworks.pool.ntp.org iburst
server 3.cumulusnetworks.pool.ntp.org iburst


# By default, exchange time with everybody, but don't allow configuration.
restrict -4 default kod notrap nomodify nopeer noquery
restrict -6 default kod notrap nomodify nopeer noquery

# Local users may interrogate the ntp server more closely.
restrict 127.0.0.1
restrict ::1

# Specify interfaces, don't listen on switch ports
interface listen eth1
EOT

echo " ### Pushing Ansible Hosts File ###"
mkdir -p /etc/ansible
cat << EOT > /etc/ansible/hosts
[oob-switch]
oob-mgmt-switch ansible_host=10.0.3.1 ansible_user=cumulus


[leaf]
leaf01 ansible_host=10.0.3.11 ansible_user=cumulus
leaf02 ansible_host=10.0.3.12 ansible_user=cumulus
leaf04 ansible_host=10.0.3.14 ansible_user=cumulus
leaf03 ansible_host=10.0.3.13 ansible_user=cumulus
leaf04 ansible_host=10.0.3.14 ansible_user=cumulus
leaf05 ansible_host=10.0.3.15 ansible_user=cumulus
leaf06 ansible_host=10.0.3.16 ansible_user=cumulus
leaf07 ansible_host=10.0.3.17 ansible_user=cumulus
leaf08 ansible_host=10.0.3.18 ansible_user=cumulus
leaf09 ansible_host=10.0.3.19 ansible_user=cumulus
leaf10 ansible_host=10.0.3.20 ansible_user=cumulus
leaf11 ansible_host=10.0.3.21 ansible_user=cumulus
leaf12 ansible_host=10.0.3.22 ansible_user=cumulus
leaf13 ansible_host=10.0.3.23 ansible_user=cumulus
leaf14 ansible_host=10.0.3.24 ansible_user=cumulus
leaf15 ansible_host=10.0.3.25 ansible_user=cumulus
leaf16 ansible_host=10.0.3.26 ansible_user=cumulus

[spine]
spine01 ansible_host=10.0.3.31 ansible_user=cumulus
spine02 ansible_host=10.0.3.32 ansible_user=cumulus
spine03 ansible_host=10.0.3.33 ansible_user=cumulus
spine04 ansible_host=10.0.3.34 ansible_user=cumulus

[exit]
exit01 ansible_host=10.0.3.41 ansible_user=cumulus
exit02 ansible_host=10.0.3.42 ansible_user=cumulus

[internet]
netq ansible_host=10.0.3.49 ansible_user=cumulus

[netq]
netq ansible_host=10.0.3.50 ansible_user=cumulus

[host]
server01 ansible_host=10.0.3.51 ansible_user=cumulus
server02 ansible_host=10.0.3.52 ansible_user=cumulus
server03 ansible_host=10.0.3.53 ansible_user=cumulus
server04 ansible_host=10.0.3.54 ansible_user=cumulus
server05 ansible_host=10.0.3.55 ansible_user=cumulus
server06 ansible_host=10.0.3.56 ansible_user=cumulus
server07 ansible_host=10.0.3.57 ansible_user=cumulus
server08 ansible_host=10.0.3.58 ansible_user=cumulus
server09 ansible_host=10.0.3.59 ansible_user=cumulus
server10 ansible_host=10.0.3.60 ansible_user=cumulus
server11 ansible_host=10.0.3.61 ansible_user=cumulus
server12 ansible_host=10.0.3.62 ansible_user=cumulus
server13 ansible_host=10.0.3.63 ansible_user=cumulus
server14 ansible_host=10.0.3.64 ansible_user=cumulus
server15 ansible_host=10.0.3.65 ansible_user=cumulus
server16 ansible_host=10.0.3.66 ansible_user=cumulus
EOT

echo " ### Pushing DHCP File ###"
cat << EOT > /etc/dhcp/dhcpd.conf
ddns-update-style none;

authoritative;

log-facility local7;

option www-server code 72 = ip-address;
option cumulus-provision-url code 239 = text;

# Create an option namespace called ONIE
# See: https://github.com/opencomputeproject/onie/wiki/Quick-Start-Guide#advanced-dhcp-2-vivsoonie/onie/
option space onie code width 1 length width 1;
# Define the code names and data types within the ONIE namespace
option onie.installer_url code 1 = text;
option onie.updater_url   code 2 = text;
option onie.machine       code 3 = text;
option onie.arch          code 4 = text;
option onie.machine_rev   code 5 = text;
# Package the ONIE namespace into option 125
option space vivso code width 4 length width 1;
option vivso.onie code 42623 = encapsulate onie;
option vivso.iana code 0 = string;
option op125 code 125 = encapsulate vivso;
class "onie-vendor-classes" {
  # Limit the matching to a request we know originated from ONIE
  match if substring(option vendor-class-identifier, 0, 11) = "onie_vendor";
  # Required to use VIVSO
  option vivso.iana 01:01:01;

  ### Example how to match a specific machine type ###
  #if option onie.machine = "" {
  #  option onie.installer_url = "";
  #  option onie.updater_url = "";
  #}
}

# OOB Management subnet
shared-network LOCAL-NET{

subnet 10.0.3.0 netmask 255.255.255.128 {
  range 10.0.3.90 10.0.3.120;
  option domain-name-servers 10.0.3.126;
  option domain-name "simulation";
  default-lease-time 172800;  #2 days
  max-lease-time 345600;      #4 days
  option www-server 10.0.3.126;
  option default-url = "http://10.0.3.126/onie-installer";
  option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";
  option ntp-servers 10.0.3.126;
}

}

#include "/etc/dhcp/dhcpd.pools";
include "/etc/dhcp/dhcpd.hosts";
EOT

echo " ### Push DHCP Host Config ###"
cat << EOT > /etc/dhcp/dhcpd.hosts
group {

  option domain-name-servers 10.0.3.126;
  option domain-name "simulation";
  option routers 10.0.3.126;
  option www-server 10.0.3.126;
  option default-url = "http://10.0.3.126/onie-installer";

  host oob-mgmt-switch {hardware ethernet a0:00:00:00:00:71; fixed-address 10.0.3.1; option host-name "oob-mgmt-switch"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }

  host leaf01 {hardware ethernet a0:00:00:00:00:11; fixed-address 10.0.3.11; option host-name "leaf01"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host leaf02 {hardware ethernet a0:00:00:00:00:12; fixed-address 10.0.3.12; option host-name "leaf02"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host leaf03 {hardware ethernet a0:00:00:00:00:13; fixed-address 10.0.3.13; option host-name "leaf03"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host leaf04 {hardware ethernet a0:00:00:00:00:14; fixed-address 10.0.3.14; option host-name "leaf04"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host leaf05 {hardware ethernet a0:00:00:00:00:15; fixed-address 10.0.3.15; option host-name "leaf05"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host leaf06 {hardware ethernet a0:00:00:00:00:16; fixed-address 10.0.3.16; option host-name "leaf06"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host leaf07 {hardware ethernet a0:00:00:00:00:17; fixed-address 10.0.3.17; option host-name "leaf07"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host leaf08 {hardware ethernet a0:00:00:00:00:18; fixed-address 10.0.3.18; option host-name "leaf08"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host leaf09 {hardware ethernet a0:00:00:00:00:19; fixed-address 10.0.3.19; option host-name "leaf09"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host leaf10 {hardware ethernet a0:00:00:00:00:20; fixed-address 10.0.3.20; option host-name "leaf10"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host leaf11 {hardware ethernet a0:00:00:00:00:21; fixed-address 10.0.3.21; option host-name "leaf11"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host leaf12 {hardware ethernet a0:00:00:00:00:22; fixed-address 10.0.3.22; option host-name "leaf12"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host leaf13 {hardware ethernet a0:00:00:00:00:23; fixed-address 10.0.3.23; option host-name "leaf13"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host leaf14 {hardware ethernet a0:00:00:00:00:24; fixed-address 10.0.3.24; option host-name "leaf14"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host leaf15 {hardware ethernet a0:00:00:00:00:25; fixed-address 10.0.3.25; option host-name "leaf15"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host leaf16 {hardware ethernet a0:00:00:00:00:26; fixed-address 10.0.3.26; option host-name "leaf16"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }

  host spine01 {hardware ethernet a0:00:00:00:00:31; fixed-address 10.0.3.31; option host-name "spine01"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host spine02 {hardware ethernet a0:00:00:00:00:32; fixed-address 10.0.3.32; option host-name "spine02"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host spine03 {hardware ethernet a0:00:00:00:00:33; fixed-address 10.0.3.33; option host-name "spine03"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host spine04 {hardware ethernet a0:00:00:00:00:34; fixed-address 10.0.3.34; option host-name "spine04"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }

  host exit01 {hardware ethernet a0:00:00:00:00:41; fixed-address 10.0.3.41; option host-name "exit01"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }
  host exit02 {hardware ethernet a0:00:00:00:00:42; fixed-address 10.0.3.42; option host-name "exit02"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }

  host internet {hardware ethernet a0:00:00:00:00:49; fixed-address 10.0.3.49; option host-name "internet"; option cumulus-provision-url "http://10.0.3.126/ztp_oob.sh";  }

  host netq {hardware ethernet a0:00:00:00:00:50; fixed-address 10.0.3.50; option host-name "netq"; }

  host server01 {hardware ethernet a0:00:00:00:00:11; fixed-address 10.0.3.11; option host-name "server01"; }
  host server02 {hardware ethernet a0:00:00:00:00:12; fixed-address 10.0.3.12; option host-name "server02"; }
  host server03 {hardware ethernet a0:00:00:00:00:13; fixed-address 10.0.3.13; option host-name "server03"; }
  host server04 {hardware ethernet a0:00:00:00:00:14; fixed-address 10.0.3.14; option host-name "server04"; }
  host server05 {hardware ethernet a0:00:00:00:00:15; fixed-address 10.0.3.15; option host-name "server05"; }
  host server06 {hardware ethernet a0:00:00:00:00:16; fixed-address 10.0.3.16; option host-name "server06"; }
  host server07 {hardware ethernet a0:00:00:00:00:17; fixed-address 10.0.3.17; option host-name "server07"; }
  host server08 {hardware ethernet a0:00:00:00:00:18; fixed-address 10.0.3.18; option host-name "server08"; }
  host server09 {hardware ethernet a0:00:00:00:00:19; fixed-address 10.0.3.19; option host-name "server09"; }
  host server10 {hardware ethernet a0:00:00:00:00:20; fixed-address 10.0.3.20; option host-name "server10"; }
  host server11 {hardware ethernet a0:00:00:00:00:21; fixed-address 10.0.3.21; option host-name "server11"; }
  host server12 {hardware ethernet a0:00:00:00:00:22; fixed-address 10.0.3.22; option host-name "server12"; }
  host server13 {hardware ethernet a0:00:00:00:00:23; fixed-address 10.0.3.23; option host-name "server13"; }
  host server14 {hardware ethernet a0:00:00:00:00:24; fixed-address 10.0.3.24; option host-name "server14"; }
  host server15 {hardware ethernet a0:00:00:00:00:25; fixed-address 10.0.3.25; option host-name "server15"; }
  host server16 {hardware ethernet a0:00:00:00:00:26; fixed-address 10.0.3.26; option host-name "server16"; }


}#End of static host group
EOT

chmod 755 -R /etc/dhcp/*
systemctl enable dhcpd
systemctl restart dhcpd

echo " ### Push Hosts File ###"
cat << EOT > /etc/hosts
127.0.0.1 localhost
127.0.1.1 oob-mgmt-server

10.0.3.126 oob-mgmt-server

10.0.3.11 leaf01
10.0.3.12 leaf02
10.0.3.14 leaf04
10.0.3.13 leaf03
10.0.3.14 leaf04
10.0.3.15 leaf05
10.0.3.16 leaf06
10.0.3.17 leaf07
10.0.3.18 leaf08
10.0.3.19 leaf09
10.0.3.20 leaf10
10.0.3.21 leaf11
10.0.3.22 leaf12
10.0.3.23 leaf13
10.0.3.24 leaf14
10.0.3.25 leaf15
10.0.3.26 leaf16

10.0.3.31 spine01
10.0.3.32 spine02
10.0.3.33 spine03
10.0.3.34 spine04

10.0.3.41 exit01
10.0.3.42 exit02
10.0.3.49 internet

10.0.3.50 netq

10.0.3.51 server01
10.0.3.52 server02
10.0.3.53 server03
10.0.3.54 server04
10.0.3.55 server05
10.0.3.56 server06
10.0.3.57 server07
10.0.3.58 server08
10.0.3.59 server09
10.0.3.60 server10
10.0.3.61 server11
10.0.3.62 server12
10.0.3.63 server13
10.0.3.64 server14
10.0.3.65 server15
10.0.3.66 server16

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOT

echo " ### Creating SSH keys for cumulus user ###"
mkdir -p /home/cumulus/.ssh
#/usr/bin/ssh-keygen -b 2048 -t rsa -f /home/cumulus/.ssh/id_rsa -q -N ""
cat <<EOT > /home/cumulus/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAsx/kflIY1YnFLSNHWjVHHnWIX74E9XW2V4GN9yG5uDDqPl/O
CMLs4q5t0BZ2H9jt7smYzcqwOn4/ahROxJLpeGw+jwrLULqVz8HzzI57NjO7ZB7C
py2IzcVjapf6wlMaB9gepz8s7XEQmrLN5SHNnJX15AmPSbX+5IAtnv3ZnIcsD1eT
6xarZR4GVJ8qD8lgR+zozy1cWMLQiZ/erBZK42hvUAznqHojb3BpZOAyaf4PS+H9
gGhKuvcfPoAUxVKgBbA/HnDveNXDPLGtdeu67ET8e0it9u9CYuRFBd5WbIKWoiID
IbSAf+0DU5DfWY0AWs8cZTVTelrYRfKJG+zkrQIDAQABAoIBAAqDBp+7JaXybdXW
SiurEL9i2lv0BMp62/aKrdAg9Iswo66BZM/y0IAFCIC7sLbxvhTTU9pP2MO2APay
tmSm0ni0sX8nfQMB0CTfFvWcLvLhWk/n1jiFXY/l042/2YFp6w8mybW66WINzpGl
iJu3vh9AVavKO9Rxj8HNG+BGuWyMEQ7TB4JLIGOglfapHlSFzjBxlMTcVA4mWyDd
bztzh+Hn/J7Mmqw+FqmFXha+IWbojiMGTm1wS/78Iy7YgWpUYTP5CXGewC9fGnoK
H3WvZDD7puTWa8Qhd5p73NSEe/yUd5Z0qmloij7lUVX9kFNVZGS19BvbjAdj7ZL6
OCVLOkECgYEA3I7wDN0pmbuEojnvG3k09KGX4bkJRc/zblbWzC83rFzPWTn7uryL
n28JZMk1/DCEGWtroOQL68P2zSGdF6Yp3PAqsSKHks9fVJsJ0F3ZlXkZHtRFfNI7
i0dl5SsSWlnDPiSnC4bshM25vYb4qd3vij7vvHzb3rA3255u69aU0DkCgYEAz+iA
qoLEja9kTR+sqbP9zvHUWQ/xtKfNCQ5nnjXc7tZ7XUGEf0UTMrAgOKcZXKDq6g5+
hNTkEDPUpPwGhA4iAPbA96RNWh/bwClFQEkBHU3oHPzKcL2Utvo/c6pAb44f2bGD
9kS4B/sumQxvUYM41jfwXDFTNPXN/SBn2XnWUBUCgYBoRug1nMbTWTXvISbsPVUN
J+1QGhTJPfUgwMvTQ6u1wTeDPwfGFOiKW4v8a6krb6C1B/Wd3tPIByGDgJXuHXCD
dcUpdGLWxVaUAK0WJ5j8s4Ft8vxbdGYUhpAlVkTaFMBbfCbCK2tdqopbkhm07ioX
mYPtALdPRM9T9UcKF6zJ+QKBgQCd57lpR55e+foU9VyfG1xGg7dC2XA7RELegPlD
2SbuoynY/zzRqLXXBpvCS29gwbsJf26qFkMM50C2+c89FrrOvpp6u2ggbhfpz66Q
D6JwDk6fTYO3stUzT8dHYuRDlc8s+L0AGtsm/Kg8h4w4fZB6asv8SV4n2BTWDnmx
W+7grQKBgQCm52n2zAOh7b5So1upvuV7REHiAmcNNCHhuXFU75eZz7DQlqazjTzn
CNr0QLZlgxpAg0o6iqwUaduck4655bSrClg4PtnzuDe5e2RuPNSiyZRbUmmiYIYp
i06Z/SJZSH8a1AjEh2I8ayxIEIESpmyhn1Rv1aUT6IjmIQjgbxWxGg==
-----END RSA PRIVATE KEY-----
EOT

cat <<EOT > /home/cumulus/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzH+R+UhjVicUtI0daNUcedYhfvgT1dbZXgY33Ibm4MOo+X84Iwuzirm3QFnYf2O3uyZjNyrA6fj9qFE7Ekul4bD6PCstQupXPwfPMjns2M7tkHsKnLYjNxWNql/rCUxoH2B6nPyztcRCass3lIc2clfXkCY9Jtf7kgC2e/dmchywPV5PrFqtlHgZUnyoPyWBH7OjPLVxYwtCJn96sFkrjaG9QDOeoeiNvcGlk4DJp/g9L4f2AaEq69x8+gBTFUqAFsD8ecO941cM8sa1167rsRPx7SK3270Ji5EUF3lZsgpaiIgMhtIB/7QNTkN9ZjQBazxxlNVN6WthF8okb7OSt
EOT

cat /home/cumulus/.ssh/id_rsa.pub >> /home/cumulus/.ssh/authorized_keys
cp /home/cumulus/.ssh/id_rsa.pub /var/www/html/authorized_keys

chmod 700 -R /home/cumulus/.ssh
chown cumulus:cumulus -R /home/cumulus/.ssh

echo " ### Install rsync ###"
apt install rsync -y

echo " ### Pushing ZTP Script ###"
cat << EOT > /var/www/html/ztp_oob.sh
#!/bin/bash

###################
# Simple ZTP Script
###################

function error() {
  echo -e "\e[0;33mERROR: The Zero Touch Provisioning script failed while running the command \$BASH_COMMAND at line \$BASH_LINENO.\e[0m" >&2
}
trap error ERR

sed -i '/iface eth0/a \ vrf mgmt' /etc/network/interfaces
cat <<EOT2 >> /etc/network/interfaces
auto mgmt
iface mgmt
  address 127.0.0.1/8
  vrf-table auto
EOT2

# Setup SSH key authentication for Ansible
mkdir -p /home/cumulus/.ssh
#wget -O /home/cumulus/.ssh/authorized_keys http://10.0.3.126/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzH+R+UhjVicUtI0daNUcedYhfvgT1dbZXgY33Ibm4MOo+X84Iwuzirm3QFnYf2O3uyZjNyrA6fj9qFE7Ekul4bD6PCstQupXPwfPMjns2M7tkHsKnLYjNxWNql/rCUxoH2B6nPyztcRCass3lIc2clfXkCY9Jtf7kgC2e/dmchywPV5PrFqtlHgZUnyoPyWBH7OjPLVxYwtCJn96sFkrjaG9QDOeoeiNvcGlk4DJp/g9L4f2AaEq69x8+gBTFUqAFsD8ecO941cM8sa1167rsRPx7SK3270Ji5EUF3lZsgpaiIgMhtIB/7QNTkN9ZjQBazxxlNVN6WthF8okb7OSt" >> /home/cumulus/.ssh/authorized_keys
chmod 700 -R /home/cumulus/.ssh
chown cumulus:cumulus -R /home/cumulus/.ssh


echo "cumulus ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/10_cumulus

# Setup NTP
sed -i '/^server [1-3]/d' /etc/ntp.conf
sed -i 's/^server 0.cumulusnetworks.pool.ntp.org iburst/server 10.0.3.126 iburst/g' /etc/ntp.conf

ping 8.8.8.8 -c2
if [ "\$?" == "0" ]; then
  apt-get update -qy
  apt-get install ntpdate -qy
fi

# Edit /etc/apt/sources.list and add the Debian repository
sh -c 'echo "deb http://ftp.us.debian.org/debian/ jessie main contrib non-free" >> /etc/apt/sources.list'

# Download and execute Salt Bootstrap and to point to the Salt Master
curl -L https://bootstrap.saltstack.com -o install_salt.sh && sudo sh install_salt.sh -P -X -A 10.0.3.126

# Stop and disable salt-minion service
systemctl stop salt-minion.service && systemctl disable salt-minion.service

# Add salt-minion to systemd vrf based services and reload systemd daemon to regenerate systemd files
sh -c 'echo "salt-minion" >> /etc/vrf/systemd.conf' && systemctl daemon-reload

# Start and enable salt-minion on the mgmt VRF
systemctl start salt-minion@mgmt && systemctl enable salt-minion@mgmt

nohup bash -c 'sleep 2; shutdown now -r "Rebooting to Complete ZTP"' &
exit 0
#CUMULUS-AUTOPROVISIONING
EOT

echo "############################################"
echo "      DONE!"
echo "############################################"
