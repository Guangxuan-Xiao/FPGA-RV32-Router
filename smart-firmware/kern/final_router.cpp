#include "rip.h"
#include "router.h"
#include "router_hal.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <netinet/udp.h>
#include <algorithm>

#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#define BE16(x) __builtin_bswap16(x)
#define BE32(x) __builtin_bswap32(x)
#else
#define BE16(x) x
#define BE32(x) x
#endif

#define CNT1(x) __builtin_popcount(x)

extern bool validateIPChecksum(uint8_t *packet, size_t len);
extern void update(bool insert, RoutingTableEntry entry);
extern bool prefix_query(uint32_t addr, uint32_t *nexthop, uint32_t *if_index);
extern bool forward(uint8_t *packet, size_t len);
extern bool disassemble(const uint8_t *packet, uint32_t len, RipPacket *output);
extern uint32_t assemble(const RipPacket *rip, uint8_t *buffer);
extern void insert(RoutingTableEntry entry);
extern void remove(uint32_t ip, uint32_t prefix_len);
extern uint32_t search(uint32_t ip, uint32_t *nexthop_ip, uint32_t *port, uint32_t *metric);
extern uint32_t get_clock();

uint8_t packet[2048];
uint8_t output[2048];

//ip packet extract difinition
struct ipheader {
  uint8_t ihl : 4, version : 4;
  uint8_t tos;
  uint16_t tot_len;
  uint16_t id;
  uint16_t frag_off;
  uint8_t ttl;
  uint8_t protocol;
  uint16_t check;
  uint32_t saddr;
  uint32_t daddr;
};

//rip packet extract difinition
struct RawRip {
  uint8_t command;  // 1(request) or 2(reponse)
  uint8_t version;  // 2
  uint16_t zero;
  struct Entry {
    uint16_t family;  // 0(request) or 2(response)
    uint16_t tag;     // 0
    uint32_t addr;
    uint32_t mask;  // todo
    uint32_t nexthop;
    uint32_t metric;  // [1, 16]
  } entries[0];
};

// for online experiment, don't change
#ifdef ROUTER_R1
// 0: 192.168.1.1
// 1: 192.168.3.1
// 2: 192.168.6.1
// 3: 192.168.7.1
const in_addr_t addrs[N_IFACE_ON_BOARD] = {0x0101a8c0, 0x0103a8c0, 0x0106a8c0,
                                           0x0107a8c0};
const int router_id = 1;
#elif defined(ROUTER_R2)
// 0: 192.168.3.2
// 1: 192.168.4.1
// 2: 192.168.8.1
// 3: 192.168.9.1
const in_addr_t addrs[N_IFACE_ON_BOARD] = {0x0203a8c0, 0x0104a8c0, 0x0108a8c0,
                                           0x0109a8c0};
const int router_id = 2;
#elif defined(ROUTER_R3)
// 0: 192.168.4.2
// 1: 192.168.5.2
// 2: 192.168.10.1
// 3: 192.168.11.1
const in_addr_t addrs[N_IFACE_ON_BOARD] = {0x0204a8c0, 0x0205a8c0, 0x010aa8c0,
                                           0x010ba8c0};
const int router_id = 3;
#else

// 自己调试用，你可以按需进行修改，注意字节序
// 0: 10.0.0.1
// 1: 10.0.1.1
// 2: 10.0.2.1
// 3: 10.0.3.1
in_addr_t addrs[N_IFACE_ON_BOARD] = {0x0100000a, 0x0101000a, 0x0102000a,
                                     0x0103000a};
const int router_id = 4;
#endif
const in_addr_t multicastIP = 0x090000e0; //组播地址
const macaddr_t multicastMac = {0x01,0x00,0x5e,0x00,0x00,0x09};
const in_addr_t debugIP = 0x0000010a;

uint16_t calculate_checksum(ip *ip_header){
  uint16_t old = ip_header->ip_sum;
  ip_header->ip_sum = 0;
  uint32_t len = (ip_header->ip_hl) * 2;
  uint32_t sum = 0;
  uint16_t *cur = (uint16_t *)ip_header;
  for(int i = 0; i < len; ++i){
    sum += *(cur++);
  }
  ip_header->ip_sum = old;
  sum = (sum & 0xffff) + (sum >> 16);
  sum = (sum & 0xffff) + (sum >> 16);
  return (uint16_t)~sum;
}

#define IP_FMT(x) x >> 24, x >> 16 & 0xFF, x >> 8 & 0xFF, x & 0xFF

void print_table() {
  uint32_t size = (uint32_t)routingTbl.size();
  printf("router:%d, routingTbl: count = %d, last 25 elements = [\n",router_id, size);
  // for (uint32_t i = size > 25 ? size - 25 : 0; i < size; ++i) {
  //   RoutingTableEntry &e = routingTbl[i];
  //   uint32_t addr = BE32(e.addr), nexthop = BE32(e.nexthop);
  //   printf("  { addr: %d.%d.%d.%d, mask: %08x, nexthop: %d.%d.%d.%d, metric: %d},\n",
  //          IP_FMT(addr), BE32(~(( 1 << (32-e.len) )- 1)), IP_FMT(nexthop), (e.metric));
  // }
  // printf("]\n");
  fflush(stdout);
}

//使用前应当先将checksum置为零
uint16_t get_checksum(uint16_t *hdr, const size_t bytes){
  uint32_t sum = 0;
  uint16_t *cur = (uint16_t *)hdr;
  for(int i = 0; i < bytes / 2; ++i){
    sum += *(cur++);
  }
  sum = (sum & 0xffff) + (sum >> 16);
  sum = (sum & 0xffff) + (sum >> 16);
  return (uint16_t)~sum;
}

void send_all_rip(int if_index, const uint32_t dst_addr, const macaddr_t dst_mac){
  int rest_ripentry = routingTbl.size();
  while(rest_ripentry > 25){
    // printf("rest_rip_entry = %d\n", rest_ripentry);
    // fflush(stdout);
    int start = rest_ripentry - 25;
    RipPacket resp;
    // TODO: fill resp  
    // implement split horizon with poisoned reverse
    // ref. RFC 2453 Section 3.4.3
    resp.command = 2;
    resp.numEntries = 25;

    // printf("multicast[%d]:routingTbl:[\n", i);
    for(int i = start; i < rest_ripentry; ++i){
      resp.entries[i - start].addr = routingTbl[i].addr; //网络字节序
      resp.entries[i - start].mask = BE32(~((1<<(32 - routingTbl[i].len)) - 1)); //网络字节序
      resp.entries[i - start].metric = BE32(routingTbl[i].metric); 
      resp.entries[i - start].nexthop = 0; // 网络字节序
      // printf("{ addr: %d.%d.%d.%d, mask: %08x, nexthop: %d.%d.%d.%d, metric: %d},\n",
      //   IP_FMT(resp.entries[i].addr), resp.entries[i].mask, IP_FMT(resp.entries[i].nexthop), resp.entries[i].metric);
    }
      // printf("]\n");
      // fflush(stdout);
    // printf("finished resp fill\n");
    // fflush(stdout);

    // fill IP headers
    struct ip *ip_header = (struct ip *)output;
    ip_header->ip_hl = 5;
    uint32_t totlen = ip_header->ip_hl * 4 + 8 + 4 + resp.numEntries * 20;
    ip_header->ip_v = 4;
    // TODO: set tos = 0, id = 0, off = 0, ttl = 1, p = 17(udp), dst and src DONE
    ip_header->ip_tos = 0;
    ip_header->ip_id = 0;
    ip_header->ip_off = 0;
    ip_header->ip_ttl = 1;
    ip_header->ip_p = 17;
    ip_header->ip_len = BE16((uint16_t)totlen);
    ip_header->ip_dst.s_addr = dst_addr;
    ip_header->ip_src.s_addr = addrs[if_index]; 

    // printf("finish ip header filling\n");
    // fflush(stdout);
    // fill UDP headers
    struct udphdr *udpHeader = (struct udphdr *)&output[ip_header->ip_hl * 4];
    // src port = 520
    udpHeader->uh_sport = htons(520);
    // dst port = 520
    udpHeader->uh_dport = htons(520);

    // assemble RIP
    uint32_t rip_len = assemble(&resp, &output[ip_header->ip_hl * 4 + 8]);
    // TODO: udp length
    udpHeader->uh_ulen = BE16((uint16_t)(rip_len + 8));

    // TODO: checksum calculation for ip and udp
    // if you don't want to calculate udp checksum, set it to zero
    udpHeader->uh_sum = 0; 

    // printf("finish udp header filling\n");
    // fflush(stdout);
    
    uint16_t checksum = calculate_checksum(ip_header);
    ip_header->ip_sum = checksum;

    // printf("finish checksum\n");
    // fflush(stdout);

          

          //*************debug*************
          // RawRip* debugrip = (RawRip *)&output[28];
          // printf("send rip packet entries:[\n");
          // for(int i = 0; i < (totlen - 32) / 20; ++i){
          // printf("{ addr: %d.%d.%d.%d, mask: %08x, nexthop: %d.%d.%d.%d, metric: %d},\n",
          //     IP_FMT(debugrip->entries[i].addr), debugrip->entries[i].mask, IP_FMT(debugrip->entries[i].nexthop), debugrip->entries[i].metric);
          // }
          // printf("]\n");
          // fflush(stdout);
          //*******************************

        
          // send it back
    macaddr_t dest_mac;
    if(HAL_ArpGetMacAddress(if_index, dst_addr, dest_mac) == 0){
      // printf("start send IP packet\n");
      // fflush(stdout);
      HAL_SendIPPacket(if_index, output, totlen, dest_mac);
    }

    // printf("sent HAL\n");
    // fflush(stdout);
    rest_ripentry -= 25;
    }
    if(rest_ripentry > 0){
      RipPacket resp;
      // TODO: fill resp  
      // implement split horizon with poisoned reverse
      // ref. RFC 2453 Section 3.4.3
      resp.command = 2;
      resp.numEntries = rest_ripentry;

      // printf("multicast[%d]:routingTbl:[\n", i);
      for(int i = 0; i < rest_ripentry; ++i){
        resp.entries[i].addr = routingTbl[i].addr; //网络字节序
        resp.entries[i].mask = BE32(~((1<<(32 - routingTbl[i].len)) - 1)); //网络字节序
        resp.entries[i].metric = BE32(routingTbl[i].metric); 
        resp.entries[i].nexthop = 0; // 网络字节序
        // printf("{ addr: %d.%d.%d.%d, mask: %08x, nexthop: %d.%d.%d.%d, metric: %d},\n",
        //   IP_FMT(resp.entries[i].addr), resp.entries[i].mask, IP_FMT(resp.entries[i].nexthop), resp.entries[i].metric);
      }
        // printf("]\n");
        // fflush(stdout);

      // fill IP headers
      struct ip *ip_header = (struct ip *)output;
      ip_header->ip_hl = 5;
      uint32_t totlen = ip_header->ip_hl * 4 + 8 + 4 + resp.numEntries * 20;
      ip_header->ip_v = 4;
      // TODO: set tos = 0, id = 0, off = 0, ttl = 1, p = 17(udp), dst and src DONE
      ip_header->ip_tos = 0;
      ip_header->ip_id = 0;
      ip_header->ip_off = 0;
      ip_header->ip_ttl = 1;
      ip_header->ip_p = 17;
      ip_header->ip_len = BE16((uint16_t)totlen);
      ip_header->ip_dst.s_addr = dst_addr;
      ip_header->ip_src.s_addr = addrs[if_index]; 

      // fill UDP headers
      struct udphdr *udpHeader = (struct udphdr *)&output[ip_header->ip_hl * 4];
      // src port = 520
      udpHeader->uh_sport = htons(520);
      // dst port = 520
      udpHeader->uh_dport = htons(520);

      // assemble RIP
      uint32_t rip_len = assemble(&resp, &output[ip_header->ip_hl * 4 + 8]);
      // TODO: udp length
      udpHeader->uh_ulen = BE16((uint16_t)(rip_len + 8));

      // TODO: checksum calculation for ip and udp
      // if you don't want to calculate udp checksum, set it to zero
      udpHeader->uh_sum = 0; 
    
      uint16_t checksum = calculate_checksum(ip_header);
      ip_header->ip_sum = checksum;

          

          //*************debug*************
          // RawRip* debugrip = (RawRip *)&output[28];
          // printf("send rip packet entries:[\n");
          // for(int i = 0; i < (totlen - 32) / 20; ++i){
          // printf("{ addr: %d.%d.%d.%d, mask: %08x, nexthop: %d.%d.%d.%d, metric: %d},\n",
          //     IP_FMT(debugrip->entries[i].addr), debugrip->entries[i].mask, IP_FMT(debugrip->entries[i].nexthop), debugrip->entries[i].metric);
          // }
          // printf("]\n");
          // fflush(stdout);
          //*******************************

        
          // send it back
      macaddr_t dest_mac;
      if(HAL_ArpGetMacAddress(if_index, dst_addr, dest_mac) == 0){
        HAL_SendIPPacket(if_index, output, totlen, dest_mac);
      }
    }
}


int main(int argc, char *argv[]) 
{
  // TO DELETE
  int res = HAL_Init(1, addrs);
  if (res < 0) 
  {
    return res;
  }
  for (uint32_t i = 0; i < N_IFACE_ON_BOARD; i++) 
  {
    RoutingTableEntry entry = 
    {
        .addr = addrs[i] & 0x00FFFFFF, 
        .len = 24,                     
        .if_index = i,                 
        .nexthop = 0,                  
        .metric = 1               
    };
    // FORMER: update(true, entry);
    insert(entry);
  }

  uint32_t last_time = 0;
  while (1) 
  {
    uint32_t time = HAL_GetTicks();
    if (time > last_time + 5 * 1000) {
      // ref. RFC 2453 Section 3.8
      printf("5s Timer\n");
      // HINT: print complete routing table to stdout/stderr for debugging
      print_table();
      // TODO: send complete routing table to every interface DONE
      for (int i = 0; i < N_IFACE_ON_BOARD; i++) {
        // construct rip response
        // do the mostly same thing as step 3a.3
        // except that dst_ip is RIP multicast IP 224.0.0.9
        // and dst_mac is RIP multicast MAC 01:00:5e:00:00:09
      
        send_all_rip(i, multicastIP, multicastMac);
      }
      last_time = time;
    }

    int mask = (1 << N_IFACE_ON_BOARD) - 1; //15
    macaddr_t src_mac;
    macaddr_t dst_mac;
    int if_index;
    res = HAL_ReceiveIPPacket(mask, packet, sizeof(packet), src_mac, dst_mac,
                              1000, &if_index);
    if (res == HAL_ERR_EOF) {
      break;
    } else if (res < 0) {
      return res;
    } else if (res == 0) {
      // Timeout
      continue;
    } else if (res > sizeof(packet)) {
      // packet is truncated, ignore it
      printf("truncated\n");
      fflush(stdout);
      continue;
    }

    // 1. validate
    if (!validateIPChecksum(packet, res)) {
      printf("Invalid IP Checksum\n");
      // drop if ip checksum invalid
      continue;
    }
    in_addr_t src_addr, dst_addr;
    // TODO: extract src_addr and dst_addr from packet (big endian)  DONE
    ipheader* ip_header = (ipheader *)packet;
    src_addr = ip_header->saddr; //big endian
    dst_addr = ip_header->daddr; //big endian

    // 2. check whether dst is me
    bool dst_is_me = false;
    for (int i = 0; i < N_IFACE_ON_BOARD; i++) {
      if (memcmp(&dst_addr, &addrs[i], sizeof(in_addr_t)) == 0) {
        dst_is_me = true;
        break;
      }
    }
    // TODO: handle rip multicast address(224.0.0.9)  DONE
    if(dst_addr == multicastIP)
      dst_is_me = true; //如果是组播也要进行处理


    if (dst_is_me) {
      // printf("****************\ndst is me\n****************\n");
      // fflush(stdout);
      
      // 3a.1
      RipPacket rip;
      // check and validate
      if (disassemble(packet, res, &rip)) {
        if (rip.command == 1) {
          // printf("****************\nrip request\n****************\n");
          // fflush(stdout);
          // 3a.3 request, ref. RFC 2453 Section 3.9.1
          // only need to respond to whole table requests in the lab

          send_all_rip(if_index, src_addr, src_mac);
        } else {
          // printf("****************\nrip response\n****************\n");
          // fflush(stdout);
          // 3a.2 response, ref. RFC 2453 Section 3.9.2
          // TODO: update routing table
          // new metric = ?
          // update metric, if_index, nexthop
          // HINT: handle nexthop = 0 case
          // HINT: what is missing from RoutingTableEntry?
          // you might want to use `prefix_query` and `update`, but beware of
          // the difference between exact match and longest prefix match.
          // optional: triggered updates ref. RFC 2453 Section 3.10.1
          int rip_entry_cnt = (res - (ip_header->ihl * 4 + 8) - 4) / 20;
          // if(routingTbl.size() > 2300){
          //   printf("routingTbl size = %ld\treceive %d rip entries\n", routingTbl.size(), rip_entry_cnt);
          //   fflush(stdout);
          // }
          // printf("router:%d, rip_entry_cnt:%d\n", router_id, rip_entry_cnt);
          // fflush(stdout);
          for(int i = 0; i < rip_entry_cnt; ++i){
            uint32_t mask = rip.entries[i].mask;
            uint32_t addr = rip.entries[i].addr & mask;
            // if(addr == debugIP){
            //   printf("src IP %d.%d.%d.%d\tdst IP %d.%d.%d.%d\n", IP_FMT(BE32(src_addr)), IP_FMT(BE32(dst_addr)));
            //   printf("get IP %d.%d.%d.%d\n", IP_FMT(BE32(debugIP)));
            //   fflush(stdout);
            // }
            uint32_t metric = std::min(16u, BE32(rip.entries[i].metric) + 1);
            // printf("metric[%d]:%d\n", i, metric);
            //这时要精确匹配查找一个路由表项使得addr和mask完全相同，更新路由表
            bool largetthan200 = (addr & 0xff) > 200 ? true : false;
            bool found = false;
            for(auto iter = routingTbl.begin(); iter != routingTbl.end(); ++iter){
              // printf("**********debug*********\n");
              // printf("iter->addr:%d.%d.%d.%d\taddr:%d.%d.%d.%d\n", IP_FMT(iter->addr), IP_FMT(addr));
              // printf("iter->mask:%d.%d.%d.%d\tmask:%d.%d.%d.%d\n", IP_FMT((~((1<<(32 - iter->len)) - 1))), IP_FMT(BE32(mask)));
              // printf("************************\n");
              if(iter->addr == addr && BE32(mask)==(~((1<<(32 - iter->len)) - 1))){
                found = true;
                // if(largetthan200) printf("found. addr=%d.%d.%d.%d, decide = %d\n", IP_FMT(BE32(addr)), addr&0xff);
                // fflush(stdout);
                if(iter->nexthop == src_addr){
                  if((iter->metric = metric) == 16u){
                    std::swap(*iter, routingTbl.back());
                    routingTbl.pop_back();
                  }
                }
                else if(iter->metric > metric){
                  iter->nexthop = src_addr;
                  iter->if_index = if_index;
                  iter->metric = metric;
                }
                break;
              }
            }
            
            if(!found){
              // if(largetthan200) printf("not found. addr=%d.%d.%d.%d\n", IP_FMT(BE32(addr)));
              // fflush(stdout);
              routingTbl.push_back(RoutingTableEntry{addr, CNT1(BE32(mask)), if_index, src_addr, metric});
            }
          }
        }
      } 
      else {
        // not a rip packet
        // handle icmp echo request packet
        // TODO: how to determine?
        // printf("****************\nnot a rip packet\n****************\n");
        icmphdr* icmpRecv = (struct icmphdr *)&packet[20];
        // printf("see as icmp packet, type:%d\tcode:%d\n", icmpRecv->type, icmpRecv->code);
        // fflush(stdout);
        if (ip_header->protocol == 1 && icmpRecv->type == 8) { //request
          // printf("****************\nicmp echo request\n****************\n");
          // fflush(stdout);
          // construct icmp echo reply
          // reply is mostly the same as request,
          // you need to:
          // 1. swap src ip addr and dst ip addr
          // 2. change icmp `type` in header
          // 3. set ttl to 64
          // 4. re-calculate icmp checksum and ip checksum
          // 5. send icmp packet
          memcpy(output, packet, res);
          struct ip *ip = (struct ip *)output;
          std::swap(ip->ip_src, ip->ip_dst);
          struct icmphdr *icmpHeader = (struct icmphdr *)&output[20];
          icmpHeader->type = 0;
          ip->ip_ttl = 64;
          //recalculate icmp checksum
          icmpHeader->checksum = 0;
          icmpHeader->checksum = get_checksum((uint16_t *)icmpHeader, res - ip->ip_hl * 4);
          //recalculate ip checksum
          ip->ip_sum = calculate_checksum(ip);

          //send packet
          HAL_SendIPPacket(if_index, output, res, src_mac);
        }
      }
    } 
    else {
      // 3b.1 dst is not me
      // check ttl
      // printf("****************\ndst is not me\n****************\n");
      uint8_t ttl = packet[8];\
      uint8_t ip_hl = ip_header->ihl;
      // printf("****************\nttl: %d\n****************\n", ttl);
      // fflush(stdout);
      if (ttl <= 1) {
        // send icmp time to live exceeded to src addr
        // fill IP header
        // printf("****************\nttl timeout, send back icmp packet\n****************\n");
        // fflush(stdout);

        struct ip *ip_header = (struct ip *)output;
        ip_header->ip_hl = 5;
        ip_header->ip_v = 4;
        // TODO: set tos = 0, id = 0, off = 0, ttl = 64, p = 1(icmp), src and dst
        ip_header->ip_tos = 0;
        ip_header->ip_id = 0;
        ip_header->ip_off = 0;
        ip_header->ip_ttl = 64;
        ip_header->ip_p = 1;
        ip_header->ip_src.s_addr = addrs[if_index];
        ip_header->ip_dst.s_addr = src_addr;

        // fill icmp header
        struct icmphdr *icmp_header = (struct icmphdr *)&output[ip_hl * 4];
        // icmp type = Time Exceeded
        icmp_header->type = ICMP_TIME_EXCEEDED;
        // TODO: icmp code = 0
        icmp_header->code = 0;
        // TODO: fill unused fields with zero
        icmp_header->checksum = 0;
        icmp_header->un.gateway = 0;
        // TODO: append "ip header and first 8 bytes of the original payload"
        memcpy(&output[4 * ip_hl + sizeof(struct icmphdr)], packet, 28); //assume ip header length is 20 bytes
        int totlen = 4 * ip_hl+ sizeof(struct icmphdr) + 28;
        ip_header->ip_len = BE16(totlen);
        // TODO: calculate icmp checksum and ip checksum
        icmp_header->checksum = get_checksum((uint16_t *)icmp_header, totlen - 4 * ip_hl);
        ip_header->ip_sum = calculate_checksum(ip_header);
        // TODO: send icmp packet

        HAL_SendIPPacket(if_index, output, totlen, src_mac);
      } else {
        // forward
        // beware of endianness
        // printf("****************\nicmp foward, query next hop\n****************\n");
        // fflush(stdout);
        uint32_t nexthop, dest_if;
        if (prefix_query(dst_addr, &nexthop, &dest_if)) {
          // found
          macaddr_t dest_mac;
          // direct routing
          if (nexthop == 0) {
            nexthop = dst_addr;
          }
          if (HAL_ArpGetMacAddress(dest_if, nexthop, dest_mac) == 0) {
            // found
            memcpy(output, packet, res);
            // update ttl and checksum
            forward(output, res);
            HAL_SendIPPacket(dest_if, output, res, dest_mac);
          } else {
            // not found
            // you can drop it
            printf("ARP not found for nexthop %x\n", nexthop);
          }
        } else {
          // not found
          // send ICMP Destination Network Unreachable
          printf("IP not found in routing table for src %x dst %x\n", src_addr, dst_addr);
          // send icmp destination net unreachable to src addr
          // fill IP header
          struct ip *ip_header = (struct ip *)output;
          ip_header->ip_hl = 5;
          ip_header->ip_v = 4;
          // TODO: set tos = 0, id = 0, off = 0, ttl = 64, p = 1(icmp), src and dst
          ip_header->ip_tos = 0;
          ip_header->ip_id = 0;
          ip_header->ip_off = 0;
          ip_header->ip_ttl = 64;
          ip_header->ip_p = 1;
          ip_header->ip_src.s_addr = addrs[if_index];
          ip_header->ip_dst.s_addr = src_addr;

          // fill icmp header
          struct icmphdr *icmp_header = (struct icmphdr *)&output[ip_hl* 4];
          // icmp type = Destination Unreachable
          icmp_header->type = ICMP_DEST_UNREACH;
          // TODO: icmp code = Destination Network Unreachable
          icmp_header->code = ICMP_NET_UNREACH;
          // TODO: fill unused fields with zero
          icmp_header->checksum = 0;
          icmp_header->un.gateway = 0;
          // TODO: append "ip header and first 8 bytes of the original payload"
          memcpy(&output[4 * ip_hl + sizeof(struct icmphdr)], packet, 28); //assume ip header length is 20 bytes
          int totlen = 4 * ip_hl + sizeof(struct icmphdr) + 28;
          ip_header->ip_len = BE16(totlen);
          // TODO: calculate icmp checksum and ip checksum
          icmp_header->checksum = get_checksum((uint16_t *)icmp_header, totlen - 4 * ip_hl);
          ip_header->ip_sum = calculate_checksum(ip_header);
          // TODO: send icmp packet
          HAL_SendIPPacket(if_index, output, totlen, src_mac);
        }
      }
    }
  }
  return 0;
}
