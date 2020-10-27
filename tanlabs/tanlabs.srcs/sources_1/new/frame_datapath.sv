`timescale 1ns / 1ps

// Example Frame Data Path.

module frame_datapath
#(
    parameter DATA_WIDTH = 64,
    parameter ID_WIDTH = 3
)
(
    input eth_clk,
    input reset,

    input [DATA_WIDTH - 1:0] s_data,
    input [DATA_WIDTH / 8 - 1:0] s_keep,
    input s_last,
    input [DATA_WIDTH / 8 - 1:0] s_user,
    input [ID_WIDTH - 1:0] s_id,
    input s_valid,
    output wire s_ready,

    output wire [DATA_WIDTH - 1:0] m_data,
    output wire [DATA_WIDTH / 8 - 1:0] m_keep,
    output wire m_last,
    output wire [DATA_WIDTH / 8 - 1:0] m_user,
    output wire [ID_WIDTH - 1:0] m_dest,
    output wire m_valid,
    input m_ready
);

    `include "frame_datapath.vh"

    frame_data in;
    wire in_ready;

    // README: Here, we use a width upsizer to change the width to 48 bytes
    // (MAC 14 + ARP 28 + round up 6) to ensure that L2 (MAC) and L3 (IPv4 or ARP) headers appear
    // in one beat (the first beat) facilitating our processing.
    // You can remove this.
    axis_dwidth_converter_up axis_dwidth_converter_up_i(
        .aclk(eth_clk),
        .aresetn(~reset),

        .s_axis_tvalid(s_valid),
        .s_axis_tready(s_ready),
        .s_axis_tdata(s_data),
        .s_axis_tkeep(s_keep),
        .s_axis_tlast(s_last),
        .s_axis_tid(s_id),
        .s_axis_tuser(s_user),

        .m_axis_tvalid(in.valid),
        .m_axis_tready(in_ready),
        .m_axis_tdata(in.data),
        .m_axis_tkeep(in.keep),
        .m_axis_tlast(in.last),
        .m_axis_tid(in.id),
        .m_axis_tuser(in.user)
    );

    assign in.drop       = 1'b0;
    assign in.drop_next  = 1'b0;
    assign in.dont_touch = 1'b0;

    reg [31:0] src_ip_addr;
    reg [31:0] trg_ip_addr;
    reg [31:0] src_ip_addr_conv;
    reg [31:0] src_ip_addr_conv;
    reg [47:0] src_mac_addr;
    reg [47:0] trg_mac_addr;
    reg arp_cache_wr_en = 0;
    reg [15:0] op;

    reg [47:0] my_mac;
    reg [31:0] my_ip;
    
    arp_cache #(
        .CACHE_ADDR_WIDTH(CACHE_ADDR_WIDTH)
    ) arp_cache_module(
        .clk(eth_clk),
        .rst(reset),
        .w_ip(src_ip_addr),
        .w_mac(src_mac_addr),
        .wr_en(arp_cache_wr_en),
        .r_ip(trg_ip_addr),
        .r_mac(trg_mac_addr)
    );

    reg [383:0] data_input_content;
    reg [383:0] data_output_content;
    reg packet_valid;
    reg [7:0] ttl;

    checksum_upd checksum
    (
        .input_data(data_input_content),
        .reset(reset),
        .output_data(data_output_content),
        .packet_valid(packet_valid)
    );

    reg [31:0] query_ip;
    reg [31:0] query_nexthop;
    reg [2:0] query_port;
    reg query_valid;

    route_hard route_table
    (
        .q_ip(query_ip),
        .q_nexthop(query_nexthop),
        .q_port(query_port),
        .q_valid(query_valid)
    );

    reg rl_wq_en;
    reg rl_ins_en;
    reg [31:0] rl_w_ip;
    reg [31:0] rl_w_mask;
    reg [31:0] rl_w_nexthop;
    reg [31:0] rl_q_ip;
    reg [31:0] rl_q_nexthop; 
    reg [2:0] rl_w_port;
    reg [2:0] rl_q_port;
    reg rl_q_found;

    route_linear route_linear_table
    (
        .clk(eth_clk),
        .rst(reset),
        .wq_en(rl_wq_en),
        .ins_en(rl_ins_en),
        .w_ip(rl_w_ip),
        .w_mask(rl_w_mask),
        .w_port(rl_w_port),
        .w_nexthop(rl_w_nexthop),
        .q_ip(rl_q_ip),
        .q_nexthop(rl_q_nexthop),
        .q_port(rl_q_port),
        .q_found(rl_q_found)
    );

    reg rt_i_ready;
    reg [31:0] rt_i_ip;
    reg rt_o_valid;
    reg rt_o_ready;

    route_trie route_trie_table(
        .clka(eth_clk),
        .rst(reset),
        .i_ready(rt_i_ready),
        .i_ip(rt_i_ip),
        .o_valid(rt_o_valid),
        .o_ready(rt_o_ready)
    );

    reg arp_yes;
    reg ip_yes;

    // Track frames and figure out when it is the first beat.
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            in.is_first <= 1'b1;
        end
        else
        begin
            if (in.valid && in_ready)
            begin
                in.is_first <= in.last;
            end
        end
    end

    // README: Your code here.
    // See the guide to figure out what you need to do with frames.

    //THIS IS ONLY FOR TEST.
    reg test_packet_valid;
    assign test_packet_valid = 1;

    
    always@(*)
    begin
        // This block aims at getting my MAC and IP according to in.id.
        case(in.id)
            3'b000:
            begin
                my_mac <= MAC0;
                my_ip <= IP0;
            end
            3'b001:
            begin
                my_mac <= MAC1;
                my_ip <= IP1;
            end
            3'b010:
            begin
                my_mac <= MAC2;
                my_ip <= IP2;
            end
            3'b011:
            begin
                my_mac <= MAC3;
                my_ip <= IP3;
            end
            default:
            begin
                my_mac <= 48'h0;
                my_ip <= 32'h0;
            end
        endcase
    end

    frame_data s1;
    wire s1_ready;

    assign in_ready = s1_ready || !in.valid;
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            s1 <= 0;
        end
        else if (s1_ready)
        begin
            s1 <= in;
            rt_i_ready <= 1;
            rt_i_ip <= 32'haaaaaaaa;
            if (in.valid && in.is_first && !in.drop && !in.dont_touch) 
            begin
                if(in.data[`MAC_TYPE] == ETHERTYPE_IP4)
                begin
                    //Start checkcum and query table if this is IP packet.
                    s1.prot_type <= 3'b000;
                    data_input_content <= in.data;
                    //query_ip <= in.data[`TRG_IP_IP];
                    rl_ins_en   <= 0;
                    rl_wq_en    <= 0;
                    rl_q_ip     <= in.data[`TRG_IP_IP];                   
                end
                else if (in.data[`MAC_TYPE] == ETHERTYPE_ARP) 
                begin
                    s1.prot_type <= 3'b001;
                end
                else if (in.data[`MAC_TYPE] == ETHERTYPE_LTP)
                begin
                    s1.prot_type <= 3'b010;
                    if(in.data[`LTP_OP] == 8'h01)
                    begin
                        rl_ins_en   <= 1;
                        rl_wq_en    <= 1;
                        rl_w_ip     <= in.data[`LTP_SRC_IP];
                        rl_w_nexthop<= in.data[`LTP_TRG_IP];
                        rl_w_mask   <= in.data[`LTP_MASK];
                        rl_w_port   <= in.data[`LTP_PORT];
                        rl_q_ip     <= 32'h0;
                    end
                    else if(in.data[`LTP_OP] == 8'h02)
                    begin
                        rl_ins_en   <= 0;
                        rl_wq_en    <= 1;
                        rl_w_ip     <= in.data[`LTP_SRC_IP];
                        rl_w_nexthop<= in.data[`LTP_TRG_IP];
                        rl_w_mask   <= in.data[`LTP_MASK];
                        rl_w_port   <= in.data[`LTP_PORT];
                        rl_q_ip     <= 32'h0;                        
                    end
                    else if(in.data[`LTP_OP] == 8'h03)
                    begin
                        rl_ins_en   <= 0;
                        rl_wq_en    <= 0;
                        rl_w_ip     <= in.data[`LTP_SRC_IP];
                        rl_w_nexthop<= in.data[`LTP_TRG_IP];
                        rl_w_mask   <= in.data[`LTP_MASK];
                        rl_w_port   <= in.data[`LTP_PORT];
                        rl_q_ip     <= in.data[`LTP_SRC_IP];                        
                    end
                end
                else
                begin
                    //This is rubbish.
                    s1.prot_type <= 3'b111;
                    s1.drop <= 1;
                end
            end
        end
    end

    reg [31:0] query_nexthop_2;      
    reg [2:0] query_port_2;  
    frame_data s2;
    wire s2_ready;
    assign s1_ready = s2_ready || !s1.valid;
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            s2 <= 0;
        end
        else if (s2_ready)
        begin
            s2 <= s1;
            if (s1.valid && s1.is_first && !s1.drop && !s1.dont_touch)
            begin
                case(s1.prot_type)
                    3'b000:
                    begin
                        query_nexthop_2 <= rl_q_nexthop; 
                        query_port_2 <= rl_q_port;
                        if(!query_valid || !test_packet_valid)
                        begin
                            s2.drop <= 1;
                        end
                        else
                        begin
                            s2.drop <= 0;
                            s2.data <= data_output_content;
                        end
                    end

                    3'b001:
                    begin
                        op <= s1.data[`OP];
                    end
                endcase
            end
        end
    end

    reg [47:0] store_trg_mac;
    reg [2:0] query_port_3;  
    frame_data s3;
    wire s3_ready;
    assign s2_ready = s3_ready || !s2.valid;
    always @ (posedge eth_clk or posedge reset)
    begin
        if(reset)
        begin
            s3 <= 0;
            trg_ip_addr <= 0;
            src_ip_addr <= 0;
            src_mac_addr <= 0;
            arp_cache_wr_en <= 0;
        end
        else if (s3_ready)
        begin
            s3 <= s2;
            if (s2.valid && s2.is_first && !s2.drop && !s2.dont_touch)
            begin
                case(s2.prot_type)
                    3'b000:
                    begin
                        arp_cache_wr_en <= 1'b0;
                        trg_ip_addr <= query_nexthop_2; 
                        query_port_3 <= query_port_2;
                    end

                    3'b001:
                    begin
                        src_ip_addr <= s2.data[`SRC_IP_ADDR];
                        src_mac_addr <= s2.data[`SRC_MAC_ADDR];
                        arp_cache_wr_en <= 1'b1;
                        if (op == REQUEST && s2.data[`TRG_IP_ADDR] == my_ip)
                        begin
                            // Swap the corresponding address in ARP. Note that the source MAC address should be updated instead of swapped.
                            s3.data[`SRC_IP_ADDR] <= s2.data[`TRG_IP_ADDR];
                            s3.data[`SRC_MAC_ADDR] <= my_mac;
                            s3.data[`TRG_IP_ADDR] <= s2.data[`SRC_IP_ADDR];
                            s3.data[`TRG_MAC_ADDR] <= s2.data[`SRC_MAC_ADDR];
                            s3.data[`OP] <= REPLY;
                        end
                        else 
                        begin
                            s3.drop <= 1'b1;
                        end
                    end

                    3'b010:
                    begin
                        s3.drop <= 1;
                    end
                endcase
            end
            else
            begin
                trg_ip_addr <= 0;
                src_ip_addr <= 0;
                src_mac_addr <= 0;
                arp_cache_wr_en <= 0;
            end
        end
        else
        begin 
            trg_ip_addr <= 0;
            src_ip_addr <= 0;
            src_mac_addr <= 0;
            arp_cache_wr_en <= 0;
        end
    end

    reg [2:0] query_port_4;  
    frame_data s4;
    wire s4_ready;
    assign test_mac = trg_mac_addr;
    assign s3_ready = s4_ready || !s3.valid;
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            s4 <= 0;
        end
        else if (s4_ready)
        begin
            s4 <= s3;
            query_port_4 <= query_port_3;
        end
    end

    reg arp_yes_5;
    reg ip_yes_5;  
    frame_data s5;
    wire s5_ready;
    reg [2:0] query_port_5;  
    assign s4_ready = s5_ready || !s4.valid;
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            s5 <= 0;
        end
        else if (s5_ready)
        begin
            s5 <= s4;
            if (s4.valid && s4.is_first && !s4.drop && !s4.dont_touch)
            begin
                case (s4.prot_type)
                    3'b000:
                    begin
                        query_port_5 <= query_port_4;
                        store_trg_mac = trg_mac_addr;
                        if(!store_trg_mac)
                        //Not found, then we send an ARP packet.
                        begin
                            s5.data[`MAC_SRC] <= my_mac;
                            s5.data[`MAC_DST] <= TBD;
                            s5.data[`MAC_TYPE] <= ETHERTYPE_ARP;
                            s5.data[`HARD_TYPE] <= HARD;
                            s5.data[`PROT_TYPE] <= PROT;
                            s5.data[`OP] <= REQUEST;
                            s5.data[`HARD_LEN] <= HARD_L;
                            s5.data[`PROT_LEN] <= PROT_L;
                            s5.data[`SRC_MAC_ADDR] <= my_mac;
                            s5.data[`SRC_IP_ADDR] <= my_ip;
                            s5.data[`TRG_IP_ADDR] <= s4.data[`TRG_IP_IP];
                            s5.data[`TRG_MAC_ADDR] <= TBD;
                            s5.data[`FINAL] <= 48'h0;
                        end
                        else
                        begin
                            s5.data[`MAC_SRC] <= my_mac;
                            s5.data[`MAC_DST] <= trg_mac_addr;
                        end
                    end

                    3'b001:
                    begin
                        s5.data[`MAC_DST] <= s4.data[`MAC_SRC];
                        s5.data[`MAC_SRC] <= my_mac;
                    end
                endcase
            end
        end
    end

    frame_data s6;
    wire s6_ready;
    assign s5_ready = s6_ready || !s5.valid;
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            s6 <= 0;
        end
        else if (s6_ready)
        begin
            s6 <= s5;
            if (s5.valid && s5.is_first && !s5.drop && !s5.dont_touch)
            // Send the frame to the port from previous query.
            begin
                if(ip_yes_5)
                begin
                    s6.dest <= query_port_5;
                end
                else if(arp_yes_5)
                begin
                    s6.dest <= s5.id;
                end
                else
                begin
                    s6.dest <= 0;
                end
            end
        end
    end
    
    frame_data out;
    assign out = s6;

    wire out_ready;
    assign s6_ready = out_ready || !out.valid;

    reg out_is_first;
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            out_is_first <= 1'b1;
        end
        else
        begin
            if (out.valid && out_ready)
            begin
                out_is_first <= out.last;
            end
        end
    end

    reg [ID_WIDTH - 1:0] dest;
    reg drop_by_prev;  // Dropped by the previous frame?
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            dest <= 0;
            drop_by_prev <= 1'b0;
        end
        else
        begin
            if (out_is_first && out.valid && out_ready)
            begin
                dest <= out.dest;
                drop_by_prev <= out.drop_next;
            end
        end
    end

    // Rewrite dest.
    wire [ID_WIDTH - 1:0] dest_current = out_is_first ? out.dest : dest;

    frame_data filtered;
    wire filtered_ready;

    frame_filter
    #(
        .DATA_WIDTH(DATAW_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    )
    frame_filter_i(
        .eth_clk(eth_clk),
        .reset(reset),

        .s_data(out.data),
        .s_keep(out.keep),
        .s_last(out.last),
        .s_user(out.user),
        .s_id(dest_current),
        .s_valid(out.valid),
        .s_ready(out_ready),

        .drop(out.drop || drop_by_prev),

        .m_data(filtered.data),
        .m_keep(filtered.keep),
        .m_last(filtered.last),
        .m_user(filtered.user),
        .m_id(filtered.dest),
        .m_valid(filtered.valid),
        .m_ready(filtered_ready)
    );

    // README: Change the width back. You can remove this.
    axis_dwidth_converter_down axis_dwidth_converter_down_i(
        .aclk(eth_clk),
        .aresetn(~reset),

        .s_axis_tvalid(filtered.valid),
        .s_axis_tready(filtered_ready),
        .s_axis_tdata(filtered.data),
        .s_axis_tkeep(filtered.keep),
        .s_axis_tlast(filtered.last),
        .s_axis_tid(filtered.dest),
        .s_axis_tuser(filtered.user),

        .m_axis_tvalid(m_valid),
        .m_axis_tready(m_ready),
        .m_axis_tdata(m_data),
        .m_axis_tkeep(m_keep),
        .m_axis_tlast(m_last),
        .m_axis_tid(m_dest),
        .m_axis_tuser(m_user)
    );
endmodule