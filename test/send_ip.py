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
send(IP(ttl=255, dst="10.0.1.1"), iface="enx00e04c683cb7")
# sudo ip addr add 68.68.68.69/8 dev enx00e04c68002d
# sudo arping -I enx00e04c68002d 68.68.68.68 -c 2
# sudo minicom -b 9600 -D /dev/ttyACM0
# sudo arping -I enx00e04c68002d 172.172.172.172