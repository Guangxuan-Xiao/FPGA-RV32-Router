#ifndef ROUTER_H
#define ROUTER_H
#include <stdint.h>
void set_ip(uint32_t ip0, uint32_t ip1, uint32_t ip2, uint32_t ip3);
void set_mac_prefix(uint32_t mac_prefix);
void read_ip(uint32_t *ip0, uint32_t *ip1, uint32_t *ip2, uint32_t *ip3);
uint32_t read_mac_prefix();
#endif
