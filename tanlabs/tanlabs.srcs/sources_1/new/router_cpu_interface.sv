`timescale 1ns/1ps
`include "frame_datapath.vh"

module router_cpu_interface(
    input clk_router;
    input clk_cpu;
    input rst;

    input [7:0] internal_rx_data,
    input internal_rx_last,
    input internal_rx_user,
    input internal_rx_valid, 
    input internal_rx_ready,

    output [7:0] internal_tx_data,
    output internal_tx_last,
    output internal_tx_user,
    output internal_tx_valid, 
    output internal_tx_ready,

    input [7:0] cpu_addr_i,
    input [7:0] cpu_data_i,

    output cpu_read_en,
    output cpu_write_en,
    output [DATAW_WIDTH - 1 : 0] cpu_data_o
);

localparam ADDRLEN = 7;

reg [1:0] use_state;               // 2'b01 for ROUTER use, 2'b10 for CPU use, else for IDLE state.
reg bram_router_w_en;                // the enable signal for router to write BRAM data, zero disabled.
reg bram_cpu_w_en;                   // the enable signal for cpu to write BRAM data, zero disabled.
reg bram_router_r_en;               // the enable signal for router to read BRAM data, zero disabled.
reg bram_cpu_r_en;                  // the enable signal for cpu to read BRAM data, zero disabled.

reg [ADDRLEN:0] router_addr;        // The address for router to visit BRAM.
reg [ADDRLEN:0] cpu_addr;           // The address for cpu to visit BRAM.

reg[7:0] bram_data;                 // Data send to BRAM.

reg packet_transmit_en;

always_ff @ (posedge clk_router or posedge rst)
begin
    if(rst)
    begin
        use_state <= 2'b00;
        bram_router_w_en <= 0;
        bram_cpu_w_en <= 0;
        bram_router_r_en <= 0;
        bram_cpu_r_en <= 0;
    end
    else
    begin
        if (internal_rx_valid && internal_rx_ready)
        begin
            bram_router_w_en <= 1;
            bram_router_r_en <= 0;
            bram_cpu_w_en <= 0;
            bram_cpu_r_en <= 0;
            bram_data <= internal_rx_data;
            router_addr <= 0;
        end
        // TODO
    end
end

endmodule
