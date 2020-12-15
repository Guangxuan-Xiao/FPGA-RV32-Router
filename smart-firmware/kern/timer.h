#ifndef TIMER_H
#define TIMER_H
#include <stdint.h>
#include <stdio.h>
const uint32_t NS_PER_CLOCK = 20;
const uint32_t CLOCK_PER_SEC = 50000000;
const uint32_t CLOCK_PER_MS =  50000;
const uint32_t CLOCK_PER_US =  50;
uint32_t get_clock()
{
    return *((volatile uint32_t *)0x10000010);
}

void sleep(uint32_t usec)
{
    uint32_t last_clock = get_clock(), current_clock = get_clock();
    while (1)
    {
        current_clock = get_clock();
        if (current_clock - last_clock >= usec * CLOCK_PER_US)
        {
            return;
        }
    }
}

void clock_test()
{
    uint32_t last_clock = get_clock(), current_clock = get_clock();
    uint32_t cnt = 0;
    while (1)
    {
        current_clock = get_clock();
        if (current_clock - last_clock >= CLOCK_PER_SEC)
        {
            printf("%u Seconds Elapsed.\n", ++cnt);
            last_clock = current_clock;
        }
    }
}
#endif // !TIMER_H