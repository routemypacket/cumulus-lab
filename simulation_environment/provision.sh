#!/bin/bash

# Bootstrap oob-mgmt-server and oob-mgmt-switch
vagrant up oob-mgmt-server oob-mgmt-switch

# Bootstrap everything else
vagrant up

# Initialize AWX
vagrant ssh oob-mgmt-util -c "sudo docker ps"

# Setup external access to oob-mgmt-util
KVM_HOST_IP=`hostname -I | cut -d' ' -f1`; UTIL_AWX_IP=$(vagrant ssh oob-mgmt-util -c "hostname -I | cut -d' ' -f1" | tr -dc '[[:print:]]' ); UTIL_AWX_IP_PORT="$UTIL_AWX_IP:80"
sudo iptables -t nat -D PREROUTING 1
sudo iptables -t nat -A PREROUTING -p tcp -d $KVM_HOST_IP --dport 8080 -j DNAT --to-destination $UTIL_AWX_IP_PORT
sudo iptables -I FORWARD -m state -d $UTIL_AWX_IP/32 --state NEW,RELATED,ESTABLISHED -j ACCEPT

# Display the external URL of Utility services
echo "***** AWX URL: http://$KVM_HOST_IP:8080 *****"
