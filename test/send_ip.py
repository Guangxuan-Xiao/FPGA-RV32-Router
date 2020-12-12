from scapy.all import *
# import argparse
# parser = argparse.ArgumentParser()
# parser.add_argument("--dst", type=str, required=True)
# parser.add_argument("--iface", type=str, required=True)
# args = parser.parse_args()
# dst = args.dst
# iface = args.iface
# while True:
    # send(IP(ttl=255, dst=dst), iface=iface)
send(IP(ttl=255, dst="68.68.68.68"), iface="enx00e04c68002d")
# sudo ip addr add 172.172.172.172/8 dev enx00e04c68002d
# sudo arping -I enx00e04c68002d 172.172.172.172 -c 2
# sudo minicom -b 9600 -D /dev/ttyACM0
# sudo arping -I enx00e04c68002d 172.172.172.172