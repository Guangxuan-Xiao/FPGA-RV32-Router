`timescale 1ns/1ps
module route_trie (input wire clk,
                   input wire rst,
                   input wire [31:0] i_ip,
                   output nexthop_t o_nexthop,
                   output reg o_valid,
                   output reg o_ready);
    
    always @ (posedge clk or posedge rst) begin
        
    end
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
