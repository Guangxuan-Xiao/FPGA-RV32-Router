#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

/**
 * @brief 进行 IP 头的校验和的验证
 * @param packet 完整的 IP 头和载荷
 * @param len 即 packet 的长度，单位是字节，保证包含完整的 IP 头
 * @return 校验和无误则返回 true ，有误则返回 false
 */
bool validateIPChecksum(uint8_t *packet, size_t len) {
  // TODO:

  uint16_t* buffer = (uint16_t*) packet;

  uint16_t oldSum = *(buffer+5);
  uint32_t sum = 0;

  int length = ( * packet >> 4) * ( 15 & * packet);

  for(int i=0; i<length; i+=2)
  {
    sum += *buffer++;
  }

  sum = (sum>>16) + (sum&0xffff);
  sum += sum >> 16;
  sum = ~sum;

  if(sum == -65536)
    return true;
  else
    return false;
}
