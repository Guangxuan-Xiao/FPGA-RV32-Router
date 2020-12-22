`timescale 1ns / 1ps

/* Tsinghua Advanced Networking Labs */

module tanlabs
#(
    parameter SIM = 0
)
(
    input RST,

    input wire gtrefclk_p,
    input wire gtrefclk_n,

    output wire [15:0] led,

    // SFP:
    // +-+-+
    // |0|2|
    // +-+-+
    // |1|3|
    // +-+-+
    input wire [3:0] sfp_rx_los,
    input wire [3:0] sfp_rx_p,
    input wire [3:0] sfp_rx_n,
    output wire [3:0] sfp_tx_disable,
    output wire [3:0] sfp_tx_p,
    output wire [3:0] sfp_tx_n,
    output wire [7:0] sfp_led,  // 0 1  2 3  4 5  6 7

    input wire clk_50M,              //50MHz 时钟输入
    input wire clk_11M0592,          //11.0592MHz 时钟输入（备用，可不用）
    input wire clock_btn,            //BTN5手动时钟按钮�?关，带消抖电路，按下时为1
    input wire reset_btn,            //BTN6手动复位按钮�?关，带消抖电路，按下时为1
    input wire[3:0] touch_btn,       //BTN1~BTN4，按钮开关，按下时为1
    input wire[15:0] dip_sw,         //16位拨码开关，拨到“ON”时�?1
    output wire[7:0] dpy0,           //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0] dpy1,           //数码管高位信号，包括小数点，输出1点亮
    output wire uart_rdn,            //读串口信号，低有�?
    output wire uart_wrn,            //写串口信号，低有�?
    input wire uart_dataready,       //串口数据准备�?
    input wire uart_tbre,            //发�?�数据标�?
    input wire uart_tsre,            //数据发�?�完毕标�?
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共�?
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持�?0
    output wire base_ram_ce_n,       //BaseRAM片�?�，低有�?
    output wire base_ram_oe_n,       //BaseRAM读使能，低有�?
    output wire base_ram_we_n,       //BaseRAM写使能，低有�?
    inout wire[31:0] ext_ram_data,   //ExtRAM数据
    output wire[19:0] ext_ram_addr,  //ExtRAM地址
    output wire[3:0] ext_ram_be_n,   //ExtRAM字节使能，低有效。如果不使用字节使能，请保持�?0
    output wire ext_ram_ce_n,        //ExtRAM片�?�，低有�?
    output wire ext_ram_oe_n,        //ExtRAM读使能，低有�?
    output wire ext_ram_we_n,        //ExtRAM写使能，低有�?
    output wire [22:0]flash_a,       //Flash地址，a0仅在8bit模式有效�?16bit模式无意�?
    inout wire [15:0]flash_d,        //Flash数据
    output wire flash_rp_n,          //Flash复位信号，低有效
    output wire flash_vpen,          //Flash写保护信号，低电平时不能擦除、烧�?
    output wire flash_ce_n,          //Flash片�?�信号，低有�?
    output wire flash_oe_n,          //Flash读使能信号，低有�?
    output wire flash_we_n,          //Flash写使能信号，低有�?
    output wire flash_byte_n         //Flash 8bit模式选择，低有效。在使用flash�?16位模式时请设�?1
);

    localparam DATA_WIDTH = 64;
    localparam ID_WIDTH = 3;

    wire [4:0] debug_ingress_interconnect_ready;
    wire debug_datapath_fifo_ready;
    wire debug_egress_interconnect_ready;

    wire reset_in = RST;
    wire locked;
    wire gtref_clk;  // 125MHz for the PHY/MAC IP core
    wire ref_clk;  // 200MHz for the PHY/MAC IP core
    wire core_clk;  // README: This is for CPU and other components. You can change the frequency
    // by re-customizing the following IP core.

    clk_wiz_0 clk_wiz_0_i(
        .ref_clk_out(ref_clk),
        .core_clk_out(core_clk),
        .reset(1'b0),
        .locked(locked),
        .clk_in1(gtref_clk)
    );

    wire reset_not_sync = reset_in || !locked;  // reset components

    wire mmcm_locked_out;
    wire rxuserclk_out;
    wire rxuserclk2_out;
    wire userclk_out;
    wire userclk2_out;
    wire pma_reset_out;
    wire gt0_pll0outclk_out;
    wire gt0_pll0outrefclk_out;
    wire gt0_pll1outclk_out;
    wire gt0_pll1outrefclk_out;
    wire gt0_pll0lock_out;
    wire gt0_pll0refclklost_out;
    wire gtref_clk_out;
    wire gtref_clk_buf_out;

    assign gtref_clk = gtref_clk_buf_out;
    wire eth_clk = userclk2_out;  // README: This is the main clock for frame processing logic,
    // 125MHz generated by the PHY/MAC IP core. 8 AXI-Streams are in this clock domain.

    wire reset_eth_not_sync = reset_in || !mmcm_locked_out;
    wire reset_eth;
    reset_sync reset_sync_reset_eth(
        .clk(eth_clk),
        .i(reset_eth_not_sync),
        .o(reset_eth)
    );

    wire [7:0] eth_tx8_data [0:4];
    wire eth_tx8_last [0:4];
    wire eth_tx8_ready [0:4];
    wire eth_tx8_user [0:4];
    wire eth_tx8_valid [0:4];

    wire [7:0] eth_rx8_data [0:4];
    wire eth_rx8_last [0:4];
    wire eth_rx8_user [0:4];
    wire eth_rx8_valid [0:4];

    genvar i;
    generate
        if (!SIM)
        begin : phy_mac_ip_cores
            // Instantiate 4 PHY/MAC IP cores.

            assign sfp_tx_disable[0] = 1'b0;
            axi_ethernet_0 axi_ethernet_0_i(
                .mac_irq(),
                .tx_mac_aclk(),
                .rx_mac_aclk(),
                .tx_reset(),
                .rx_reset(),

                .glbl_rst(reset_not_sync),

                .mmcm_locked_out(mmcm_locked_out),
                .rxuserclk_out(rxuserclk_out),
                .rxuserclk2_out(rxuserclk2_out),
                .userclk_out(userclk_out),
                .userclk2_out(userclk2_out),
                .pma_reset_out(pma_reset_out),
                .gt0_pll0outclk_out(gt0_pll0outclk_out),
                .gt0_pll0outrefclk_out(gt0_pll0outrefclk_out),
                .gt0_pll1outclk_out(gt0_pll1outclk_out),
                .gt0_pll1outrefclk_out(gt0_pll1outrefclk_out),
                .gt0_pll0lock_out(gt0_pll0lock_out),
                .gt0_pll0refclklost_out(gt0_pll0refclklost_out),
                .gtref_clk_out(gtref_clk_out),
                .gtref_clk_buf_out(gtref_clk_buf_out),

                .ref_clk(ref_clk),

                .s_axi_lite_resetn(~reset_eth),
                .s_axi_lite_clk(eth_clk),
                .s_axi_araddr(0),
                .s_axi_arready(),
                .s_axi_arvalid(0),
                .s_axi_awaddr(0),
                .s_axi_awready(),
                .s_axi_awvalid(0),
                .s_axi_bready(0),
                .s_axi_bresp(),
                .s_axi_bvalid(),
                .s_axi_rdata(),
                .s_axi_rready(0),
                .s_axi_rresp(),
                .s_axi_rvalid(),
                .s_axi_wdata(0),
                .s_axi_wready(),
                .s_axi_wvalid(0),

                .s_axis_tx_tdata(eth_tx8_data[0]),
                .s_axis_tx_tlast(eth_tx8_last[0]),
                .s_axis_tx_tready(eth_tx8_ready[0]),
                .s_axis_tx_tuser(eth_tx8_user[0]),
                .s_axis_tx_tvalid(eth_tx8_valid[0]),

                .m_axis_rx_tdata(eth_rx8_data[0]),
                .m_axis_rx_tlast(eth_rx8_last[0]),
                .m_axis_rx_tuser(eth_rx8_user[0]),
                .m_axis_rx_tvalid(eth_rx8_valid[0]),

                .s_axis_pause_tdata(0),
                .s_axis_pause_tvalid(0),

                .rx_statistics_statistics_data(),
                .rx_statistics_statistics_valid(),
                .tx_statistics_statistics_data(),
                .tx_statistics_statistics_valid(),

                .tx_ifg_delay(8'h00),
                .status_vector(),
                .signal_detect(~sfp_rx_los[0]),

                .sfp_rxn(sfp_rx_n[0]),
                .sfp_rxp(sfp_rx_p[0]),
                .sfp_txn(sfp_tx_n[0]),
                .sfp_txp(sfp_tx_p[0]),

                .mgt_clk_clk_n(gtrefclk_n),
                .mgt_clk_clk_p(gtrefclk_p)
            );

            for (i = 1; i < 4; i = i + 1)
            begin
                assign sfp_tx_disable[i] = 1'b0;
                axi_ethernet_noshared axi_ethernet_noshared_i(
                    .mac_irq(),
                    .tx_mac_aclk(),
                    .rx_mac_aclk(),
                    .tx_reset(),
                    .rx_reset(),

                    .glbl_rst(reset_not_sync),

                    .mmcm_locked(mmcm_locked_out),
                    .mmcm_reset_out(),
                    .rxuserclk(rxuserclk_out),
                    .rxuserclk2(rxuserclk2_out),
                    .userclk(userclk_out),
                    .userclk2(userclk2_out),
                    .pma_reset(pma_reset_out),
                    .rxoutclk(),
                    .txoutclk(),
                    .gt0_pll0outclk_in(gt0_pll0outclk_out),
                    .gt0_pll0outrefclk_in(gt0_pll0outrefclk_out),
                    .gt0_pll1outclk_in(gt0_pll1outclk_out),
                    .gt0_pll1outrefclk_in(gt0_pll1outrefclk_out),
                    .gt0_pll0lock_in(gt0_pll0lock_out),
                    .gt0_pll0refclklost_in(gt0_pll0refclklost_out),
                    .gt0_pll0reset_out(),
                    .gtref_clk(gtref_clk_out),
                    .gtref_clk_buf(gtref_clk_buf_out),

                    .ref_clk(ref_clk),

                    .s_axi_lite_resetn(~reset_eth),
                    .s_axi_lite_clk(eth_clk),
                    .s_axi_araddr(0),
                    .s_axi_arready(),
                    .s_axi_arvalid(0),
                    .s_axi_awaddr(0),
                    .s_axi_awready(),
                    .s_axi_awvalid(0),
                    .s_axi_bready(0),
                    .s_axi_bresp(),
                    .s_axi_bvalid(),
                    .s_axi_rdata(),
                    .s_axi_rready(0),
                    .s_axi_rresp(),
                    .s_axi_rvalid(),
                    .s_axi_wdata(0),
                    .s_axi_wready(),
                    .s_axi_wvalid(0),

                    .s_axis_tx_tdata(eth_tx8_data[i]),
                    .s_axis_tx_tlast(eth_tx8_last[i]),
                    .s_axis_tx_tready(eth_tx8_ready[i]),
                    .s_axis_tx_tuser(eth_tx8_user[i]),
                    .s_axis_tx_tvalid(eth_tx8_valid[i]),

                    .m_axis_rx_tdata(eth_rx8_data[i]),
                    .m_axis_rx_tlast(eth_rx8_last[i]),
                    .m_axis_rx_tuser(eth_rx8_user[i]),
                    .m_axis_rx_tvalid(eth_rx8_valid[i]),

                    .s_axis_pause_tdata(0),
                    .s_axis_pause_tvalid(0),

                    .rx_statistics_statistics_data(),
                    .rx_statistics_statistics_valid(),
                    .tx_statistics_statistics_data(),
                    .tx_statistics_statistics_valid(),

                    .tx_ifg_delay(8'h00),
                    .status_vector(),
                    .signal_detect(~sfp_rx_los[i]),

                    .sfp_rxn(sfp_rx_n[i]),
                    .sfp_rxp(sfp_rx_p[i]),
                    .sfp_txn(sfp_tx_n[i]),
                    .sfp_txp(sfp_tx_p[i])
                );
            end
        end
        else
        begin : axis_models
            // For simulation.
            assign gtref_clk_buf_out = gtrefclk_p;
            assign userclk2_out = gtrefclk_p;
            assign mmcm_locked_out = 1'b1;

            assign sfp_tx_disable = 0;
            assign sfp_tx_p = 0;
            assign sfp_tx_n = 0;

            wire [DATA_WIDTH - 1:0] in_data;
            wire [DATA_WIDTH / 8 - 1:0] in_keep;
            wire in_last;
            wire [DATA_WIDTH / 8 - 1:0] in_user;
            wire [ID_WIDTH - 1:0] in_id;
            wire in_valid;
            wire in_ready;

            axis_model axis_model_i(
                .clk(eth_clk),
                .reset(reset_eth),

                .m_data(in_data),
                .m_keep(in_keep),
                .m_last(in_last),
                .m_user(in_user),
                .m_id(in_id),
                .m_valid(in_valid),
                .m_ready(in_ready)
            );

            wire [DATA_WIDTH - 1:0] sim_tx_data [0:3];
            wire [DATA_WIDTH / 8 - 1:0] sim_tx_keep [0:3];
            wire sim_tx_last [0:3];
            wire sim_tx_ready [0:3];
            wire [DATA_WIDTH / 8 - 1:0] sim_tx_user [0:3];
            wire sim_tx_valid [0:3];

            axis_interconnect_egress axis_interconnect_sim_in_i(
                .ACLK(eth_clk),
                .ARESETN(~reset_eth),

                .S00_AXIS_ACLK(eth_clk),
                .S00_AXIS_ARESETN(~reset_eth),
                .S00_AXIS_TVALID(in_valid),
                .S00_AXIS_TREADY(in_ready),
                .S00_AXIS_TDATA(in_data),
                .S00_AXIS_TKEEP(in_keep),
                .S00_AXIS_TLAST(in_last),
                .S00_AXIS_TDEST(in_id),
                .S00_AXIS_TUSER(in_user),

                .M00_AXIS_ACLK(eth_clk),
                .M00_AXIS_ARESETN(~reset_eth),
                .M00_AXIS_TVALID(sim_tx_valid[0]),
                .M00_AXIS_TREADY(sim_tx_ready[0]),
                .M00_AXIS_TDATA(sim_tx_data[0]),
                .M00_AXIS_TKEEP(sim_tx_keep[0]),
                .M00_AXIS_TLAST(sim_tx_last[0]),
                .M00_AXIS_TDEST(),
                .M00_AXIS_TUSER(sim_tx_user[0]),

                .M01_AXIS_ACLK(eth_clk),
                .M01_AXIS_ARESETN(~reset_eth),
                .M01_AXIS_TVALID(sim_tx_valid[1]),
                .M01_AXIS_TREADY(sim_tx_ready[1]),
                .M01_AXIS_TDATA(sim_tx_data[1]),
                .M01_AXIS_TKEEP(sim_tx_keep[1]),
                .M01_AXIS_TLAST(sim_tx_last[1]),
                .M01_AXIS_TDEST(),
                .M01_AXIS_TUSER(sim_tx_user[1]),

                .M02_AXIS_ACLK(eth_clk),
                .M02_AXIS_ARESETN(~reset_eth),
                .M02_AXIS_TVALID(sim_tx_valid[2]),
                .M02_AXIS_TREADY(sim_tx_ready[2]),
                .M02_AXIS_TDATA(sim_tx_data[2]),
                .M02_AXIS_TKEEP(sim_tx_keep[2]),
                .M02_AXIS_TLAST(sim_tx_last[2]),
                .M02_AXIS_TDEST(),
                .M02_AXIS_TUSER(sim_tx_user[2]),

                .M03_AXIS_ACLK(eth_clk),
                .M03_AXIS_ARESETN(~reset_eth),
                .M03_AXIS_TVALID(sim_tx_valid[3]),
                .M03_AXIS_TREADY(sim_tx_ready[3]),
                .M03_AXIS_TDATA(sim_tx_data[3]),
                .M03_AXIS_TKEEP(sim_tx_keep[3]),
                .M03_AXIS_TLAST(sim_tx_last[3]),
                .M03_AXIS_TDEST(),
                .M03_AXIS_TUSER(sim_tx_user[3]),

                .M04_AXIS_ACLK(eth_clk),
                .M04_AXIS_ARESETN(~reset_eth),
                .M04_AXIS_TVALID(),
                .M04_AXIS_TREADY(1'b1),
                .M04_AXIS_TDATA(),
                .M04_AXIS_TKEEP(),
                .M04_AXIS_TLAST(),
                .M04_AXIS_TDEST(),
                .M04_AXIS_TUSER(),

                .S00_DECODE_ERR()
            );

            for (i = 0; i < 4; i = i + 1)
            begin
                axis_dwidth_converter_64_8 axis_dwidth_converter_64_8_i(
                    .aclk(eth_clk),
                    .aresetn(~reset),

                    .s_axis_tvalid(sim_tx_valid[i]),
                    .s_axis_tready(sim_tx_ready[i]),
                    .s_axis_tdata(sim_tx_data[i]),
                    .s_axis_tkeep(sim_tx_keep[i]),
                    .s_axis_tlast(sim_tx_last[i]),
                    .s_axis_tuser(sim_tx_user[i]),

                    .m_axis_tvalid(eth_rx8_valid[i]),
                    .m_axis_tready(debug_ingress_interconnect_ready[i]),  // FIXME
                    .m_axis_tdata(eth_rx8_data[i]),
                    .m_axis_tkeep(),
                    .m_axis_tlast(eth_rx8_last[i]),
                    .m_axis_tuser(eth_rx8_user[i])
                );
            end

            wire [DATA_WIDTH - 1:0] out_data;
            wire [DATA_WIDTH / 8 - 1:0] out_keep;
            wire out_last;
            wire [DATA_WIDTH / 8 - 1:0] out_user;
            wire [ID_WIDTH - 1:0] out_dest;
            wire out_valid;
            wire out_ready;

            axis_interconnect_ingress axis_interconnect_sim_out_i(
                .ACLK(eth_clk),
                .ARESETN(~reset_eth),

                .S00_AXIS_ACLK(eth_clk),
                .S00_AXIS_ARESETN(~reset_eth),
                .S00_AXIS_TVALID(eth_tx8_valid[0]),
                .S00_AXIS_TREADY(eth_tx8_ready[0]),
                .S00_AXIS_TDATA(eth_tx8_data[0]),
                .S00_AXIS_TKEEP(1'b1),
                .S00_AXIS_TLAST(eth_tx8_last[0]),
                .S00_AXIS_TID(3'd0),
                .S00_AXIS_TUSER(eth_tx8_user[0]),

                .S01_AXIS_ACLK(eth_clk),
                .S01_AXIS_ARESETN(~reset_eth),
                .S01_AXIS_TVALID(eth_tx8_valid[1]),
                .S01_AXIS_TREADY(eth_tx8_ready[1]),
                .S01_AXIS_TDATA(eth_tx8_data[1]),
                .S01_AXIS_TKEEP(1'b1),
                .S01_AXIS_TLAST(eth_tx8_last[1]),
                .S01_AXIS_TID(3'd1),
                .S01_AXIS_TUSER(eth_tx8_user[1]),

                .S02_AXIS_ACLK(eth_clk),
                .S02_AXIS_ARESETN(~reset_eth),
                .S02_AXIS_TVALID(eth_tx8_valid[2]),
                .S02_AXIS_TREADY(eth_tx8_ready[2]),
                .S02_AXIS_TDATA(eth_tx8_data[2]),
                .S02_AXIS_TKEEP(1'b1),
                .S02_AXIS_TLAST(eth_tx8_last[2]),
                .S02_AXIS_TID(3'd2),
                .S02_AXIS_TUSER(eth_tx8_user[2]),

                .S03_AXIS_ACLK(eth_clk),
                .S03_AXIS_ARESETN(~reset_eth),
                .S03_AXIS_TVALID(eth_tx8_valid[3]),
                .S03_AXIS_TREADY(eth_tx8_ready[3]),
                .S03_AXIS_TDATA(eth_tx8_data[3]),
                .S03_AXIS_TKEEP(1'b1),
                .S03_AXIS_TLAST(eth_tx8_last[3]),
                .S03_AXIS_TID(3'd3),
                .S03_AXIS_TUSER(eth_tx8_user[3]),

                .S04_AXIS_ACLK(eth_clk),
                .S04_AXIS_ARESETN(~reset_eth),
                .S04_AXIS_TVALID(1'b0),
                .S04_AXIS_TREADY(),
                .S04_AXIS_TDATA(0),
                .S04_AXIS_TKEEP(1'b1),
                .S04_AXIS_TLAST(1'b0),
                .S04_AXIS_TID(3'd4),
                .S04_AXIS_TUSER(1'b0),

                .M00_AXIS_ACLK(eth_clk),
                .M00_AXIS_ARESETN(~reset_eth),
                .M00_AXIS_TVALID(out_valid),
                .M00_AXIS_TREADY(out_ready),
                .M00_AXIS_TDATA(out_data),
                .M00_AXIS_TKEEP(out_keep),
                .M00_AXIS_TLAST(out_last),
                .M00_AXIS_TID(out_dest),
                .M00_AXIS_TUSER(out_user),

                .S00_ARB_REQ_SUPPRESS(0),
                .S01_ARB_REQ_SUPPRESS(0),
                .S02_ARB_REQ_SUPPRESS(0),
                .S03_ARB_REQ_SUPPRESS(0),
                .S04_ARB_REQ_SUPPRESS(0),

                .S00_FIFO_DATA_COUNT(),
                .S01_FIFO_DATA_COUNT(),
                .S02_FIFO_DATA_COUNT(),
                .S03_FIFO_DATA_COUNT(),
                .S04_FIFO_DATA_COUNT()
            );

            axis_receiver axis_receiver_i(
                .clk(eth_clk),
                .reset(reset_eth),

                .s_data(out_data),
                .s_keep(out_keep),
                .s_last(out_last),
                .s_user(out_user),
                .s_dest(out_dest),
                .s_valid(out_valid),
                .s_ready(out_ready)
            );
        end
    endgenerate

    wire [7:0] internal_tx_data;
    wire internal_tx_last;
    wire internal_tx_user;
    wire internal_tx_valid;
    assign eth_rx8_data[4] = internal_tx_data;
    assign eth_rx8_last[4] = internal_tx_last;
    assign eth_rx8_user[4] = internal_tx_user;
    assign eth_rx8_valid[4] = internal_tx_valid;

    wire [7:0] internal_rx_data = eth_tx8_data[4];
    wire internal_rx_last = eth_tx8_last[4];
    wire internal_rx_user = eth_tx8_user[4];
    wire internal_rx_valid = eth_tx8_valid[4];
    wire internal_rx_ready;
    assign eth_tx8_ready[4] = internal_rx_ready;

    // README: internal_tx_* and internal_rx_* are left for internal use.
    // You can connect them with your CPU to transfer frames between the router part and the CPU part,
    // and you may need to write some logic to receive from internal_rx_*, store data to some memory,
    // read data from some memory, and send to internal_tx_*.
    // You can also transfer frames in other ways.
    // assign internal_tx_data = 0;
    // assign internal_tx_last = 0;
    // assign internal_tx_user = 0;
    // assign internal_tx_valid = 0;
    // assign internal_rx_ready = 0;

    wire [7:0] out_led;
    led_delayer led_delayer_i(
        .clk(eth_clk),
        .reset(reset_eth),
        .in_led({(eth_tx8_valid[3] & eth_tx8_ready[3]) | eth_rx8_valid[3], ~sfp_rx_los[3],
                 (eth_tx8_valid[2] & eth_tx8_ready[2]) | eth_rx8_valid[2], ~sfp_rx_los[2],
                 (eth_tx8_valid[1] & eth_tx8_ready[1]) | eth_rx8_valid[1], ~sfp_rx_los[1],
                 (eth_tx8_valid[0] & eth_tx8_ready[0]) | eth_rx8_valid[0], ~sfp_rx_los[0]}),
        .out_led(out_led)
    );
    assign sfp_led = out_led;

    wire [DATA_WIDTH - 1:0] eth_rx_data;
    wire [DATA_WIDTH / 8 - 1:0] eth_rx_keep;
    wire eth_rx_last;
    wire [DATA_WIDTH / 8 - 1:0] eth_rx_user;
    wire [ID_WIDTH - 1:0] eth_rx_id;
    wire eth_rx_valid;

    axis_interconnect_ingress axis_interconnect_ingress_i(
        .ACLK(eth_clk),
        .ARESETN(~reset_eth),

        .S00_AXIS_ACLK(eth_clk),
        .S00_AXIS_ARESETN(~reset_eth),
        .S00_AXIS_TVALID(eth_rx8_valid[0]),
        .S00_AXIS_TREADY(debug_ingress_interconnect_ready[0]),
        .S00_AXIS_TDATA(eth_rx8_data[0]),
        .S00_AXIS_TKEEP(1'b1),
        .S00_AXIS_TLAST(eth_rx8_last[0]),
        .S00_AXIS_TID(3'd0),
        .S00_AXIS_TUSER(eth_rx8_user[0]),

        .S01_AXIS_ACLK(eth_clk),
        .S01_AXIS_ARESETN(~reset_eth),
        .S01_AXIS_TVALID(eth_rx8_valid[1]),
        .S01_AXIS_TREADY(debug_ingress_interconnect_ready[1]),
        .S01_AXIS_TDATA(eth_rx8_data[1]),
        .S01_AXIS_TKEEP(1'b1),
        .S01_AXIS_TLAST(eth_rx8_last[1]),
        .S01_AXIS_TID(3'd1),
        .S01_AXIS_TUSER(eth_rx8_user[1]),

        .S02_AXIS_ACLK(eth_clk),
        .S02_AXIS_ARESETN(~reset_eth),
        .S02_AXIS_TVALID(eth_rx8_valid[2]),
        .S02_AXIS_TREADY(debug_ingress_interconnect_ready[2]),
        .S02_AXIS_TDATA(eth_rx8_data[2]),
        .S02_AXIS_TKEEP(1'b1),
        .S02_AXIS_TLAST(eth_rx8_last[2]),
        .S02_AXIS_TID(3'd2),
        .S02_AXIS_TUSER(eth_rx8_user[2]),

        .S03_AXIS_ACLK(eth_clk),
        .S03_AXIS_ARESETN(~reset_eth),
        .S03_AXIS_TVALID(eth_rx8_valid[3]),
        .S03_AXIS_TREADY(debug_ingress_interconnect_ready[3]),
        .S03_AXIS_TDATA(eth_rx8_data[3]),
        .S03_AXIS_TKEEP(1'b1),
        .S03_AXIS_TLAST(eth_rx8_last[3]),
        .S03_AXIS_TID(3'd3),
        .S03_AXIS_TUSER(eth_rx8_user[3]),

        .S04_AXIS_ACLK(eth_clk),
        .S04_AXIS_ARESETN(~reset_eth),
        .S04_AXIS_TVALID(eth_rx8_valid[4]),
        .S04_AXIS_TREADY(debug_ingress_interconnect_ready[4]),
        .S04_AXIS_TDATA(eth_rx8_data[4]),
        .S04_AXIS_TKEEP(1'b1),
        .S04_AXIS_TLAST(eth_rx8_last[4]),
        .S04_AXIS_TID(3'd4),
        .S04_AXIS_TUSER(eth_rx8_user[4]),

        .M00_AXIS_ACLK(eth_clk),
        .M00_AXIS_ARESETN(~reset_eth),
        .M00_AXIS_TVALID(eth_rx_valid),
        .M00_AXIS_TREADY(1'b1),
        .M00_AXIS_TDATA(eth_rx_data),
        .M00_AXIS_TKEEP(eth_rx_keep),
        .M00_AXIS_TLAST(eth_rx_last),
        .M00_AXIS_TID(eth_rx_id),
        .M00_AXIS_TUSER(eth_rx_user),

        .S00_ARB_REQ_SUPPRESS(0),
        .S01_ARB_REQ_SUPPRESS(0),
        .S02_ARB_REQ_SUPPRESS(0),
        .S03_ARB_REQ_SUPPRESS(0),
        .S04_ARB_REQ_SUPPRESS(0),

        .S00_FIFO_DATA_COUNT(),
        .S01_FIFO_DATA_COUNT(),
        .S02_FIFO_DATA_COUNT(),
        .S03_FIFO_DATA_COUNT(),
        .S04_FIFO_DATA_COUNT()
    );

    wire [DATA_WIDTH - 1:0] dp_rx_data;
    wire [DATA_WIDTH / 8 - 1:0] dp_rx_keep;
    wire dp_rx_last;
    wire [DATA_WIDTH / 8 - 1:0] dp_rx_user;
    wire [ID_WIDTH - 1:0] dp_rx_id;
    wire dp_rx_valid;
    wire dp_rx_ready;

    frame_datapath_fifo
    #(
        .ENABLE(1),  // README: enable this if your datapath may block.
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    )
    frame_datapath_fifo_i(
        .eth_clk(eth_clk),
        .reset(reset_eth),

        .s_data(eth_rx_data),
        .s_keep(eth_rx_keep),
        .s_last(eth_rx_last),
        .s_user(eth_rx_user),
        .s_id(eth_rx_id),
        .s_valid(eth_rx_valid),
        .s_ready(debug_datapath_fifo_ready),

        .m_data(dp_rx_data),
        .m_keep(dp_rx_keep),
        .m_last(dp_rx_last),
        .m_user(dp_rx_user),
        .m_id(dp_rx_id),
        .m_valid(dp_rx_valid),
        .m_ready(dp_rx_ready)
    );

    wire [DATA_WIDTH - 1:0] dp_tx_data;
    wire [DATA_WIDTH / 8 - 1:0] dp_tx_keep;
    wire dp_tx_last;
    wire [DATA_WIDTH / 8 - 1:0] dp_tx_user;
    wire [ID_WIDTH - 1:0] dp_tx_dest;
    wire dp_tx_valid;

    // README: Instantiate your datapath.
    reg [31:0] ip0_i;
    reg [31:0] ip1_i;
    reg [31:0] ip2_i;
    reg [31:0] ip3_i;
    reg [43:0] mac_i;

    wire[3:0] trie_web[32:0];
    wire[4:0] nexthop_web;
    wire[TRIE_ADDR_WIDTH-1:0] node_addr[32:0];
    trie_node_t node_data_cpu[32:0];
    trie_node_t node_data_router[32:0];
    wire[NEXTHOP_ADDR_WIDTH-1:0] nexthop_addr;
    nexthop_t nexthop_data_cpu;
    nexthop_t nexthop_data_router;
    frame_datapath
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    )
    frame_datapath_i(
        .eth_clk(eth_clk),
        .cpu_clk(core_clk),
        .reset(reset_eth),

        .s_data(dp_rx_data),
        .s_keep(dp_rx_keep),
        .s_last(dp_rx_last),
        .s_user(dp_rx_user),
        .s_id(dp_rx_id),
        .s_valid(dp_rx_valid),
        .s_ready(dp_rx_ready),

        .dip_sw(dip_sw),
        .ip0_i(ip0_i),
        .ip1_i(ip1_i),
        .ip2_i(ip2_i),
        .ip3_i(ip3_i),
        .mac_i(mac_i),

        .m_data(dp_tx_data),
        .m_keep(dp_tx_keep),
        .m_last(dp_tx_last),
        .m_user(dp_tx_user),
        .m_dest(dp_tx_dest),
        .m_valid(dp_tx_valid),
        .m_ready(1'b1),
        .trie_web,
        .nexthop_web,
        .node_addr_b(node_addr),
        .node_dinb(node_data_cpu),
        .node_doutb(node_data_router),
        .nexthop_addr_b(nexthop_addr),
        .nexthop_dinb(nexthop_data_cpu),
        .nexthop_doutb(nexthop_data_router)
        // README: You will need to add some signals for your CPU to control the datapath,
        // or access the forwarding table or the address resolution cache.
    );

    wire [DATA_WIDTH - 1:0] eth_tx_data [0:4];
    wire [DATA_WIDTH / 8 - 1:0] eth_tx_keep [0:4];
    wire eth_tx_last [0:4];
    wire eth_tx_ready [0:4];
    wire [DATA_WIDTH / 8 - 1:0] eth_tx_user [0:4];
    wire eth_tx_valid [0:4];

    axis_interconnect_egress axis_interconnect_egress_i(
        .ACLK(eth_clk),
        .ARESETN(~reset_eth),

        .S00_AXIS_ACLK(eth_clk),
        .S00_AXIS_ARESETN(~reset_eth),
        .S00_AXIS_TVALID(dp_tx_valid),
        .S00_AXIS_TREADY(debug_egress_interconnect_ready),
        .S00_AXIS_TDATA(dp_tx_data),
        .S00_AXIS_TKEEP(dp_tx_keep),
        .S00_AXIS_TLAST(dp_tx_last),
        .S00_AXIS_TDEST(dp_tx_dest),
        .S00_AXIS_TUSER(dp_tx_user),

        .M00_AXIS_ACLK(eth_clk),
        .M00_AXIS_ARESETN(~reset_eth),
        .M00_AXIS_TVALID(eth_tx_valid[0]),
        .M00_AXIS_TREADY(eth_tx_ready[0]),
        .M00_AXIS_TDATA(eth_tx_data[0]),
        .M00_AXIS_TKEEP(eth_tx_keep[0]),
        .M00_AXIS_TLAST(eth_tx_last[0]),
        .M00_AXIS_TDEST(),
        .M00_AXIS_TUSER(eth_tx_user[0]),

        .M01_AXIS_ACLK(eth_clk),
        .M01_AXIS_ARESETN(~reset_eth),
        .M01_AXIS_TVALID(eth_tx_valid[1]),
        .M01_AXIS_TREADY(eth_tx_ready[1]),
        .M01_AXIS_TDATA(eth_tx_data[1]),
        .M01_AXIS_TKEEP(eth_tx_keep[1]),
        .M01_AXIS_TLAST(eth_tx_last[1]),
        .M01_AXIS_TDEST(),
        .M01_AXIS_TUSER(eth_tx_user[1]),

        .M02_AXIS_ACLK(eth_clk),
        .M02_AXIS_ARESETN(~reset_eth),
        .M02_AXIS_TVALID(eth_tx_valid[2]),
        .M02_AXIS_TREADY(eth_tx_ready[2]),
        .M02_AXIS_TDATA(eth_tx_data[2]),
        .M02_AXIS_TKEEP(eth_tx_keep[2]),
        .M02_AXIS_TLAST(eth_tx_last[2]),
        .M02_AXIS_TDEST(),
        .M02_AXIS_TUSER(eth_tx_user[2]),

        .M03_AXIS_ACLK(eth_clk),
        .M03_AXIS_ARESETN(~reset_eth),
        .M03_AXIS_TVALID(eth_tx_valid[3]),
        .M03_AXIS_TREADY(eth_tx_ready[3]),
        .M03_AXIS_TDATA(eth_tx_data[3]),
        .M03_AXIS_TKEEP(eth_tx_keep[3]),
        .M03_AXIS_TLAST(eth_tx_last[3]),
        .M03_AXIS_TDEST(),
        .M03_AXIS_TUSER(eth_tx_user[3]),

        .M04_AXIS_ACLK(eth_clk),
        .M04_AXIS_ARESETN(~reset_eth),
        .M04_AXIS_TVALID(eth_tx_valid[4]),
        .M04_AXIS_TREADY(eth_tx_ready[4]),
        .M04_AXIS_TDATA(eth_tx_data[4]),
        .M04_AXIS_TKEEP(eth_tx_keep[4]),
        .M04_AXIS_TLAST(eth_tx_last[4]),
        .M04_AXIS_TDEST(),
        .M04_AXIS_TUSER(eth_tx_user[4]),

        .S00_DECODE_ERR()
    );

    generate
        for (i = 0; i < 5; i = i + 1)
        begin
            egress_wrapper
            #(
                .DATA_WIDTH(DATA_WIDTH),
                .ID_WIDTH(ID_WIDTH)
            )
            egress_wrapper_i(
                .eth_clk(eth_clk),
                .reset(reset_eth),

                .s_data(eth_tx_data[i]),
                .s_keep(eth_tx_keep[i]),
                .s_last(eth_tx_last[i]),
                .s_user(eth_tx_user[i]),
                .s_valid(eth_tx_valid[i]),
                .s_ready(eth_tx_ready[i]),

                .m_data(eth_tx8_data[i]),
                .m_last(eth_tx8_last[i]),
                .m_user(eth_tx8_user[i]),
                .m_valid(eth_tx8_valid[i]),
                .m_ready(eth_tx8_ready[i])
            );
        end
    endgenerate

    led_delayer led_delayer_debug_i1(
        .clk(eth_clk),
        .reset(reset_eth),
        .in_led({1'b0, ~debug_egress_interconnect_ready,
                 ~debug_datapath_fifo_ready,
                 ~debug_ingress_interconnect_ready}),
        .out_led(led[7:0])
    );
    assign led[15:8] = 0;

    // README: You may use this to reset your CPU.
    wire reset_core;
    reset_sync reset_sync_reset_core(
        .clk(core_clk),
        .i(reset_not_sync),
        .o(reset_core)
    );

    // README: Your code here.

    wire[31:0] ram_data_ram, ram_data_cpu, ram_addr;
    wire[3:0] ram_be;
    wire ram_we, ram_oe, ram_req, ram_ready;

    // Interface here.

    wire cpu_write_web;
    wire [`BUFFER_ADDR_WIDTH - 1:0] cpu_write_addrb;
    wire [7:0] cpu_write_dinb;
    wire cpu_write_end;
    wire [`BUFFER_WIDTH - 1:0] cpu_write_end_ptr;

    wire cpu_read_start;
    wire [`BUFFER_WIDTH - 1:0] cpu_read_start_ptr;
    wire [`BUFFER_ADDR_WIDTH - 1:0] cpu_read_addrb;
    wire [7:0] cpu_read_doutb;
    wire cpu_read_end;
    wire [`BUFFER_WIDTH - 1:0] cpu_read_end_ptr;
    wire internal_tx_ready = eth_tx_ready[4];

    router_cpu_interface router_cpu_interface(
    .clk_router(eth_clk),
    .clk_cpu(core_clk),
    .rst_router(reset_eth),
    .rst_cpu(reset_core),

    .internal_rx_data(internal_rx_data),
    .internal_rx_last(internal_rx_last),
    .internal_rx_user(internal_rx_user),
    .internal_rx_valid(internal_rx_valid), 
    .internal_rx_ready(internal_rx_ready),

    .internal_tx_data(internal_tx_data),
    .internal_tx_last(internal_tx_last),
    .internal_tx_user(internal_tx_user),
    .internal_tx_valid(internal_tx_valid),
    .internal_tx_ready(internal_tx_ready),

    .cpu_write_web(cpu_write_web),
    .cpu_write_addrb(cpu_write_addrb),
    .cpu_write_dinb(cpu_write_dinb),
    .cpu_write_end(cpu_write_end),
    .cpu_write_end_ptr(cpu_write_end_ptr),

    .cpu_read_start(cpu_read_start),
    .cpu_read_start_ptr(cpu_read_start_ptr),
    .cpu_read_addrb(cpu_read_addrb),
    .cpu_read_doutb(cpu_read_doutb),
    .cpu_read_end(cpu_read_end),
    .cpu_read_end_ptr(cpu_read_end_ptr)
    );

    bus bus(
    .clk(core_clk),
    .rst(reset_core),
    
    .base_ram_data(base_ram_data),
    .base_ram_addr(base_ram_addr),
    .base_ram_be_n(base_ram_be_n),
    .base_ram_we_n(base_ram_we_n),
    .base_ram_oe_n(base_ram_oe_n),
    .base_ram_ce_n(base_ram_ce_n),
    
    .ext_ram_data(ext_ram_data),
    .ext_ram_addr(ext_ram_addr),
    .ext_ram_be_n(ext_ram_be_n),
    .ext_ram_we_n(ext_ram_we_n),
    .ext_ram_oe_n(ext_ram_oe_n),
    .ext_ram_ce_n(ext_ram_ce_n),
    
    .ram_data_cpu(ram_data_cpu),
    .ram_data_ram(ram_data_ram),
    .ram_addr_i(ram_addr),
    .ram_be_i(ram_be),
    .ram_oe_i(ram_oe),
    .ram_we_i(ram_we),
    .ram_req(ram_req),
    .ram_ready(ram_ready),
    
    .uart_dataready(uart_dataready),
    .uart_tsre(uart_tsre),
    .uart_tbre(uart_tbre),
    .uart_rdn(uart_rdn),
    .uart_wrn(uart_wrn),

    .flash_a(flash_a),
    .flash_d(flash_d),
    .flash_rp_n(flash_rp_n),
    .flash_vpen(flash_vpen),
    .flash_ce_n(flash_ce_n),
    .flash_oe_n(flash_oe_n),
    .flash_we_n(flash_we_n),
    .flash_byte_n(flash_byte_n),
    .trie_web,
    .nexthop_web,
    .node_addr(node_addr),
    .node_data_cpu(node_data_cpu),
    .node_data_router(node_data_router),
    .nexthop_addr(nexthop_addr),
    .nexthop_data_cpu(nexthop_data_cpu),
    .nexthop_data_router(nexthop_data_router),

    .cpu_write_web(cpu_write_web),
    .cpu_write_addrb(cpu_write_addrb),
    .cpu_write_dinb(cpu_write_dinb),
    .cpu_write_end(cpu_write_end),
    .cpu_write_end_ptr(cpu_write_end_ptr),

    .cpu_read_start(cpu_read_start),
    .cpu_read_start_ptr(cpu_read_start_ptr),
    .cpu_read_addrb(cpu_read_addrb),
    .cpu_read_doutb(cpu_read_doutb),
    .cpu_read_end(cpu_read_end),
    .cpu_read_end_ptr(cpu_read_end_ptr),

    .ip0_o(ip0_i),
    .ip1_o(ip1_i),
    .ip2_o(ip2_i),
    .ip3_o(ip3_i),
    .mac_o(mac_i)
    );
    
    
    cpu cpu(
    .clk(core_clk),
    .rst(reset_core),
    .ram_data_o(ram_data_cpu),
    .ram_data_i(ram_data_ram),
    .ram_addr_o(ram_addr),
    .ram_be_o(ram_be),
    .ram_we_o(ram_we),
    .ram_oe_o(ram_oe),
    .ram_req(ram_req),
    .ram_ready(ram_ready)
    );
endmodule
