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

    clock clock_i
    (
        .clk_125M(clk_125M)
    );

    reg internal_rx_last;
    reg internal_rx_valid;
    reg internal_rx_ready;
    reg [7:0] internal_rx_data;

    reg internal_tx_last;
    reg internal_tx_valid;
    reg internal_tx_ready;
    reg [7:0] internal_tx_data;

    initial 
    begin
        #20
        internal_rx_valid = 1;
        internal_rx_ready = 1;
        #20
        internal_rx_data = 8'b00000001;
        #20
        internal_rx_data = 8'b00000010;
        #20
        internal_rx_data = 8'b00000100;
        #20
        internal_rx_data = 8'b00001000;
        #20
        internal_rx_last = 1;
        #20
        internal_rx_data = 8'b11111111;
        #20
        internal_rx_last = 0;
        #20
        internal_rx_ready = 0;
        internal_rx_valid = 0;
    end

    router_cpu_interface router_module
    (
    .clk_router(clk_125M),
    .rst(reset),
    
    .internal_rx_data(internal_rx_data),
    .internal_rx_last(internal_rx_last),
    .internal_rx_ready(internal_rx_ready),
    .internal_rx_valid(internal_rx_valid)
);

endmodule

