module conv_16 (input wire [15:0] wire_in,
                output wire [15:0] wire_out);
assign wire_out[15:8] = wire_in[7:0];
assign wire_out[7:0]  = wire_in[15:8];
endmodule
