#include "router.h"
#include "lookup.h"
#include <stdio.h>

void receive(uint8_t* buffer, uint32_t src)
{
    volatile uint32_t* ptr;
    ptr = (volatile uint32_t*)(buffer_read_start_addr + src * buffer_size + buffer_size_addr);
    uint32_t buf = 0;
    uint32_t len = *ptr;
    len = ((len & 0xFF000000) >> 24) + ((len & 0xFF0000) >> 8);
    ptr = (volatile uint32_t*)(buffer_read_start_addr + src * buffer_size);
    for (i = 0; i < len; i = i + 4)
    {
        buf = *ptr;
        buffer[i] = buf & 0xFF;
        buffer[i + 1] = (buf & 0xFF00) >> 8;
        buffer[i + 2] = (buf & 0xFF0000) >> 16;
        buffer[i + 3] = (buf & 0xFF000000) >> 24;
        ptr = ptr + 1;
    }
    buf = 0;
}

void send(uint8_t* buffer, uint32_t len, uint32_t dst);
{
    uint32_t i = 0;
    volatile uint32_t* ptr;
    ptr = (volatile uint32_t*)(buffer_write_start_addr + dst * buffer_size);
    uint32_t buf = 0;
    len = len - 4;
    for (i = 0; i < len; i = i + 4)
    {
        buf = buffer[i] + (buffer[i+1]<<8) + (buffer[i+2]<<16) + (buffer[i+3]<<24);
        *ptr = buf;
        ptr = ptr + 1;
    }
    len = len + 4;
    buf = 0;
    for (; i < len; i++)
    {
        buf = buf + (buffer[i] << (i % 4));
    }
    *ptr = buf;
    ptr = (volatile uint32_t*)(buffer_read_start_addr + dst * buffer_size + buffer_size_addr);
    buf = ((len & 0xFF) << 24) + ((len & 0xFF00) << 8);
    *ptr = buf;
}
