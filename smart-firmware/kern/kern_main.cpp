#include <stdio.h>
#include <math.h>
#include "route_table.h"
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
	RoutingTableEntry entry = {
		.ip = 0x12345678,
		.prefix_len = 24,
		.port = 3,
		.nexthop_ip = 0xabcdabcd
	};
	insert(entry);
	uint32_t nexthop_ip, port;
	search(entry.ip, &nexthop_ip, &port);
	printf("Nexthop: %x\nPort: %x\n", nexthop_ip, port);
	remove(entry.ip, entry.prefix_len);
	search(entry.ip, &nexthop_ip, &port);
	printf("Nexthop: %x\nPort: %x\n", nexthop_ip, port);
	return 233;
}
