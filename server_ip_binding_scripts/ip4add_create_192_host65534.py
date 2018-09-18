import subprocess
import ipaddress
from subprocess import Popen, PIPE

mask = '/17'

network = ipaddress.ip_network('192.168.0.0/17')

for i in network.hosts():
    i=str(i)
    i = i + mask
    toping = Popen(['ip', 'address', 'add', i, 'dev', 'ens3f1' ], stdout=PIPE)
    output=toping.communicate()[0]
    hostalive=toping.returncode
    if hostalive ==0:
        print (i,'added')
    else:
        print (i,'problem')

toping = Popen(['ip', 'address', 'delete', '192.168.0.3/17', 'dev', 'ens3f1' ], stdout=PIPE)
output=toping.communicate()[0]
toping = Popen(['ip', 'address', 'delete', '192.168.0.1/17', 'dev', 'ens3f1' ], stdout=PIPE)
output=toping.communicate()[0]

toping = Popen(['ip', 'address', 'delete', '192.168.0.2/17', 'dev', 'ens3f1' ], stdout=PIPE)
output=toping.communicate()[0]

toping = Popen(['ip', 'address', 'delete', '192.168.0.33/17', 'dev', 'ens3f1' ], stdout=PIPE)
output=toping.communicate()[0]

toping = Popen(['ip', 'address', 'delete', '192.168.0.11/17', 'dev', 'ens3f1' ], stdout=PIPE)
output=toping.communicate()[0]





