`timescale 1ns / 1ps
module tb_route_trie ();
    reg rst;
    reg i_ready;
    initial begin
        rst     = 1;
        i_ready = 0;
        #5
        rst     = 0;
        i_ready = 0;
    end
    
    wire clk_125M;
    
    clock clock_i(
    .clk_125M(clk_125M)
    );
    
    reg [31:0] ip;

    nexthop_t nexthop;
    wire o_valid;
    wire o_ready;
    
    route_trie #() route_trie_module(
    .clka(clk_125M),
    .rst(rst),
    .i_ready(i_ready),
    .i_ip(ip),
    .o_nexthop(nexthop),
    .o_valid(o_valid),
    .o_ready(o_ready)
    );
    
    initial begin
        #20
        ip      = 32'h0000aaaa;
        i_ready = 1;
        #20
        i_ready = 0;
        #20
        ip      = 32'h0000bbbb;
        i_ready = 1;
        #20
        i_ready = 0;
        #20
        ip      = 32'h0000cccc;
        i_ready = 1;
        #20
        i_ready = 0;
        #20
        ip      = 32'h0000dddd;
        i_ready = 1;
        #20
        i_ready = 0;
        // #20
        // ip      = 32'habcdabcd;
        // i_ready = 1;
        // #20
        // i_ready = 0;
        // #20
        // ip      = 32'hbbbbbbbb;
        // i_ready = 1;
        // #20
        // i_ready = 0;
        // #20
        // ip      = 32'hcbcbcbcb;
        // i_ready = 1;
        // #20
        // i_ready = 0;
        // #20
        // ip      = 32'hcccccccc;
        // i_ready = 1;
        // #20
        // i_ready = 0;
        // #20
        // ip      = 32'h10101010;
        // i_ready = 1;
        // #20
        // i_ready = 0;
        // #20
        // ip      = 32'hdddddddd;
        // i_ready = 1;
        // #20
        // i_ready = 0;
    end
endmodule
