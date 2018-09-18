import subprocess
import ipaddress
from subprocess import Popen, PIPE
import time





network = ipaddress.ip_network('192.168.0.0/17')

for i in network.hosts():
    i=str(i)
    time.sleep(0.020)

    toping = Popen(['ping', '-c', '1', '-w', '0' , '-I', i , '8.8.8.8' ], stdout=PIPE)
    output=toping.communicate()[0]
    hostalive=toping.returncode
    if hostalive ==0:
        print (i,'ok')
    else:
        print (i,'doh')


