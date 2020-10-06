`timescale 1ps/1ps
typedef struct packed
{
reg valid;
reg [31:0] ip;
reg [47:0] mac;
} arp_entry;

module arp_cache #(parameter CACHE_ADDR_WIDTH = 8)
                  (input wire clk,
                   input wire rst,
                   input wire[31:0] w_ip,
                   input wire[47:0] w_mac,
                   input wire w_en,
                   input wire[31:0] r_ip,
                   output reg[47:0] r_mac,
                   input wire r_en);
    // cache data
    arp_entry [(2**CACHE_ADDR_WIDTH)-1:0] cache;
    reg [CACHE_ADDR_WIDTH-1:0] next;
    reg found;
    reg [CACHE_ADDR_WIDTH:0] ptr;
    
    always @(posedge clk) begin
        if (rst) begin
            for (ptr = 0; ptr<(2**CACHE_ADDR_WIDTH); ptr = ptr +1) begin
                cache[ptr].valid <= 1'b0;
                next             <= 0;
                found            <= 1'b0;
                r_mac            <= 48'h0;
            end
        end
        else begin
            if (w_en) begin
                found = 1'b0;
                for(ptr = 0; ptr < (2**CACHE_ADDR_WIDTH); ptr = ptr+1) begin
                    if (cache[ptr].valid && cache[ptr].ip == w_ip) begin
                        cache[ptr].mac <= w_mac;
                        found = 1'b1;
                    end
                end
                if (!found) begin
                    cache[next].valid    <= 1'b1;
                    cache[next].ip       <= w_ip;
                    cache[next].mac_addr <= w_mac;
                    next                 <= next + 1;
                end
            end
                if (r_en) begin
                    r_mac <= 48'h0;
                    for (ptr = 0; ptr < (2**CACHE_ADDR_WIDTH); ptr = ptr+1) begin
                        if (cache[ptr].valid && cache[ptr].ip == r_ip) begin
                            r_mac <= cache[ptr].mac;
                        end
                    end
                end
        end
    end
    
endmodule
