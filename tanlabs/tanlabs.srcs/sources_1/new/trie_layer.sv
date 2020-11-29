`timescale 1ns/1ps
`include "frame_datapath.vh"
module trie_layer(input wire clka,
                  input wire clkb,
                  input wire rst,
                  input wire ip_bit,
                  input wire[31:0] i_ip,
                  input wire i_ready,
                  input wire i_valid,
                  input wire[TRIE_ADDR_WIDTH-1:0] current_node_addr_a,
                  input wire[NEXTHOP_ADDR_WIDTH-1:0] i_nexthop_addr,
                  output reg[TRIE_ADDR_WIDTH-1:0] next_node_addr,
                  output reg[NEXTHOP_ADDR_WIDTH-1:0] o_nexthop_addr,
                  output reg[31:0] o_ip,
                  output reg o_valid,
                  output reg o_ready,
                  input wire web,
                  input wire[TRIE_ADDR_WIDTH-1:0] node_addr_b,
                  input trie_node_t node_dinb,
                  output trie_node_t node_doutb
                  );
    // A is for hardware reading.
    // B is for software manipulation, which has not been implemented yet.
    trie_node_t current_node_data;
    
    blk_mem_gen_2 trie_bram (
    .clka(clka),    // input wire clka
    .ena(1),      // input wire ena
    .wea(0),      // input wire [0 : 0] wea, which is read-only.
    .addra(current_node_addr_a),  // input wire [13 : 0] addra
    // .dina(dina),     // input wire [31 : 0] dina
    .douta(current_node_data),  // output wire [31 : 0] douta
    .clkb(clkb),    // input wire clkb
    .enb(1),      // input wire enb
    .web(web),      // input wire [0 : 0] web
    .addrb(node_addr_b),  // input wire [13 : 0] addrb
    .dinb(node_dinb),    // input wire [31 : 0] dinb
    .doutb(node_doutb)  // output wire [31 : 0] doutb
    );
    
    // Get current node information
    // If there is nexthop information in current node
    // - store it into nexthop_addr
    // - set o_valid to 1
    // next_node = bit ? current_node->lc : current_node->rc
    // 32-stage pipeline
    reg ip_bit_old;
    reg[NEXTHOP_ADDR_WIDTH-1:0] i_nexthop_addr_old;
    reg i_valid_old;
    always_ff @(posedge clka, posedge rst) begin
        if (rst) begin
            o_ip               <= 'b0;
            o_ready            <= 'b0;
            ip_bit_old         <= 'b0;
            i_valid_old        <= 'b0;
            i_nexthop_addr_old <= 'b0;
        end
        else if (i_ready)begin
            o_ready            <= 'b1;
            o_ip               <= i_ip;
            ip_bit_old         <= ip_bit;
            i_valid_old        <= i_valid;
            i_nexthop_addr_old <= i_nexthop_addr;
        end
        else begin
            o_ip               <= 'b0;
            o_ready            <= 'b0;
            ip_bit_old         <= 'b0;
            i_valid_old        <= 'b0;
            i_nexthop_addr_old <= 'b0;
        end
    end

    always_comb begin
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
            o_valid        = i_valid_old;
        end
    end
endmodule
