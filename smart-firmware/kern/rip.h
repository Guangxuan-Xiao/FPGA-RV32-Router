#ifndef RIP_H
#define RIP_H
#include <stdint.h>
#define RIP_MAX_ENTRY 25
typedef struct
{
    // 所有字段都是大端序
    // 没有存储 `family` 字段，因为在请求里是 0，在回应里是 2
    // 也不用存储 `tag` 字段，因为它是 0
    uint32_t addr;
    uint32_t mask;
    uint32_t nexthop;
    uint32_t metric;
} RipEntry;

typedef struct
{
    uint32_t numEntries;
    // 下面所有字段都是大端序
    uint8_t command;
    // 不用存储 `version`，因为它总是 2
    // 不用存储 `zero`，因为它总是 0
    RipEntry entries[RIP_MAX_ENTRY];
} RipPacket;

bool disassemble(const uint8_t *packet, uint32_t len, RipPacket *output);
uint32_t assemble(const RipPacket *rip, uint8_t *buffer);
#endif // !RIP_H
