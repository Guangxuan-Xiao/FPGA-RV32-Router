`timescale 1ns/1ps
`include "frame_datapath.vh"

module router_cpu_interface(
    input wire clk_router,
    input wire clk_cpu,
    input wire rst_router,
    input wire rst_cpu,

    input wire [7:0] internal_rx_data,
    input wire internal_rx_last,
    input wire internal_rx_user,
    input wire internal_rx_valid, 
    output wire internal_rx_ready,

    output wire [7:0] internal_tx_data,
    output wire internal_tx_last,
    output wire internal_tx_user,
    output wire internal_tx_valid, 
    input wire internal_tx_ready,

    input wire cpu_write_enb,
    input wire [3:0] cpu_write_web,
    input wire [15:0] cpu_write_addrb,
    input wire [31:0] cpu_write_data,
    input wire cpu_write_done,
    input wire [6:0] cpu_write_address,

    output wire cpu_start_enb,
    output wire [6:0] cpu_start_addrb,
    input wire cpu_read_enb,
    input wire [15:0] cpu_read_addrb,
    output wire [31:0] cpu_read_data,
    input wire cpu_finish_enb,
    input wire [6:0] cpu_finish_addrb
);

typedef enum reg[2:0] { START, ACCESS, END1, END2, END3 } router_write_state_t;
router_write_state_t router_write_state = START;

reg [6:0] router_pointer;
reg [6:0] cpu_pointer;
reg [6:0] router_pointer_cpu;

reg [7:0] router_write_data;
reg [17:0] router_write_addr;
reg [17:0] router_write_addr_tmp;
reg internal_rx_ready_i;
reg router_write_en;

assign internal_rx_ready = internal_rx_ready_i;

// Showing the state of router write.
always @ (posedge clk_router)
begin
  if (rst_router)
  begin
    router_write_state    <= START;
    router_pointer        <= 0;
    router_write_data     <= 0;
    router_write_addr     <= 0;
    router_write_en       <= 0;
    internal_rx_ready_i   <= 1;
    router_write_addr_tmp <= 0;
  end
  else
  begin
    case (router_write_state)
    START:
    begin
      if (internal_rx_ready && internal_rx_valid)
      begin
        router_write_state <= ACCESS;
        router_write_data <= internal_rx_data;
        router_write_en   <= 1;
      end
      else
      begin
        router_write_state <= START;
        router_write_en    <= 0;
      end
    end

    ACCESS:
    begin
      if (internal_rx_ready && internal_rx_valid)
      begin
        if (internal_rx_last)
        begin
          router_write_state    <= END1;
          router_write_data     <= internal_rx_data;
          router_write_en       <= 1;
          router_write_addr     <= router_write_addr + 1;
          router_write_addr_tmp <= router_write_addr + 1;
          internal_rx_ready_i   <= 0;
        end
        else
        begin
          router_write_state <= ACCESS;
          router_write_data  <= internal_rx_data;
          router_write_addr  <= router_write_addr + 1;
          router_write_en    <= 1;
        end
      end
      else
      begin
        router_write_state <= ACCESS;
        router_write_en    <= 0;
      end
    end

    END1:
    begin
      router_write_state      <= END2;
      router_write_data       <= router_write_addr_tmp[7:0];
      router_write_en         <= 1;
      router_write_addr[10:0] <= 11'b11111111111;
      internal_rx_ready_i     <= 0;
    end

    END2:
    begin
      router_write_state      <= END3;
      router_write_data       <= router_write_addr_tmp[10:8];
      router_write_en         <= 1;
      router_write_addr[10:0] <= 11'b11111111110;
      router_pointer          <= router_pointer + 1;
      internal_rx_ready_i     <= 0;
    end

    END3:
    begin
      router_write_addr   <= router_pointer << 11;
      router_write_state  <= START;
      router_write_en     <= 0;
      internal_rx_ready_i <= 1;
    end

    default:
    begin
      router_write_state <= START;
      router_write_en    <= 0;
    end
    endcase
  end
end

always @ (posedge clk_cpu)
begin
  if (rst_cpu)
  begin
    cpu_pointer <= 0;
  end
  else
  begin
    if (cpu_finish_enb && (cpu_finish_addrb == cpu_pointer))
    begin
      cpu_pointer <= cpu_pointer + 1;
    end
    else
    begin
      cpu_pointer <= cpu_pointer;
    end
  end
end

assign cpu_start_enb = (router_pointer_cpu != cpu_pointer) ? 1'b1 : 1'b0;
assign cpu_start_addrb = cpu_pointer;

/*reg[7:0] rubbish_but_useful;
assign cpu_start_enb = rubbish_but_useful[7];
assign cpu_start_addrb = rubbish_but_useful[6:0];
xpm_cdc_array_single #(
  .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
  .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
  .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
  .SRC_INPUT_REG(1),  // DECIMAL; 0=do not register input, 1=register input
  .WIDTH(7)           // DECIMAL; range: 1-1024
)
xpm_cdc_array_single_inst_114514 (
  .dest_out(rubbish_but_useful), // WIDTH-bit output: src_in synchronized to thcpu_pointer_routertination clock domain. This
                        // output is registered.

  .dest_clk(clk_cpu), // 1-bit input: Clock signal for the destination clock domain.
  .src_clk(clk_router),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
  .src_in({internal_rx_ready, internal_rx_valid, internal_rx_last, internal_rx_data[4:0]})      // WIDTH-bit input: Input single-bit array to be synchronized to destination clock
                        // domain. It is assumed that each bit of the array is unrelated to the others. This
                        // is reflected in the constraints applied to this macro. To transfer a binary value
                        // losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead.
);*/

xpm_cdc_array_single #(
  .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
  .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
  .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
  .SRC_INPUT_REG(1),  // DECIMAL; 0=do not register input, 1=register input
  .WIDTH(7)           // DECIMAL; range: 1-1024
)
xpm_cdc_array_single_inst (
  .dest_out(router_pointer_cpu), // WIDTH-bit output: src_in synchronized to thcpu_pointer_routertination clock domain. This
                        // output is registered.

  .dest_clk(clk_cpu), // 1-bit input: Clock signal for the destination clock domain.
  .src_clk(clk_router),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
  .src_in(router_pointer)      // WIDTH-bit input: Input single-bit array to be synchronized to destination clock
                        // domain. It is assumed that each bit of the array is unrelated to the others. This
                        // is reflected in the constraints applied to this macro. To transfer a binary value
                        // losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead.
);

// A for router, B for CPU
blk_mem_gen_3 router2CPU 
(
  .clka(clk_router),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(router_write_en),      // input wire [0 : 0] wea
  .addra(router_write_addr),  // input wire [17 : 0] addra
  .dina(router_write_data),    // input wire [7 : 0] dina
  //.douta(douta),  // output wire [7 : 0] douta
  .clkb(clk_cpu),    // input wire clkb
  .enb(cpu_read_enb),      // input wire enb
  .web(4'b0),      // input wire [3 : 0] web
  .addrb(cpu_read_addrb),  // input wire [15 : 0] addrb
  //.dinb(dinb),    // input wire [31 : 0] dinb
  .doutb(cpu_read_data)   // output wire [31 : 0] doutb
);


// Above is all about BRAM 1, where CPU can read and Router can write. 
// ====================================================================
// Below is all about BRAM 2, where CPU can write and Router can read.

typedef enum reg[2:0] { START_O, PREP1, PREP2, PREP3, ACCESS_O, END_1, END_2 } router_read_state_t;
router_read_state_t router_read_state = START_O;
reg [6:0] cpu_pointer_2 = 0;
reg [6:0] cpu_pointer_2_router = 0;
reg [6:0] router_pointer_2 = 0;
reg [7:0] router_read_data;
reg [7:0] internal_tx_data_i;
reg internal_tx_last_i;
reg internal_tx_user_i;
reg internal_tx_valid_i;

assign internal_tx_data = internal_tx_data_i;
assign internal_tx_last = internal_tx_last_i;
assign internal_tx_user = internal_tx_user_i;
assign internal_tx_valid = internal_tx_valid_i;

wire router_start_enb = (router_pointer_2 != cpu_pointer_2_router) ? 1'b1 : 1'b0;
reg[10:0] counter;
reg[17:0] router_read_addr;

xpm_cdc_array_single #(
  .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
  .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
  .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
  .SRC_INPUT_REG(1),  // DECIMAL; 0=do not register input, 1=register input
  .WIDTH(7)           // DECIMAL; range: 1-1024
)
xpm_cdc_array_single_inst_2 (
  .dest_out(cpu_pointer_2_router), // WIDTH-bit output: src_in synchronized to the destination clock domain. This
                        // output is registered.

  .dest_clk(clk_router), // 1-bit input: Clock signal for the destination clock domain.
  .src_clk(clk_cpu),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
  .src_in(cpu_pointer_2)      // WIDTH-bit input: Input single-bit array to be synchronized to destination clock
                        // domain. It is assumed that each bit of the array is unrelated to the others. This
                        // is reflected in the constraints applied to this macro. To transfer a binary value
                        // losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead.
);

always @ (posedge clk_router)
begin
  if (rst_router)
  begin
    internal_tx_data_i  <= 0;
    internal_tx_valid_i <= 0;
    internal_tx_user_i  <= 0;
    internal_tx_last_i  <= 0;
    router_read_addr    <= 11'b11111111111;
    router_read_state   <= START_O;
  end
  else if (!internal_tx_ready)
  begin
    internal_tx_data_i  <= 0;
    internal_tx_valid_i <= 0;
    internal_tx_last_i  <= 0;
  end
  else if (router_start_enb)
  begin
    case (router_read_state)
    START_O:
    begin
      internal_tx_data_i  <= 0;
      internal_tx_valid_i <= 0;
      internal_tx_last_i  <= 0;
      router_read_state   <= PREP1;
      router_read_addr    <= router_read_addr - 1;
    end
    PREP1:
    begin
      internal_tx_data_i  <= 0;
      internal_tx_valid_i <= 0;
      internal_tx_last_i  <= 0;
      router_read_state   <= PREP2;
      counter[7:0]        <= router_read_data;
      router_read_addr[10:0] <= 11'b0;
    end
    PREP2:
    begin
      internal_tx_data_i  <= 0;
      internal_tx_valid_i <= 0;
      internal_tx_last_i  <= 0;
      router_read_state   <= PREP3;
      counter[7:0]        <= router_read_data;
      router_read_addr    <= router_read_addr + 1;
    end
    PREP3:
    begin
      internal_tx_data_i  <= 0;
      internal_tx_valid_i <= 0;
      internal_tx_last_i  <= 0;
      router_read_state   <= ACCESS_O;
      counter[10:8]       <= router_read_data[2:0];
      router_read_addr    <= router_read_addr + 1;
    end
    ACCESS_O:
    begin
      if (counter == 1)
      begin
        internal_tx_valid_i <= 1;
        internal_tx_data_i  <= router_read_data;
        router_read_state   <= END_1;
      end
      else
      begin
        internal_tx_valid_i <= 1;
        router_read_state   <= ACCESS_O;
        router_read_addr    <= router_read_addr + 1;
        internal_tx_data_i  <= router_read_data;
        counter             <= counter - 1;
      end
    end
    END_1:
    begin
      internal_tx_valid_i <= 1;
      internal_tx_data_i  <= router_read_data;
      router_read_state   <= END_2;
    end
    END_2:
    begin
      router_read_addr    <= (router_pointer_2 << 11) + 12'b111111111111;
      internal_tx_valid_i <= 1;
      internal_tx_last_i  <= 1;
      internal_tx_data_i  <= router_read_data;
      internal_tx_user_i  <= 0;
      router_read_state   <= START_O;
      router_pointer_2    <= router_pointer_2 + 1;
    end
    endcase
  end
  else
  begin
    internal_tx_data_i  <= 0;
    internal_tx_valid_i <= 0;
    internal_tx_user_i  <= 0;
    internal_tx_last_i  <= 0;
    router_read_state   <= START_O;
  end
end

always @ (posedge clk_cpu)
begin
  if (rst_cpu)
  begin
    cpu_pointer_2 <= 0;
  end
  else
  begin
    if (cpu_write_done && (cpu_write_address == cpu_pointer_2))
    begin
      cpu_pointer_2 <= cpu_pointer_2 + 1;
    end
    else
    begin
      cpu_pointer_2 <= cpu_pointer_2;
    end
  end
end

blk_mem_gen_3 CPU2router 
(
  .clka(clk_router),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(router_read_addr),  // input wire [17 : 0] addra
  //.dina(dina),    // input wire [7 : 0] dina
  .douta(router_read_data),  // output wire [7 : 0] douta
  .clkb(clk_cpu),    // input wire clkb
  .enb(cpu_write_enb),      // input wire enb
  .web(cpu_write_web),      // input wire [3 : 0] web
  .addrb(cpu_write_addrb),  // input wire [15 : 0] addrb
  .dinb(cpu_write_data)    // input wire [31 : 0] dinb
  //.doutb(doutb)   // output wire [31 : 0] doutb
);

endmodule
