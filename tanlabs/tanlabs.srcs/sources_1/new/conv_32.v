module conv_32
(
    input wire [31:0] wire_in,
    output wire [31:0] wire_out
)

assign wire_out[31:24] = wire_in[7:0];
assign wire_out[23:16] = wire_in[15:8];
assign wire_out[15:8] = wire_in[23:16];
assign wire_out[7:0] = wire_in[31:24];