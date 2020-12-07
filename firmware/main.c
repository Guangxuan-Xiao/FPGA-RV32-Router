#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <uart.h>
#include <route_table.h>
extern uint32_t _bss_begin[];
extern uint32_t _bss_end[];

void start(void)
{
    for (uint32_t *p = _bss_begin; p != _bss_end; ++p)
    {
        *p = 0;
    }

    init_uart();

    printf("hello, world\r\n");
    RoutingTableEntry entry = {
        .ip = 0x12345678,
        .prefix_len = 24,
        .port = 3,
        .nexthop_ip = 0xabcdabcd};
    printf("1\r\n");
    insert(entry);
    printf("2\r\n");
    uint32_t nexthop_ip, port;
    printf("3\r\n");
    search(entry.ip, &nexthop_ip, &port);
    printf("Nexthop: %x\r\nPort: %x\r\n", nexthop_ip, port);
    remove(entry.ip, entry.prefix_len);
    printf("4\r\n");
    search(entry.ip, &nexthop_ip, &port);
    printf("Nexthop: %x\r\nPort: %x\r\n", nexthop_ip, port);
    while (true)
        ;
}
