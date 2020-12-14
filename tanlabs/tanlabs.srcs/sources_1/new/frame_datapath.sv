`timescale 1ns / 1ps
`include "frame_datapath.vh"

// Example Frame Data Path.
module frame_datapath #(
    parameter ID_WIDTH = 3,
    parameter DATA_WIDTH = 64
)
(
    input wire eth_clk,
    input wire cpu_clk,
    input wire reset,

    input wire [DATA_WIDTH - 1:0] s_data,
    input wire [DATA_WIDTH / 8 - 1:0] s_keep,
    input wire s_last,
    input wire [DATA_WIDTH / 8 - 1:0] s_user,
    input wire [ID_WIDTH - 1:0] s_id,
    input wire s_valid,
    output wire s_ready,

    input wire [15:0] dip_sw,
    input wire [31:0] ip0_i,
    input wire [31:0] ip1_i,
    input wire [31:0] ip2_i,
    input wire [31:0] ip3_i,
    input wire [43:0] mac_i,

    output wire [DATA_WIDTH - 1:0] m_data,
    output wire [DATA_WIDTH / 8 - 1:0] m_keep,
    output wire m_last,
    output wire [DATA_WIDTH / 8 - 1:0] m_user,
    output wire [ID_WIDTH - 1:0] m_dest,
    output wire m_valid,
    input wire m_ready,
    input wire[3:0] trie_web[32:0],
    input wire[4:0] nexthop_web,
    input wire[TRIE_ADDR_WIDTH-1:0] node_addr_b[32:0],
    input trie_node_t node_dinb[32:0],
    output trie_node_t node_doutb[32:0],
    input wire[NEXTHOP_ADDR_WIDTH-1:0] nexthop_addr_b,
    input nexthop_t nexthop_dinb,
    output nexthop_t nexthop_doutb
);

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
    nexthop_t rt_o_nexthop;

    route_trie route_trie_table(
        .clka(eth_clk),
        .clkb(cpu_clk),
        .rst(reset),
        .i_ready(rt_i_ready),
        .i_ip(rt_i_ip),
        .o_valid(rt_o_valid),
        .o_ready(rt_o_ready),
        .o_nexthop(rt_o_nexthop),
        .trie_web,
        .nexthop_web,
        .node_addr_b,
        .node_dinb,
        .node_doutb,
        .nexthop_addr_b,
        .nexthop_dinb,
        .nexthop_doutb
    );

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
    
    reg[43:0] mac;
    reg[31:0] ip0, ip1, ip2, ip3;
     xpm_cdc_array_single #(
      .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1),  // DECIMAL; 0=do not register input, 1=register input
      .WIDTH(172)           // DECIMAL; range: 1-1024
   )
   xpm_cdc_array_single_inst (
      .dest_out({mac, ip0, ip1, ip2, ip3}), // WIDTH-bit output: src_in synchronized to the destination clock domain. This
                           // output is registered.
      .dest_clk(eth_clk),  // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(cpu_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in({mac_i, ip0_i, ip1_i, ip2_i, ip3_i})      // WIDTH-bit input: Input single-bit array to be synchronized to destination clock
                           // domain. It is assumed that each bit of the array is unrelated to the others. This
                           // is reflected in the constraints applied to this macro. To transfer a binary value
                           // losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead.
   );
   
   reg [31:0] ip_val;
    always@(*)
    begin
        // This block aims at getting my MAC and IP according to in.id.
        case(in.id)
            3'b000:
            begin
                my_mac <= {dip_sw[15:12], mac};
                my_ip  <= ip0;
                ip_val <= {ip0[7:0], ip0[15:8], ip0[23:16], ip0[31:24]};
            end
            3'b001:
            begin
                my_mac <= {dip_sw[11:8], mac};
                my_ip  <= ip1;
                ip_val <= {ip1[7:0], ip1[15:8], ip1[23:16], ip1[31:24]};
            end
            3'b010:
            begin
                my_mac <= {dip_sw[7:4], mac};
                my_ip  <= ip2;
                ip_val <= {ip2[7:0], ip2[15:8], ip2[23:16], ip2[31:24]};
            end
            3'b011:
            begin
                my_mac <= {dip_sw[3:0], mac};
                my_ip  <= ip3;
                ip_val <= {ip3[7:0], ip3[15:8], ip3[23:16], ip3[31:24]};
            end
            default:
            begin
                my_mac <= 48'h0;
                my_ip  <= 32'h0;
                ip_val <= 0;
            end
        endcase
    end

    frame_data s1;
    wire s1_ready;
    reg [31:0] ip_file;
    reg store_to_cpu = 0;
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
                    s1.prot_type <= 3'b000;
                    data_input_content <= in.data;
                    rt_i_ip <= in.data[`TRG_IP_IP];   
                    rt_i_ready <= 1;
                    ip_file <= in.data[`TRG_IP_IP];
                    if(in.id != 4)
                    begin
                        if (in.data [`TRG_IP_IP] == my_ip || ( ip_val <= 32'hEFFFFFFF && ip_val >= 32'hE0000000))
                        begin
                            s1.dest <= 4;
                            s1.to_cpu <= 1;
                            s1.data[`MAC_DST] <= in.id;
                        end
                        else
                        begin
                            s1.to_cpu <= 0;
                        end
                    end
                    else
                    begin
                        s1.to_cpu <= 0;
                    end
                end
                else if (in.data[`MAC_TYPE] == ETHERTYPE_ARP) 
                begin
                    s1.prot_type <= 3'b001;
                    s1.to_cpu    <= 0;
                end
                else
                begin
                    //This is rubbish
                    s1.prot_type <= 3'b111;
                    s1.drop <= 1;
                    s1.to_cpu <= 0;
                end
            end
            else if (in.valid && !in.is_first && !in.drop && !in.dont_touch)
            begin
                s1.prot_type <= 3'b110;
                s1.to_cpu    <= 0;
            end
        end
    end

    reg [383:0] manage;
    frame_data query_trie_1;
    wire query_trie_1_ready;
    assign s1_ready = query_trie_1_ready || !s1.valid;
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            query_trie_1 <= 0;
        end
        else if(query_trie_1_ready)
        begin
            query_trie_1 <= s1;
            if(s1.prot_type == 3'b000 && !s1.to_cpu && s1.id != 4)
            begin
                manage <= data_output_content;
                query_trie_1.data <= data_output_content;
            end
        end
    end

frame_data query_trie_2;
wire query_trie_2_ready;
assign query_trie_1_ready = query_trie_2_ready || !query_trie_1.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_2 <= 0;
	end
	else if (query_trie_2_ready)
	begin
		query_trie_2 <= query_trie_1;
	end
end


frame_data query_trie_3;
wire query_trie_3_ready;
assign query_trie_2_ready = query_trie_3_ready || !query_trie_2.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_3 <= 0;
	end
	else if (query_trie_3_ready)
	begin
		query_trie_3 <= query_trie_2;
	end
end


frame_data query_trie_4;
wire query_trie_4_ready;
assign query_trie_3_ready = query_trie_4_ready || !query_trie_3.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_4 <= 0;
	end
	else if (query_trie_4_ready)
	begin
		query_trie_4 <= query_trie_3;
	end
end


frame_data query_trie_5;
wire query_trie_5_ready;
assign query_trie_4_ready = query_trie_5_ready || !query_trie_4.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_5 <= 0;
	end
	else if (query_trie_5_ready)
	begin
		query_trie_5 <= query_trie_4;
	end
end


frame_data query_trie_6;
wire query_trie_6_ready;
assign query_trie_5_ready = query_trie_6_ready || !query_trie_5.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_6 <= 0;
	end
	else if (query_trie_6_ready)
	begin
		query_trie_6 <= query_trie_5;
	end
end


frame_data query_trie_7;
wire query_trie_7_ready;
assign query_trie_6_ready = query_trie_7_ready || !query_trie_6.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_7 <= 0;
	end
	else if (query_trie_7_ready)
	begin
		query_trie_7 <= query_trie_6;
	end
end


frame_data query_trie_8;
wire query_trie_8_ready;
assign query_trie_7_ready = query_trie_8_ready || !query_trie_7.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_8 <= 0;
	end
	else if (query_trie_8_ready)
	begin
		query_trie_8 <= query_trie_7;
	end
end


frame_data query_trie_9;
wire query_trie_9_ready;
assign query_trie_8_ready = query_trie_9_ready || !query_trie_8.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_9 <= 0;
	end
	else if (query_trie_9_ready)
	begin
		query_trie_9 <= query_trie_8;
	end
end


frame_data query_trie_10;
wire query_trie_10_ready;
assign query_trie_9_ready = query_trie_10_ready || !query_trie_9.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_10 <= 0;
	end
	else if (query_trie_10_ready)
	begin
		query_trie_10 <= query_trie_9;
	end
end


frame_data query_trie_11;
wire query_trie_11_ready;
assign query_trie_10_ready = query_trie_11_ready || !query_trie_10.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_11 <= 0;
	end
	else if (query_trie_11_ready)
	begin
		query_trie_11 <= query_trie_10;
	end
end


frame_data query_trie_12;
wire query_trie_12_ready;
assign query_trie_11_ready = query_trie_12_ready || !query_trie_11.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_12 <= 0;
	end
	else if (query_trie_12_ready)
	begin
		query_trie_12 <= query_trie_11;
	end
end


frame_data query_trie_13;
wire query_trie_13_ready;
assign query_trie_12_ready = query_trie_13_ready || !query_trie_12.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_13 <= 0;
	end
	else if (query_trie_13_ready)
	begin
		query_trie_13 <= query_trie_12;
	end
end


frame_data query_trie_14;
wire query_trie_14_ready;
assign query_trie_13_ready = query_trie_14_ready || !query_trie_13.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_14 <= 0;
	end
	else if (query_trie_14_ready)
	begin
		query_trie_14 <= query_trie_13;
	end
end


frame_data query_trie_15;
wire query_trie_15_ready;
assign query_trie_14_ready = query_trie_15_ready || !query_trie_14.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_15 <= 0;
	end
	else if (query_trie_15_ready)
	begin
		query_trie_15 <= query_trie_14;
	end
end


frame_data query_trie_16;
wire query_trie_16_ready;
assign query_trie_15_ready = query_trie_16_ready || !query_trie_15.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_16 <= 0;
	end
	else if (query_trie_16_ready)
	begin
		query_trie_16 <= query_trie_15;
	end
end


frame_data query_trie_17;
wire query_trie_17_ready;
assign query_trie_16_ready = query_trie_17_ready || !query_trie_16.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_17 <= 0;
	end
	else if (query_trie_17_ready)
	begin
		query_trie_17 <= query_trie_16;
	end
end


frame_data query_trie_18;
wire query_trie_18_ready;
assign query_trie_17_ready = query_trie_18_ready || !query_trie_17.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_18 <= 0;
	end
	else if (query_trie_18_ready)
	begin
		query_trie_18 <= query_trie_17;
	end
end


frame_data query_trie_19;
wire query_trie_19_ready;
assign query_trie_18_ready = query_trie_19_ready || !query_trie_18.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_19 <= 0;
	end
	else if (query_trie_19_ready)
	begin
		query_trie_19 <= query_trie_18;
	end
end


frame_data query_trie_20;
wire query_trie_20_ready;
assign query_trie_19_ready = query_trie_20_ready || !query_trie_19.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_20 <= 0;
	end
	else if (query_trie_20_ready)
	begin
		query_trie_20 <= query_trie_19;
	end
end


frame_data query_trie_21;
wire query_trie_21_ready;
assign query_trie_20_ready = query_trie_21_ready || !query_trie_20.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_21 <= 0;
	end
	else if (query_trie_21_ready)
	begin
		query_trie_21 <= query_trie_20;
	end
end


frame_data query_trie_22;
wire query_trie_22_ready;
assign query_trie_21_ready = query_trie_22_ready || !query_trie_21.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_22 <= 0;
	end
	else if (query_trie_22_ready)
	begin
		query_trie_22 <= query_trie_21;
	end
end


frame_data query_trie_23;
wire query_trie_23_ready;
assign query_trie_22_ready = query_trie_23_ready || !query_trie_22.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_23 <= 0;
	end
	else if (query_trie_23_ready)
	begin
		query_trie_23 <= query_trie_22;
	end
end


frame_data query_trie_24;
wire query_trie_24_ready;
assign query_trie_23_ready = query_trie_24_ready || !query_trie_23.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_24 <= 0;
	end
	else if (query_trie_24_ready)
	begin
		query_trie_24 <= query_trie_23;
	end
end


frame_data query_trie_25;
wire query_trie_25_ready;
assign query_trie_24_ready = query_trie_25_ready || !query_trie_24.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_25 <= 0;
	end
	else if (query_trie_25_ready)
	begin
		query_trie_25 <= query_trie_24;
	end
end


frame_data query_trie_26;
wire query_trie_26_ready;
assign query_trie_25_ready = query_trie_26_ready || !query_trie_25.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_26 <= 0;
	end
	else if (query_trie_26_ready)
	begin
		query_trie_26 <= query_trie_25;
	end
end


frame_data query_trie_27;
wire query_trie_27_ready;
assign query_trie_26_ready = query_trie_27_ready || !query_trie_26.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_27 <= 0;
	end
	else if (query_trie_27_ready)
	begin
		query_trie_27 <= query_trie_26;
	end
end


frame_data query_trie_28;
wire query_trie_28_ready;
assign query_trie_27_ready = query_trie_28_ready || !query_trie_27.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_28 <= 0;
	end
	else if (query_trie_28_ready)
	begin
		query_trie_28 <= query_trie_27;
	end
end


frame_data query_trie_29;
wire query_trie_29_ready;
assign query_trie_28_ready = query_trie_29_ready || !query_trie_28.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_29 <= 0;
	end
	else if (query_trie_29_ready)
	begin
		query_trie_29 <= query_trie_28;
	end
end


frame_data query_trie_30;
wire query_trie_30_ready;
assign query_trie_29_ready = query_trie_30_ready || !query_trie_29.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_30 <= 0;
	end
	else if (query_trie_30_ready)
	begin
		query_trie_30 <= query_trie_29;
	end
end


frame_data query_trie_31;
wire query_trie_31_ready;
assign query_trie_30_ready = query_trie_31_ready || !query_trie_30.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_31 <= 0;
	end
	else if (query_trie_31_ready)
	begin
		query_trie_31 <= query_trie_30;
	end
end


frame_data query_trie_32;
wire query_trie_32_ready;
assign query_trie_31_ready = query_trie_32_ready || !query_trie_31.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_32 <= 0;
	end
	else if (query_trie_32_ready)
	begin
		query_trie_32 <= query_trie_31;
	end
end


frame_data query_trie_33;
wire query_trie_33_ready;
assign query_trie_32_ready = query_trie_33_ready || !query_trie_32.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_33 <= 0;
	end
	else if (query_trie_33_ready)
	begin
		query_trie_33 <= query_trie_32;
	end
end

frame_data query_trie_34;
wire query_trie_34_ready;
assign query_trie_33_ready = query_trie_34_ready || !query_trie_33.valid;
always @ (posedge eth_clk or posedge reset)
begin
	if (reset)
	begin
		query_trie_34 <= 0;
	end
	else if (query_trie_34_ready)
	begin
		query_trie_34 <= query_trie_33;
	end
end

    reg liushui = 0;
    reg [31:0] query_nexthop_2;      
    reg [2:0] query_port_2;  
    frame_data s2;
    wire s2_ready;
    assign query_trie_34_ready = s2_ready || !query_trie_34.valid;
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            s2 <= 0;
        end
        else if (s2_ready)
        begin
            s2 <= query_trie_34;
            if (query_trie_34.valid && query_trie_34.is_first && !query_trie_34.drop && !query_trie_34.dont_touch)
            begin
                case(query_trie_34.prot_type)
                    3'b000:
                    begin
                        if(!query_trie_34.to_cpu && query_trie_34.id != 4)
                        begin
                            liushui <= rt_o_ready;
                            query_nexthop_2 <= rt_o_nexthop.ip; 
                            query_port_2 <= rt_o_nexthop.port;
                            if( !rt_o_valid ||!test_packet_valid)
                            begin
                                s2.drop <= 1;
                            end
                            else
                            begin
                                s2.drop <= 0;
                            end
                        end
                    end

                    3'b001:
                    begin
                        op <= query_trie_34.data[`OP];
                    end
                endcase
            end
            else if (!query_trie_34.is_first)
            begin
                
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
                        if(!s2.to_cpu && s2.id != 4)
                        begin
                            arp_cache_wr_en <= 1'b0;
                            trg_ip_addr <= query_nexthop_2; 
                            query_port_3 <= query_port_2;
                        end
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
        else if (!s2.is_first)
        begin
            
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
//    assign test_mac = trg_mac_addr;
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
                        if (!s4.to_cpu && s4.id != 4)
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
                    end

                    3'b001:
                    begin
                        s5.data[`MAC_DST] <= s4.data[`MAC_SRC];
                        s5.data[`MAC_SRC] <= my_mac;
                    end
                endcase
            end
            else if (!s4.is_first)
            begin
                
            end
        end
    end

    reg [2:0] store_dst;

    frame_data s6;
    wire s6_ready;
    reg [47:0] portmac;
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
                case(s5.prot_type)
                3'b000:
                begin
                    //TODO: change to prev_5
                    if (s5.id == 4)
                    begin
                        s6.dest <= s5.data[`MAC_SRC];
                        store_dst <= s5.data[`MAC_SRC];
                    end
                    else if(!s5.to_cpu)
                    begin
                        s6.dest <= query_port_5;
                        store_dst <= query_port_5;
                    end
                    else
                    begin
                        s6.dest <= 4;
                        store_dst <= 4;
                    end
                end

                3'b001:
                begin
                    s6.dest <= s5.id;
                end

                default:
                begin
                    s6.dest <= 0;
                end
                endcase
            end
            else if (s5.last)
            begin
                s6.drop <= 1;
            end
            else if (!s5.is_first)
            begin
                s6.dest <= store_dst;
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
                //TODO : change to out.dest.
                dest <= out.dest;
                //dest <= 4;
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
