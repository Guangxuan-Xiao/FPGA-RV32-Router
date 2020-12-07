#ifndef TRIE_H
#define TRIE_H
#include <stdint.h>
const uint32_t TRIE_BASE_ADDR = 0x20000000;
const uint32_t TRIE_LAYER_SIZE = 0x00008000;
const uint32_t TRIE_LAYER_WIDTH = 15;
const uint32_t TRIE_LAYER_CAPACITY = 0x00002000;
const uint32_t TRIE_NODE_WIDTH = 2;
const uint32_t TRIE_NODE_SIZE = 0x4;
const uint32_t NEXTHOP_BASE_ADDR = 0x20200000;
const uint32_t NEXTHOP_SIZE = 0x200;
const uint32_t NEXTHOP_WIDTH = 3;
const uint32_t ROOT_ADDR = 0x20000004;
struct trie_node_t
{
    uint32_t *lc_ptr;
    uint32_t *rc_ptr;
    uint32_t nexthop_idx;
};

inline uint32_t *get_node_addr(uint32_t layer, uint32_t idx)
{
    if (idx == 0)
        return 0;
    return TRIE_BASE_ADDR + (layer << TRIE_LAYER_WIDTH) + (idx << TRIE_NODE_WIDTH);
}

inline uint32_t *get_nexthop_ip_addr(int idx)
{
    return NEXTHOP_BASE_ADDR + (idx << NEXTHOP_WIDTH);
}

inline uint32_t *get_nexthop_port_addr(int idx)
{
    return NEXTHOP_BASE_ADDR + (idx << NEXTHOP_WIDTH) + 4;
}

inline uint32_t parse_lc(uint32_t node_data)
{
    return (node_data >> 19) & (0x1FFF);
}

inline uint32_t parse_rc(uint32_t node_data)
{
    return (node_data >> 6) & (0x1FFF);
}

inline uint32_t parse_nexthop(uint32_t node_data)
{
    return node_data & 0x3F;
}

inline void set_lc(uint32_t *node_addr, uint32_t lc_idx)
{
    *node_addr &= 0x7FFFF;
    *node_addr |= (lc_idx & 0x1FFF) << 19;
}

inline void set_rc(uint32_t *node_addr, uint32_t rc_idx)
{
    *node_addr &= 0xFFF8003F;
    *node_addr |= (rc_idx & 0x1FFF) << 6;
}

inline void set_nexthop(uint32_t *node_addr, uint32_t nexthop_idx)
{
    *node_addr &= 0xFFFFFFC0;
    *node_addr |= (nexthop_idx & 0x3F);
}

inline void parse_node(uint32_t *node_ptr, struct trie_node_t *node)
{
    uint32_t layer = ((uint32_t)node_ptr - TRIE_BASE_ADDR) >> TRIE_LAYER_WIDTH;
    uint32_t node_data = *node_ptr;
    uint32_t lc_idx = parse_lc(node_data), rc_idx = parse_rc(node_data);
    node->lc_ptr = get_node_addr(layer + 1, lc_idx);
    node->rc_ptr = get_node_addr(layer + 1, rc_idx);
    node->nexthop_idx = parse_nexthop(node_data);
}
#endif