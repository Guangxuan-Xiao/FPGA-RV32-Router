#include "trie.h"
void parse_node(uint32_t *node_ptr, struct trie_node_t *node)
{
    node->layer = ((uint32_t)node_ptr - TRIE_BASE_ADDR) >> TRIE_LAYER_WIDTH;
    uint32_t node_data = *node_ptr;
    uint32_t lc = parse_lc(node_data), rc = parse_rc(node_data), nexthop = parse_nexthop(node_data);
    node->lc_ptr = get_node_addr(node->layer + 1, lc);
    node->rc_ptr = get_node_addr(node->layer + 1, rc);
    node->nexthop_idx = nexthop;
}