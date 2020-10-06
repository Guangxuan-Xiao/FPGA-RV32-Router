`define REQUEST 16'h0001
`define REPLY   16'h0002

module arp_send (input wire clk,
                 input wire reset,
                 input wire [31:0] send_ip_addr_reply,
                 input wire [47:0] send_mac_addr_reply,
                 input wire [31:0] send_ip_addr_request,
                 input wire [31:0] spa,
                 input wire [47:0] sha,
                 input wire request_en,
                 input wire reply_en,
                 input wire send_buffer_ready,
                 output reg arp_valid,
                 output reg [31:0] arp_data,
                 output reg reply_ready,
                 output reg request_ready,
                 output reg [47:0] arp_mac_addr);
    
    reg [2:0] word_counter;
    reg [15:0] hard_type;
    reg [15:0] prot_type;
    reg [15:0] op;
    reg [7:0] hard_len;
    reg [7:0] prot_len;
    reg [47:0] tha;
    reg [31:0] tpa;
    reg request_buffer_valid;
    reg reply_buffer_valid;
    reg clear_to_send;
    reg [31:0] ip_request_buffer;
    reg [31:0] ip_reply_buffer;
    reg [47:0] mac_reply_buffer;
    
    assign request_ready = ~request_buffer_valid;
    assign reply_ready   = ~reply_buffer_valid;
    
    always@(posedge clk)
    begin
        if (reset)
        begin
            word_counter         <= 3'd0;
            hard_type            <= 16'h0001;
            prot_type            <= 16'h0800;
            hard_len             <= 8'h06;
            prot_len             <= 8'h04;
            op                   <= 16'h0;
            tha                  <= 48'h0;
            tpa                  <= 32'h0;
            clear_to_send        <= 1'b0;
            request_buffer_valid <= 1'b0;
            reply_buffer_valid   <= 1'b0;
            ip_request_buffer    <= 32'b0;
            ip_reply_buffer      <= 32'b0;
            mac_reply_buffer     <= 32'b0;
            arp_mac_addr         <= 48'b0;
            arp_valid            <= 1'b0;
            arp_data             <= 32'b0;
        end
        else
        begin
            case({request_en, reply_en})
                2'b00:
                begin
                    if ((send_buffer_ready) && (!clear_to_send) && (!arp_valid))
                    begin
                        if (request_buffer_valid)
                        begin
                            op                   <= `REQUEST;
                            tpa                  <= ip_request_buffer;
                            tha                  <= 48'h0;
                            request_buffer_valid <= 1'b0;
                            clear_to_send        <= 1'b1;
                        end
                        else if ((reply_buffer_valid) && (!request_buffer_valid))
                        begin
                            op                 <= `REPLY;
                            tpa                <= ip_reply_buffer;
                            tha                <= mac_reply_buffer;
                            reply_buffer_valid <= 1'b0;
                            clear_to_send      <= 1'b1;
                        end
                            end
                        else
                        begin
                            clear_to_send <= 1'b0;
                        end
                    end
                    
                    2'b01:
                    begin
                        if ((send_buffer_ready) && (!clear_to_send) && (!arp_valid))
                        begin
                            op            <= `REPLY;
                            tpa           <= send_ip_addr_reply;
                            tha           <= send_mac_addr_reply;
                            clear_to_send <= 1'b1;
                        end
                        else
                        begin
                            ip_reply_buffer    <= send_ip_addr_reply;
                            reply_buffer_valid <= 1'b1;
                            mac_reply_buffer   <= send_mac_addr_reply;
                            clear_to_send      <= 1'b0;
                        end
                    end
                    
                    2'b10:
                    begin
                        if ((send_buffer_ready) && (!clear_to_send) && (!arp_valid))
                        begin
                            op            <= `REQUEST;
                            tpa           <= send_ip_addr_request;
                            tha           <= 48'h0;
                            clear_to_send <= 1'b1;
                        end
                        else
                        begin
                            ip_request_buffer    <= send_ip_addr_request;
                            request_buffer_valid <= 1'b1;
                            clear_to_send        <= 1'b0;
                        end
                    end
                    
                    2'b11:
                    begin
                        if ((send_buffer_ready) && (!clear_to_send) && (!arp_valid))
                        begin
                            op            <= `REQUEST;
                            tpa           <= send_ip_addr_request;
                            tha           <= 48'h0;
                            clear_to_send <= 1'b1;
                        end
                        else
                        begin
                            ip_request_buffer    <= send_ip_addr_request;
                            request_buffer_valid <= 1'b1;
                            clear_to_send        <= 1'b0;
                        end
                        ip_reply_buffer    <= send_ip_addr_reply;
                        reply_buffer_valid <= 1'b1;
                        mac_reply_buffer   <= send_mac_addr_reply;
                    end
                    
                    default:
                    begin
                        
                    end
            endcase
            
            if (send_buffer_ready)
            begin
                case(word_counter)
                    3'd0:
                    begin
                        if (clear_to_send)
                        begin
                            arp_data      <= {hard_type,prot_type};
                            arp_valid     <= 1'b1;
                            word_counter  <= word_counter + 1;
                            clear_to_send <= 1'b0;
                            
                            if (op == `REQUEST)
                            begin
                                arp_mac_addr <= 48'hFFFFFFFFFFFF;
                            end
                            else begin
                                arp_mac_addr <= tha;
                            end
                        end
                        else begin
                            arp_valid <= 1'b0;
                        end
                    end
                    
                    3'd1:
                    begin
                        arp_data     <= {hard_len, prot_len, op};
                        arp_valid    <= 1'b1;
                        word_counter <= word_counter + 1;
                    end
                    
                    3'd2:
                    begin
                        arp_data     <= sha[47:16];
                        arp_valid    <= 1'b1;
                        word_counter <= word_counter + 1;
                    end
                    
                    3'd3:
                    begin
                        arp_data     <= {sha[15:0], spa[31:16]};
                        arp_valid    <= 1'b1;
                        word_counter <= word_counter + 1;
                    end
                    
                    3'd4:
                    begin
                        arp_data     <= {spa[15:0], tha[47:32]};
                        arp_valid    <= 1'b1;
                        word_counter <= word_counter + 1;
                    end
                    
                    3'd5:
                    begin
                        arp_data     <= tha[31:0];
                        arp_valid    <= 1'b1;
                        word_counter <= word_counter + 1;
                    end
                    
                    3'd6:
                    begin
                        arp_data     <= tpa;
                        arp_valid    <= 1'b1;
                        word_counter <= 3'd0;
                    end
                    
                    default:
                    begin
                        arp_data     <= 32'b0;
                        arp_valid    <= 1'b0;
                        word_counter <= 3'b0;
                    end
                endcase
            end
            else
            begin
                arp_valid <= 1'b0;
            end
        end
    end
    
endmodule
