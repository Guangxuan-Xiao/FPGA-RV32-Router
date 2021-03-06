`ifndef FRAME_DATAPATH_VH
`define FRAME_DATAPATH_VH

localparam DATA_WIDTH = 64;
localparam ID_WIDTH = 3;

// 'w' means wide.
localparam DATAW_WIDTH        = 8 * 48;
localparam CACHE_ADDR_WIDTH   = 4;
// README: Your code here.

typedef struct packed
{
// AXI-Stream signals.
logic [DATAW_WIDTH - 1:0] data;
logic [DATAW_WIDTH / 8 - 1:0] keep;
logic last;
logic [DATAW_WIDTH / 8 - 1:0] user;
logic [ID_WIDTH - 1:0] id;  // ingress interface
logic valid;

// Control signals.
logic is_first;  // Is this the first beat of a frame?

// Other control signals.
// **They are only effective at the first beat.**
logic [ID_WIDTH - 1:0] dest;  // egress interface
logic drop;  // Drop this frame?
logic dont_touch;  // Do not touch this beat!

// Drop the next frame? It is useful when you need to shrink a frame
// (e.g., replace an IPv4 packet to an ARP request).
// You can do so by setting both last and drop_next.
logic drop_next;

//Type
logic [2:0] prot_type;
logic to_cpu;
logic [31:0] my_ip;
logic [47:0] my_mac;
//logic [DATAW_WIDTH - 1:0] store_data;

// README: Your code here.
} frame_data;

// README: Your code here. You can define some other constants like EtherType.
`define MAC_DST (0 * 8) +: 48
`define MAC_SRC (6 * 8) +: 48
`define MAC_TYPE (12 * 8) +: 16
`define IP4_TTL ((14 + 8) * 8) +: 8
`define HARD_TYPE (14 * 8) +: 16
`define PROT_TYPE (16 * 8) +: 16
`define HARD_LEN (18 * 8) +: 8
`define PROT_LEN (19 * 8) +: 8
`define SRC_MAC_ADDR (22 * 8) +: 48
`define TRG_MAC_ADDR (32 * 8) +: 48
`define SRC_IP_ADDR (28 * 8) +: 32
`define TRG_IP_ADDR (38 * 8) +: 32
`define FINAL (42 * 8) +: 48
`define OP (20 * 8) +: 16

`define TRG_IP_IP (30 * 8) +: 32
`define TTL_POS (22 * 8) +: 8

`define LTP_OP (14 * 8) +: 8
`define LTP_PORT (15 * 8) +: 8
`define LTP_MASK (16 * 8) +: 32
`define LTP_SRC_IP (20 * 8) +: 32
`define LTP_TRG_IP (24 * 8) +: 32

`define BUFFER_WIDTH 5
`define BUFFER_SPARE 2
`define BUFFER_ADDR_WIDTH 16

localparam ID_CPU = 3'd4;  // The interface ID of CPU is 4.

localparam ETHERTYPE_IP4 = 16'h0008;
localparam ETHERTYPE_ARP = 16'h0608;
localparam ETHERTYPE_LTP = 16'h1509;

localparam REQUEST = 16'h0100;
localparam REPLY   = 16'h0200;

localparam MAC0 = 48'h10aaaaaaaa80;
localparam IP0  = 32'h00aaaaaa;

localparam MAC1 = 48'h10bbbbbbbb80;
localparam IP1  = 32'h00bbbbbb;

localparam MAC2 = 48'h10cccccccc80;
localparam IP2  = 32'h00cccccc;

localparam MAC3 = 48'h10dddddddd80;
localparam IP3  = 32'h00dddddd;

localparam TBD  = 48'hffffffffffff;
localparam HARD = 16'h0100;
localparam PROT = 16'h0008;

localparam HARD_L = 8'h06;
localparam PROT_L = 8'h04;

// Incrementally update the checksum in an IPv4 header
// when TTL is decreased by 1.
// Note: This *function* should be a combinational logic.
// Input: old checksum
// Output: new checksum
function [15:0] ip4_update_checksum;
    input [15:0] sum;
    begin
        // README: Your code here.
        ip4_update_checksum = 0;
    end
endfunction

localparam TRIE_ADDR_WIDTH    = 13;
localparam NEXTHOP_ADDR_WIDTH = 6;

typedef struct packed
{
logic [7:0] port;
logic [31:0] ip;
} nexthop_t;

typedef struct packed
{
logic[TRIE_ADDR_WIDTH-1:0] lc_addr;
logic[TRIE_ADDR_WIDTH-1:0] rc_addr;
logic[NEXTHOP_ADDR_WIDTH-1:0] nexthop_addr;
} trie_node_t;
`endif