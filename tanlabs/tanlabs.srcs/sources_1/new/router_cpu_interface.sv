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

    input wire cpu_write_web,
    input wire [`BUFFER_ADDR_WIDTH - 1:0] cpu_write_addrb,
    input wire [7:0] cpu_write_dinb,
    input wire cpu_write_end,
    input wire [`BUFFER_WIDTH - 1:0] cpu_write_end_ptr,

    output wire cpu_read_start,
    output wire [`BUFFER_WIDTH - 1:0] cpu_read_start_ptr,
    input wire [`BUFFER_ADDR_WIDTH - 1:0] cpu_read_addrb,
    output wire [7:0] cpu_read_doutb,
    input wire cpu_read_end,
    input wire [`BUFFER_WIDTH - 1:0] cpu_read_end_ptr
);

typedef enum reg[2:0] { START, ACCESS, END1, END2, END3 } router_write_state_t;
router_write_state_t router_write_state = START;

reg [`BUFFER_WIDTH - 1:0] cpu_ptr1;
reg [`BUFFER_WIDTH - 1:0] router_ptr1;
reg [`BUFFER_WIDTH - 1:0] cpu_router_ptr1;

reg [7:0] router_write_dina;
reg [`BUFFER_ADDR_WIDTH - 1:0] router_write_addra;
reg [`BUFFER_ADDR_WIDTH - 1:0] router_write_addra_tmp;
reg router_write_wea;

reg internal_rx_ready_i;
assign internal_rx_ready = internal_rx_ready_i;

assign cpu_read_start = (cpu_router_ptr1 != cpu_ptr1) ? 1'b1 : 1'b0;
assign cpu_read_start_ptr = cpu_ptr1;

wire [7:0] dina;
wire [7:0] douta;
wire [7:0] dinb;
wire [7:0] doutb;

// Showing the state of router write.
always @ (posedge clk_router)
begin
  /*if (rst_router)
  begin
    router_write_state    <= START;
    router_ptr1        <= 0;
    router_write_dina     <= 0;
    router_write_addra     <= 0;
    router_write_wea       <= 0;
    internal_rx_ready_i   <= 1;
    router_write_addra_tmp <= 0;
  end
  else
  begin
    case (router_write_state)
    START:
    begin
      if (internal_rx_ready && internal_rx_valid)
      begin
        router_write_state <= ACCESS;
        router_write_dina <= internal_rx_data;
        router_write_wea   <= 1;
      end
      else
      begin
        router_write_state <= START;
        router_write_wea    <= 0;
      end
    end

    ACCESS:
    begin
      if (internal_rx_ready && internal_rx_valid)
      begin
        if (internal_rx_last)
        begin
          router_write_state    <= END1;
          router_write_dina     <= internal_rx_data;
          router_write_wea       <= 1;
          router_write_addra     <= router_write_addra + 1;
          router_write_addra_tmp <= router_write_addra + 1;
          internal_rx_ready_i   <= 0;
        end
        else
        begin
          router_write_state <= ACCESS;
          router_write_dina  <= internal_rx_data;
          router_write_addra  <= router_write_addra + 1;
          router_write_wea    <= 1;
        end
      end
      else
      begin
        router_write_state <= ACCESS;
        router_write_wea    <= 0;
      end
    end

    END1:
    begin
      router_write_state      <= END2;
      router_write_dina       <= router_write_addra_tmp[7:0];
      router_write_wea         <= 1;
      router_write_addra[10:0] <= 11'b11111111111;
      internal_rx_ready_i     <= 0;
    end

    END2:
    begin
      router_write_state      <= END3;
      router_write_dina       <= {5'b0, router_write_addra_tmp[10:8]};
      router_write_wea         <= 1;
      router_write_addra[10:0] <= 11'b11111111110;
      router_ptr1          <= router_ptr1 + 1;
      internal_rx_ready_i     <= 0;
    end

    END3:
    begin
      router_write_addra   <= router_ptr1 << 11;
      router_write_state  <= START;
      router_write_wea     <= 0;
      internal_rx_ready_i <= 1;
    end

    default:
    begind
      router_write_state <= START;
      router_write_wea    <= 0;
    end
    endcase
  end*/
  if (rst_router)
  begin
    router_write_dina  <= 0;
    router_write_addra <= 0;
    router_write_wea   <= 0;
  end
  else
  begin
    router_write_dina  <= router_write_dina + 1;
    router_write_addra <= router_write_addra + 1;
    router_write_wea   <= 1;
  end
end

always @ (posedge clk_cpu)
begin
  if (rst_cpu)
  begin
    cpu_ptr1 <= 0;
  end
  else
  begin
    if (cpu_read_end && (cpu_read_end_ptr == cpu_ptr1))
    begin
      cpu_ptr1 <= cpu_ptr1 + 1;
    end
    else
    begin
      cpu_ptr1 <= cpu_ptr1;
    end
  end
end

xpm_cdc_array_single #(
  .DEST_SYNC_FF(4),
  .INIT_SYNC_FF(0),
  .SIM_ASSERT_CHK(0),
  .SRC_INPUT_REG(1),
  .WIDTH(`BUFFER_WIDTH)
)
xpm_cdc_array_single_inst1 (
  .dest_out(cpu_router_ptr1),
  .dest_clk(clk_cpu),
  .src_clk(clk_router),
  .src_in(router_ptr1)
);

blk_mem_gen_3 router2CPU 
(
  .clka(clk_router),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(router_write_wea),      // input wire [0 : 0] wea
  .addra(router_write_addra),  // input wire [16 : 0] addra
  .dina(router_write_dina),    // input wire [7 : 0] dina
  .douta(douta),  // output wire [7 : 0] douta
  .clkb(clk_cpu),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .web(1'b0),      // input wire [0 : 0] web
  .addrb(cpu_read_addrb),  // input wire [16 : 0] addrb
  .dinb(dinb),    // input wire [7 : 0] dinb
  .doutb(cpu_read_doutb)   // output wire [7 : 0] doutb
);


// Above is all about BRAM 1, where CPU can read and Router can write. 
// ====================================================================
// Below is all about BRAM 2, where CPU can write and Router can read.

typedef enum reg[2:0] { START0, PREP1, PREP2, PREP3, ACCESS0, END4, END5 } router_read_state_t;
router_read_state_t router_read_state = START0;

reg [`BUFFER_WIDTH - 1:0] cpu_ptr2 = 0;
reg [`BUFFER_WIDTH - 1:0] router_ptr2 = 0;
reg [`BUFFER_WIDTH - 1:0] router_cpu_ptr2 = 0;

reg [7:0] router_read_douta;
reg[`BUFFER_ADDR_WIDTH - 1:0] router_read_addra;

reg [7:0] internal_tx_data_i;
reg internal_tx_last_i;
reg internal_tx_user_i;
reg internal_tx_valid_i;
assign internal_tx_data = internal_tx_data_i;
assign internal_tx_last = internal_tx_last_i;
assign internal_tx_user = internal_tx_user_i;
assign internal_tx_valid = internal_tx_valid_i;

wire router_read_start = (router_ptr2 != router_cpu_ptr2) ? 1'b1 : 1'b0;
reg[10:0] router_read_counter;

always @ (posedge clk_router)
begin
  if (rst_router)
  begin
    internal_tx_data_i  <= 0;
    internal_tx_valid_i <= 0;
    internal_tx_user_i  <= 0;
    internal_tx_last_i  <= 0;
    router_read_addra   <= 11'b11111111111;
    router_read_state   <= START0;
  end
  else if (!internal_tx_ready)
  begin
    internal_tx_data_i  <= 0;
    internal_tx_valid_i <= 1;
    internal_tx_last_i  <= 0;
  end
  else if (router_read_start)
  begin
    case (router_read_state)
    START0:
    begin
      internal_tx_data_i  <= 0;
      internal_tx_valid_i <= 0;
      internal_tx_last_i  <= 0;
      router_read_state   <= PREP1;
      router_read_addra   <= router_read_addra - 1;
    end
    PREP1:
    begin
      internal_tx_data_i       <= 0;
      internal_tx_valid_i      <= 0;
      internal_tx_last_i       <= 0;
      router_read_state        <= PREP2;
      router_read_counter[7:0] <= router_read_douta;
      router_read_addra[10:0]  <= 11'b0;
    end
    PREP2:
    begin
      internal_tx_data_i       <= 0;
      internal_tx_valid_i      <= 0;
      internal_tx_last_i       <= 0;
      router_read_state        <= PREP3;
      router_read_counter[7:0] <= router_read_douta;
      router_read_addra        <= router_read_addra + 1;
    end
    PREP3:
    begin
      internal_tx_data_i        <= 0;
      internal_tx_valid_i       <= 0;
      internal_tx_last_i        <= 0;
      router_read_state         <= ACCESS0;
      router_read_counter[10:8] <= router_read_douta[2:0];
      router_read_addra         <= router_read_addra + 1;
    end
    ACCESS0:
    begin
      if (router_read_counter == 1)
      begin
        internal_tx_valid_i <= 1;
        internal_tx_data_i  <= router_read_douta;
        router_read_state   <= END4;
      end
      else
      begin
        internal_tx_valid_i <= 1;
        router_read_state   <= ACCESS0;
        router_read_addra   <= router_read_addra + 1;
        internal_tx_data_i  <= router_read_douta;
        router_read_counter <= router_read_counter - 1;
      end
    end
    END4:
    begin
      internal_tx_valid_i <= 1;
      internal_tx_data_i  <= router_read_douta;
      router_read_state   <= END5;
    end
    END5:
    begin
      router_read_addra   <= (router_ptr2 << 11) + 12'b111111111111;
      internal_tx_valid_i <= 1;
      internal_tx_last_i  <= 1;
      internal_tx_data_i  <= router_read_douta;
      internal_tx_user_i  <= 0;
      router_read_state   <= START0;
      router_ptr2         <= router_ptr2 + 1;
    end
    endcase
  end
  else
  begin
    internal_tx_data_i  <= 0;
    internal_tx_valid_i <= 0;
    internal_tx_user_i  <= 0;
    internal_tx_last_i  <= 0;
    router_read_state   <= START0;
  end
end

always @ (posedge clk_cpu)
begin
  if (rst_cpu)
  begin
    cpu_ptr2 <= 0;
  end
  else
  begin
    if (cpu_write_end && (cpu_write_end_ptr == cpu_ptr2))
    begin
      cpu_ptr2 <= cpu_ptr2 + 1;
    end
    else
    begin
      cpu_ptr2 <= cpu_ptr2;
    end
  end
end

xpm_cdc_array_single #(
  .DEST_SYNC_FF(4),
  .INIT_SYNC_FF(0),
  .SIM_ASSERT_CHK(0),
  .SRC_INPUT_REG(1),
  .WIDTH(`BUFFER_WIDTH)
)
xpm_cdc_array_single_inst2 (
  .dest_out(router_cpu_ptr2),
  .dest_clk(clk_router),
  .src_clk(clk_cpu),
  .src_in(cpu_ptr2)
);

blk_mem_gen_3 CPU2router 
(
  .clka(clk_router),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(router_read_addra),  // input wire [16 : 0] addra
  .dina(dina),    // input wire [7 : 0] dina
  .douta(router_read_douta),  // output wire [7 : 0] douta
  .clkb(clk_cpu),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .web(cpu_write_web),      // input wire [0 : 0] web
  .addrb(cpu_write_addrb),  // input wire [16 : 0] addrb
  .dinb(cpu_write_dinb),    // input wire [7 : 0] dinb
  .doutb(doutb)   // output wire [7 : 0] doutb
);

endmodule
