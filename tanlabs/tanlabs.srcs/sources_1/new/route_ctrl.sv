`default_nettype none
`include "frame_datapath.vh"
module route_ctrl(
    input wire clk,
    input wire rst,
    input wire[31:0] ram_data_cpu,
    output reg[31:0] ram_data_ram,
    input wire[31:0] ram_addr_i,
    input wire[3:0] ram_be_i,
    input wire ram_we_i,
    input wire ram_oe_i,
    input wire ram_req,
    output wire ram_ready,
    output reg [32:0] trie_web,
    output reg nexthop_web,
    output reg [TRIE_ADDR_WIDTH-1:0] node_addr_b[32:0],
    output trie_node_t node_dinb[32:0],
    input trie_node_t node_doutb[32:0],
    output reg [NEXTHOP_ADDR_WIDTH-1:0] nexthop_addr_b,
    output nexthop_t nexthop_dinb,
    input nexthop_t nexthop_doutb
);
    // Trie BRAM Address
    // | 0x20000000-0x2000FFFF | layer 0|
    // | 0x20010000-0x2001FFFF | layer 1|
    // | 0x20020000-0x2002FFFF | layer 2|
    // | 0x20030000-0x2003FFFF | layer 3|
    // | 0x20040000-0x2004FFFF | layer 4|
    // | 0x20050000-0x2005FFFF | layer 5|
    // | 0x20060000-0x2006FFFF | layer 6|
    // | 0x20070000-0x2007FFFF | layer 7|
    // | 0x20080000-0x2008FFFF | layer 8|    
    // | 0x20090000-0x2009FFFF | layer 9|
    // | 0x200A0000-0x200AFFFF | layer A|
    // | 0x200B0000-0x200BFFFF | layer B|
    // | 0x200C0000-0x200CFFFF | layer C|    
    // | 0x200D0000-0x200DFFFF | layer D|
    // | 0x200E0000-0x200EFFFF | layer E|
    // | 0x200F0000-0x200FFFFF | layer F|
    // | 0x20100000-0x2010FFFF | layer 10|
    // | 0x20110000-0x2011FFFF | layer 11|
    // | 0x20120000-0x2012FFFF | layer 12|
    // | 0x20130000-0x2013FFFF | layer 13|
    // | 0x20140000-0x2014FFFF | layer 14|
    // | 0x20150000-0x2015FFFF | layer 15|
    // | 0x20160000-0x2016FFFF | layer 16|
    // | 0x20170000-0x2017FFFF | layer 17|
    // | 0x20180000-0x2018FFFF | layer 18|    
    // | 0x20190000-0x2019FFFF | layer 19|
    // | 0x201A0000-0x201AFFFF | layer 1A|
    // | 0x201B0000-0x201BFFFF | layer 1B|
    // | 0x201C0000-0x201CFFFF | layer 1C|    
    // | 0x201D0000-0x201DFFFF | layer 1D|
    // | 0x201E0000-0x201EFFFF | layer 1E|
    // | 0x201F0000-0x201FFFFF | layer 1F|
    // | 0x20200000-0x2020FFFF | layer 20|
    localparam TRIE_ADDR_START = 32'h20000000;
    localparam TRIE_ADDR_END = 32'h2020FFFF;
    wire trie_ram_req = ram_req && (ram_addr_i >= TRIE_ADDR_START) && (ram_addr_i <= TRIE_ADDR_END);
    wire[7:0] trie_layer_req = ram_addr_i[23:16];
    trie_node_t trie_ram_data;
    reg [TRIE_ADDR_WIDTH-1:0]

endmodule