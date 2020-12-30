PORT0=enx00e04c683cb7
PORT1=enx00e04c680024
BOARD_IP_0=10.0.0.1
BOARD_IP_1=10.2.1.1
PC_IP_0=10.0.0.2
PC_IP_1=10.2.1.2
sudo ip addr add ${PC_IP_1}/24 dev ${PORT0}
sudo ip route add 10.0.0.0/8 via ${BOARD_IP_1} dev ${PORT0}
sudo arping -I ${PORT1} ${BOARD_IP_1} -c 2
# iperf3 -s
# sudo ip addr add 10.0.0.2/24 dev enx00e04c680f4e
# sudo ip route add 10.0.0.0/8 via 10.0.0.1 dev enx00e04c680f4e
# sudo arping -I enx00e04c680f4e 10.0.0.1 -c 2
# ping -c 5 10.2.1.2