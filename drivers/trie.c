#include "trie.h"
inline uint32_t parse_lc(uint32_t node) {
    return (node >> 19) & (0x1FFF);
}

inline uint32_t parse_rc(uint32_t node) {
    return (node >> 6) & (0x1FFF);
}

inline uint32_t parse_nexthop(uint32_t node) {
    return node & 0x3F;
}

void parse_node(uint32_t* node_ptr, struct trie_node_t* node) {
    node->layer = ((uint32_t)node_ptr - TRIE_BASE_ADDR) >> TRIE_LAYER_WIDTH;
    uint32_t node_info = *node_ptr;
    uint32_t lc = parse_lc(node_info), rc = parse_rc(node_info), nexthop = parse_nexthop(node_info);
    if (lc) node->lc_ptr = TRIE_BASE_ADDR + ((node->layer + 1) << TRIE_LAYER_WIDTH) + (lc << TRIE_NODE_WIDTH);
    else node->lc_ptr = 0;
    if (rc) node->rc_ptr = TRIE_BASE_ADDR + ((node->layer + 1) << TRIE_LAYER_WIDTH) + (rc << TRIE_NODE_WIDTH);
    else node->rc_ptr = 0;
    if (nexthop) {
        node->nexthop_ip_ptr = NEXTHOP_BASE_ADDR + (nexthop << NEXTHOP_WIDTH);
        node->nexthop_port_ptr = NEXTHOP_BASE_ADDR + (nexthop << NEXTHOP_WIDTH) + 4;
        node->hit = 1;
    }
    else {
        node->hit = 0;
    }
}