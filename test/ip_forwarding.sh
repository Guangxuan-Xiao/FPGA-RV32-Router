PORT0=enx000ec650a042
PORT1=enx00e04c680024
BOARD_IP_0=170.170.170.0
BOARD_IP_1=187.187.187.0
PC_IP_0=170.170.170.170
PC_IP_1=187.187.187.187
sudo ifconfig $PORT0 ${PC_IP_0}
sudo ifconfig $PORT1 ${PC_IP_1}
sudo arping -I ${PORT0} ${BOARD_IP_0} -c 1
sudo arping -I ${PORT1} ${BOARD_IP_1} -c 1
sudo python3 send_ip.py --dst $PC_IP_1 --iface $PORT0
# ping -f 187.187.187.187
