module arp_request_send(

    input wire clk,
    input wire reset,
    input wire request_en,
    input wire [31:0] my_ip,
    input wire [47:0] my_mac,
    input wire [31:0] trg_ip,
    input wire [15:0] ether_type,
    input wire [15:0] hard_type,
    input wire [15:0] prot_type,
    input wire [7:0] hard_len,
    input wire [7:0] prot_len,
    // No operation because this is REQUEST module. 
    output wire [383:0] arp_data
);

`include "frame_datapath.vh"

always@(posedge clk)
begin 
    if(reset)
    begin
        arp_data[`MAC_DST] <= 48'h0;
        arp_data[`MAC_SRC] <= 48'h0;
        arp_data[`MAC_TYPE] <= 16'h0;
        arp_data[`HARD_TYPE] <= 16'h0;
        arp_data[`PROT_TYPE] <= 16'h0;
        arp_data[`HARD_LEN] <= 8'h0;
        arp_data[`PROT_LEN] <= 8'h0;
        arp_data[`SRC_MAC_ADDR] <= 48'h0;
        arp_data[`SRC_IP_ADDR] <= 32'h0;
        arp_data[`TRG_IP_ADDR] <= 32'h0;
        arp_data[`TRG_MAC_ADDR] <= 48'h0;
    end
    if(request_en)
    begin
        arp_data[`MAC_DST] <= 48'hffffffffffff;
        arp_data[`MAC_SRC] <= my_mac;
        arp_data[`MAC_TYPE] <= ether_type;
        arp_data[`HARD_TYPE] <= hard_type;
        arp_data[`PROT_TYPE] <= prot_type;
        arp_data[`HARD_LEN] <= hard_len;
        arp_data[`PROT_LEN] <= prot_len;
        arp_data[`SRC_MAC_ADDR] <= my_mac;
        arp_data[`SRC_IP_ADDR] <= my_ip;
        arp_data[`TRG_IP_ADDR] <= trg_ip;
        arp_data[`TRG_MAC_ADDR] <= 48'hffffffffffff;
    end
end

endmodule