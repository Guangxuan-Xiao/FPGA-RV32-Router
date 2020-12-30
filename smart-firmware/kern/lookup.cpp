#include "lookup.h"
#include "trie.h"
#include "allocator.h"
#include <stdio.h>
#include <netinet/ip.h>
static Allocator<uint16_t, TRIE_LAYER_CAPACITY + 20> allocators[32];
static int nexthop_size = 0;

static uint8_t metrics[32][TRIE_LAYER_CAPACITY + 20], times[32][TRIE_LAYER_CAPACITY + 20];
void RoutingTableEntry::print()
{
    printf("IP: %08x\r\n", ip);
    printf("Prefix Length: %u\r\n", prefix_len);
    printf("Port: %u\r\n", port);
    printf("Next-hop IP: %08x\r\n", nexthop_ip);
    printf("Metric: %d\r\n", metric);
}

void init()
{
    nexthop_size = 0;
    for (uint32_t i = 0; i <= 32; ++i)
    {
        printf("Initializing Layer: %u\r\n", i);
        for (uint32_t j = 1; j < TRIE_LAYER_CAPACITY; ++j)
        {
            // printf("Clearing node %u\r\n", j);
            *get_node_addr(i, j) = 0;
        }
    }
}

void insert(RoutingTableEntry entry)
{
    trie_node_t parent;
    uint32_t *current_node = (uint32_t *)ROOT_ADDR;
    uint16_t idx;
    uint32_t ip = ntohl(entry.ip);
    for (uint32_t i = 0; i < entry.prefix_len; ++i)
    {
        // printf("Node Addr: %u %x\r\n", current_node_s, current_node);
        parse_node(current_node, &parent);
        int bit = (ip >> (31 - i)) & 1;
        if (bit)
        {
            if (!parent.rc_ptr)
            {
                idx = allocators[i].get();
                if (idx == 0xFFFF)
                    return;
                parent.rc_ptr = get_node_addr(i + 1, idx);
                set_rc(current_node, idx);
            }
            current_node = parent.rc_ptr;
        }
        else
        {
            if (!parent.lc_ptr)
            {
                idx = allocators[i].get();
                if (idx == 0xFFFF)
                    return;
                parent.lc_ptr = get_node_addr(i + 1, idx);
                set_lc(current_node, idx);
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
    uint32_t current_idx = get_idx(current_node);
    metrics[entry.prefix_len - 1][current_idx] = entry.metric;
    times[entry.prefix_len - 1][current_idx] = 0;
}

void remove(uint32_t ip, uint32_t prefix_len)
{
    trie_node_t parent;
    uint32_t *current_node = (uint32_t *)ROOT_ADDR;
    uint32_t *path[33] = {current_node, 0};
    ip = ntohl(ip);
    for (uint32_t i = 0; i < prefix_len; ++i)
    {
        parse_node(current_node, &parent);
        int bit = (ip >> (31 - i)) & 1;
        if (bit)
        {
            if (parent.rc_ptr)
            {
                current_node = parent.rc_ptr;
            }
            else
                return;
        }
        else
        {
            if (parent.lc_ptr)
            {
                current_node = parent.lc_ptr;
            }
            else
                return;
        }
        path[i + 1] = current_node;
    }
    set_nexthop(current_node, 0);
    uint32_t current_idx = get_idx(current_node);
    metrics[prefix_len - 1][current_idx] = -1;
    times[prefix_len - 1][current_idx] = 0;
    // Trace back
    uint16_t idx;
    for (int i = prefix_len - 1; i >= 0; --i)
    {
        int bit = (ip >> (31 - i)) & 1;
        if (*path[i + 1] == 0)
        {
            // --layer_size[i];
            idx = get_idx(path[i + 1]);
            allocators[i].put(idx);
            if (bit)
            {
                set_rc(path[i], 0);
            }
            else
            {
                set_lc(path[i], 0);
            }
        }
        else
            return;
    }
}

uint32_t search(uint32_t ip, uint32_t prefix_len, uint32_t *nexthop_ip, uint32_t *port, uint32_t *metric)
{
    trie_node_t parent;
    uint32_t nexthop_idx = 0;
    uint32_t *current_node = (uint32_t *)ROOT_ADDR;
    parse_node(current_node, &parent);
    *metric = 0x10;
    ip = ntohl(ip);
    for (uint32_t i = 0; i < prefix_len; ++i)
    {
        int bit = (ip >> (31 - i)) & 1;
        if (bit)
        {
            if (parent.rc_ptr)
            {
                current_node = parent.rc_ptr;
            }
            else
                return 0;
        }
        else
        {
            if (parent.lc_ptr)
            {
                current_node = parent.lc_ptr;
            }
            else
                return 0;
        }
        parse_node(current_node, &parent);
    }
    if (parent.nexthop_idx)
    {
        nexthop_idx = parent.nexthop_idx;
        *metric = metrics[prefix_len - 1][get_idx(current_node)];
        *nexthop_ip = *get_nexthop_ip_addr(nexthop_idx);
        *port = *get_nexthop_port_addr(nexthop_idx);
        return nexthop_idx;
    }
    else
        return 0;
}

void traverse_node(uint32_t ip, uint8_t depth, uint32_t *addr_h, RoutingTableEntry *buffer, uint32_t *len)
{
    //printf("Node Addr: %u %x\r\n", addr_s, addr_h);
    if (!addr_h)
        return;
    trie_node_t node_h;
    parse_node(addr_h, &node_h);
    uint32_t nexthop_idx = node_h.nexthop_idx;
    if (nexthop_idx)
    {
        buffer[*len].ip = htonl(ip);
        buffer[*len].metric = metrics[depth - 1][get_idx(addr_h)];
        buffer[*len].nexthop_ip = *get_nexthop_ip_addr(nexthop_idx);
        buffer[*len].port = *get_nexthop_port_addr(nexthop_idx);
        buffer[*len].prefix_len = depth;
        *len = (*len) + 1;
    }
    traverse_node(ip, depth + 1, node_h.lc_ptr, buffer, len);
    traverse_node(ip | (1 << (31 - depth)), depth + 1, node_h.rc_ptr, buffer, len);
}

uint32_t traverse(RoutingTableEntry *buffer)
{
    //printf("start traverse.\r\n");
    uint32_t len = 0;
    traverse_node(0, 0, (uint32_t *)ROOT_ADDR, buffer, &len);
    return len;
}

void step_node(uint32_t ip, uint8_t depth, uint32_t *addr_h)
{
    if (!addr_h)
        return;
    trie_node_t node_h;
    parse_node(addr_h, &node_h);
    uint32_t nexthop_idx = node_h.nexthop_idx;
    if (nexthop_idx)
    {
        uint32_t nexthop_ip = *get_nexthop_ip_addr(nexthop_idx);
        if (nexthop_ip)
            ++times[depth - 1][get_idx(addr_h)];
        if (times[depth - 1][get_idx(addr_h)] >= GARBAGE)
        {
            remove(htonl(ip), depth);
        }
        else if (times[depth - 1][get_idx(addr_h)] >= TIMEOUT)
        {
            metrics[depth - 1][get_idx(addr_h)] = 16;
        }
    }
    step_node(ip, depth + 1, node_h.lc_ptr);
    step_node(ip | (1 << (31 - depth)), depth + 1, node_h.rc_ptr);
}

void step()
{
    step_node(0, 0, (uint32_t *)ROOT_ADDR);
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
    remove(0x00030201, 24);
    insert(entry1);
    RoutingTableEntry entry2 = {
        .ip = 0x04030201,
        .prefix_len = 32,
        .port = 10,
        .nexthop_ip = 0x0109a8c0,
        .metric = 3};
    insert(entry2);
    RoutingTableEntry entry3 = {
        .ip = 0x0b0a0103,
        .prefix_len = 24,
        .port = 8,
        .nexthop_ip = 0x0109a8c0,
        .metric = 1};
    insert(entry3);
    RoutingTableEntry buffer[10];
    uint32_t len = traverse(buffer);
    printf("Routing Table Size: %u\r\n", len);
    for (uint32_t i = 0; i < len; ++i)
        buffer[i].print();
    printf("\r\n");
    // uint32_t nexthop_ip, port, metric;
    // search(0x04030201, &nexthop_ip, &port, &metric);
    // printf("Nexthop: 0x%08x\r\nPort: %d\r\nMetric: %d\r\n", nexthop_ip, port, metric);
    // search(0x01030201, &nexthop_ip, &port, &metric);
    // printf("Nexthop: 0x%08x\r\nPort: %d\r\nMetric: %d\r\n", nexthop_ip, port, metric);
    // search(0x00000000, &nexthop_ip, &port, &metric);
    // printf("Nexthop: 0x%08x\r\nPort: %d\r\nMetric: %d\r\n", nexthop_ip, port, metric);
    // remove(0x04030201, 32);
    // len = traverse(buffer);
    // printf("Routing Table Size: %u\r\n", len);
    // for (uint32_t i = 0; i < len; ++i)
    //     buffer[i].print();
    // printf("\r\n");
    // search(0x04030201, &nexthop_ip, &port, &metric);
    // printf("Nexthop: 0x%08x\r\nPort: %d\r\nMetric: %d\r\n", nexthop_ip, port, metric);
    // search(0x01030201, &nexthop_ip, &port, &metric);
    // printf("Nexthop: 0x%08x\r\nPort: %d\r\nMetric: %d\r\n", nexthop_ip, port, metric);
    // search(0x00000000, &nexthop_ip, &port, &metric);
    // printf("Nexthop: 0x%08x\r\nPort: %d\r\nMetric: %d\r\n", nexthop_ip, port, metric);
    // remove(0x00030201, 24);
    // search(0x0b0a0103, &nexthop_ip, &port, &metric);
    // printf("Nexthop: 0x%08x\r\nPort: %d\r\nMetric: %d\r\n", nexthop_ip, port, metric);
    // len = traverse(buffer);
    // printf("Routing Table Size: %u\r\n", len);
    // for (uint32_t i = 0; i < len; ++i)
    //     buffer[i].print();
    // printf("\r\n");
    // search(0x04030201, &nexthop_ip, &port, &metric);
    // printf("Nexthop: 0x%08x\r\nPort: %d\r\nMetric: %d\r\n", nexthop_ip, port, metric);
    // search(0x01030201, &nexthop_ip, &port, &metric);
    // printf("Nexthop: 0x%08x\r\nPort: %d\r\nMetric: %d\r\n", nexthop_ip, port, metric);
    // search(0x00000000, &nexthop_ip, &port, &metric);
    // printf("Nexthop: 0x%08x\r\nPort: %d\r\nMetric: %d\r\n", nexthop_ip, port, metric);
}