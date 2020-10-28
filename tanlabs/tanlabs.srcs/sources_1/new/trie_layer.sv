`timescale 1ns/1ps

typedef struct packed
{
logic[TRIE_ADDR_WIDTH-1:0] lc_addr;
logic[TRIE_ADDR_WIDTH-1:0] rc_addr;
logic[NEXTHOP_ADDR_WIDTH-1:0] nexthop_addr;
} trie_node_t;


module trie_layer(input wire clka,
                  input wire clkb,
                  input wire rst,
                  input wire ip_bit,
                  input wire[31:0] i_ip,
                  input wire i_ready,
                  input wire i_valid,
                  input wire[TRIE_ADDR_WIDTH-1:0] current_node_addr,
                  input wire[NEXTHOP_ADDR_WIDTH-1:0] i_nexthop_addr,
                  output reg[TRIE_ADDR_WIDTH-1:0] next_node_addr,
                  output reg[NEXTHOP_ADDR_WIDTH-1:0] o_nexthop_addr,
                  output reg[31:0] o_ip,
                  output reg o_valid,
                  output reg o_ready);
    // A is for hardware reading.
    // B is for software manipulation, which has not been implemented yet.
    reg ena, wea;
    always_comb begin
        ena = 1; // currently we only use hardware side interface.
        wea = 0; // hardware manipulation is read-only.
    end
    
    trie_node_t current_node_data;
    
    blk_mem_gen_2 trie_bram (
    .clka(clka),    // input wire clka
    .ena(ena),      // input wire ena
    .wea(wea),      // input wire [0 : 0] wea, which is read-only.
    .addra({1'b0,current_node_addr}),  // input wire [13 : 0] addra
    // .dina(dina),     // input wire [33 : 0] dina
    .douta(current_node_data)  // output wire [33 : 0] douta
    // .clkb(clkb),    // input wire clkb
    // .enb(enb),      // input wire enb
    // .web(web),      // input wire [0 : 0] web
    // .addrb(addrb),  // input wire [13 : 0] addrb
    // .dinb(dinb),    // input wire [33 : 0] dinb
    // .doutb(doutb)  // output wire [33 : 0] doutb
    );
    
    // Get current node information
    // If there is nexthop information in current node
    // - store it into nexthop_addr
    // - set o_valid to 1
    // next_node = bit ? current_node->lc : current_node->rc
    reg ip_bit_old; // To store ip bit of last interval.
    reg i_ready_old;
    reg[31:0] ip_old;
    reg[NEXTHOP_ADDR_WIDTH-1:0] i_nexthop_addr_old;
    // 32-stage pipeline
    always_ff @(posedge clka, posedge rst) begin
        if (rst) begin
            i_ready_old        <= 'b0;
            ip_bit_old         <= 'b0;
            ip_old             <= 'b0;
            o_ip               <= 'b0;
            i_nexthop_addr_old <= 'b0;
        end
        else begin
            i_ready_old        <= i_ready;
            ip_bit_old         <= ip_bit;
            o_ip               <= ip_old;
            ip_old             <= i_ip;
            i_nexthop_addr_old <= i_nexthop_addr;
        end
    end
    
    always_comb begin
        if (rst) begin
            next_node_addr = 'b0;
            o_nexthop_addr = 'b0;
            o_valid        = 'b0;
            o_ready        = 'b0;
        end
        else if (i_ready_old) begin
            // $display("branch 0 %d",i_ready_old);
            if (ip_bit_old) begin
                next_node_addr = current_node_data.rc_addr;
            end
            else begin
                next_node_addr = current_node_data.lc_addr;
            end
            if (current_node_data.nexthop_addr) begin
                o_nexthop_addr = current_node_data.nexthop_addr;
                o_valid        = 'b1;
            end
            else begin
                o_nexthop_addr = i_nexthop_addr_old;
                o_valid        = i_valid;
            end
            o_ready = 'b1;
        end
        else begin
            // $display("branch 1 %d",i_ready_old);
            next_node_addr = 'b0;
            o_nexthop_addr = 'b0;
            o_valid        = 'b0;
            o_ready        = 'b0;
        end
    end
    
    // 64-stage pipeline
    // always_ff @(posedge clka, posedge rst) begin
    //     if (rst) begin
    //         next_node_addr <= 'b0;
    //         nexthop_addr   <= 'b0;
    //         o_valid        <= 'b0;
    //         ip_bit_old     <= 'b0;
    //     end
    //     else begin
    //         ip_bit_old     <= ip_bit;
    //         next_node_addr <= ip_bit_old?current_node_data.rc_addr:current_node_data.lc_addr;
    //         nexthop_addr   <= current_node_data.nexhop_addr;
    //         o_valid        <= current_node_data.nexthop_addr?1:0;
    //     end
    // end
endmodule
