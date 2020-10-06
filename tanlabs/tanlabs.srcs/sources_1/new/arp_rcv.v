module arp_rcv (input wire clk,
                input wire reset,
                input wire arp_valid,
                input wire [31:0] arp_data,
                input wire reply_ready,
                output reg [31:0] w_ip_addr,
                output reg [47:0] w_mac_addr,
                output reg w_en,
                output reg [31:0] send_ip_addr,
                output reg [47:0] send_mac_addr,
                output reg send_en);
    
    reg [2:0] word_counter;
    reg [15:0] hard_type, prot_type, op;
    reg [7:0] hard_len, prot_len;
    reg [47:0] sha, tha;
    reg [31:0] spa, tpa;
    reg set_outputs;
    
    always @(posedge clk)
    begin
        if (reset) begin
            word_counter  <= 3'd0;
            set_outputs   <= 1'b0;
            hard_type     <= 16'b0;
            prot_type     <= 16'b0;
            op            <= 16'b0;
            hard_len      <= 8'b0;
            prot_len      <= 8'b0;
            sha           <= 48'b0;
            tha           <= 48'b0;
            spa           <= 32'b0;
            tpa           <= 32'b0;
            w_ip_addr     <= 32'b0;
            w_mac_addr    <= 48'b0;
            w_en          <= 1'b0;
            send_ip_addr  <= 32'b0;
            send_mac_addr <= 48'b0;
            send_en       <= 1'b0;
        end
        else begin
            if (arp_valid && reply_ready) begin
                case (word_counter)
                    3'd0:
                    begin
                        hard_type    <= arp_data[31:16];
                        prot_type    <= arp_data[15:0];
                        word_counter <= word_counter + 1;
                        set_outputs  <= 1'b0;
                        w_en         <= 1'b0;
                        send_en      <= 1'b0;
                    end
                    3'd1:
                    begin
                        hard_len     <= arp_data[31:24];
                        prot_len     <= arp_data[23:16];
                        op           <= arp_data[15:0];
                        word_counter <= word_counter + 1;
                    end
                    3'd2:
                    begin
                        sha[47:16]   <= arp_data;
                        word_counter <= word_counter + 1;
                    end
                    3'd3:
                    begin
                        sha[15:0]    <= arp_data[31:16];
                        spa[31:16]   <= arp_data[15:0];
                        word_counter <= word_counter + 1;
                    end
                    3'd4:
                    begin
                        spa[15:0]    <= arp_data[31:16];
                        tha[47:32]   <= arp_data[15:0];
                        word_counter <= word_counter + 1;
                    end
                    3'd5:
                    begin
                        tha[31:0]    <= arp_data;
                        word_counter <= word_counter + 1;
                    end
                    3'd6:
                    begin
                        tpa          <= arp_data;
                        word_counter <= 3'd0;
                        set_outputs  <= 1'b1;
                    end
                    default:
                    begin
                        word_counter <= 3'd0;
                        set_outputs  <= 1'b0;
                    end
                endcase
            end
            else
            begin
                if (set_outputs)
                begin
                    w_en       <= 1'b1;
                    w_ip_addr  <= spa;
                    w_mac_addr <= sha;
                    if ((op == 16'h1) && reply_ready)
                    begin
                        send_en       <= 1'b1;
                        send_ip_addr  <= spa;
                        send_mac_addr <= sha;
                    end
                    else
                    begin
                        send_en <= 1'b0;
                    end
                    set_outputs <= 1'b0;
                end
                else
                begin
                    w_en    <= 1'b0;
                    send_en <= 1'b0;
                end
            end
        end
    end
endmodule
