`timescale 1ns / 1ps
module tb_arp_cache #(parameter CACHE_ADDR_WIDTH = 4)
                     ();
    reg reset;
    initial begin
        reset = 1;
        #5
        reset = 0;
    end
    
    wire clk_125M;
    
    clock clock_i(
    .clk_125M(clk_125M)
    );
    
    reg [31:0] src_ip_addr;
    reg [47:0] src_mac_addr;
    wire [47:0] trg_mac_addr;
    reg [31:0] trg_ip_addr;
    reg arp_cache_w_en = 0;
    reg arp_cache_r_en = 0;
    
    initial begin
        #20
        src_ip_addr    = 32'habcdabcd;
        src_mac_addr   = 48'h114514191981;
        arp_cache_w_en = 1;
        #20
        arp_cache_w_en = 0;
        #20
        src_ip_addr    = 32'hdcbadcba;
        src_mac_addr   = 48'h114514191981;
        arp_cache_w_en = 1;
        #20
        arp_cache_w_en = 0;
        #20
        src_ip_addr    = 32'habcdabcd;
        src_mac_addr   = 48'h110110110110;
        arp_cache_w_en = 1;
        #20
        arp_cache_w_en = 0;
        #20
        trg_ip_addr    = 32'habcdabcd;
        arp_cache_r_en = 1;
        #20
        arp_cache_r_en = 0;
    end

    arp_cache #(
    .CACHE_ADDR_WIDTH(CACHE_ADDR_WIDTH)
    ) arp_cache_module(
    .clk(clk_125M),
    .rst(reset),
    .w_ip(src_ip_addr),
    .w_mac(src_mac_addr),
    .w_en(arp_cache_w_en),
    .r_ip(trg_ip_addr),
    .r_mac(trg_mac_addr),
    .r_en(arp_cache_r_en)
    );
endmodule