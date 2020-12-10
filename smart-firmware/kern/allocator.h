#ifndef ALLOCATOR_H
#define ALLOCATOR_H
#include <stdint.h>
const uint16_t ALLOCATOR_SIZE = 8192;
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
    Allocator();
    uint16_t get();
    void put(uint16_t idx);
};

#endif // !1