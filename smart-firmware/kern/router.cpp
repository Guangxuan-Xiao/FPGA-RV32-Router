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
#define RD_SRT (*(volatile uint8_t *)(0x70000000))
#define RD_END (*(volatile uint8_t *)(0x70000010))
#define WR_END (*(volatile uint8_t *)(0x70000020))

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

uint32_t receive(uint8_t *buffer, uint8_t *src_mac, uint8_t *dst_mac, int *if_index)
{
    uint8_t status = RD_SRT;
    if (!(status & 0x80))
    {
        return 0;
    }
    uint32_t src = status & 0x7F;
    volatile uint32_t* ptr;
    ptr = (volatile uint32_t*)(read_start + (src << width) + size_addr);
    uint32_t buf = 0;
    uint32_t length = *ptr;
    length = ((length & 0xFF000000) >> 24) + ((length & 0xFF0000) >> 8);
    ptr = (volatile uint32_t*)(read_start + (src << width));
    buf = *ptr;
    dst_mac[0] = buf & 0xFF;
    *if_index = buf & 0xFF;
    dst_mac[1] = (buf & 0xFF00) >> 8;
    dst_mac[2] = (buf & 0xFF0000) >> 16;
    dst_mac[3] = (buf & 0xFF000000) >> 24;
    ptr = ptr + 1;
    buf = *ptr;
    dst_mac[4] = buf & 0xFF;
    dst_mac[5] = (buf & 0xFF00) >> 8;
    src_mac[0] = (buf & 0xFF0000) >> 16;
    src_mac[1] = (buf & 0xFF000000) >> 24;
    ptr = ptr + 1;
    buf = *ptr;
    src_mac[2] = buf & 0xFF;
    src_mac[3] = (buf & 0xFF00) >> 8;
    src_mac[4] = (buf & 0xFF0000) >> 16;
    src_mac[5] = (buf & 0xFF000000) >> 24;
    ptr = ptr + 1;
    buf = *ptr;
    buffer[0] = (buf & 0xFF0000) >> 16;
    buffer[1] = (buf & 0xFF000000) >> 24;
    ptr = ptr + 1;
    length = length - 14;
    for (uint32_t i = 2; i < length; i = i + 4)
    {
        buf = *ptr;
        buffer[i] = buf & 0xFF;
        buffer[i + 1] = (buf & 0xFF00) >> 8;
        buffer[i + 2] = (buf & 0xFF0000) >> 16;
        buffer[i + 3] = (buf & 0xFF000000) >> 24;
        ptr = ptr + 1;
    }
    length = length + 14;
    RD_END = status;
    return length;
}

void send(int if_index, const uint8_t *buffer, uint32_t length, uint32_t dst, const uint8_t *dst_mac)
{
    volatile uint32_t* ptr;
    ptr = (volatile uint32_t*)(write_start + (dst << width));
    uint32_t buf = 0;
    buf = dst_mac[0] + (dst_mac[1] << 8) + (dst_mac[2] << 16) + (dst_mac[3] << 24);
    *ptr = buf;
    ptr = ptr + 1;
    buf = dst_mac[0] + (dst_mac[1] << 8) + ((if_index & 0xFF) << 16);
    *ptr = buf;
    ptr = ptr + 1;
    buf = 0;
    *ptr = buf;
    ptr = ptr + 1;
    buf = 0x0800 + (buffer[0] << 16) + (buffer[1] << 24);
    *ptr = buf;
    ptr = ptr + 1;
    length = length - 14;
    for (uint32_t i = 2; i < length; i = i + 4)
    {
        buf = buffer[i] + (buffer[i + 1] << 8) + (buffer[i + 2] << 16) + (buffer[i + 3] << 24);
        *ptr = buf;
        ptr = ptr + 1;
    }
    length = length + 14;
    ptr = (volatile uint32_t*)(read_start + (dst << width) + size_addr);
    buf = ((length & 0xFF) << 24) + ((length & 0xFF00) << 8);
    *ptr = buf;
    WR_END = (uint8_t)(dst | 0x80);
}
