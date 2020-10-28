PORT0=enx00e04c683cb7
PORT1=enx00e04c680024
BOARD_IP_0=170.170.170.0
BOARD_IP_1=187.187.187.0
PC_IP_0=170.170.170.170
PC_IP_1=187.187.187.187
sudo ip addr add ${PC_IP_0}/8 dev $PORT0
sudo ip route add 187.0.0.0/8 via ${BOARD_IP_0} dev $PORT0
sudo arping -I ${PORT0} ${BOARD_IP_0} -c 2
# iperf3 -c $PC_IP_1 -t 10 -R -i 2
# sudo ping -f $PC_IP_1
