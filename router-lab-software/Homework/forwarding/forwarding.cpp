#include <stdint.h>
#include <stdlib.h>

// 在 checksum.cpp 中定义
extern bool validateIPChecksum(uint8_t *packet, size_t len);


/**
 * @brief 进行转发时所需的 IP 头的更新：
 *        你需要先检查 IP 头校验和的正确性，如果不正确，直接返回 false ；
 *        如果正确，请更新 TTL 和 IP 头校验和，并返回 true 。
 *        你可以调用 checksum 题中的 validateIPChecksum 函数，
 *        编译的时候会链接进来。
 * @param packet 收到的 IP 包，既是输入也是输出，原地更改
 * @param len 即 packet 的长度，单位为字节
 * @return 校验和无误则返回 true ，有误则返回 false
 */
bool forward(uint8_t *packet, size_t len) {
  if(validateIPChecksum(packet, len) == false)
    return false;
  else
  {
    uint8_t ttl = *(packet + 8);
    uint16_t* buffer = (uint16_t*) packet;
    uint16_t sum = 0;
    int length = ( * packet >> 4) * ( 15 & * packet);

    packet[8] = ttl - 1;
    for(int i=0;i<length;i+=2)
    {
      if(i!=10)
        sum += *buffer++;
      else
        buffer++;
    }
    sum = (sum>>16) + (sum&0xffff);
    sum += sum >> 16;
    sum = ~sum;
    if(sum != 0)
      sum -= 1;
    packet[11] = sum >> 8;
    packet[10] = sum & 255; 
    return true;
  }
}
