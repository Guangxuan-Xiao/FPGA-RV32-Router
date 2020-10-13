`timescale 1ns / 1ps
module tb_checksum_upd ();
    reg [383:0] input_data;
    reg reset;
    wire [383:0] output_data;
    wire packet_valid;
    wire [7:0] time_to_live;
    reg [383:0] output_data_expect;
    reg packet_valid_expect;
    reg [7:0] time_to_live_expect;
    
    initial begin
        reset = 1;
        #5
        reset = 0;
    end
    
    initial begin
        input_data          = 0;
        output_data_expect  = 0;
        packet_valid_expect = 0;
        time_to_live_expect = 0;
        #10
        input_data[271:112]         = 160'h450000200000400040110d63b7ad71b701020304;
        output_data_expect[271:112] = 160'h45000020000040003f110e63b7ad71b701020304;
        packet_valid_expect         = 1;
        time_to_live_expect         = 8'h40;
        #10
        input_data[271:112]         = 160'h46c00020c61640005002feff00000000e0000001;
        output_data_expect[271:112] = 160'h46c00020c61640004f02000000000000e0000001;
        packet_valid_expect         = 0;
        time_to_live_expect         = 8'h50;
        #10
        input_data[271:112]         = 160'h45000020000040003011feff07a1402701020304;
        output_data_expect[271:112] = 160'h4500002000003f002f11000007a1402701020304;
        packet_valid_expect         = 1;
        time_to_live_expect         = 8'h30;
    end
    
    checksum_upd #() checksum_upd_module(
    .input_data(input_data),
    .reset(reset),
    .output_data(output_data),
    .packet_valid(packet_valid),
    .time_to_live(time_to_live)
    );
endmodule
