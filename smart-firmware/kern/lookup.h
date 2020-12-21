#ifndef LOOKUP_H
#define LOOKUP_H
#include <stdint.h>

/*
  RoutingTable Entry 的定义如下：
  typedef struct {
    uint32_t addr; // 大端序，IPv4 地址
    uint32_t len; // 小端序，前缀长度
    uint32_t if_index; // 小端序，出端口编号
    uint32_t nexthop; // 大端序，下一跳的 IPv4 地址
  } RoutingTableEntry;

  约定 addr 和 nexthop 以 **大端序** 存储。
  这意味着 1.2.3.4 对应 0x04030201 而不是 0x01020304。
  保证 addr 仅最低 len 位可能出现非零。
  当 nexthop 为零时这是一条直连路由。
  你可以在全局变量中把路由表以一定的数据结构格式保存下来。
*/
struct RoutingTableEntry
{
  uint32_t ip;
  uint32_t prefix_len;
  uint32_t port;
  uint32_t nexthop_ip;
  uint32_t metric;
  void print();
};
void init();
void insert(RoutingTableEntry entry);
void remove(uint32_t ip, uint32_t prefix_len);
uint32_t search(uint32_t ip, uint32_t prefix_len, uint32_t *nexthop_ip, uint32_t *port, uint32_t *metric);
uint32_t traverse(RoutingTableEntry *buffer);
void lookup_test();
#endif