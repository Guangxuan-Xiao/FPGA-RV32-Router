`default_nettype none
`include "frame_datapath.vh"
module bus(input wire clk,
    input wire rst,
    inout wire[31:0] base_ram_data, // BaseRAM数据，低8位与CPLD串口控制器共享
    output reg[19:0] base_ram_addr, // BaseRAM地址
    output reg[3:0] base_ram_be_n,  // BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output reg base_ram_ce_n,       // BaseRAM片选，低有效
    output reg base_ram_oe_n,       // BaseRAM读使能，低有效
    output reg base_ram_we_n,       // BaseRAM写使能，低有效
    inout wire[31:0] ext_ram_data,  // ExtRAM数据
    output reg[19:0] ext_ram_addr,  // ExtRAM地址
    output reg[3:0] ext_ram_be_n,   // ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output reg ext_ram_ce_n,        // ExtRAM片选，低有效
    output reg ext_ram_oe_n,        // ExtRAM读使能，低有效
    output reg ext_ram_we_n,        // ExtRAM写使能，低有效
    input wire[31:0] ram_data_cpu,
    output reg[31:0] ram_data_ram,
    input wire[31:0] ram_addr_i,
    input wire[3:0] ram_be_i,
    input wire ram_we_i,
    input wire ram_oe_i,
    input wire ram_req,
    output wire ram_ready,
    input wire uart_dataready,      // 串口数据准备好
    input wire uart_tbre,           // 发送数据标志
    input wire uart_tsre,           // 数据发送完毕标志
    output reg uart_rdn,            // 读串口信号，低有效
    output reg uart_wrn,             // 写串口信号，低有效
    output reg [22:0]flash_a,      // Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout  wire [15:0]flash_d,      // Flash数据
    output reg flash_rp_n,         // Flash复位信号，低有效
    output reg flash_vpen,         // Flash写保护信号，低电平时不能擦除、烧写
    output reg flash_ce_n,         // Flash片选信号，低有效
    output reg flash_oe_n,         // Flash读使能信号，低有效
    output reg flash_we_n,         // Flash写使能信号，低有效
    output reg flash_byte_n,       // Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1
    output reg[3:0] trie_web[32:0],
    output reg [4:0] nexthop_web,
    output reg [TRIE_ADDR_WIDTH-1:0] node_addr[32:0],
    output trie_node_t node_data_cpu[32:0],
    input trie_node_t node_data_router[32:0],
    output reg [NEXTHOP_ADDR_WIDTH-1:0] nexthop_addr,
    output nexthop_t nexthop_data_cpu,
    input nexthop_t nexthop_data_router,
    output reg cpu_write_enb,
    output reg [3:0] cpu_write_web,
    output reg [15:0] cpu_write_addrb,
    output reg [31:0] cpu_write_data,
    output reg cpu_write_done,
    output reg [6:0] cpu_write_address,
    input wire cpu_start_enb,
    input wire [6:0] cpu_start_addrb,
    output reg cpu_read_enb,
    output reg [15:0] cpu_read_addrb,
    input wire [31:0] cpu_read_data,
    output reg cpu_finish_enb,
    output reg [6:0] cpu_finish_addrb,
    input wire [31:0] rubbish2333,
    output reg [43:0] mac_o,
    output reg [31:0] ip0_o,
    output reg [31:0] ip1_o,
    output reg [31:0] ip2_o,
    output reg [31:0] ip3_o
    );
    // | 0x80000000-0x800FFFFF | 监控程序代码 |
    // | 0x80100000-0x803FFFFF | 用户程序代码 |
    // | 0x80400000-0x807EFFFF | 用户程序数据 |
    // | 0x807F0000-0x807FFFFF | 监控程序数据 |
    // | 0x10000000-0x10000007 | 串口数据及状态 |
    // | 0x40000000-0x407FFFFF | Flash数据 |

    localparam BASE_ADDR_START = 32'h80000000;
    localparam BASE_ADDR_END = 32'h803FFFFF;
    localparam EXT_ADDR_START = 32'h80400000;
    localparam EXT_ADDR_END = 32'h807FFFFF;
    localparam UART_DATA_ADDRESS = 32'h10000000;
    localparam UART_CTRL_ADDRESS = 32'h10000005;
    localparam FLASH_ADDR_START = 32'h40000000;
    localparam FLASH_ADDR_END = 32'h407FFFFF;
    
    // Trie BRAM Address
    // | 0x20000000-0x20007FFF | layer 0 |
    // | 0x20008000-0x2000FFFF | layer 1 |
    // | 0x20010000-0x20017FFF | layer 2 |
    // | 0x20018000-0x2001FFFF | layer 3 |
    // ...
    // | 0x20100000-0x20107FFF | layer 32 |
    localparam TRIE_ADDR_START = 32'h20000000;
    localparam TRIE_ADDR_END   = 32'h20107FFF;

    // Nexthop BRAM Address
    // | 0x20200000-0x202001FF | Next-hop BRAM Data |
    // 第2位地址（Addr[2]）为0（第偶数个字）表示IP地址
    // 第2位地址（Addr[2]）为1（第奇数个字）表示Port（低对齐）。
    // 第3-8位地址（n = Addr[8:3]）表示第n个IP地址或Port。
    // E.g.1
    // | 0x20200000-0x20200003 | IP[0] |
    // | 0x20200004-0x20200007 | {24'b0, port[0]} |
    // E.g.2
    // | 0x20200018-0x2020001B | IP[3] |
    // | 0x2020001C-0x2020001F | {24'b0, port[3]} |

    localparam NEXTHOP_ADDR_START = 32'h20200000;
    localparam NEXTHOP_ADDR_END   = 32'h202001FF;

    // Interface BRAM Serial Port
    // | 0x60000000-0x6003FFFF | CPU Read BRAM Data |
    // | 0x60000000-0x600007FF | CPU Read buffer 0 |
    // | 0x600007FE-0x600007FF | CPU Read buffer 0 length |
    // | 0x60000800-0x60000FFF | CPU Read buffer 1 |
    // ...
    // | 0x6003F800-0x6003FFFF | CPU Read buffer 127 |
    // ============================================= //
    // | 0x60040000-0x6007FFFF | CPU Write BRAM Data |
    // | 0x60040000-0x600407FF | CPU Write buffer 0 |
    // | 0x60040800-0x60040FFF | CPU Write buffer 1 |
    // ...
    // | 0x6007F800-0x6007FFFF | CPU Write buffer 127 |

    localparam BUFFER_READ_START  = 32'h60000000;
    localparam BUFFER_READ_END    = 32'h6003FFFF;
    localparam BUFFER_WRITE_START = 32'h60040000;
    localparam BUFFER_WRITE_END   = 32'h6007FFFF;

    // Interface BRAM Address
    // | 0x70000000-0x70000020 | Buffer 串口数据及状态 |

    localparam BUFFER_START_READ = 32'h70000000;
    localparam BUFFER_END_READ   = 32'h70000010;
    localparam BUFFER_END_WRITE  = 32'h70000020;
    localparam BUFFER_RUBBISH    = 32'h70000030;

    localparam CLOCK_ADDR = 32'h10000010;
    localparam IP0_ADDR = 32'h10000100;
    localparam IP1_ADDR = 32'h10000110;
    localparam IP2_ADDR = 32'h10000120;
    localparam IP3_ADDR = 32'h10000130;
    localparam MAC_ADDR = 32'h10000200;

    reg[31:0] counter;
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
    
    wire base_ram_req   = ram_req && (ram_addr_i >= BASE_ADDR_START) && (ram_addr_i <= BASE_ADDR_END);
    wire ext_ram_req    = ram_req && (ram_addr_i >= EXT_ADDR_START) && (ram_addr_i <= EXT_ADDR_END);
    wire uart_state_req = ram_req && ram_addr_i == UART_CTRL_ADDRESS;
    wire uart_data_req  = ram_req && ram_addr_i == UART_DATA_ADDRESS;
    wire clock_req  = ram_req && ram_addr_i == CLOCK_ADDR;
    wire sram_req = base_ram_req || ext_ram_req || uart_state_req || uart_data_req;
    wire flash_req = ram_req && ram_addr_i >= FLASH_ADDR_START && ram_addr_i <= FLASH_ADDR_END;
    wire ip0_req  = ram_req && ram_addr_i == IP0_ADDR;
    wire ip1_req  = ram_req && ram_addr_i == IP1_ADDR;
    wire ip2_req  = ram_req && ram_addr_i == IP2_ADDR;
    wire ip3_req  = ram_req && ram_addr_i == IP3_ADDR;
    wire mac_req  = ram_req && ram_addr_i == MAC_ADDR;

    reg[31:0] base_ram_data_reg, ext_ram_data_reg, ram_data_reg;
    wire[19:0] sram_phy_addr = ram_addr_i[21:2];
    wire[31:0] base_ram_data_o, ext_ram_data_o;

    reg[15:0] flash_data_reg;
    wire[22:0] flash_phy_addr = {ram_addr_i[22:1], 1'b0};
    wire[31:0] flash_data_o;
    
    reg[31:0] uart_status1, uart_status2;
    
    wire trie_req = ram_req && (ram_addr_i >= TRIE_ADDR_START) && (ram_addr_i <= TRIE_ADDR_END);
    wire[5:0] trie_layer_req = ram_addr_i[TRIE_ADDR_WIDTH+7:TRIE_ADDR_WIDTH+2];
    trie_node_t trie_data_reg;
    wire [TRIE_ADDR_WIDTH-1:0] trie_phy_addr = ram_addr_i[TRIE_ADDR_WIDTH+1:2];

    wire nexthop_req = ram_req && (ram_addr_i >= NEXTHOP_ADDR_START) && (ram_addr_i <= NEXTHOP_ADDR_END);
    wire nexthop_ip_req = nexthop_req && (~ram_addr_i[2]);
    wire nexthop_port_req = nexthop_req && ram_addr_i[2];
    wire [NEXTHOP_ADDR_WIDTH-1:0] nexthop_phy_addr = ram_addr_i[NEXTHOP_ADDR_WIDTH+2:3];
    nexthop_t nexthop_data_reg;

    wire buffer_read  = ram_req && (ram_addr_i >= BUFFER_READ_START) && (ram_addr_i <= BUFFER_READ_END);
    wire buffer_write = ram_req && (ram_addr_i >= BUFFER_WRITE_START) && (ram_addr_i <= BUFFER_WRITE_END);
    wire buffer_addr  = ram_addr_i[17:2];

    wire read_start = ram_req && (ram_addr_i == BUFFER_START_READ);
    wire read_end   = ram_req && (ram_addr_i == BUFFER_END_READ);
    wire write_end  = ram_req && (ram_addr_i == BUFFER_END_WRITE);
    wire rubbish    = ram_req && (ram_addr_i == BUFFER_RUBBISH);
    wire buffer_req = buffer_read || buffer_write || read_start || read_end || write_end || rubbish;

    // set base ram data not zzz only on writing it.
    assign base_ram_data = (base_ram_req || uart_data_req) && ram_we_i ? base_ram_data_reg : 32'bz;
    assign base_ram_data_o = base_ram_data;
    assign ext_ram_data = (ext_ram_req && ram_we_i) ? ext_ram_data_reg : 32'hz;
    assign ext_ram_data_o = ext_ram_data;
    assign flash_d = (flash_req && ram_we_i) ? flash_data_reg : 16'hz;
    
    always_comb begin
        node_data_cpu = '{default:32'hz};
        node_data_cpu[trie_layer_req] = trie_data_reg;
    end

    assign nexthop_data_cpu = nexthop_data_reg;

    // SRAM State Machine
    typedef enum reg[1:0] { START, ACCESS, END } sram_state_t;
    sram_state_t sram_state;
    reg sram_we;
    wire sram_ready = ram_req & sram_state == END;
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst || !sram_req) begin
            sram_state <= START;
            sram_we  <= 0;
        end
        else begin
            case (sram_state)
                START:
                sram_state <= ACCESS;
                ACCESS:
                sram_state <= END;
                END:
                sram_state <= START;
            endcase
            sram_we  <= ram_we_i & sram_state == START;
        end
    end

    wire buffer_ready = ram_req & buffer_state == END;
    sram_state_t buffer_state;
    always_ff @(posedge clk, posedge rst) begin
        if (rst || !buffer_req) begin
            buffer_state <= START;
        end
        else begin
            case (buffer_state)
                START:
                buffer_state <= ACCESS;
                ACCESS:
                buffer_state <= END;
                END:
                buffer_state <= START;
            endcase
        end
    end

    // Flash State Machine
    reg[1:0] flash_state;
    reg flash_we;
    wire flash_ready = flash_req & flash_state == 2'b11;
    
    always_ff @(posedge clk, posedge rst) begin
        flash_we  <= 0;
        if (rst || !flash_req) begin
            flash_state <= 0;
        end
        else begin
            flash_state <= flash_state + 1;
        end
    end

    assign ram_data_ram = ram_data_reg;
    assign ram_ready = sram_ready | flash_ready | trie_req | nexthop_req | clock_req | buffer_ready | ip0_req | ip1_req | ip2_req | ip3_req | mac_req;

    // CPU Reading RAM control
    always_comb begin
        if (base_ram_req) begin
            ram_data_reg = base_ram_data;
        end else if (uart_data_req) begin
            ram_data_reg = base_ram_data;
        end else if (ext_ram_req) begin
            ram_data_reg = ext_ram_data_o;
        end else if (uart_state_req) begin
            ram_data_reg = uart_status2;
        end else if (clock_req) begin
            ram_data_reg = counter;
        end else if (mac_req) begin
            ram_data_reg = mac_o[31:0];
        end else if (ip0_req) begin
            ram_data_reg = ip0_o;
        end else if (ip1_req) begin
            ram_data_reg = ip1_o;
        end else if (ip2_req) begin
            ram_data_reg = ip2_o;
        end else if (ip3_req) begin
            ram_data_reg = ip3_o;
        end else if (flash_req) begin
            ram_data_reg = {16'b0, flash_d};
        end else if (trie_req) begin
            ram_data_reg = node_data_router[trie_layer_req];
        end else if (nexthop_port_req) begin
            ram_data_reg = {24'b0, nexthop_data_router.port};
        end else if (nexthop_ip_req) begin
            ram_data_reg = nexthop_data_router.ip;
        end else if (buffer_read) begin
            ram_data_reg = cpu_read_data;
        end else if (read_start) begin
            ram_data_reg = {24'b0, cpu_start_enb, cpu_start_addrb};
        end else if (rubbish) begin
            ram_data_reg = rubbish2333;
        end
        end else begin
            ram_data_reg = 32'b0;
        end
    end

    // UART status stablizer
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            uart_status1 <= 32'b0;
            uart_status2 <= 32'b0;
        end
        else begin 
            uart_status1 <= {18'b0, uart_tsre & uart_tbre, 4'b0, uart_dataready, 8'b0};
            uart_status2 <= uart_status1;
        end
    end

    // uart control
    always_comb begin
        if (uart_data_req) begin
            uart_wrn = !sram_we;
            uart_rdn = ram_we_i;
        end
        else begin
            uart_rdn = 1;
            uart_wrn = 1;
        end
    end
    
    // Base ram writing control
    always_comb begin 
        base_ram_data_reg = ram_data_cpu;
        base_ram_ce_n = 1'b0;
        base_ram_addr = sram_phy_addr;
        if (base_ram_req || uart_data_req) begin
            base_ram_be_n = ~ram_be_i; 
            if (base_ram_req) begin
                base_ram_we_n = !sram_we;
                base_ram_oe_n = ram_we_i; 
            end else begin 
                // uart
                base_ram_we_n = 1;
                base_ram_oe_n = 1;
            end
        end else begin
            base_ram_we_n = 1'b1;
            base_ram_oe_n = 1'b1;
            base_ram_be_n = 4'b0000;
        end
    end
    
    // Ext RAM writing control
    always_comb begin
        ext_ram_addr = sram_phy_addr;
        ext_ram_data_reg = ram_data_cpu;
        ext_ram_ce_n = 1'b0;
        if (ext_ram_req) begin
            ext_ram_we_n = !sram_we; 
            ext_ram_oe_n = ram_we_i;
            ext_ram_be_n = ~ram_be_i;
        end
        else begin
            ext_ram_be_n = 4'b0000;
            ext_ram_we_n = 1'b1;
            ext_ram_oe_n = 1'b1;
        end
    end

    // Flash writing control
    always_comb begin
        flash_a = flash_phy_addr;
        flash_data_reg = ram_data_cpu[15:0];
        flash_ce_n = 1'b0;
        flash_rp_n = 1'b1;
        flash_byte_n = 1'b1;
        flash_vpen = 1'b1;
        if (flash_req) begin
            flash_oe_n = ram_we_i;
            flash_we_n = !flash_we;
        end
        else begin
            flash_oe_n = 1'b1;
            flash_we_n = 1'b1;
        end
    end

    // Trie writing control
    always_comb begin
        node_addr = '{default: 0};
        node_addr[trie_layer_req] = trie_phy_addr;
        trie_data_reg = ram_data_cpu;
        trie_web = '{default: 0};
        if (trie_req & ram_we_i) begin
            trie_web[trie_layer_req] = ram_be_i;
        end
    end

    // Next-hop writing control
    always_comb begin
        nexthop_addr = nexthop_phy_addr;
        nexthop_data_reg = 0;
        nexthop_web = 0;
        if (nexthop_ip_req & ram_we_i) begin
            nexthop_web = 5'b01111 & {1'b0, ram_be_i};
            nexthop_data_reg.ip = ram_data_cpu;
        end else if (nexthop_port_req & ram_we_i) begin
            nexthop_data_reg.port = ram_data_cpu[7:0];
            nexthop_web = 5'b10000;
        end
    end

    // Buffer writing control
    always_comb begin
        cpu_write_enb   = 0;
        cpu_write_web   = 0;
        cpu_write_addrb = buffer_addr;
        cpu_write_data  = 0;
        cpu_read_enb    = 1;
        cpu_read_addrb  = buffer_addr;
        if (buffer_write & ram_we_i) begin
            cpu_write_enb  = 1'b1;
            cpu_write_web  = ram_be_i;
            cpu_write_data = ram_data_cpu;
        end
    end

    // Buffer Serial Port writing control
    always_comb begin
        cpu_write_done    = 0;
        cpu_write_address = 0;
        cpu_finish_enb    = 0;
        cpu_finish_addrb  = 0;
        if (write_end & ram_we_i) begin
            cpu_write_done    = ram_data_cpu[7];
            cpu_write_address = ram_data_cpu[6:0];
        end else if (read_end & ram_we_i) begin
            cpu_finish_enb   = ram_data_cpu[7];
            cpu_finish_addrb = ram_data_cpu[6:0];
        end
    end

    // IP and MAC management
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            mac_o <= 44'h10aaaaaaaaa;
            ip0_o <= 32'h0100000a;
            ip1_o <= 32'h0101000a;
            ip2_o <= 32'h0102000a;
            ip3_o <= 32'h0103000a;
        end else if (ip0_req & ram_we_i) begin
            ip0_o <= ram_data_cpu;
        end else if (ip1_req & ram_we_i) begin
            ip1_o <= ram_data_cpu;
        end else if (ip2_req & ram_we_i) begin
            ip2_o <= ram_data_cpu;
        end else if (ip3_req & ram_we_i) begin
            ip3_o <= ram_data_cpu;
        end else if (mac_req & ram_we_i) begin
            mac_o[31:0] <= ram_data_cpu;
        end
    end
endmodule
