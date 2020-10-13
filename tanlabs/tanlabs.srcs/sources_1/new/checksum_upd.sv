module checksum_upd
#(  parameter DATA_WIDTH = 384,
    parameter IP_HEAD_START = 112,
    parameter IP_HEAD_END = 272,
    parameter IP_HEAD_LEN = 160,
    parameter IP_CHECKSUM_INTERMEDIATE = 20,
    parameter IP_CHECKSUM_NUMBER = 10,
    parameter IP_CHECKSUM_LEN = 16,
    parameter BYTE_LEN = 8,
    parameter TTL_START = 64,
    parameter TTL_END = 72,
    parameter HEAD_LEN_START = 4,
    parameter HEAD_LEN_END = 8
)
(   input wire [DATA_WIDTH - 1:0] input_data,
    output reg [DATA_WIDTH - 1:0] output_data,
    output wire packet_valid,
    output wire [BYTE_LEN - 1:0] time_to_live
);
    
    wire [IP_HEAD_LEN - 1:0] ip_head;
    reg [IP_CHECKSUM_INTERMEDIATE * IP_CHECKSUM_NUMBER - 1:0] checksum_intermediate;
    wire [IP_CHECKSUM_LEN - 1:0] checksum;
    wire checksum_valid;
    wire ttl_valid;
    wire len_valid;
    
    assign ip_head = input_data[IP_HEAD_END - 1:IP_HEAD_START];
    
    always @ (*)
    begin
        checksum_intermediate[IP_CHECKSUM_INTERMEDIATE - 1:0]
            = (ip_head[BYTE_LEN - 1:0] << 8) + ip_head[IP_CHECKSUM_LEN - 1:BYTE_LEN];
        for (int i = 1; i < IP_CHECKSUM_NUMBER; i++)
        begin
            checksum_intermediate[i * IP_CHECKSUM_INTERMEDIATE +: IP_CHECKSUM_INTERMEDIATE]
                = checksum_intermediate[(i - 1) * IP_CHECKSUM_INTERMEDIATE +: IP_CHECKSUM_INTERMEDIATE]
                + (ip_head[i * IP_CHECKSUM_LEN +: BYTE_LEN] << 8)
                + ip_head[i * IP_CHECKSUM_LEN + BYTE_LEN +: BYTE_LEN];
        end
    end
    
    assign checksum
        = checksum_intermediate[(IP_CHECKSUM_NUMBER - 1) * IP_CHECKSUM_INTERMEDIATE +: IP_CHECKSUM_LEN]
        + checksum_intermediate[(IP_CHECKSUM_NUMBER - 1) * IP_CHECKSUM_INTERMEDIATE + IP_CHECKSUM_LEN +: BYTE_LEN];
    
    assign checksum_valid = checksum == 16'hffff;

    assign ttl_valid = ip_head[TTL_END - 1:TTL_START] >= 2;

    assign len_valid = ip_head[HEAD_LEN_END - 1:HEAD_LEN_START] == 5;
    
    assign packet_valid = checksum_valid & ttl_valid & len_valid;

    assign time_to_live = ip_head[TTL_END - 1:TTL_START];

endmodule
