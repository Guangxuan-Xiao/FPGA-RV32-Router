#include "router.h"
#include "lookup.h"
#include <stdio.h>
static uint32_t *const ip0_ptr = (uint32_t *)0x10000100;
static uint32_t *const ip1_ptr = (uint32_t *)0x10000110;
static uint32_t *const ip2_ptr = (uint32_t *)0x10000120;
static uint32_t *const ip3_ptr = (uint32_t *)0x10000130;
static uint32_t *const mac_prefix_ptr = (uint32_t *)0x10000200;
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

// void receive(uint8_t* buffer, uint8_t src)
// {
    
// }