`timescale 1ns / 1ps
module tb_route_hard ();
    reg [31:0] ip;
    wire[31:0] nexthop;
    wire [1:0] port;
    wire valid;

    route_hard #() route_hard_module(
    .q_ip(ip),
    .q_nexthop(nexthop),
    .q_port(port),
    .q_valid(valid)
    );

    initial begin
        #20        
        ip     = 32'h00001010;
        #20
        ip     = 32'habcdabcd;
        #20        
        ip     = 32'hdcbadcba;
        #20
        ip     = 32'hcbcbcbcb;
        #20        
        ip     = 32'hbabababa;        
        #20
        ip     = 32'h10101010;
        #20        
        ip     = 32'h00001010;
    end
endmodule
