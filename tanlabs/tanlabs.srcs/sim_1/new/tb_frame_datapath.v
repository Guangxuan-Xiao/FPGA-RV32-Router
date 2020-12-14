`timescale 1ps / 1ps

module tb_frame_datapath
#(
    parameter DATA_WIDTH = 64,
    parameter ID_WIDTH = 3
)
(
    
);

    reg reset;
    reg [43:0] mac_i;
    reg [31:0] ip1_i;
    reg [31:0] ip2_i;
    reg [31:0] ip3_i;
    reg [31:0] ip4_i;
    reg [15:0] dip_sw;

    initial begin
        reset = 1;
        #6000
        reset = 0;
        dip_sw = 16'b0001001001001000;
        mac_i = 44'h12345678123;
        ip1_i = 32'h11111111;
        ip2_i = 32'h22222222;
        ip3_i = 32'h33333333;
        ip4_i = 32'h44444444;
    end

    wire clk_125M;
    wire clk_50M;

    clock clock_i(
        .clk_125M(clk_125M),
        .clk_50M(clk_50M)
    );

    wire [DATA_WIDTH - 1:0] in_data;
    wire [DATA_WIDTH / 8 - 1:0] in_keep;
    wire in_last;
    wire [DATA_WIDTH / 8 - 1:0] in_user;
    wire [ID_WIDTH - 1:0] in_id;
    wire in_valid;
    wire in_ready;

    axis_model axis_model_i(
        .clk(clk_125M),
        .reset(reset),

        .m_data(in_data),
        .m_keep(in_keep),
        .m_last(in_last),
        .m_user(in_user),
        .m_id(in_id),
        .m_valid(in_valid),
        .m_ready(in_ready)
    );

    wire [DATA_WIDTH - 1:0] out_data;
    wire [DATA_WIDTH / 8 - 1:0] out_keep;
    wire out_last;
    wire [DATA_WIDTH / 8 - 1:0] out_user;
    wire [ID_WIDTH - 1:0] out_dest;
    wire out_valid;
    wire out_ready;
    wire [383:0] out_data_real;
    wire [383:0] in_data_real;

    // README: Instantiate your datapath.
    frame_datapath dut(
        .eth_clk(clk_125M),
        .cpu_clk(clk_50M),
        .reset(reset),

        .s_data(in_data),
        .s_keep(in_keep),
        .s_last(in_last),
        .s_user(in_user),
        .s_id(in_id),
        .s_valid(in_valid),
        .s_ready(in_ready),

        .dip_sw(dip_sw),
        .ip0_i(ip1_i),
        .ip1_i(ip2_i),
        .ip2_i(ip3_i),
        .ip3_i(ip4_i),
        .mac_i(mac_i),

        .m_data(out_data),
        .m_keep(out_keep),
        .m_last(out_last),
        .m_user(out_user),
        .m_dest(out_dest),
        .m_valid(out_valid),
        .m_ready(out_ready)
    );

    axis_receiver axis_receiver_i(
        .clk(clk_125M),
        .reset(reset),

        .s_data(out_data),
        .s_keep(out_keep),
        .s_last(out_last),
        .s_user(out_user),
        .s_dest(out_dest),
        .s_valid(out_valid),
        .s_ready(out_ready)
    );
endmodule
