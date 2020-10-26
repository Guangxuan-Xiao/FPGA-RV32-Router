PORT0=enx000ec650a042
PORT1=enx00e04c680f4e
BOARD_IP_0=170.170.170.0
BOARD_IP_1=187.187.187.0
PC_IP_0=170.170.170.170
PC_IP_1=187.187.187.187
sudo ifconfig $PORT0 ${PC_IP_0}
sudo ifconfig $PORT1 ${PC_IP_1}
# sudo arping -I ${PORT0} ${BOARD_IP_0} -c 2
# sudo arping -I ${PORT1} ${BOARD_IP_1} -c 2
# sudo python3 send_ip.py --dst $BOARD_IP_0 --iface $PORT0
sudo python3 send_ip.py --dst $PC_IP_0 --iface $PORT1
# ping -f 187.187.187.187
