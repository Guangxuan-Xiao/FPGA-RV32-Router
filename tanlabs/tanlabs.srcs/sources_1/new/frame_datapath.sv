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
    input m_ready,
    output wire [383 : 0] out_data,
    output wire [383: 0] in_data
);

    `include "frame_datapath.vh"

    frame_data in;
    wire in_ready;
    (*keep = "TRUE"*) reg [1023:0] data;
    assign data[1023:256] = {out_data, in_data};
    ila_0 ila_0_test (
	.clk(eth_clk), // input wire clk


	.probe0(data) // input wire [1023:0] probe0
);

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
    reg arp_cache_w_en = 0;
    reg arp_cache_r_en = 0;
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
        .w_en(arp_cache_w_en),
        .r_ip(trg_ip_addr),
        .r_mac(trg_mac_addr),
        .r_en(arp_cache_r_en)
    );

    reg [383:0] data_input_content;
    reg [383:0] data_output_content;
    reg packet_valid;
    reg [7:0] ttl;

    checksum_upd checksum
    (
        .input_data(data_input_content),
        .output_data(data_output_content),
        .packet_valid(packet_valid),
        .time_to_live(ttl)
    );

    reg [31:0] query_ip;
    reg [31:0] query_nexthop;
    reg [1:0] query_port;
    reg query_valid;

    route_hard route_table
    (
        .q_ip(query_ip),
        .q_nexthop(query_nexthop),
        .q_port(query_port),
        .q_valid(query_valid)
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
            if (in.valid && in.is_first && !in.drop && !in.dont_touch) 
            begin
                if(in.data[`MAC_TYPE] == ETHERTYPE_IP4)
                begin
                    //Start checkcum and query table if this is IP packet.
                    ip_yes <= 1;
                    arp_yes <= 0;
                    data_input_content <= in.data;
                    query_ip <= in.data[`TRG_IP_IP];
                end
                else if (in.data[`MAC_TYPE] == ETHERTYPE_ARP) 
                begin
                    //This is ARP packet.
                    ip_yes <= 0;
                    arp_yes <= 1;
                end
                else
                begin
                    //This is rubbish.
                    ip_yes <= 0;
                    arp_yes <= 0;
                    s1.drop <= 1;
                end
            end
        end
    end
            
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
                if(ip_yes)
                begin
                    // Check the result of checksum, ttl, and decide whether drop or not.
                    if(!query_valid || !packet_valid)
                    begin
                        s2.drop <= 1;
                    end
                    else if(ttl<=1)
                    begin
                        s2.drop <= 1;
                    end
                    else
                    begin
                        s2.drop <= 0;
                        s2.data <= data_output_content;
                    end
                end
                else
                begin
                    //(ARP) Get the op-code.
                    op <= s1.data[`OP];
                end
            end
        end
    end

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
                if(ip_yes)
                begin
                // Query MAC address from ARP cache.
                    arp_cache_wr_en <= 1'b0;
                    trg_ip_addr <= s2.data[`TRG_IP_IP]; 
                end
                else
                begin
                    //(ARP)
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
    

    frame_data s4;
    wire s4_ready;
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
            if (s3.valid && s3.is_first && !s3.drop && !s3.dont_touch)
            begin
                if(ip_yes)
                begin
                    if(trg_mac_addr == 48'h0)
                    //Not found, then we send an ARP packet.
                    begin
                        s4.data[`MAC_SRC] <= my_mac;
                        s4.data[`MAC_DST] <= TBD;
                        s4.data[`MAC_TYPE] <= ETHERTYPE_ARP;
                        s4.data[`HARD_TYPE] <= HARD;
                        s4.data[`PROT_TYPE] <= PROT;
                        s4.data[`OP] <= REQUEST;
                        s4.data[`HARD_LEN] <= HARD_L;
                        s4.data[`PROT_LEN] <= PROT_L;
                        s4.data[`SRC_MAC_ADDR] <= my_mac;
                        s4.data[`SRC_IP_ADDR] <= my_ip;
                        s4.data[`TRG_IP_ADDR] <= trg_ip_addr;
                        s4.data[`TRG_MAC_ADDR] <= TBD;
                    end
                    else
                    begin
                        s4.data[`MAC_SRC] <= my_mac;
                        s4.data[`MAC_DST] <= trg_mac_addr;
                    end
                end
                else
                begin
                    // Change the MAC address of ether frame.
                    s4.data[`MAC_DST] <= s3.data[`MAC_SRC];
                    s4.data[`MAC_SRC] <= my_mac;
                end
            end
        end
    end

    frame_data s5;
    wire s5_ready;
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
            // Send the frame to the port from previous query.
            begin
                if(ip_yes)
                begin
                    s5.dest <= query_port;
                end
                else
                begin
                    s5.dest <= s4.id;
                end
            end
        end
    end
    
    frame_data out;
    assign out = s5;
    assign out_data = s5.data;
    assign in_data = in.data;

    wire out_ready;
    assign s5_ready = out_ready || !out.valid;

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