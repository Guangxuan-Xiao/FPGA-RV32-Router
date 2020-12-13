`timescale 1ns / 1ps

module tb_interface();
    reg reset;
    initial 
    begin
        reset = 1;
        #5
        reset = 0;    
    end

    wire clk_125M;
    wire clk_50M;

    clock clock_i
    (
        .clk_125M(clk_125M),
        .clk_50M(clk_50M)
    );

    reg rst;

    reg internal_rx_last;
    reg internal_rx_valid;
    reg internal_rx_ready;
    reg [7:0] internal_rx_data;

    wire internal_tx_last;
    wire internal_tx_valid;
    wire internal_tx_ready;
    wire [7:0] internal_tx_data;

    reg cpu_write_enb;
    reg [3:0] cpu_write_web;
    reg [15:0] cpu_write_addrb;
    reg [31:0] cpu_write_dinb;
    reg cpu_write_end;
    reg [6:0] cpu_write_end_ptr;

    reg cpu_read_enb;
    reg [15:0] cpu_read_addr;
    wire [31:0] cpu_read_doutb;
    reg cpu_read_end;
    reg [6:0] cpu_read_end_ptr;

    initial
    begin
        #8
        rst = 1;
        #8
        rst = 0;
        internal_rx_valid = 1;
        #12
        internal_rx_data = 8'b00000001;
        internal_rx_ready = 1;
        // #8
        // internal_rx_data = 0;
        // internal_rx_ready = 0;
        #8
        internal_rx_ready = 1;
        internal_rx_data = 8'b00000010;
        // #8
        // internal_rx_data = 0;
        // internal_rx_ready = 0;
        #8
        internal_rx_ready = 1;
        internal_rx_data = 8'b00000100;
        // #8
        // internal_rx_data = 0;
        // internal_rx_ready = 0;
        #8
        internal_rx_ready = 1;
        internal_rx_data = 8'b00001000;
        internal_rx_last = 1;
        #8
        // internal_rx_ready = 0;
        // internal_rx_last = 0;
        internal_rx_data = 8'b11111111;
        #8
        internal_rx_ready = 0;
        internal_rx_valid = 0;
        #8
        cpu_read_enb = 1;
        cpu_read_addr = 0;
        #8
        cpu_read_end = 1;
        cpu_read_end_ptr = 0;
        #20
        cpu_write_enb = 1'b1;
        cpu_write_web = 4'b1111;
        cpu_write_addrb = 0;
        cpu_write_dinb = 32'h9731;
        #20
        cpu_write_enb = 1'b1;
        cpu_write_web = 4'b1111;
        cpu_write_addrb = 0;
        cpu_write_dinb = 32'h97311454;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 32'h86421145;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 32'h55556666;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 32'h32423415;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 32'h32412532;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 32'h65443453;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 32'h45362543;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 32'h45322453;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 32'h66333555;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 32'h32423415;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 32'h32412532;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 32'h65443453;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 32'h45362543;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 32'h45322453;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 32'h66333555;
        #20
        cpu_write_addrb = cpu_write_addrb[15:9] + 9'b111111111;
        cpu_write_dinb = 32'h30000000;
        #20
        cpu_write_end = 1'b1;
        cpu_write_end_ptr = 7'b0;
    end

    router_cpu_interface router_module
    (
    .clk_router(clk_125M),
    .clk_cpu(clk_50M),
    .rst(reset),
    
    .internal_rx_data(internal_rx_data),
    .internal_rx_last(internal_rx_last),
    .internal_rx_ready(internal_rx_ready),
    .internal_rx_valid(internal_rx_valid),

    .internal_tx_data(internal_tx_data),
    .internal_tx_last(internal_tx_last),
    .internal_tx_ready(internal_tx_ready),
    .internal_tx_valid(internal_tx_valid),

    .cpu_write_enb(cpu_write_enb),
    .cpu_write_web(cpu_write_web),
    .cpu_write_addrb(cpu_write_addrb),
    .cpu_write_dinb(cpu_write_dinb),
    .cpu_write_end(cpu_write_end),
    .cpu_write_end_ptr(cpu_write_end_ptr),

    .cpu_read_addrb(cpu_read_addr),
    .cpu_read_doutb(cpu_read_doutb),
    .cpu_read_enb(cpu_read_enb),
    .cpu_read_end(cpu_read_end),
    .cpu_read_end_ptr(cpu_read_end_ptr)
);

endmodule

