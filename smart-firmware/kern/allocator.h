#ifndef ALLOCATOR_H
#define ALLOCATOR_H
#include <stdint.h>
#include <stdlib.h>
struct AllocatorNode
{
    uint16_t succ;
    uint16_t idx;
};
class Allocator
{
private:
    AllocatorNode *nodes;
    uint16_t allocated;

public:
    Allocator(uint16_t size = 8192);
    ~Allocator();
    uint16_t get();
    void put(uint16_t idx);
};

#endif // !1