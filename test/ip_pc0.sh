PORT0=enx00e04c683cb7
PORT1=enx00e04c680024
BOARD_IP_0=10.0.0.1
BOARD_IP_1=10.0.2.1
PC_IP_0=10.0.0.2
PC_IP_1=10.0.2.2
sudo ip addr add ${PC_IP_0}/24 dev $PORT0
sudo ip route add 10.0.2.0/24 via ${BOARD_IP_0} dev $PORT0
sudo arping -I ${PORT0} ${BOARD_IP_0} -c 2
# iperf3 -c $PC_IP_1 -t 10 -R -i 2
# sudo ping -f $PC_IP_1
