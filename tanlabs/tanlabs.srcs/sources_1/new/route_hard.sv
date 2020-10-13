`timescale 1ns/1ps
module route_hard #(parameter PORT0 = 0,
                    parameter PORT1 = 1,
                    parameter PORT2 = 2,
                    parameter PORT3 = 3,
                    parameter IP0 = 32'haaaaaaaa,
                    parameter IP1 = 32'hbbbbbbbb,
                    parameter IP2 = 32'hcccccccc,
                    parameter IP3 = 32'hdddddddd,
                    parameter SUB_NET0 = 32'h000000aa,
                    parameter SUB_NET1 = 32'h000000bb,
                    parameter SUB_NET2 = 32'h000000cc,
                    parameter SUB_NET3 = 32'h000000dd,
                    parameter MASK = 32'h000000ff)
                   (input wire [31:0] q_ip,
                    output reg [31:0] q_nexthop,
                    output reg [2:0] q_port,
                    output reg q_valid);
    always @(*) begin
        case (q_ip & MASK)
            SUB_NET0:begin
                q_port    <= PORT0;
                q_nexthop <= IP0;
                q_valid   <= 1;
            end
            SUB_NET1:begin
                q_port    <= PORT1;
                q_nexthop <= IP1;
                q_valid   <= 1;
            end
            SUB_NET2:begin
                q_port    <= PORT2;
                q_nexthop <= IP2;
                q_valid   <= 1;
            end
            SUB_NET3:begin
                q_port    <= PORT3;
                q_nexthop <= IP3;
                q_valid   <= 1;
            end
            default: begin
                q_port    <= PORT0;
                q_nexthop <= IP0;
                q_valid   <= 0;
            end
        endcase
    end
    
endmodule
