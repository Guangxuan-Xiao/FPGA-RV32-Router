from scapy.all import *
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--dst", type=str, required=True)
parser.add_argument("--iface", type=str, required=True)
args = parser.parse_args()
dst = args.dst
iface = args.iface
while True:
    send(IP(ttl=255, dst=dst), iface=iface)
