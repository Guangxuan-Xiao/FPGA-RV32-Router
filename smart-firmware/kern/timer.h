#ifndef TIME_H
#define TIME_H
#include <stdint.h>
#include <stdio.h>
const uint32_t NS_PER_CLOCK = 20;
const uint32_t CLOCK_PER_SEC = 50000000;
const uint32_t CLOCK_PER_MS = 50000;
uint32_t get_clock()
{
    return *((uint32_t *)0x10000010);
}
void clock_test()
{
    uint32_t last_clock = get_clock(), current_clock;
    uint32_t cnt = 0;
    while (1)
    {
        current_clock = get_clock();
        if (current_clock - last_clock >= CLOCK_PER_SEC)
        {
            printf("%d\n", ++cnt);
            last_clock = current_clock;
        }
    }
}
#endif // !TIME_H