`include "frame_datapath.vh"
module trie_layer(input wire clka,
                  input wire clkb,
                  input wire rst,
                  input wire ip_bit,
                  input wire[TRIE_ADDR_WIDTH-1:0] current_node_addr,
                  output reg[TRIE_ADDR_WIDTH-1:0] next_node_addr,
                  output reg[NEXTHOP_ADDR_WIDTH-1:0] nexthop_addr,
                  output reg valid);
    // A is for hardware reading.
    // B is for software manipulation, which has not been implemented yet.
    reg ena, wea;
    always_comb begin
        ena = 1; // currently we only use hardware side interface.
        wea = 0; // hardware manipulation is read-only.
    end
    
    trie_node_t current_node_data;
    
    blk_mem_gen_2 trie_bram (
    .clka(clk),    // input wire clka
    .ena(ena),      // input wire ena
    .wea(wea),      // input wire [0 : 0] wea, which is read-only.
    .addra(current_node_addr),  // input wire [13 : 0] addra
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
    // - set valid to 1
    // next_node = bit ? current_node->lc : current_node->rc
    always_ff @(posedge clka, posedge rst) begin
        if (rst) begin
            next_node_addr <= 'b0;
            nexthop_addr   <= 'b0;
            valid          <= 'b0;
        end
        else begin
            next_node_addr <= ip_bit?current_node_data.rc_addr:current_node_data.lc_addr;
            nexthop_addr   <= current_node_data.nexhop_addr;
            valid          <= current_node_data.nexthop_addr?1:0;
        end
    end
endmodule
