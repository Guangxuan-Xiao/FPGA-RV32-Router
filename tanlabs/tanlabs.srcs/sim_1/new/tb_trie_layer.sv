`timescale 1ns / 1ps

module tb_trie_layer ();
    reg rst;
    reg [31:0] ip;
    reg[12:0] nexthop_addr;
    reg i_ready;
    wire o_valid;
    wire o_ready;
    wire[31:0] o_ip;
    reg[12:0] current_node_addr;
    reg[12:0] next_node_addr;
    reg[7:0] i_nexthop_addr;
    
    initial begin
        rst               = 1;
        current_node_addr = 9;
        i_nexthop_addr    = 0;
        #5
        rst = 0;
    end
    
    wire clk_125M;
    
    clock clock_i(
    .clk_125M(clk_125M)
    );
    
    
    trie_layer #() trie_layer_module(
    .clka(clk_125M),
    .rst(rst),
    .ip_bit(ip[7]),
    .i_ip(ip),
    .i_ready,
    .i_valid(0),
    .current_node_addr,
    .i_nexthop_addr,
    .next_node_addr,
    .o_nexthop_addr(nexthop_addr),
    .o_ip,
    .o_valid(o_valid),
    .o_ready(o_ready)
    );
    
    initial begin
        #20
        ip = 32'h0000aaaa;
        #20
        ip = 32'habcdabcd;
    end
endmodule
