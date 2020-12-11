#ifndef ALLOCATOR_H
#define ALLOCATOR_H
#include <stdint.h>
const uint16_t ALLOCATOR_SIZE = 8192;
const uint32_t ROUTING_TRIE_SIZE = 0x20000;
struct AllocatorNode
{
    uint16_t succ;
    uint16_t idx;
};
class Allocator
{
private:
    AllocatorNode nodes[ALLOCATOR_SIZE];
    uint16_t allocated;

public:
    Allocator()
    {
        allocated = 0;
        for (uint16_t i = 0; i < ALLOCATOR_SIZE; ++i)
        {
            nodes[i].idx = i;
            nodes[i].succ = i + 1;
        }
    }
    uint16_t get()
    {
        ++allocated;
        uint16_t idx = nodes[nodes[0].succ].idx;
        nodes[0].succ = nodes[nodes[0].succ].succ;
        return idx;
    }
    void put(uint16_t idx)
    {
        nodes[allocated].idx = idx;
        nodes[allocated].succ = nodes[0].succ;
        nodes[0].succ = allocated;
        --allocated;
    }
};

struct RoutingTrieAllocatorNode
{
    uint32_t succ;
    uint32_t idx;
};
class RoutingTrieAllocator
{
private:
    AllocatorNode nodes[ROUTING_TRIE_SIZE];
    uint32_t allocated;

public:
    RoutingTrieAllocator()
    {
        allocated = 0;
        for (uint32_t i = 0; i < ROUTING_TRIE_SIZE; ++i)
        {
            nodes[i].idx = i;
            nodes[i].succ = i + 1;
        }
        get();
    }
    uint32_t get()
    {
        ++allocated;
        uint32_t idx = nodes[nodes[0].succ].idx;
        nodes[0].succ = nodes[nodes[0].succ].succ;
        return idx;
    }
    void put(uint32_t idx)
    {
        nodes[allocated].idx = idx;
        nodes[allocated].succ = nodes[0].succ;
        nodes[0].succ = allocated;
        --allocated;
    }
};

#endif // !1