PORT0=enx00e04c683cb7
PORT1=enx00e04c680024
BOARD_IP_0=170.170.170.0
BOARD_IP_1=187.187.187.0
PC_IP_0=170.170.170.170
PC_IP_1=187.187.187.187
sudo ip addr add ${PC_IP_1}/8 dev $PORT1
sudo ip route add 170.0.0.0/8 via ${BOARD_IP_1} dev $PORT1
sudo arping -I $PORT1 $BOARD_IP_1 -c 2
iperf3 -s
# sudo ping -f $PC_IP_0
