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
    output [31:0] cpu_data_o
);

typedef enum reg[1:0] { START, ACCESS, END } router_write_state;

// Showing the state of router write.
always @ (posedge clk_router)
begin
   if (rst)
   begin
     router_write_state <= START;
   end
   else
   begin
     if (!internal_rx_ready || !internal_rx_valid)
     begin
       router_write_state <= START;
     end
     else if (internal_rx_ready && internal_rx_valid && !internal_rx_last)
     begin
       router_write_state <= ACCESS;
     end
     else if (internal_rx_ready && internal_rx_valid && internal_rx_last)
     begin
       router_write_state <= END;
     end
     else
     begin
       router_write_state <= START;
     end
   end
end

reg cpu_done;
reg router_is_last;
reg [17:0] bram_b_addr;  //cpi -> router 
reg [17:0] bram_b_pointer;
reg [8:0]  bram_b_data;
typedef enum reg[1:0] { START, ACCESS, END } router_read_state;
//Showing the process of router read.
always @ (posedge clk_router)
begin
  if (rst)
  begin
        internal_tx_ready <= 0;
        internal_tx_valid <= 0;
        internal_tx_last <= 0;
        internal_tx_data <= 0;
        bram_b_addr <= 0;
        router_read_state <= START;
  end 
  else
  begin
    if (cpu_done)
    begin
      if (router_read_state == START)
      begin
        internal_tx_ready <= 1;
        internal_tx_valid <= 1;
        internal_tx_last <= 0;
        internal_tx_data <= 0;
        bram_b_addr <= bram_b_pointer;
        router_read_state <= ACCESS;
      end
      else if (router_read_state == ACCESS)
      begin
        if (router_is_last)
        begin
          internal_tx_last <= 1;
          internal_tx_data <= bram_b_data;
          bram_b_addr <= bram_b_addr + 4 ; // Uncertain.
          router_read_state <= END;
        end
        else 
        begin
          internal_tx_last <= 1;
          internal_tx_data <= bram_b_data;
          bram_b_addr <= bram_b_addr + 4 ; // Uncertain.
          router_read_state <= ACCESS;
        end
      end
      else
      begin
        internal_tx_last <= 0;
        internal_tx_ready <= 0;
        internal_tx_valid <= 0;
        internal_tx_data  <= 0;
        bram_b_addr <= 0;
        router_read_state <= START;
      end
    end
    else
    begin
        internal_tx_ready <= 0;
        internal_tx_valid <= 0;
        internal_tx_last <= 0;
        internal_tx_data <= 0;
        bram_b_addr <= 0;
        router_read_state <= START;
    end
  end
end

// A for router, B for CPU
blk_mem_gen_3 data_interface 
(
  .clka(clk_router),    // input wire clka
  .ena(ena),      // input wire ena
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [14 : 0] addra
  .dina(dina),    // input wire [7 : 0] dina
  .douta(douta),  // output wire [7 : 0] douta
  .clkb(clk_cpu),    // input wire clkb
  .enb(enb),      // input wire enb
  .web(web),      // input wire [3 : 0] web
  .addrb(addrb),  // input wire [12 : 0] addrb
  .dinb(dinb),    // input wire [31 : 0] dinb
  .doutb(doutb)   // output wire [31 : 0] doutb
);

endmodule
