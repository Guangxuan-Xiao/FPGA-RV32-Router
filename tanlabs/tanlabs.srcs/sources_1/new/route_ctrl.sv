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
    output reg[3:0] trie_web[32:0],
    output reg [4:0] nexthop_web,
    output reg [TRIE_ADDR_WIDTH-1:0] node_addr_b[32:0],
    output trie_node_t node_dinb[32:0],
    input trie_node_t node_doutb[32:0],
    output reg [NEXTHOP_ADDR_WIDTH-1:0] nexthop_addr_b,
    output nexthop_t nexthop_dinb,
    input nexthop_t nexthop_doutb
);
    // Trie BRAM Address
    // | 0x20000000-0x20007FFF | layer 0 |
    // | 0x20008000-0x2000FFFF | layer 1 |
    // | 0x20010000-0x20017FFF | layer 2 |
    // | 0x20018000-0x2001FFFF | layer 3 |
    // ...
    // | 0x20100000-0x20107FFF | layer 32 |
    localparam TRIE_ADDR_START = 32'h20000000;
    localparam TRIE_ADDR_END = 32'h2020FFFF;
    wire trie_ram_req = ram_req && (ram_addr_i >= TRIE_ADDR_START) && (ram_addr_i <= TRIE_ADDR_END);
    wire[5:0] trie_layer_req = ram_addr_i[TRIE_ADDR_WIDTH+7:TRIE_ADDR_WIDTH+2];
    trie_node_t trie_ram_data;
    wire [TRIE_ADDR_WIDTH-1:0] trie_ram_phy_addr = ram_addr_i[TRIE_ADDR_WIDTH+1:2];
    always_comb begin
        
    end
endmodule