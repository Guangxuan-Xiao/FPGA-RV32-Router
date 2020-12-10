#include "lookup.h"
#include "trie.h"
#include "allocator.h"
#include <stdio.h>
// static int layer_size[32] = {0};
static Allocator allocators[32];
static int nexthop_size = 0;
static const int ROUTE_NODES_NUM = 1 << 16;
static int route_node_num = 1;
class route_node_t
{
public:
    uint32_t lc;
    uint32_t rc;
    uint32_t metric;
    route_node_t() : lc(0), rc(0), metric(0xffffffff) {}
    static const uint32_t root = 1;
    static uint32_t new_node()
    {
        return ++route_node_num;
    }
};
static route_node_t route_nodes[ROUTE_NODES_NUM];
void RoutingTableEntry::print()
{
    printf("IP: %08x\n", ip);
    printf("Prefix Length: %u\n", prefix_len);
    printf("Port: %u\n", port);
    printf("Next-hop IP: %08x\n", nexthop_ip);
    printf("Metric: %d\n", metric);
}

void init()
{
    route_node_num = 1;
    nexthop_size = 0;
    // for (int i = 0; i < 32; ++i)
    //     layer_size[i] = 0;
}

void insert(RoutingTableEntry entry)
{
    trie_node_t parent;
    uint32_t *current_node = (uint32_t *)ROOT_ADDR;
    uint32_t current_node_s = route_node_t::root;
    uint16_t idx;
    for (uint32_t i = 0; i < entry.prefix_len; ++i)
    {
        parse_node(current_node, &parent);
        int bit = (entry.ip >> i) & 1;
        if (bit)
        {
            if (!parent.rc_ptr)
            {
                // layer_size[i]++;
                idx = allocators[i].get();
                parent.rc_ptr = get_node_addr(i + 1, idx);
                set_rc(current_node, idx);
                route_nodes[current_node_s].rc = route_node_t::new_node();
            }
            current_node = parent.rc_ptr;
            current_node_s = route_nodes[current_node_s].rc;
        }
        else
        {
            if (!parent.lc_ptr)
            {
                // layer_size[i]++;
                idx = allocators[i].get();
                parent.lc_ptr = get_node_addr(i + 1, idx);
                set_lc(current_node, idx);
                route_nodes[current_node_s].lc = route_node_t::new_node();
            }
            current_node = parent.lc_ptr;
            current_node_s = route_nodes[current_node_s].lc;
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
    route_nodes[current_node_s].metric = entry.metric;
}

void remove(uint32_t ip, uint32_t prefix_len)
{
    trie_node_t parent;
    uint32_t *current_node = (uint32_t *)ROOT_ADDR;
    uint32_t *path[33] = {current_node, 0};
    uint32_t current_node_s = route_node_t::root;
    uint32_t path_s[33] = {current_node_s, 0};
    for (uint32_t i = 0; i < prefix_len; ++i)
    {
        parse_node(current_node, &parent);
        int bit = (ip >> i) & 1;
        if (bit)
        {
            if (parent.rc_ptr)
            {
                current_node = parent.rc_ptr;
                current_node_s = route_nodes[current_node_s].rc;
            }
            else
                return;
        }
        else
        {
            if (parent.lc_ptr)
            {
                current_node = parent.lc_ptr;
                current_node_s = route_nodes[current_node_s].lc;
            }
            else
                return;
        }
        path[i + 1] = current_node;
        path_s[i + 1] = current_node_s;
    }
    set_nexthop(current_node, 0);
    route_nodes[current_node_s].metric = -1;
    // Trace back
    uint16_t idx;
    for (int i = prefix_len - 1; i >= 0; --i)
    {
        int bit = (ip >> i) & 1;
        if (*path[i + 1] == 0)
        {
            // --layer_size[i];
            idx = get_idx(path[i + 1]);
            allocators[i].put(idx);
            if (bit)
            {
                set_rc(path[i], 0);
                route_nodes[path_s[i]].rc = 0;
            }
            else
            {
                set_lc(path[i], 0);
                route_nodes[path_s[i]].lc = 0;
            }
        }
        else
            return;
    }
}

uint32_t search(uint32_t ip, uint32_t *nexthop_ip, uint32_t *port, uint32_t *metric)
{
    trie_node_t parent;
    uint32_t nexthop_idx = 0;
    uint32_t *current_node = (uint32_t *)ROOT_ADDR;
    uint32_t current_node_s = route_node_t::root;
    parse_node(current_node, &parent);
    *metric = 0xffffffff;
    for (int i = 0; i < 32; ++i)
    {
        int bit = (ip >> i) & 1;
        if (bit)
        {
            if (parent.rc_ptr)
            {
                current_node = parent.rc_ptr;
                current_node_s = route_nodes[current_node_s].rc;
            }
            else
                break;
        }
        else
        {
            if (parent.lc_ptr)
            {
                current_node = parent.lc_ptr;
                current_node_s = route_nodes[current_node_s].lc;
            }
            else
                break;
        }
        parse_node(current_node, &parent);
        if (parent.nexthop_idx)
        {
            nexthop_idx = parent.nexthop_idx;
            *metric = route_nodes[current_node_s].metric;
        }
    }
    *nexthop_ip = *get_nexthop_ip_addr(nexthop_idx);
    *port = *get_nexthop_port_addr(nexthop_idx);
    return nexthop_idx;
}

void traverse_node(uint32_t ip, uint8_t depth, uint32_t *addr_h, uint32_t addr_s, RoutingTableEntry *buffer, uint32_t *len)
{
    if (!addr_h || !addr_s)
        return;
    trie_node_t node_h;
    parse_node(addr_h, &node_h);
    uint32_t nexthop_idx = node_h.nexthop_idx;
    if (nexthop_idx)
    {
        buffer[*len].ip = ip;
        buffer[*len].metric = route_nodes[addr_s].metric;
        buffer[*len].nexthop_ip = *get_nexthop_ip_addr(nexthop_idx);
        buffer[*len].port = *get_nexthop_port_addr(nexthop_idx);
        buffer[*len].prefix_len = depth;
        *len = (*len) + 1;
    }
    traverse_node(ip, depth + 1, node_h.lc_ptr, route_nodes[addr_s].lc, buffer, len);
    traverse_node(ip | (1 << depth), depth + 1, node_h.rc_ptr, route_nodes[addr_s].rc, buffer, len);
}

void traverse(RoutingTableEntry *buffer, uint32_t *len)
{
    *len = 0;
    traverse_node(0, 0, (uint32_t *)ROOT_ADDR, route_node_t::root, buffer, len);
}

void lookup_test()
{
    RoutingTableEntry entry1 = {
        .ip = 0x00030201,
        .prefix_len = 24,
        .port = 9,
        .nexthop_ip = 0x0203a8c0,
        .metric = 5};
    insert(entry1);
    RoutingTableEntry entry2 = {
        .ip = 0x04030201,
        .prefix_len = 32,
        .port = 10,
        .nexthop_ip = 0x0109a8c0,
        .metric = 3};
    insert(entry2);
    RoutingTableEntry buffer[10];
    uint32_t len = 0;
    traverse(buffer, &len);
    for (uint32_t i; i < len; ++i)
        buffer[i].print();
    uint32_t nexthop_ip, port, metric;
    search(0x04030201, &nexthop_ip, &port, &metric);
    printf("Nexthop: 0x%08x\nPort: %d\nMetric: %d\n", nexthop_ip, port, metric);
    search(0x01030201, &nexthop_ip, &port, &metric);
    printf("Nexthop: 0x%08x\nPort: %d\nMetric: %d\n", nexthop_ip, port, metric);
    search(0x00000000, &nexthop_ip, &port, &metric);
    printf("Nexthop: 0x%08x\nPort: %d\nMetric: %d\n", nexthop_ip, port, metric);
    remove(0x04030201, 32);
    search(0x04030201, &nexthop_ip, &port, &metric);
    printf("Nexthop: 0x%08x\nPort: %d\nMetric: %d\n", nexthop_ip, port, metric);
    search(0x01030201, &nexthop_ip, &port, &metric);
    printf("Nexthop: 0x%08x\nPort: %d\nMetric: %d\n", nexthop_ip, port, metric);
    search(0x00000000, &nexthop_ip, &port, &metric);
    printf("Nexthop: 0x%08x\nPort: %d\nMetric: %d\n", nexthop_ip, port, metric);
    remove(0x00030201, 24);
    search(0x04030201, &nexthop_ip, &port, &metric);
    printf("Nexthop: 0x%08x\nPort: %d\nMetric: %d\n", nexthop_ip, port, metric);
    search(0x01030201, &nexthop_ip, &port, &metric);
    printf("Nexthop: 0x%08x\nPort: %d\nMetric: %d\n", nexthop_ip, port, metric);
    search(0x00000000, &nexthop_ip, &port, &metric);
    printf("Nexthop: 0x%08x\nPort: %d\nMetric: %d\n", nexthop_ip, port, metric);
}