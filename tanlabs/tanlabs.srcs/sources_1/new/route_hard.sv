`timescale 1ns/1ps
module route_hard #(parameter NET0 = 0,
                    parameter NET1 = 1,
                    parameter NET2 = 2,
                    parameter NET3 = 3,
                    parameter IP0 = 32'haaaaaaaa,
                    parameter IP1 = 32'hbbbbbbbb,
                    parameter IP2 = 32'hcccccccc,
                    parameter IP3 = 32'hdddddddd,
                    parameter MASK = 32'hf0000000)
                   (input wire [31:0] q_ip,
                    output reg [31:0] q_nexthop,
                    output reg [1:0] q_port,
                    output reg q_valid);
    always @(*) begin
        case (q_ip & MASK)
            32'ha0000000:begin
                q_port    <= NET0;
                q_nexthop <= IP0;
                q_valid   <= 1;
            end
            32'hb0000000:begin
                q_port    <= NET1;
                q_nexthop <= IP1;
                q_valid   <= 1;
            end
            32'hc0000000:begin
                q_port    <= NET2;
                q_nexthop <= IP2;
                q_valid   <= 1;
            end
            32'hd0000000:begin
                q_port    <= NET3;
                q_nexthop <= IP3;
                q_valid   <= 1;
            end
            default: begin
                q_port    <= NET0;
                q_nexthop <= IP0;
                q_valid   <= 0;
            end
        endcase
    end
    
endmodule
