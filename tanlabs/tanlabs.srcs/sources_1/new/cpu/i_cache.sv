`default_nettype none
typedef struct packed {
logic valid;
logic[19:0] phy_addr;
logic[31:0] inst;
} i_entry;
module i_cache #(parameter CACHE_ADDR_WIDTH = 5)
                (input wire clk,
                 input wire rst,
                 input wire[31:0] pc_addr,
                 input wire[31:0] pc_rm_addr,
                 input wire rm_en,
                 output reg if_ram_req,
                 output reg[31:0] if_inst,
                 input wire if_ram_ready,
                 output reg[31:0] pc_ram_addr_o,
                 input wire[31:0] ram_data);
    wire [19:0] pc_phy_addr                   = pc_addr[21:2];
    wire [19:0] pc_rm_phy_addr                = pc_rm_addr[21:2];
    i_entry [(2**CACHE_ADDR_WIDTH)-1:0] cache = 0;
    logic [CACHE_ADDR_WIDTH-1:0] next         = 0;
    logic [CACHE_ADDR_WIDTH:0] ptr1           = 0;
    logic [CACHE_ADDR_WIDTH:0] ptr2           = 0;
    logic hit                                 = 0;
    
    assign pc_ram_addr_o = pc_addr;
    
    
    always_comb begin
        hit     = 0;
        if_inst = ram_data;
        for (ptr1 = 0; ptr1 < (2**CACHE_ADDR_WIDTH); ptr1 = ptr1 + 1) begin
            if (cache[ptr1].valid == 1'b1 && cache[ptr1].phy_addr == pc_phy_addr) begin
                if_inst = cache[ptr1].inst;
                hit     = 1;
            end
        end
        if_ram_req = ~hit;
    end
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            cache = 0;
            next  = 0;
        end
        else  begin
            if (rm_en) begin
                for (ptr2 = 0; ptr2 < (2**CACHE_ADDR_WIDTH); ptr2 = ptr2 + 1) begin
                    if (cache[ptr2].valid && cache[ptr2].phy_addr == pc_rm_phy_addr) begin
                        cache[ptr2].valid = 0;
                    end
                end
            end
            if (!hit && if_ram_ready) begin
                cache[next].valid    = 1'b1;
                cache[next].phy_addr = pc_phy_addr;
                cache[next].inst     = ram_data;
                next                 = next + 1;
            end
        end
    end
endmodule
