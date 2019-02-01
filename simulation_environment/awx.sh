
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
git clone https://github.com/ansible/awx.git && cd awx/installer
ansible-playbook -i inventory install.yml
#
#
# Create port forwarding for AWX
#

cd /home/thgadmin/dev-dir/simulation_environment; KVM_HOST_IP=`hostname -I | cut -d' ' -f1`; UTIL_AWX_IP=$(vagrant ssh oob-mgmt-util -c "hostname -I | cut -d' ' -f1" | tr -dc '[[:print:]]' ); UTIL_AWX_IP_PORT="$UTIL_AWX_IP:80"
iptables -t nat -A PREROUTING -p tcp -d $KVM_HOST_IP --dport 8080 -j DNAT --to-destination $UTIL_AWX_IP_PORT

iptables -I FORWARD -m state -d $UTIL_AWX_IP/32 --state NEW,RELATED,ESTABLISHED -j ACCEPT
