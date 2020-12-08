#include "rip.h"
#include <inet.h>
static const uint32_t TOP1 = 0x80000000;
/*
  在头文件 rip.h 中定义了如下的结构体：
  #define RIP_MAX_ENTRY 25
  typedef struct {
    // all fields are big endian
    // we don't store 'family', as it is always 2(for response) and 0(for
  request)
    // we don't store 'tag', as it is always 0
    uint32_t addr;
    uint32_t mask;
    uint32_t nexthop;
    uint32_t metric;
  } RipEntry;

  typedef struct {
    uint32_t numEntries;
    // all fields below are big endian
    uint8_t command; // 1 for request, 2 for response, otherwsie invalid
    // we don't store 'version', as it is always 2
    // we don't store 'zero', as it is always 0
    RipEntry entries[RIP_MAX_ENTRY];
  } RipPacket;

  你需要从 IPv4 包中解析出 RipPacket 结构体，也要从 RipPacket 结构体构造出对应的
  IP 包 由于 Rip 包结构本身不记录表项的个数，需要从 IP 头的长度中推断，所以在
  RipPacket 中额外记录了个数。 需要注意这里的地址都是用 **大端序**
  存储的，1.2.3.4 对应 0x04030201 。
*/

bool checkZero(const uint8_t *packet, uint32_t start, uint32_t end)
{
    while (start < end)
    {
        if (packet[start])
            return false;
        ++start;
    }
    return true;
}

bool checkMask(uint32_t mask)
{
    while (mask & TOP1)
        mask <<= 1;
    return !mask;
}

/**
 * @brief 从接受到的 IP 包解析出 Rip 协议的数据
 * @param packet 接受到的 IP 包
 * @param len 即 packet 的长度
 * @param output 把解析结果写入 *output
 * @return 如果输入是一个合法的 RIP 包，把它的内容写入 RipPacket 并且返回
 * true；否则返回 false
 *
 * IP 包的 Total Length 长度可能和 len 不同，当 Total Length 大于 len
 * 时，把传入的 IP 包视为不合法。 你不需要校验 IP 头和 UDP 的校验和是否合法。
 * 你需要检查 Command 是否为 1 或 2，Version 是否为 2， Zero 是否为 0，
 * Family 和 Command 是否有正确的对应关系（见上面结构体注释），Tag 是否为 0，
 * Metric 转换成小端序后是否在 [1,16] 的区间内，
 * Mask 的二进制是不是连续的 1 与连续的 0 组成等等。
 */
bool disassemble(const uint8_t *packet, uint32_t len, RipPacket *output)
{
    uint32_t totalLength = (packet[2] << 8) | packet[3];
    if (totalLength > len)
        return false;
    uint32_t i = (packet[0] & 0xF) << 2;
    i += 8;
    uint8_t command = packet[i], version = packet[i + 1];
    if (command != 1 && command != 2)
        return false;
    if (version != 2)
        return false;
    i += 2;
    if (!checkZero(packet, i, i + 2))
        return false;
    i += 2;
    uint32_t num = (len - i) / 20;
    output->numEntries = num;
    output->command = command;
    for (int j = 0; j < num; ++j)
    {
        RipEntry &entry = output->entries[j];
        uint16_t family = (packet[i] << 8) | packet[i + 1];
        if ((command == 1 && family != 0) || (command == 2 && family != 2))
            return false;
        i += 2;
        if (!checkZero(packet, i, i + 2))
            return false;
        i += 2;

        entry.addr = *((uint32_t *)(packet + i));
        i += 4;

        uint32_t mask = *((uint32_t *)(packet + i));
        i += 4;

        if (!checkMask(htonl(mask)))
            return false;
        entry.mask = mask;
        entry.nexthop = *((uint32_t *)(packet + i));
        i += 4;

        entry.metric = *((uint32_t *)(packet + i));
        i += 4;
        uint32_t metric = htonl(entry.metric);
        if (metric < 1 || metric > 16)
            return false;
    }
    return true;
}

/**
 * @brief 从 RipPacket 的数据结构构造出 RIP 协议的二进制格式
 * @param rip 一个 RipPacket 结构体
 * @param buffer 一个足够大的缓冲区，你要把 RIP 协议的数据写进去
 * @return 写入 buffer 的数据长度
 *
 * 在构造二进制格式的时候，你需要把 RipPacket 中没有保存的一些固定值补充上，包括
 * Version、Zero、Address Family 和 Route Tag 这四个字段 你写入 buffer
 * 的数据长度和返回值都应该是四个字节的 RIP 头，加上每项 20 字节。
 * 需要注意一些没有保存在 RipPacket 结构体内的数据的填写。
 */
uint32_t assemble(const RipPacket *rip, uint8_t *buffer)
{
    uint32_t i = 0;
    buffer[i++] = rip->command;
    buffer[i++] = 2;
    buffer[i] = buffer[i + 1] = 0;
    i += 2;
    uint8_t family = rip->command == 1 ? 0 : 2;
    for (int j = 0; j < rip->numEntries; ++j)
    {
        *(uint8_t *)(buffer + i) = 0;
        ++i;
        *(uint8_t *)(buffer + i) = family;
        ++i;
        *(uint16_t *)(buffer + i) = 0;
        i += 2;
        *(uint32_t *)(buffer + i) = rip->entries[j].addr;
        i += 4;
        *(uint32_t *)(buffer + i) = rip->entries[j].mask;
        i += 4;
        *(uint32_t *)(buffer + i) = rip->entries[j].nexthop;
        i += 4;
        *(uint32_t *)(buffer + i) = rip->entries[j].metric;
        i += 4;
    }
    return i;
}
