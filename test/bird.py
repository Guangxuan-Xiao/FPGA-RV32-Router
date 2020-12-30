from time import sleep
from scapy.layers.inet import Ether, IP, UDP, Packet
from scapy.layers.rip import RIPEntry, RIP
from scapy.all import send
import sys
import struct
import time
import socket
ENTRY_NUM = 11000
IPs = ['10.0.0.1', '10.0.1.1', '10.0.2.1', '10.0.3.1']
PORT = 0
with open("fib12000.txt") as f:
    lines = f.readlines()


def prefixlen_to_netmask(prefix_len):
    host_bits = 32 - int(prefix_len)
    netmask = socket.inet_ntoa(struct.pack('!I', (1 << 32) - (1 << host_bits)))
    return netmask

port = 0
for i in range(0, ENTRY_NUM//25):
    rip_entries = Packet()
    for j in range(i*25, (i+1)*25):
        ip, prefix_len, _, _ = lines[j].split(" ")
        rip_entries /= RIPEntry(addr=ip, mask=prefixlen_to_netmask(prefix_len))

    send(IP(dst=IPs[port], ttl=64) /
            UDP() /
            RIP(cmd=2, version=2) /
            rip_entries)
    port = port + 1 if port < 3 else 0


    # time.sleep(0.1)
time.sleep(3)
