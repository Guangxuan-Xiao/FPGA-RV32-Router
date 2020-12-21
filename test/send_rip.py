from scapy import *
from scapy.utils import *
from scapy.layers.l2 import *
from scapy.layers.inet import *
from scapy.layers.rip import *
from scapy.all import *
import sys
import struct

MAC_TESTER1 = '54:45:53:54:5f:32'
IP_TESTER1 = '10.0.1.2'
IP_RIP = '224.0.0.9'
IFACE = "To be determined"

send(Ether(src=MAC_TESTER1) / IP(src=IP_TESTER1, dst=IP_RIP, ttl=1) / UDP() / RIP(version=2) / RIPEntry(addr='140.140.0.0', mask='255.255.255.0') / RIPEntry(addr='140.140.1.0', mask='255.255.255.0') / RIPEntry(addr='140.140.2.0', mask='255.255.255.0') / RIPEntry(addr='140.140.3.0', mask='255.255.255.0') / RIPEntry(addr='140.140.4.0', mask='255.255.255.0') / RIPEntry(addr='140.140.5.0', mask='255.255.255.0') / RIPEntry(addr='140.140.6.0', mask='255.255.255.0') / RIPEntry(addr='140.140.7.0', mask='255.255.255.0') / RIPEntry(addr='140.140.8.0', mask='255.255.255.0') / RIPEntry(addr='140.140.9.0', mask='255.255.255.0') / RIPEntry(addr='140.140.10.0', mask='255.255.255.0') / RIPEntry(addr='140.140.11.0', mask='255.255.255.0') /
     RIPEntry(addr='140.140.12.0', mask='255.255.255.0') / RIPEntry(addr='140.140.13.0', mask='255.255.255.0') / RIPEntry(addr='140.140.14.0', mask='255.255.255.0') / RIPEntry(addr='140.140.15.0', mask='255.255.255.0') / RIPEntry(addr='140.140.16.0', mask='255.255.255.0') / RIPEntry(addr='140.140.17.0', mask='255.255.255.0') / RIPEntry(addr='140.140.18.0', mask='255.255.255.0') / RIPEntry(addr='140.140.19.0', mask='255.255.255.0') / RIPEntry(addr='140.140.20.0', mask='255.255.255.0') / RIPEntry(addr='140.140.21.0', mask='255.255.255.0') / RIPEntry(addr='140.140.22.0', mask='255.255.255.0') / RIPEntry(addr='140.140.23.0', mask='255.255.255.0') / RIPEntry(addr='140.140.24.0', mask='255.255.255.0'), iface=IFACE)
