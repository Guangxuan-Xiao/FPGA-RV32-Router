module mac_update
(
    input wire eth_clk,
    input wire reset,
    input wire mac_up_en,
    input wire my_ip_addr,
    input wire [31:0] trg_ip_addr_v,
    input wire [31:0] my_mac_addr,
    input wire [383:0] data_in,
    output wire [383:0] data_out,
    output wire is_send
);

`include "frame_datapath.vh"

reg [31:0] src_ip_addr_v;
reg [47:0] src_mac_addr_v;
reg request_en = 0;
reg [31:0] my_ip_c,
reg [47:0] my_mac_c,
reg [31:0] trg_ip_c,
reg [15:0] ether_type_c,
reg [15:0] hard_type_c,
reg [15:0] prot_type_c,
reg [7:0] hard_len_c,
reg [7:0] prot_len_c,
reg [47:0] trg_mac_addr_v;

arp_cache #(
    .CACHE_ADDR_WIDTH(CACHE_ADDR_WIDTH)
) arp_cache_update(
    .clk(eth_clk),
    .rst(reset),
    .w_ip(src_ip_addr_v),
    .w_mac(src_mac_addr_v),
    .wr_en(mac_up_en),
    .r_ip(trg_ip_addr_v),
    .r_mac(trg_mac_addr_v),
);

arp_request_send send_request(
    .clk(eth_clk),
    .reset(reset),
    .request_en(request_en),
    .my_ip(my_ip_c),
    .my_mac(my_mac_c),
    .trg_ip(trg_ip_c),
    .ether_type(ether_type_c),
    .hard_type(ether_type_c),
    .prot_type(prot_type_c),
    .hard_len(hard_len_c),
    .prot_len(prot_len_c),
    .arp_data(arp_data_c)
);

always@(posedge eth_clk)
begin
    if(reset)
    begin
        is_drop <= 0;
        request_en <= 0;
        my_ip_c <= 0;
        my_mac_c <= 0;
        trg_ip_c <= 0;
        ether_type_c <= 0;
        hard_type_c <= 0;
        prot_type_c <= 0;
        hard_len_c <= 0;
        prot_len_c <= 0;
    end
    else if(trg_mac_addr_v == 48'h0)
    begin
        request_en <= 1;
        my_ip_c <= my_ip_addr;
        my_mac_c <= my_mac_addr;
        trg_ip_c <= data_in[`TRG_IP_ADDR];
        ether_type_c <= data_in[`MAC_TYPE];
        hard_type_c <= data_in[`HARD_TYPE];
        prot_type_c <= data_in[`PROT_TYPE];
        hard_len_c <= data_in[`HARD_LEN];
        prot_len_c <= data_in[`PROT_LEN];
    end
    else
    begin
        request_en <= 0;
        my_ip_c <= my_ip_addr;
        my_mac_c <= my_mac_addr'
        trg_ip_c <= data_in[`TRG_IP_ADDR];
        ether_type_c <= data_in[`MAC_TYPE];
        hard_type_c <= data_in[`HARD_TYPE];
        prot_type_c <= data_in[`PROT_TYPE];
        hard_len_c <= data_in[`HARD_LEN];
        prot_len_c <= data_in[`PROT_LEN];
    end
end

always@(posedge eth_clk)
begin
    if(reset)
    begin
        is_send <= 0;
        data_out <= 0;
    end
    if(request_en)
    begin
        is_send <= 1;
        data_out <= arp_data_c;
    end
    else
    begin
        is_send <= 0;
        data_out[`MAC_DST] = trg_mac_addr_v;
        data_out[`MAC_SRC] = my_mac_addr;
    end
end

endmodule