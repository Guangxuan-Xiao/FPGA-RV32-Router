#include "rip.h"
#include "router.h"
#include "timer.h"
#include "lookup.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <netinet/udp.h>
#define N_IFACE_ON_BOARD 4

#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#define BE16(x) __builtin_bswap16(x)
#define BE32(x) __builtin_bswap32(x)
#else
#define BE16(x) x
#define BE32(x) x
#endif

#define CNT1(x) __builtin_popcount(x)

RoutingTableEntry cache[8200];

uint8_t packet[2048];
uint8_t output[2048];
uint32_t bram_addr_dst = 0;
typedef uint8_t macaddr_t[6];

struct ipheader
{
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
struct RawRip
{
	uint8_t command; // 1(request) or 2(reponse)
	uint8_t version; // 2
	uint16_t zero;
	struct Entry
	{
		uint16_t family; // 0(request) or 2(response)
		uint16_t tag;	 // 0
		uint32_t addr;
		uint32_t mask; // todo
		uint32_t nexthop;
		uint32_t metric; // [1, 16]
	} entries[0];
};
// #define ROUTER_R2
#ifdef ROUTER_R0
const in_addr_t addrs[N_IFACE_ON_BOARD] = {0x0202ff0a, 0x0100ff0a, 0x0102000a, 0x0103000a};
const uint32_t lens[N_IFACE_ON_BOARD] = {30, 30, 24, 24};
const int router_id = 0;
#elif defined(ROUTER_R1)
const in_addr_t addrs[N_IFACE_ON_BOARD] = {0x0200ff0a, 0x0101ff0a, 0x0102010a, 0x0103010a};
const uint32_t lens[N_IFACE_ON_BOARD] = {30, 30, 24, 24};
const int router_id = 1;
#elif defined(ROUTER_R2)
const in_addr_t addrs[N_IFACE_ON_BOARD] = {0x0201ff0a, 0x0102ff0a, 0x0102020a, 0x0103020a};
const uint32_t lens[N_IFACE_ON_BOARD] = {30, 30, 24, 24};
const int router_id = 2;
#elif defined(ROUTER_R3)
const in_addr_t addrs[N_IFACE_ON_BOARD] = {0x0204a8c0, 0x0205a8c0, 0x010aa8c0,
										   0x010ba8c0};
const uint32_t lens[N_IFACE_ON_BOARD] = {30, 30, 24, 24};
const int router_id = 3;
#else
const in_addr_t addrs[N_IFACE_ON_BOARD] = {0x0100000a, 0x0101000a, 0x0102000a, 0x0103000a};
const uint32_t lens[N_IFACE_ON_BOARD] = {24, 24, 24, 24};
const int router_id = 4;
#endif
const in_addr_t multicastIP = 0x090000e0;
const macaddr_t multicastMac = {0x01, 0x00, 0x5e, 0x00, 0x00, 0x09};
const in_addr_t debugIP = 0x0000010a;

uint16_t calculate_checksum(ip *ip_header)
{
	uint16_t old = ip_header->ip_sum;
	ip_header->ip_sum = 0;
	uint32_t len = (ip_header->ip_hl) * 2;
	uint32_t sum = 0;
	uint16_t *cur = (uint16_t *)ip_header;
	for (uint32_t i = 0; i < len; ++i)
	{
		sum += *(cur++);
	}
	ip_header->ip_sum = old;
	sum = (sum & 0xffff) + (sum >> 16);
	sum = (sum & 0xffff) + (sum >> 16);
	return (uint16_t)~sum;
}

#define IP_FMT(x) x >> 24, x >> 16 & 0xFF, x >> 8 & 0xFF, x & 0xFF

uint16_t get_checksum(uint16_t *hdr, const size_t bytes)
{
	uint32_t sum = 0;
	uint16_t *cur = (uint16_t *)hdr;
	for (uint32_t i = 0; i < bytes / 2; ++i)
	{
		sum += *(cur++);
	}
	sum = (sum & 0xffff) + (sum >> 16);
	sum = (sum & 0xffff) + (sum >> 16);
	return (uint16_t)~sum;
}

void send_rip(const RipPacket &resp, const uint32_t if_index, const uint32_t dst_addr, const macaddr_t dst_mac)
{
	struct ip *ip_header = (struct ip *)output;
	ip_header->ip_hl = 5;
	uint32_t totlen = ip_header->ip_hl * 4 + 8 + 4 + resp.numEntries * 20;
	ip_header->ip_v = 4;
	ip_header->ip_tos = 0;
	ip_header->ip_id = 0;
	ip_header->ip_off = 0;
	ip_header->ip_ttl = 1;
	ip_header->ip_p = 17;
	ip_header->ip_len = BE16((uint16_t)totlen);
	ip_header->ip_dst.s_addr = dst_addr;
	ip_header->ip_src.s_addr = addrs[if_index];
	struct udphdr *udpHeader = (struct udphdr *)&output[ip_header->ip_hl * 4];
	udpHeader->uh_sport = htons(520);
	udpHeader->uh_dport = htons(520);
	uint32_t rip_len = assemble(&resp, &output[ip_header->ip_hl * 4 + 8]);
	udpHeader->uh_ulen = BE16((uint16_t)(rip_len + 8));
	udpHeader->uh_sum = 0;
	uint16_t checksum = calculate_checksum(ip_header);
	ip_header->ip_sum = checksum;
	//printf("before send\r\n");
	send(if_index, output, totlen, bram_addr_dst, dst_mac);
	sleep(200);
	//printf("end send\r\n");
	bram_addr_dst = (bram_addr_dst + 1) & 0x1F;
}

void send_all_rip(uint32_t router_len, int if_index, const uint32_t dst_addr, const macaddr_t dst_mac)
{
	uint32_t rest_ripentry = router_len;
	while (rest_ripentry > 25)
	{
		int start = rest_ripentry - 25;
		RipPacket resp;
		resp.command = 2;
		resp.numEntries = 25;
		for (uint32_t i = start; i < rest_ripentry; ++i)
		{
			resp.entries[i - start].addr = cache[i].ip;									   //网络字节序
			resp.entries[i - start].mask = BE32(~((1 << (32 - cache[i].prefix_len)) - 1)); //网络字节序
			resp.entries[i - start].metric = BE32(cache[i].metric);
			resp.entries[i - start].nexthop = 0; // 网络字节序
		}
		send_rip(resp, if_index, dst_addr, dst_mac);
		rest_ripentry -= 25;
	}
	if (rest_ripentry > 0)
	{
		RipPacket resp;
		resp.command = 2;
		resp.numEntries = rest_ripentry;
		for (uint32_t i = 0; i < rest_ripentry; ++i)
		{
			resp.entries[i].addr = cache[i].ip;									   //网络字节序
			resp.entries[i].mask = BE32(~((1 << (32 - cache[i].prefix_len)) - 1)); //网络字节序
			resp.entries[i].metric = BE32(cache[i].metric);
			resp.entries[i].nexthop = 0; // 网络字节序
		}
		send_rip(resp, if_index, dst_addr, dst_mac);
	}
}

int mainLoop()
{
	for (uint32_t i = 0; i < N_IFACE_ON_BOARD; i++)
	{
		uint32_t mask = BE32(~((1 << (32 - lens[i])) - 1));
		RoutingTableEntry entry =
			{
				.ip = addrs[i] & mask,
				.prefix_len = lens[i],
				.port = i,
				.nexthop_ip = 0,
				.metric = 1};
		insert(entry);
	}
	set_ip(addrs[0], addrs[1], addrs[2], addrs[3]);
	set_mac_prefix(0xaabbccdd);
	uint32_t last_time = get_clock();
	uint32_t sec = 0;
	while (1)
	{
		uint32_t time = get_clock();
		if ((time > CLOCK_PER_SEC && time - CLOCK_PER_SEC > last_time) || (time <= CLOCK_PER_SEC && time > last_time + CLOCK_PER_SEC))
		{
			sec++;
			last_time = time;
		}
		if (sec >= 5)
		{
			printf("5s Timer at time %u\r\n", time);
			uint32_t router_len = traverse(cache);
			printf("\r\n===Lookup Table===\r\n");
			printf("Routing Table Size: %u\r\n", router_len);
			for (uint32_t i = 0; i < router_len; ++i)
				cache[i].print();
			printf("==================\r\n");
			printf("\r\n");
			for (uint32_t i = 0; i < N_IFACE_ON_BOARD; ++i)
				send_all_rip(router_len, i, multicastIP, multicastMac);
			sec = 0;
		}
		macaddr_t src_mac;
		macaddr_t dst_mac;
		uint32_t if_index;
		// TODO: Waiting for receive function.

		uint32_t res = receive(packet, src_mac, dst_mac, &if_index);

		if (res <= 0)
		{
			//printf("Receive invalid.\r\n");
			continue;
		}
		else if (res >= sizeof(packet))
		{
			// printf("truncated!\r\n");
			continue;
		}

		in_addr_t src_addr, dst_addr;
		ipheader *ip_header = (ipheader *)packet;
		src_addr = ip_header->saddr;
		dst_addr = ip_header->daddr;

		bool dst_is_me = false;
		for (int i = 0; i < N_IFACE_ON_BOARD; i++)
		{
			if (memcmp(&dst_addr, &addrs[i], sizeof(in_addr_t)) == 0)
			{
				dst_is_me = true;
				break;
			}
		}
		if (dst_addr == multicastIP)
			dst_is_me = true;
		if (dst_is_me)
		{
			//printf("dst is me.\r\n");
			RipPacket rip;
			if (disassemble(packet, res, &rip))
			{
				//printf("Rip disassemble successful\r\n");
				// printf("===Lookup Table===\r\n");
				// RoutingTableEntry buffer[20];
				// uint32_t len = 0;
				// traverse(buffer, &len);
				// printf("Routing Table Size: %u\r\n", len);
				// for (uint32_t i = 0; i < len; ++i)
				//   buffer[i].print();
				// printf("==================\r\n");
				// printf("\r\n");
				if (rip.command == 1)
				{
					uint32_t router_len = traverse(cache);
					send_all_rip(router_len, if_index, src_addr, src_mac);
				}
				else
				{
					int rip_entry_cnt = (res - (ip_header->ihl * 4 + 8) - 4) / 20;
					printf("RIP ENTRY COUNT = %d\r\n", rip_entry_cnt);
					for (int i = 0; i < rip_entry_cnt; i++)
					{
						printf("Dealing with RIP ENTRY[%d]\r\n", i);
						uint32_t nexthop;
						uint32_t port;
						uint32_t metric;
						uint32_t addr = rip.entries[i].addr;
						uint32_t mask = rip.entries[i].mask;
						uint32_t old_metric = rip.entries[i].metric;
						uint32_t addr_masked = addr & mask;
						uint32_t preLen = CNT1(BE32(mask));
						bool is_search = search(addr, preLen, &nexthop, &port, &metric);
						uint32_t new_metric = (BE32(old_metric) + 1 <= 16) ? BE32(old_metric) + 1 : 16;
						RoutingTableEntry rte =
							{
								.ip = addr_masked,
								.prefix_len = preLen,
								.port = if_index,
								.nexthop_ip = src_addr,
								.metric = new_metric};
						rte.print();
						if (is_search)
						{
							if (nexthop == src_addr)
							{
								if (new_metric == 16u)
								{
									remove(addr_masked, preLen);
								}
							}
							else if (new_metric < metric)
							{
								RoutingTableEntry rte =
									{
										.ip = addr_masked,
										.prefix_len = preLen,
										.port = if_index,
										.nexthop_ip = src_addr,
										.metric = new_metric};
								insert(rte);
								printf("Inserting routing table entry\r\n");
							}
						}
						else
						{
							RoutingTableEntry rte =
								{
									.ip = addr_masked,
									.prefix_len = preLen,
									.port = if_index,
									.nexthop_ip = src_addr,
									.metric = new_metric};
							insert(rte);
							printf("Inserting routing table entry\r\n");
						}
					}
				}
			}
			else
			{
				// printf("Not a RIP packet.\r\n");
			}
		}
		else
		{
			// printf("This is not my RIP packet.\r\n");
		}
	}
	return 0;
}
