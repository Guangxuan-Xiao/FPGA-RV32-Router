`timescale 1ns/1ps
`include "frame_datapath.vh"
module route_trie (input wire clka,
                   input wire clkb,
                   input wire rst,
                   input wire i_ready,
                   input wire [31:0] i_ip,
                   output nexthop_t o_nexthop,
                   output reg o_valid,
                   output reg o_ready,
                   input wire[3:0] trie_web[32:0],
                   input wire[4:0] nexthop_web,
                   input wire[TRIE_ADDR_WIDTH-1:0] node_addr_b[32:0],
                   input trie_node_t node_dinb[32:0],
                   output trie_node_t node_doutb[32:0],
                   input wire[NEXTHOP_ADDR_WIDTH-1:0] nexthop_addr_b,
                   input nexthop_t nexthop_dinb,
                   output nexthop_t nexthop_doutb
                   );
    reg [TRIE_ADDR_WIDTH-1:0] next_node_addr[32:0];
    reg [NEXTHOP_ADDR_WIDTH-1:0] nexthop_addr[32:0];
    reg [32:0] layer_o_valid;
    reg [32:0] layer_o_ready;
    reg [31:0] ip_t[32:0];
    
    trie_layer trie_root (
    .clka,
    .clkb,
    .rst,
    .ip_bit(i_ip[7]),
    .i_ip({i_ip[7:0], i_ip[15:8], i_ip[23:16], i_ip[31:25]}),
    .i_ready,
    .i_valid(0),
    .current_node_addr_a(1),
    .i_nexthop_addr(0),
    .next_node_addr(next_node_addr[0]),
    .o_nexthop_addr(nexthop_addr[0]),
    .o_ip(ip_t[0]),
    .o_valid(layer_o_valid[0]),
    .o_ready(layer_o_ready[0]),
    .web(trie_web[0]),
    .node_addr_b(node_addr_b[0]),
    .node_dinb(node_dinb[0]),
    .node_doutb(node_doutb[0])
    );
    
    genvar i;
    generate;
    for (i = 1; i < 33; i = i+1) begin
        trie_layer trie_layerx (
        .clka,
        .clkb,
        .rst,
        .ip_bit(ip_t[i-1][32-i]),
        .i_ip(ip_t[i-1]),
        .i_ready(layer_o_ready[i-1]),
        .i_valid(layer_o_valid[i-1]),
        .current_node_addr_a(next_node_addr[i-1]),
        .i_nexthop_addr(nexthop_addr[i-1]),
        .next_node_addr(next_node_addr[i]),
        .o_nexthop_addr(nexthop_addr[i]),
        .o_ip(ip_t[i]),
        .o_valid(layer_o_valid[i]),
        .o_ready(layer_o_ready[i]),
        .web(trie_web[i]),
        .node_addr_b(node_addr_b[i]),
        .node_dinb(node_dinb[i]),
        .node_doutb(node_doutb[i])
        );
    end
    endgenerate
    
    always_ff @(posedge clka, posedge rst) begin
        if (rst) begin
            o_valid <= 0;
            o_ready <= 0;
        end
        else begin
            o_valid <= layer_o_valid[32];
            o_ready <= layer_o_ready[32];
        end
    end
    
    blk_mem_gen_1 nexthop_bram(
    .clka,    // input wire clka
    .ena(1),      // input wire ena
    .wea(0),      // input wire [4 : 0] wea
    .addra(nexthop_addr[32]),  // input wire [5 : 0] addra
    // .dina(dina),    // input wire [39 : 0] dina
    .douta(o_nexthop),  //, output wire [39 : 0] douta
    .clkb(clkb),    // input wire clkb
    .enb(1),      // input wire enb
    .web(nexthop_web),      // input wire [4 : 0] web
    .addrb(nexthop_addr_b),  // input wire [5 : 0] addrb
    .dinb(nexthop_dinb),    // input wire [39 : 0] dinb
    .doutb(nexthop_doutb)  // output wire [39 : 0] doutb
    );
endmodule
