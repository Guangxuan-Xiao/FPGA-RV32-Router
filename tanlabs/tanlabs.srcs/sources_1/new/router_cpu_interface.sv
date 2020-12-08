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
    input [31:0] cpu_data_i,

    output cpu_read_en,
    output cpu_write_en,
    output [31:0] cpu_data_o
);




// A for router, B for CPU
blk_mem_gen_3 router2CPU 
(
  .clka(clk_router),    // input wire clka
  .ena(ena),      // input wire ena
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [17 : 0] addra
  .dina(dina),    // input wire [7 : 0] dina
  .douta(douta),  // output wire [7 : 0] douta
  .clkb(clk_cpu),    // input wire clkb
  .enb(enb),      // input wire enb
  .web(web),      // input wire [3 : 0] web
  .addrb(addrb),  // input wire [15 : 0] addrb
  .dinb(dinb),    // input wire [31 : 0] dinb
  .doutb(doutb)   // output wire [31 : 0] doutb
);

blk_mem_gen_3 CPU2router 
(
  .clka(clk_router),    // input wire clka
  .ena(ena),      // input wire ena
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [17 : 0] addra
  .dina(dina),    // input wire [7 : 0] dina
  .douta(douta),  // output wire [7 : 0] douta
  .clkb(clk_cpu),    // input wire clkb
  .enb(enb),      // input wire enb
  .web(web),      // input wire [3 : 0] web
  .addrb(addrb),  // input wire [15 : 0] addrb
  .dinb(dinb),    // input wire [31 : 0] dinb
  .doutb(doutb)   // output wire [31 : 0] doutb
);

endmodule
