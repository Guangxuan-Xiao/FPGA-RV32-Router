#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <uart.h>
#include <route_table.h>
extern uint32_t _bss_begin[];
extern uint32_t _bss_end[];
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
    // search(entry.ip, &nexthop_ip, &port);
    // printf("Nexthop: %x\nPort: %x\n", nexthop_ip, port);
}

void start(void)
{
    for (uint32_t *p = _bss_begin; p != _bss_end; ++p)
    {
        *p = 0;
    }

    init_uart();

    printf("hello, world\n");
    test();
    while (true)
        ;
}
