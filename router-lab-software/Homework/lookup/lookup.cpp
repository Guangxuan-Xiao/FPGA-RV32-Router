#include "router.h"
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <unordered_map>
#include <arpa/inet.h>
using namespace std;

/**
 * @brief 插入/删除一条路由表表项
 * @param insert 如果要插入则为 true ，要删除则为 false
 * @param entry 要插入/删除的表项
 *
 * 插入时如果已经存在一条 addr 和 len 都相同的表项，则替换掉原有的。
 * 删除时按照 addr 和 len **精确** 匹配。
 */


unordered_map<uint32_t, RoutingTableEntry> table;

void update(bool insert, RoutingTableEntry entry) 
{

  uint32_t maskShift = 32 - entry.len;
  uint32_t mask = 0xffffffff << maskShift;
  uint32_t addr = ntohl(entry.addr) & mask;

  if(insert)
    table[addr] = {addr, entry.len, entry.if_index, ntohl(entry.nexthop)};
  
  else
  {
    auto it = table.find(addr);
    if(it != table.end())
      table.erase(it);
  }
}

/**
 * @brief 进行一次路由表的查询，按照最长前缀匹配原则
 * @param addr 需要查询的目标地址，网络字节序
 * @param nexthop 如果查询到目标，把表项的 nexthop 写入
 * @param if_index 如果查询到目标，把表项的 if_index 写入
 * @return 查到则返回 true ，没查到则返回 false
 */
bool prefix_query(uint32_t addr, uint32_t *nexthop, uint32_t *if_index) {
  // TODO:
  int cur = 32;
  while(cur>=0)
  {
    uint32_t shift = 32 - cur;
    uint32_t mask = 0xffffffff << shift;
    uint32_t maskAddr = ntohl(addr) & mask;

    auto it = table.find(maskAddr);
    if(it != table.end() && it->second.len == cur)
    {
      *nexthop = htonl(it->second.nexthop);
      *if_index = it->second.if_index;
      return true;
    }

    cur--;
  }

  *nexthop = 0;
  *if_index = 0;
  return false;
}
