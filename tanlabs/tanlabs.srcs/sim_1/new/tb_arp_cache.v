`timescale 1ns / 1ps
module tb_arp_cache #(parameter CACHE_ADDR_WIDTH = 2)
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
    reg arp_cache_wr_en = 0;
    
    initial begin
        // write abcdabcd, 114514191981
        #20
        src_ip_addr     = 32'habcdabcd;
        src_mac_addr    = 48'h114514191981;
        arp_cache_wr_en = 1;
        #20
        arp_cache_wr_en = 0;
        #20
        
        // write dcbadcba, 114514191981
        src_ip_addr     = 32'hdcbadcba;
        src_mac_addr    = 48'h114514191981;
        arp_cache_wr_en = 1;
        #20
        arp_cache_wr_en = 0;
        
        // overwrite abcdabcd, 110110110110
        #20
        src_ip_addr     = 32'habcdabcd;
        src_mac_addr    = 48'h110110110110;
        arp_cache_wr_en = 1;
        #20
        arp_cache_wr_en = 0;
        
        // query abcdabcd
        #20
        trg_ip_addr = 32'habcdabcd;
        #20
        
        // query dcbadcba
        #20
        trg_ip_addr = 32'hdcbadcba;
        #20
        
        // query aaaaaaaa
        #20
        trg_ip_addr = 32'haaaaaaaa;
    end
    
    arp_cache #(
    .CACHE_ADDR_WIDTH(CACHE_ADDR_WIDTH)
    ) arp_cache_module(
    .clk(clk_125M),
    .rst(reset),
    .w_ip(src_ip_addr),
    .w_mac(src_mac_addr),
    .wr_en(arp_cache_wr_en),
    .r_ip(trg_ip_addr),
    .r_mac(trg_mac_addr)
    );
endmodule
