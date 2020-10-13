`timescale 1ns/1ps
module route_hard #(
    parameter NET0 = 0,
    parameter NET1 = 1,
    parameter NET2 = 2,
    parameter NET3 = 3,
    parameter IP0 = 32'haaaaaaaa,
    parameter IP1 = 32'hbbbbbbbb,
    parameter IP2 = 32'hcccccccc,
    parameter IP3 = 32'hdddddddd,
    )(
    input wire [31:0] ip,
    input wire [31:0] mask,
    output reg [31:0] next_ip,
    output reg [1:0] next_port,
    output reg o_valid,
    );
    case (ip & mask)
        32'ha0000000:begin
            next_port <= NET0;
            next_ip <= IP0;
            o_valid <= 1;
        end
        32'hb0000000:begin
            next_port <= NET1;
            next_ip <= IP1;
            o_valid <= 1;
        end
        32'hc0000000:begin
            next_port <= NET2;
            next_ip <= IP2;
            o_valid <= 1;
        end
        32'hd0000000:begin
            next_port <= NET3;
            next_ip <= IP3;
            o_valid <= 1;
        end
        default: begin
            next_port <= NET0;
            next_ip <= IP0;
            o_valid <= 0;
        end
    endcase
endmodule