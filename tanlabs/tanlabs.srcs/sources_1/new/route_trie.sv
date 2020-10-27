`timescale 1ns/1ps

localparam TRIE_ADDR_WIDTH    = 13;
localparam NEXTHOP_ADDR_WIDTH = 8;

typedef struct packed
{
logic [2:0] port;
logic [31:0] ip;
} nexthop_t;


module route_trie (input wire clka,
                   input wire clkb,
                   input wire rst,
                   input wire i_ready,
                   input wire [31:0] i_ip,
                   output nexthop_t o_nexthop,
                   output wire o_valid,
                   output wire o_ready,
                   output wire [32:0] layer_o_ready_o);
    wire[TRIE_ADDR_WIDTH-1:0] next_node_addr[32:0];
    wire[NEXTHOP_ADDR_WIDTH-1:0] nexthop_addr[32:0];
    wire[32:0] layer_o_valid;
    wire[32:0] layer_o_ready;
    wire[32:0] ip_t[31:0];
    
    trie_layer trie_root (
    .clka,
    .clkb,
    .rst,
    .ip_bit(i_ip[0]),
    .i_ip(i_ip),
    .i_ready,
    .current_node_addr(1),
    .next_node_addr(next_node_addr[0]),
    .nexthop_addr(nexthop_addr[0]),
    .o_ip(ip_t[0]),
    .o_valid(layer_o_valid[0]),
    .o_ready(layer_o_ready[0])
    );
    
    genvar i;
    generate;
    for (i = 1; i <= 32; i = i+1) begin
        trie_layer trie_layerx (
        .clka,
        .clkb,
        .rst,
        .ip_bit(ip_t[i-1][i]),
        .i_ip(ip_t[i-1]),
        .i_ready(layer_o_ready[i-1]),
        .current_node_addr(next_node_addr[i-1]),
        .next_node_addr(next_node_addr[i]),
        .nexthop_addr(nexthop_addr[i]),
        .o_ip(ip_t[i]),
        .o_valid(layer_o_valid[i]),
        .o_ready(layer_o_ready[i])
        );
    end
    endgenerate
    
    
    assign o_valid = layer_o_valid[32];
    assign o_ready = layer_o_ready[32];
    
    reg ena, wea;
    always_comb begin
        ena = 1; // currently we only use hardware side interface.
        wea = 0; // hardware manipulation is read-only.
    end
    blk_mem_gen_1 nexthop_bram(
    .clka,    // input wire clka
    .ena,      // input wire ena
    .wea,      // input wire [0 : 0] wea
    .addra(nexthop_addr[32]),  // input wire [7 : 0] addra
    // .dina(dina),    // input wire [34 : 0] dina
    .douta(o_nexthop)  //, output wire [34 : 0] douta
    // .clkb(clkb),    // input wire clkb
    // .enb(enb),      // input wire enb
    // .web(web),      // input wire [0 : 0] web
    // .addrb(addrb),  // input wire [7 : 0] addrb
    // .dinb(dinb),    // input wire [34 : 0] dinb
    // .doutb(doutb)  // output wire [34 : 0] doutb
    );
endmodule
