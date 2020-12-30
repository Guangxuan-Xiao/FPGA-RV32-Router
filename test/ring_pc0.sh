PORT0=enx00e04c680f4e
BOARD_IP_1=10.0.1.1
PC_IP_1=10.0.1.2
sudo ip addr add ${PC_IP_1}/24 dev ${PORT0}
sudo ip route add 10.0.0.0/8 via ${BOARD_IP_1} dev ${PORT0}
sudo arping -I ${PORT0} ${BOARD_IP_1} -c 2
