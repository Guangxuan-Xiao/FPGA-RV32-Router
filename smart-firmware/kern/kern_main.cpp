#include <stdio.h>
#include <math.h>
#include "route_table.h"
void test()
{
	RoutingTableEntry entry1 = {
		.ip = 0x00030201,
		.prefix_len = 24,
		.port = 9,
		.nexthop_ip = 0x0203a8c0};
	insert(entry1);
	RoutingTableEntry entry2 = {
		.ip = 0x04030201,
		.prefix_len = 32,
		.port = 10,
		.nexthop_ip = 0x0109a8c0};
	insert(entry2);
	uint32_t nexthop_ip, port;
	search(0x04030201, &nexthop_ip, &port);
	printf("Nexthop: 0x%08x\nPort: %d\n", nexthop_ip, port);
	search(0x01030201, &nexthop_ip, &port);
	printf("Nexthop: 0x%08x\nPort: %d\n", nexthop_ip, port);
	search(0x00000000, &nexthop_ip, &port);
	printf("Nexthop: 0x%08x\nPort: %d\n", nexthop_ip, port);
	remove(0x04030201, 32);
	search(0x04030201, &nexthop_ip, &port);
	printf("Nexthop: 0x%08x\nPort: %d\n", nexthop_ip, port);
	search(0x01030201, &nexthop_ip, &port);
	printf("Nexthop: 0x%08x\nPort: %d\n", nexthop_ip, port);
	search(0x00000000, &nexthop_ip, &port);
	printf("Nexthop: 0x%08x\nPort: %d\n", nexthop_ip, port);
	remove(0x00030201, 24);
	search(0x04030201, &nexthop_ip, &port);
	printf("Nexthop: 0x%08x\nPort: %d\n", nexthop_ip, port);
	search(0x01030201, &nexthop_ip, &port);
	printf("Nexthop: 0x%08x\nPort: %d\n", nexthop_ip, port);
	search(0x00000000, &nexthop_ip, &port);
	printf("Nexthop: 0x%08x\nPort: %d\n", nexthop_ip, port);
}

static void print_hello()
{
	printf("Hello world!\n");

	double e = 0, tmp = 1;
	for (int i = 1; i <= 20; i++)
	{
		e += tmp;
		tmp /= i;
	}
	printf("e = %.15lf\n", e);
	printf("pi = 2 * atan2(1, 0) = %.15lf\n", 2 * atan2(1, 0));
}

int main()
{
	print_hello();
	test();
	return 233;
}
