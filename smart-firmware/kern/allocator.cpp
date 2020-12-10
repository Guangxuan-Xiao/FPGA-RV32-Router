#include "allocator.h"
Allocator::Allocator()
{
    allocated = 0;
    for (uint16_t i = 0; i < ALLOCATOR_SIZE; ++i)
    {
        nodes[i].idx = i;
        nodes[i].succ = i + 1;
    }
}

uint16_t Allocator::get()
{
    ++allocated;
    uint16_t idx = nodes[nodes[0].succ].idx;
    nodes[0].succ = nodes[nodes[0].succ].succ;
    return idx;
}

void Allocator::put(uint16_t idx)
{
    nodes[allocated].idx = idx;
    nodes[allocated].succ = nodes[0].succ;
    nodes[0].succ = allocated;
    --allocated;
}