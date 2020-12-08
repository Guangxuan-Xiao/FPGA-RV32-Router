#include "rip.h"
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <arpa/inet.h>

#define BE16(x) __builtin_bswap16(x)
#define BE32(x) __builtin_bswap32(x)

/*
  在头文件 rip.h 中定义了结构体 `RipEntry` 和 `RipPacket` 。
  你需要从 IPv4 包中解析出 RipPacket 结构体，也要从 RipPacket 结构体构造出对应的
  IP 包。 由于 RIP 包结构本身不记录表项的个数，需要从 IP 头的长度中推断，所以在
  RipPacket 中额外记录了个数。 需要注意这里的地址都是用 **网络字节序（大端序）**
  存储的，1.2.3.4 在小端序的机器上被解释为整数 0x04030201 。
*/

/**
 * @brief 从接受到的 IP 包解析出 RIP 协议的数据
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
 * Metric 是否在 [1,16] 的区间内，
 * Mask 的二进制是不是连续的 1 与连续的 0 组成等等。
 */
bool disassemble(const uint8_t *packet, uint32_t len, RipPacket *output) {
  // TODO:
  uint16_t *buff = (uint16_t *)packet;
  uint16_t length = ntohs(*(buff+1));

  if(length > len)
    return false;

  uint16_t headerLen = (packet[0] & 15) * (packet[0] >> 4);
  uint16_t udpLen = ntohs(*(uint16_t *)(packet + headerLen + 4));
  uint16_t udpNum = (udpLen - 12) / 20;

  const uint8_t *ripPtr = packet + headerLen + 8;
  uint8_t command = *(ripPtr);
  uint8_t version = *(ripPtr+1);
  uint8_t zero0 = *(ripPtr+2);
  uint8_t zero1 = *(ripPtr+3);

  if((command == 1 || command == 2) && version == 2 && zero0 == 0 && zero1 == 0)
  {
    ripPtr += 4;
    output->command = command;
    output->numEntries = udpNum;

    for(int i=0; i<udpNum; i++)
    {

      uint16_t family = *(uint16_t *)ripPtr;
      uint16_t tag = *(uint16_t *)(ripPtr + 2);
      uint32_t ip = *(uint32_t *)(ripPtr + 4);
      uint32_t mask = *(uint32_t *)(ripPtr + 8);
      uint32_t next = *(uint32_t *)(ripPtr + 12);
      uint32_t metric = *(uint32_t *)(ripPtr + 16);
      uint32_t convertMetric = ntohl(metric);

      if(convertMetric < 1 || convertMetric > 16)
        return false;

      bool flag = false;
      uint32_t convertMask = ntohl(mask);

      for(int i=0; i<32; i++)
      {
        bool cur = convertMask & 1;
        if(!flag && cur)
          flag = true;
        if(flag && !cur)
          return false;
        convertMask >>= 1;
      }

      uint16_t convertFamily = ntohs(family);
      if(!(((command==1 && convertFamily==0 ) || (command==2 && convertFamily==2 )) && !tag))
        return false;

      ripPtr += 20;
      output->entries[i].addr = ip;
      output->entries[i].mask = mask;
      output->entries[i].metric = metric;
      output->entries[i].nexthop = next;
    }
    return true;
  }
  else
  {
    return false;
  }
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
uint32_t assemble(const RipPacket *rip, uint8_t *buffer) {
  // TODO:

  *buffer++ = rip->command;
  *buffer++ = 2;
  *buffer++ = 0;
  *buffer++ = 0;

  for(int i=0; i<rip->numEntries; i++)
  {
    int command = (rip->command == 2)? 2 : 0;
    *((uint16_t *)buffer) = htons(command);
    
    buffer += 2;
    *buffer++ = 0;
    *buffer++ = 0;
    *((uint32_t *)buffer) = rip->entries[i].addr;
    buffer += 4;
    *((uint32_t *)buffer) = rip->entries[i].mask;
    buffer += 4;
    *((uint32_t *)buffer) = rip->entries[i].nexthop;
    buffer += 4;
    *((uint32_t *)buffer) = rip->entries[i].metric;
    buffer += 4;
  }

  return 20 * rip->numEntries + 4;
}
