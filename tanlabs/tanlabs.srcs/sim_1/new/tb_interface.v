`timescale 1ns / 1ps

module tb_interface();
    reg reset;
    initial 
    begin
        reset = 1;
        #100
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
    wire internal_rx_ready;
    reg internal_rx_ready_i;
    assign internal_rx_ready = internal_rx_ready_i;
    reg internal_rx_user;
    reg [7:0] internal_rx_data;

    wire internal_tx_last;
    wire internal_tx_valid;
    wire internal_tx_ready;
    assign internal_tx_ready = 1;
    wire internal_tx_user;
    wire [7:0] internal_tx_data;

    reg cpu_write_web;
    reg [15:0] cpu_write_addrb;
    reg [7:0] cpu_write_dinb;
    reg cpu_write_end;
    reg [4:0] cpu_write_end_ptr;

    reg [15:0] cpu_read_addr;
    wire [7:0] cpu_read_doutb;
    reg cpu_read_end;
    reg [4:0] cpu_read_end_ptr;

    initial
    begin
        reset = 1;
        #100
        reset = 0;
        internal_rx_valid = 1;
        #12
        internal_rx_data = 8'b00000001;
        internal_rx_ready_i = 1;
        // #8
        // internal_rx_data = 0;
        // internal_rx_ready = 0;
        #8
        internal_rx_ready_i = 1;
        internal_rx_data = 8'b00000010;
        // #8
        // internal_rx_data = 0;
        // internal_rx_ready = 0;
        #8
        internal_rx_ready_i = 1;
        internal_rx_data = 8'b00000100;
        // #8
        // internal_rx_data = 0;
        // internal_rx_ready = 0;
        #8
        internal_rx_ready_i = 1;
        internal_rx_data = 8'b00001000;
        internal_rx_last = 1;
        #8
        // internal_rx_ready = 0;
        // internal_rx_last = 0;
        internal_rx_data = 8'b11111111;
        #8
        internal_rx_ready_i = 0;
        internal_rx_valid = 0;
        #8
        cpu_read_addr = 0;
        #8
        cpu_read_end = 1;
        cpu_read_end_ptr = 0;
        #20
        cpu_write_web = 1'b1;
        cpu_write_addrb = 0;
        cpu_write_dinb = 8'h97;
        #20
        cpu_write_web = 1'b1;
        cpu_write_addrb = 0;
        cpu_write_dinb = 8'h97;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 8'h86;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 8'h55;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 8'h32;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 8'h32;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 8'h65;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 8'h45;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 8'h22;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 8'h65;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 8'h24;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 8'h12;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 8'h43;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 8'h62;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 8'h22;
        #20
        cpu_write_addrb = cpu_write_addrb + 1;
        cpu_write_dinb = 8'h35;
        #20
        cpu_write_addrb = cpu_write_addrb[15:11] + 11'b11111111111;
        cpu_write_dinb = 8'h10;
        #20
        cpu_write_end = 1'b1;
        cpu_write_end_ptr = 7'b0;
    end

    router_cpu_interface router_module
    (
    .clk_router(clk_125M),
    .clk_cpu(clk_50M),
    .rst_router(reset),
    .rst_cpu(reset),
    
    .internal_rx_data(internal_rx_data),
    .internal_rx_last(internal_rx_last),
    .internal_rx_ready(internal_rx_ready),
    .internal_rx_valid(internal_rx_valid),
    .internal_rx_user(internal_rx_user),

    .internal_tx_data(internal_tx_data),
    .internal_tx_last(internal_tx_last),
    .internal_tx_ready(internal_tx_ready),
    .internal_tx_valid(internal_tx_valid),
    .internal_tx_user(internal_tx_user),

    .cpu_write_web(cpu_write_web),
    .cpu_write_addrb(cpu_write_addrb),
    .cpu_write_dinb(cpu_write_dinb),
    .cpu_write_end(cpu_write_end),
    .cpu_write_end_ptr(cpu_write_end_ptr),

    .cpu_read_addrb(cpu_read_addr),
    .cpu_read_doutb(cpu_read_doutb),
    .cpu_read_end(cpu_read_end),
    .cpu_read_end_ptr(cpu_read_end_ptr)
);

endmodule

