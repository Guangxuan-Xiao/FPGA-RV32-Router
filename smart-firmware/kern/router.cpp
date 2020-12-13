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
#define RUBISH (*(volatile uint32_t *)(0x70000030))
static uint32_t tmp;

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

void read_ip(uint32_t *ip0, uint32_t *ip1, uint32_t *ip2, uint32_t *ip3)
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
    bool flag = false;
    uint32_t rubbish = RUBISH;
    printf("here in receive\r\n");
    if (tmp != rubbish)
    {
        printf("ready = 0x%x\r\n", tmp >> 31);
        printf("valid = 0x%x\r\n", (tmp >> 30) & 1);
        printf("last = 0x%x\r\n", (tmp >> 29) & 1);
        printf("data = 0x%x\r\n", (tmp >> 21) & 255);
        printf("state = 0x%x\r\n", (tmp >> 18) & 7);
        printf("addr = 0x%x\r\n", tmp & 0x3FFFF);
        flag = true;
        volatile uint8_t *ptr;
        ptr = (volatile uint8_t *)(read_start + (tmp & 0x3FFFF));
        uint8_t data = *ptr;
        printf("readdata = 0x%x\r\n", data);
        tmp = rubbish;
    }
    uint8_t status = RD_SRT;
    printf("status: %d\r\n", status);
    if (!(status & 0x80))
    {
        printf("Exit receive with status \r\n");
        return 0;
    }
    uint32_t src = status & 0x7F;
    volatile uint32_t *ptr;
    ptr = (volatile uint32_t *)(read_start + (src << width) + size_addr);
    uint32_t buf = 0;
    uint32_t length = *ptr;
    length = ((length & 0xFF000000) >> 24) + ((length & 0xFF0000) >> 8);
    if (flag)
    {
        printf("length = 0x%x\r\n", length);
    }
    ptr = (volatile uint32_t*)(read_start + (src << width));
    /*buf = *ptr;
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
    for (uint32_t i = 0; i < 512; i++)
    {
        buf = *ptr;
        //printf("buf: 0x%x\r\n", buf);
        //printf("ptr: 0x%x\r\n\r\n", ptr);
        ptr = ptr + 1;
    }*/
    printf("read a packet\r\n");
    RD_END = status;
    return length;
}

void send(int if_index, const uint8_t *buffer, uint32_t length, uint32_t dst, const uint8_t *dst_mac)
{
    volatile uint32_t* ptr;
    printf("before ptr\r\n");
    ptr = (volatile uint32_t*)(write_start + (dst << width));
    printf("end ptr\r\n");
    uint32_t buf = 0;
    printf("b1\r\n");
    buf = dst_mac[0] + (dst_mac[1] << 8) + (dst_mac[2] << 16) + (dst_mac[3] << 24);
    printf("b1\r\n");
    *ptr = buf;
    printf("b1\r\n");
    ptr = ptr + 1;
    printf("b2\r\n");
    buf = dst_mac[0] + (dst_mac[1] << 8) + ((if_index & 0xFF) << 16);
    *ptr = buf;
    ptr = ptr + 1;
    buf = 0;
    *ptr = buf;
    ptr = ptr + 1;
    printf("b3\r\n");
    buf = 0x0800 + (buffer[0] << 16) + (buffer[1] << 24);
    *ptr = buf;
    ptr = ptr + 1;
    length = length - 14;
    printf("before lopo\r\n");
    for (uint32_t i = 2; i < length; i = i + 4)
    {
        buf = buffer[i] + (buffer[i + 1] << 8) + (buffer[i + 2] << 16) + (buffer[i + 3] << 24);
        *ptr = buf;
        ptr = ptr + 1;
    }
    printf("end loop\r\n");
    length = length + 14;
    printf("before ptr\r\n");
    ptr = (volatile uint32_t*)(read_start + (dst << width) + size_addr);
    printf("end ptr\r\n");
    buf = ((length & 0xFF) << 24) + ((length & 0xFF00) << 8);
    *ptr = buf;
    printf("before wrend\r\n");
    WR_END = (uint8_t)(dst | 0x80);
    printf("end wrend\r\n");
}

void ip_mac_test()
{
    uint32_t ip0, ip1, ip2, ip3, mac_prefix;
    read_ip(&ip0, &ip1, &ip2, &ip3);
    printf("IP0: %08x IP1: %08x IP2: %08x IP3: %08x \r\n", ip0, ip1, ip2, ip3);
    mac_prefix = read_mac_prefix();
    printf("MAC[35:4]: %08x\r\n", mac_prefix);
    set_ip(0x00aaaaaa, 0x00bbbbbb, 0x00cccccc, 0xdddddddd);
    set_mac_prefix(0xabcdabcd);
    read_ip(&ip0, &ip1, &ip2, &ip3);
    printf("IP0: %08x IP1: %08x IP2: %08x IP3: %08x \r\n", ip0, ip1, ip2, ip3);
    mac_prefix = read_mac_prefix();
    printf("MAC[35:4]: %08x\r\n", mac_prefix);
}