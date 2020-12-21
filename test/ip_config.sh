PORT0=enx00e04c68114b
PORT1=enx00e04c683cb7
PORT2=enx00e04c680024
PORT3=enx00e04c680028
PC_IP_0=10.0.0.2
PC_IP_1=10.0.1.2
PC_IP_2=10.0.2.2
PC_IP_3=10.0.3.2
BOARD_IP_0=10.0.0.1
BOARD_IP_1=10.0.1.1
BOARD_IP_2=10.0.2.1
BOARD_IP_3=10.0.3.1
sudo ip addr add ${PC_IP_0}/24 dev $PORT0
sudo ip route add 10.0.0.0/24 via ${BOARD_IP_0} dev $PORT0
sudo arping -I ${PORT0} ${BOARD_IP_0} -c 2
sudo ip addr add ${PC_IP_1}/24 dev $PORT1
sudo ip route add 10.0.1.0/24 via ${BOARD_IP_1} dev $PORT1
sudo arping -I ${PORT1} ${BOARD_IP_1} -c 2
sudo ip addr add ${PC_IP_2}/24 dev $PORT2
sudo ip route add 10.0.2.0/24 via ${BOARD_IP_2} dev $PORT2
sudo arping -I ${PORT2} ${BOARD_IP_2} -c 2
sudo ip addr add ${PC_IP_3}/24 dev $PORT3
sudo ip route add 10.0.3.0/24 via ${BOARD_IP_3} dev $PORT3
sudo arping -I ${PORT3} ${BOARD_IP_3} -c 2