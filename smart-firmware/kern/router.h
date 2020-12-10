#ifndef ROUTER_H
#define ROUTER_H
#include <stdint.h>

void set_ip(uint32_t ip0, uint32_t ip1, uint32_t ip2, uint32_t ip3);
void set_mac_prefix(uint32_t mac_prefix);
void read_ip(uint32_t *ip0, uint32_t *ip1, uint32_t *ip2, uint32_t *ip3);
uint32_t read_mac_prefix();
uint32_t receive(uint8_t *buffer, uint8_t *src_mac, uint8_t *dst_mac, int *if_index);
void ip_mac_test();
void send(int if_index, const uint8_t *buffer, uint32_t length, uint32_t dst, const uint8_t *dst_mac);

#endif
