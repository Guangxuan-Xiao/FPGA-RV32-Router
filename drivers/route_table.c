#include "route_table.h"
#include "trie.h"
static int layer_size[32] = {0};
static int nexthop_size = 0;
void insert(struct RoutingTableEntry entry)
{
    struct trie_node_t parent;
    uint32_t *current_node = ROOT_ADDR;
    for (int i = 0; i < entry.prefix_len; ++i)
    {
        parse_node(current_node, &parent);
        int bit = (entry.ip >> i) & 1;
        if (bit)
        {
            if (!parent.rc_ptr)
            {
                layer_size[i]++;
                parent.rc_ptr = get_node_addr(i + 1, layer_size[i]);
                set_rc(current_node, layer_size[i]);
            }
            current_node = parent.rc_ptr;
        }
        else
        {
            if (!parent.lc_ptr)
            {
                layer_size[i]++;
                parent.lc_ptr = get_node_addr(i + 1, layer_size[i]);
                set_lc(current_node, layer_size[i]);
            }
            current_node = parent.lc_ptr;
        }
    }
    int nexthop_idx;
    for (nexthop_idx = 1; nexthop_idx <= nexthop_size; ++nexthop_idx)
    {
        if (*get_nexthop_ip_addr(nexthop_idx) == entry.nexthop_ip && *get_nexthop_port_addr(nexthop_idx) == entry.port)
            break;
    }
    if (nexthop_idx > nexthop_size)
    {
        nexthop_size++;
        *get_nexthop_ip_addr(nexthop_idx) = entry.nexthop_ip;
        *get_nexthop_port_addr(nexthop_idx) = entry.port;
    }
    set_nexthop(current_node, nexthop_idx);
}

void remove(struct RoutingTableEntry entry)
{
}

uint32_t search(uint32_t ip, uint32_t *nexthop_ip, uint32_t *port)
{
    struct trie_node_t parent;
    uint32_t nexthop_idx;
    uint32_t *current_node = ROOT_ADDR;
    parse_node(current_node, &parent);
    for (int i = 0; i < 32; ++i)
    {
        int bit = (ip >> i) & 1;
        if (bit)
        {
            if (parent.rc_ptr)
                current_node = parent.rc_ptr;
            else
                break;
        }
        else
        {
            if (parent.lc_ptr)
                current_node = parent.lc_ptr;
            else
                break;
        }
        parse_node(current_node, &parent);
        if (parent.nexthop_idx)
            nexthop_idx = parent.nexthop_idx;
    }
    *nexthop_ip = *get_nexthop_ip_addr(nexthop_idx);
    *port = *get_nexthop_port_addr(nexthop_idx);
    return nexthop_idx;
}