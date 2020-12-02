#include "route_table.h"
#include "trie.h"
static int size[32] = {0};
void insert(struct RoutingTableEntry entry) {
    struct trie_node_t parent;
    parse_node((uint32_t*)ROOT_ADDR, *parent);
    for (int i = 0; i < entry.prefix_len; ++i) {
        int bit = entry.ip & (1<<i);
        if (bit) {

        }
        else {
            
        }
    }
}

void remove(struct RoutingTableEntry entry) {

}

void search(uint32_t ip, uint32_t *nexthop_ip, uint32_t *port) {

}