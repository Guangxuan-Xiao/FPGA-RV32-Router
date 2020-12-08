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

    reg internal_rx_last;
    reg internal_rx_valid;
    reg internal_rx_ready;
    reg [7:0] internal_rx_data;

    reg internal_tx_last;
    reg internal_tx_valid;
    reg internal_tx_ready;
    reg [7:0] internal_tx_data;

    reg cpu_read_enb;
    reg [15:0] cpu_read_addr;
    wire [31:0] cpu_read_data;

    initial 
    begin
        #8
        internal_rx_valid = 1;
        #12
        internal_rx_data = 8'b00000001;
        internal_rx_ready = 1;
        #8
        internal_rx_data = 0;
        internal_rx_ready = 0;
        #8
        internal_rx_ready = 1;
        internal_rx_data = 8'b00000010;
        #8
        internal_rx_data = 0;
        internal_rx_ready = 0;
        #8
        internal_rx_ready = 1;
        internal_rx_data = 8'b00000100;
        #8
        internal_rx_data = 0;
        internal_rx_ready = 0;
        #8
        internal_rx_ready = 1;
        internal_rx_data = 8'b00001000;
        internal_rx_last = 1;
        #8
        internal_rx_ready = 0;
        internal_rx_last = 0;
        internal_rx_data = 8'b11111111;
        #8
        internal_rx_ready = 0;
        internal_rx_valid = 0;
        #80
        cpu_read_enb = 1;
        cpu_read_addr = 0;
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

    .cpu_read_addrb(cpu_read_addr),
    .cpu_read_data(cpu_read_data),
    .cpu_read_enb(cpu_read_enb)
);

endmodule

