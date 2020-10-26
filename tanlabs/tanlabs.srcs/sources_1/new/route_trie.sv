`timescale 1ns/1ps
typedef struct packed {
reg valid;         // If this entry is valid
reg[31:0] ip;      // Big endian, ipv4 address.
reg[31:0] mask;    // Little endian, subnet mask.
reg[2:0]  port;    // Little endian, nexthop out port.
reg[31:0] nexthop; // Big endian, nexthop ipv4 addr.
} route_entry;


module route_trie #(parameter CACHE_ADDR_WIDTH = 6)
                     (input wire clk,
                      input wire rst,
                      input wire wq_en,
                      input wire ins_en,
                      input wire[31:0] w_ip,
                      input wire[31:0] w_mask,
                      input wire[2:0] w_port,
                      input wire[31:0] w_nexthop,
                      input wire[31:0] q_ip,
                      output reg[31:0] q_nexthop,
                      output reg[2:0] q_port,
                      output reg q_found);
    // cache data
    route_entry [(2**CACHE_ADDR_WIDTH)-1:0] cache = 0;
    reg [CACHE_ADDR_WIDTH-1:0] next               = 0;
    reg found                                     = 0;
    reg [CACHE_ADDR_WIDTH:0] ptr                  = 0;
    
    always @(posedge clk) begin
        if (rst) begin
            for (ptr = 0; ptr<(2**CACHE_ADDR_WIDTH); ptr = ptr +1) begin
                cache[ptr].valid <= 0;
                next             <= 0;
                found            <= 0;
            end
        end
        else begin
            if (wq_en) begin
                if (ins_en) begin
                    // Insert
                    found = 1'b0;
                    for(ptr = 0; ptr < (2**CACHE_ADDR_WIDTH); ptr = ptr+1) begin
                        if (cache[ptr].valid && cache[ptr].ip == w_ip && cache[ptr].mask == w_mask) begin
                            cache[ptr].port    <= w_port;
                            cache[ptr].nexthop <= w_nexthop;
                            found = 1'b1;
                        end
                    end
                    if (!found) begin
                        cache[next].valid   <= 1'b1;
                        cache[next].ip      <= w_ip;
                        cache[next].mask    <= w_mask;
                        cache[next].port    <= w_port;
                        cache[next].nexthop <= w_nexthop;
                        next                <= next + 1;
                    end
                end
                else begin
                    // Delete
                    for(ptr = 0; ptr < (2**CACHE_ADDR_WIDTH); ptr = ptr+1) begin
                        if (cache[ptr].valid && cache[ptr].ip == w_ip && cache[ptr].mask == w_mask) begin
                            cache[ptr].valid = 0;
                        end
                    end
                end
            end
        end
    end
    
    reg[31:0] best_nexthop = 0;
    reg[1:0] best_port     = 0;
    reg [31:0] best_mask   = 0;
    always @(*) begin
        if (rst || wq_en) begin
            // Insert or Delete
            q_nexthop    = 0;
            q_port       = 0;
            q_found      = 0;
            best_nexthop = 0;
            best_port    = 0;
            best_mask    = 0;
        end
        else begin
            q_found      = 0;
            best_nexthop = 0;
            best_port    = 0;
            best_mask    = 0;
            // Query
            for (ptr = 0; ptr < (2**CACHE_ADDR_WIDTH); ptr = ptr+1) begin
                // Longest Prefix Match
                if (cache[ptr].valid && (cache[ptr].ip & cache[ptr].mask) == (q_ip & cache[ptr].mask) && cache[ptr].mask > best_mask) begin
                    best_nexthop = cache[ptr].nexthop;
                    best_port    = cache[ptr].port;
                    best_mask    = cache[ptr].mask;
                    q_found      = 1;
                end
                else begin
                    best_nexthop = best_nexthop;
                    best_port    = best_port;
                    best_mask    = best_mask;
                    q_found      = q_found;
                end
            end
            if (q_found) begin
                q_nexthop = best_nexthop;
                q_port    = best_port;
            end
            else begin
                q_nexthop = 0;
                q_port    = 0;
            end
        end
    end
endmodule
