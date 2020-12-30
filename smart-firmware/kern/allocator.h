#ifndef ALLOCATOR_H
#define ALLOCATOR_H
#include <stdint.h>
template <typename T>
struct AllocatorNode
{
    T succ;
    T idx;
};
template <typename T, uint32_t SIZE>
class Allocator
{
private:
    AllocatorNode<T> nodes[SIZE];
    T allocated;

public:
    Allocator()
    {
        allocated = 0;
        for (T i = 0; i < SIZE; ++i)
        {
            nodes[i].idx = i;
            nodes[i].succ = i + 1;
        }
    }
    T get()
    {
        if (allocated >= SIZE - 1)
            return -1;
        ++allocated;
        T idx = nodes[nodes[0].succ].idx;
        nodes[0].succ = nodes[nodes[0].succ].succ;
        return idx;
    }
    void put(T idx)
    {
        nodes[allocated].idx = idx;
        nodes[allocated].succ = nodes[0].succ;
        nodes[0].succ = allocated;
        --allocated;
    }
};

#endif // !1