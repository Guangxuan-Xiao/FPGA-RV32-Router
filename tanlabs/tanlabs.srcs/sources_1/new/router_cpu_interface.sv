`timescale 1ns/1ps
`include "frame_datapath.vh"

module router_cpu_interface(
    input wire clk_router,
    input wire clk_cpu,
    input wire rst,

    input wire [7:0] internal_rx_data,
    input wire internal_rx_last,
    input wire internal_rx_user,
    input wire internal_rx_valid, 
    input wire internal_rx_ready,

    output wire [7:0] internal_tx_data,
    output wire internal_tx_last,
    output wire internal_tx_user,
    output wire internal_tx_valid, 
    output wire internal_tx_ready,

    input wire cpu_write_enb, // CPU2Router的使能
    input wire [3:0] cpu_write_web, // CPU2Router的写使能
    input wire [15:0] cpu_write_addrb, // CPU2Router的写地址
    input wire [31:0] cpu_write_data, // CPU2Router写入的数据
    input wire cpu_write_done,        // CPU2Router写入完毕
    input wire [6:0] cpu_write_address, // 在写完的时候，表示这一帧是第几帧，从0开始
    input wire [10:0] frame_len, // 表示这一帧有多长，用bytes作为单位

    output wire cpu_start_enb, // 为1时，表示CPU当前可以进入读状态了
    output wire [6:0] cpu_start_addrb, // 我们的BRAM有128个2048bytes，我们的这个表示我们现在读到第几个2048bytes了，从0开始
    input wire cpu_read_enb, // CPU的读使能
    input wire [15:0] cpu_read_addrb, // CPU的读地址
    output wire [31:0] cpu_read_data, // CPU读到的数据
    input wire cpu_finish_enb, // 为1时，表示CPU读完了！！！
    input wire [6:0] cpu_finish_addrb // 在读完了之后，我们向这一字节写入当前读到的是第几帧，从0开始
);

typedef enum reg[1:0] { START, ACCESS, END } router_write_state_t;
router_write_state_t router_write_state = START;

reg [6:0] router_pointer = 7'b0;
reg [6:0] cpu_pointer = 7'b0;

reg [7:0] router_write_data;
reg [17:0] router_write_addr;
reg router_write_en;

// Showing the state of router write.
always @ (posedge clk_router)
begin
  if (rst)
  begin
    router_write_state <= START;
    router_pointer <= 0;
    router_write_data <= 0;
    router_write_addr <= 0;
    router_write_en <= 0;
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
          router_write_state <= END;
          router_write_data  <= internal_rx_data;
          router_write_en    <= 1;
          router_write_addr  <= router_write_addr + 1;
          router_pointer     <= router_pointer + 1;
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

    END:
    begin
      router_write_addr <= router_pointer << 11;
      if (internal_rx_ready && internal_rx_valid)
      begin
        router_write_state <= ACCESS;
        router_write_data  <= internal_rx_data;
        router_write_en    <= 1;
      end
      else
      begin
        router_write_state <= START;
        router_write_en    <= 0;
      end
    end  
    endcase
  end
end


always @ (posedge clk_cpu)
begin
  if (rst)
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

assign cpu_start_enb = (router_pointer != cpu_pointer) ? 1'b1 : 1'b0;

// A for router, B for CPU
blk_mem_gen_3 router2CPU 
(
  .clka(clk_router),    // input wire clka
  .ena(1),      // input wire ena
  .wea(router_write_en),      // input wire [0 : 0] wea
  .addra(router_write_addr),  // input wire [17 : 0] addra
  .dina(router_write_data),    // input wire [7 : 0] dina
  //.douta(douta),  // output wire [7 : 0] douta
  .clkb(clk_cpu),    // input wire clkb
  .enb(cpu_read_enb),      // input wire enb
  //.web(web),      // input wire [3 : 0] web
  .addrb(cpu_read_addrb),  // input wire [15 : 0] addrb
  //.dinb(dinb),    // input wire [31 : 0] dinb
  .doutb(cpu_read_data)   // output wire [31 : 0] doutb
);


// Above is all about BRAM 1, where CPU can read and Router can write. 
// ============================================================================================================
// Below is all about BRAM 2, where CPU can write and Router can read.

typedef enum reg[2:0] { START_O, PREP1, PREP2, PREP3, ACCESS_O, END_O } router_read_state_t;
router_read_state_t router_read_state = START_O;
reg [6:0] cpu_pointer_2;
reg [6:0] router_pointer_2;
reg [7:0] router_read_data;
reg [7:0] internal_tx_data_i;
reg internal_tx_last_i;
reg internal_tx_user_i;
reg internal_tx_valid_i;
reg internal_tx_ready_i;

assign internal_tx_data = internal_tx_data_i;
assign internal_tx_last = internal_tx_last_i;
assign internal_tx_user = internal_tx_user_i;
assign internal_tx_valid = internal_tx_valid_i;
assign internal_tx_ready = internal_tx_ready_i;

wire router_start_enb = (router_pointer_2 != cpu_pointer_2) ? 1'b1 : 1'b0;
reg[10:0] counter;
reg[17:0] router_read_addr;

always @ (posedge clk_router)
begin
  if (rst)
  begin
    internal_tx_data_i  <= 0;
    internal_tx_valid_i <= 0;
    internal_tx_ready_i <= 0;
    internal_tx_user_i  <= 0;
    internal_tx_last_i  <= 0;
    router_read_addr    <= 0;
    router_read_state   <= START_O;
  end
  else if (router_start_enb)
  begin
    case (router_read_state)
    START_O:
    begin
      internal_tx_data_i  <= 0;
      internal_tx_valid_i <= 0;
      internal_tx_ready_i <= 0;
      internal_tx_last_i  <= 0;
      router_read_state   <= PREP1;
    end
    PREP1:
    begin
      internal_tx_data_i  <= 0;
      internal_tx_valid_i <= 0;
      internal_tx_ready_i <= 0;
      internal_tx_last_i  <= 0;
      router_read_state   <= PREP2;
      counter[7:0]        <= router_read_data;
      router_read_addr    <= router_read_addr - 1;
    end
    PREP2:
    begin
      internal_tx_data_i     <= 0;
      internal_tx_valid_i    <= 0;
      internal_tx_ready_i    <= 0;
      internal_tx_last_i     <= 0;
      router_read_state      <= PREP3;
      counter[10:8]          <= router_read_data[2:0];
      router_read_addr[10:0] <= 11'b0;
    end
    PREP3:
    begin
      internal_tx_data_i  <= 0;
      internal_tx_valid_i <= 0;
      internal_tx_ready_i <= 0;
      internal_tx_last_i  <= 0;
      router_read_state   <= ACCESS_O;
      counter             <= counter - 1;
    end
    ACCESS_O:
    begin
      internal_tx_data_i  <= router_read_data;
      internal_tx_valid_i <= 1;
      internal_tx_ready_i <= 1;
      if (counter == 0)
      begin
        internal_tx_last_i <= 1;
        router_read_state  <= END_O;
        router_pointer_2   <= router_pointer_2 + 1;
      end
      else 
      begin
        internal_tx_last_i <= 0; 
        router_read_state  <= ACCESS_O;
        router_read_addr   <= router_read_addr + 1;
        counter            <= counter - 1;
      end
    end
    END_O:
    begin
      router_read_addr    <= router_pointer_2 << 11 + 11'b11111111111;
      internal_tx_data_i  <= 0;
      internal_tx_valid_i <= 0;
      internal_tx_ready_i <= 0;
      internal_tx_last_i  <= 0;
      internal_tx_user_i  <= 0;
      router_read_state   <= START_O;
    end
    endcase
  end
  else
  begin
    internal_tx_data_i  <= 0;
    internal_tx_valid_i <= 0;
    internal_tx_ready_i <= 0;
    internal_tx_user_i  <= 0;
    internal_tx_last_i  <= 0;
    router_read_state   <= START_O;
  end
end

always @ (posedge clk_cpu)
begin
  if (rst)
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
  .ena(1),      // input wire ena
  //.wea(wea),      // input wire [0 : 0] wea
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
