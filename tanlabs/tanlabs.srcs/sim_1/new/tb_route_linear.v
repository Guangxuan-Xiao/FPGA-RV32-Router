`timescale 1ns / 1ps
module tb_route_linear #(parameter CACHE_ADDR_WIDTH = 2)
                        ();
    reg rst;
    initial begin
        rst = 1;
        #5
        rst = 0;
    end
    
    wire clk_125M;
    
    clock clock_i(
    .clk_125M(clk_125M)
    );
    
    reg wq_en;
    reg ins_en;
    reg[31:0] w_ip;
    reg[31:0] w_mask;
    reg[2:0] w_port;
    reg[31:0] w_nexthop;
    reg[31:0] q_ip;
    wire[31:0] q_nexthop;
    wire[2:0] q_port;
    wire q_found;
    
    router_linear #(
    .CACHE_ADDR_WIDTH(CACHE_ADDR_WIDTH)
    ) router_linear_module(
    .clk(clk_125M),
    .rst(rst),
    .wq_en(wq_en),
    .ins_en(ins_en),
    .w_ip(w_ip),
    .w_mask(w_mask),
    .w_port(w_port),
    .w_nexthop(w_nexthop),
    .q_ip(q_ip),
    .q_nexthop(q_nexthop),
    .q_port(q_port),
    .q_found(q_found)
    );
    // Software Lookup Testcase 3
    // Input:
    // I,0x00030201,24,2,0x0203a8c0
    // I,0x04030201,32,3,0x0109a8c0
    // Q,0x04030201
    // Q,0x01030201
    // Q,0x00000000
    // D,0x04030201,32
    // Q,0x04030201
    // Q,0x01030201
    // Q,0x00000000
    // D,0x00030201,24
    // Q,0x04030201
    // Q,0x01030201
    // Q,0x00000000
    
    // Expected Output:
    // 0x0109a8c0 3
    // 0x0203a8c0 2
    // Not Found
    // 0x0203a8c0 2
    // 0x0203a8c0 2
    // Not Found
    // Not Found
    // Not Found
    // Not Found
    
    initial begin
        #20
        wq_en = 1;
        ins_en = 1;
        w_ip  = 32'h00030201;
        w_mask = 32'hffffff00;
        w_port = 2;
        w_nexthop = 32'h0203a8c0;
        #20
        wq_en = 0;

        #20
        wq_en = 1;
        ins_en = 1;
        w_ip  = 32'h04030201;
        w_mask = 32'hffffffff;
        w_port = 3;
        w_nexthop = 32'h0109a8c0;
        #20
        wq_en = 0;

        #20
        wq_en = 0;
        q_ip  = 32'h04030201;

        #20
        wq_en = 0;
        q_ip  = 32'h04030201;

    end
endmodule
