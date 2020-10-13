from scapy.all import *
a = IP(ttl = 10)
print(a)
print(a.src)
a.dst="192.168.1.1"
print(a.src)
del(a.ttl)
print(a.ttl)
send(IP(dst="1.2.3.4"))
#enx00e04c680024
#enx00e04c680024
#sendp("I'm travelling on Ethernet", iface="enx00e04c680024", loop=1, inter=0.2)
send(IP(dst='170.170.170.1'))