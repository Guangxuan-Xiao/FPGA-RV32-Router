#include "router.h"
#include "lookup.h"
#include <stdio.h>
static volatile uint32_t *const ip0_ptr = (volatile uint32_t *)0x10000100;
static volatile uint32_t *const ip1_ptr = (volatile uint32_t *)0x10000110;
static volatile uint32_t *const ip2_ptr = (volatile uint32_t *)0x10000120;
static volatile uint32_t *const ip3_ptr = (volatile uint32_t *)0x10000130;
static volatile uint32_t *const mac_prefix_ptr = (volatile uint32_t *)0x10000200;
static uint32_t const read_start = 0x60000000;
static uint32_t const write_start = 0x60040000;
static uint32_t const size_addr = 0x7FC;
static uint32_t const width = 11;

void set_ip(uint32_t ip0, uint32_t ip1, uint32_t ip2, uint32_t ip3)
{
    *ip0_ptr = ip0;
    *ip1_ptr = ip1;
    *ip2_ptr = ip2;
    *ip3_ptr = ip3;
}

void set_mac_prefix(uint32_t mac_prefix)
{
    *mac_prefix_ptr = mac_prefix;
}

void read_ip(volatile uint32_t *ip0, volatile uint32_t *ip1, volatile uint32_t *ip2, volatile uint32_t *ip3)
{
    *ip0 = *ip0_ptr;
    *ip1 = *ip1_ptr;
    *ip2 = *ip2_ptr;
    *ip3 = *ip3_ptr;
}

uint32_t read_mac_prefix()
{
    return *mac_prefix_ptr;
}

uint32_t receive(uint8_t* buffer, uint32_t src)
{
    volatile uint32_t* ptr;
    ptr = (volatile uint32_t*)(read_start + (src << width) + size_addr);
    uint32_t buf = 0;
    uint32_t len = *ptr;
    len = ((len & 0xFF000000) >> 24) + ((len & 0xFF0000) >> 8);
    ptr = (volatile uint32_t*)(read_start + (src << width));
    for (uint32_t i = 0; i < len; i = i + 4)
    {
        buf = *ptr;
        buffer[i] = buf & 0xFF;
        buffer[i + 1] = (buf & 0xFF00) >> 8;
        buffer[i + 2] = (buf & 0xFF0000) >> 16;
        buffer[i + 3] = (buf & 0xFF000000) >> 24;
        ptr = ptr + 1;
    }
    buf = 0;
    return len;
}

void send(uint8_t* buffer, uint32_t len, uint32_t dst)
{
    uint32_t i = 0;
    volatile uint32_t* ptr;
    ptr = (volatile uint32_t*)(write_start + (dst << width));
    uint32_t buf = 0;
    len = len - 4;
    for (i = 0; i < len; i = i + 4)
    {
        buf = buffer[i] + (buffer[i + 1] << 8) + (buffer[i + 2] << 16) + (buffer[i + 3] << 24);
        *ptr = buf;
        ptr = ptr + 1;
    }
    len = len + 4;
    buf = 0;
    for (; i < len; i++)
    {
        buf = buf + (buffer[i] << (i & 3));
    }
    *ptr = buf;
    ptr = (volatile uint32_t*)(read_start + (dst << width) + size_addr);
    buf = ((len & 0xFF) << 24) + ((len & 0xFF00) << 8);
    *ptr = buf;
}
