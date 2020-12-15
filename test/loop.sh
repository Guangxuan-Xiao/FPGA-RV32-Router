DEVICE=0
PORT0=enx00e04c683cb7
PORT1=enx00e04c680024
PORT2=enx00e04c680f4e
BOARD_IP_0=10.0.2.1
BOARD_IP_1=10.1.2.1
BOARD_IP_2=10.2.2.1
PC_IP_0=10.0.2.2
PC_IP_1=10.1.2.2
PC_IP_2=10.2.2.2
if [[ $DEVICE -eq 0 ]]; then
PORT_MAC=${PORT0}
BOARD_IP=$BOARD_IP_0
PC_IP=$PC_IP_0
elif [[ $DEVICE -eq 1 ]]; then
PORT_MAC=$PORT1
BOARD_IP=$BOARD_IP_1
PC_IP=$PC_IP_1
elif [[ $DEVICE -eq 2 ]]; then
PORT_MAC=$PORT2
BOARD_IP=$BOARD_IP_2
PC_IP=$PC_IP_2
fi
sudo ip addr add ${PC_IP}/24 dev ${PORT_MAC}
sudo ip route add 10.0.0.0/8 via ${BOARD_IP} dev ${PORT_MAC}
sudo arping -I ${PORT_MAC} ${BOARD_IP} -c 2
# ping ${PC_IP_1}
# iperf3 -c $PC_IP_1 -t 10 -R -i 2
# sudo ping -f $PC_IP_1
