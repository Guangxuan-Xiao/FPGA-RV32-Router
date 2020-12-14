PORT0=enx00e04c683cb7
PORT1=enx00e04c680024
BOARD_IP_0=10.0.0.1
BOARD_IP_1=10.0.2.1
PC_IP_0=10.0.0.2
PC_IP_1=10.0.2.2
sudo ip addr add ${PC_IP_1}/24 dev $PORT1
sudo ip route add 10.0.0.0/24 via ${BOARD_IP_1} dev $PORT1
sudo arping -I ${PORT1} ${BOARD_IP_1} -c 2
iperf3 -s
