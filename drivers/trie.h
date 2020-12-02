#ifndef TRIE_H
#define TRIE_H
#define TRIE_BASE_ADDR 0x20000000
#define TRIE_LAYER_SIZE 0x00008000
#define TRIE_LAYER_WIDTH 14
#define TRIE_LAYER_CAPACITY 0x00002000
#define TRIE_NODE_WIDTH 2
#define TRIE_NODE_SIZE 0x4
#define NEXTHOP_BASE_ADDR 0x20200000
#define NEXTHOP_SIZE 0x200
#define NEXTHOP_WIDTH 3
#define ROOT_ADDR 0x20000004
#include <stdint.h>
struct trie_node_t {
    uint32_t* lc_ptr;
    uint32_t* rc_ptr;
    uint32_t* nexthop_ip_ptr;
    uint32_t* nexthop_port_ptr;
    uint32_t hit;
    uint32_t layer;
};

void parse_node(uint32_t* node_addr, struct trie_node_t* node);

#endif