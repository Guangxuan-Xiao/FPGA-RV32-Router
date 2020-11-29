`default_nettype none
`include "define.v"

module mem(input wire rst,
           input wire[4:0] wd_i,
           input wire wreg_i,
           input wire[31:0] wdata_i,
           input wire[7:0] alu_op_i,
           input wire[31:0] ram_addr_i,
           input wire[31:0] excepttype_i,
           input wire[31:0] current_inst_address_i,
           output reg[4:0] wd_o,
           output reg wreg_o,
           output reg[31:0] wdata_o,
           input wire[31:0] ram_data_i,
           output wire[31:0] mem_ram_data_o,
           output reg[31:0] mem_ram_addr_o,
           output reg[3:0] mem_ram_be_o,             // byte enable
           output wire mem_ram_we_o,                 // write enable
           output reg mem_ram_oe_o,                  // read enable
           output reg[31:0] excepttype_o,
           output wire[31:0] current_inst_address_o,
           output reg[31:0] syscall_bias,
           output reg not_align,
           output reg mem_ram_req,
           input wire mem_ram_ready);
    
    reg[31:0] data_to_write;
    assign mem_ram_data_o = data_to_write;
    reg ram_we;
    assign mem_ram_we_o           = ram_we;
    assign current_inst_address_o = current_inst_address_i;
    always @(*)
    begin
        wd_o           = wd_i;
        wreg_o         = wreg_i;
        wdata_o        = wdata_i;
        mem_ram_addr_o = 0;
        mem_ram_be_o   = 0;
        ram_we         = 0;
        mem_ram_oe_o   = 0;
        data_to_write  = 0;
        not_align      = 0;
        mem_ram_req    = 0;
        case (alu_op_i)
            `EXE_LB_OP: begin
                mem_ram_addr_o = ram_addr_i;
                ram_we         = 0;
                mem_ram_oe_o   = 1;
                mem_ram_req    = 1;
                mem_ram_be_o   = 4'b1111;
                case (ram_addr_i[1:0])
                    2'b11: begin
                        wdata_o = {{24{ram_data_i[31]}}, ram_data_i[31:24]};
                    end
                    2'b10: begin
                        wdata_o = {{24{ram_data_i[23]}}, ram_data_i[23:16]};
                    end
                    2'b01: begin
                        wdata_o = {{24{ram_data_i[15]}}, ram_data_i[15:8]};
                    end
                    2'b00: begin
                        wdata_o = {{24{ram_data_i[7]}}, ram_data_i[7:0]};
                    end
                endcase
            end
            `EXE_LH_OP: begin
                mem_ram_addr_o = ram_addr_i;
                ram_we         = 0;
                mem_ram_oe_o   = 1;
                mem_ram_req    = 1;
                mem_ram_be_o   = 4'b1111;
                case (ram_addr_i[1])
                    1'b1: begin
                        wdata_o = {{16{ram_data_i[31]}}, ram_data_i[31:16]};
                    end
                    1'b0: begin
                        wdata_o = {{16{ram_data_i[15]}}, ram_data_i[15:0]};
                    end
                endcase
            end
            `EXE_LW_OP:
            begin
                mem_ram_addr_o = ram_addr_i;
                ram_we         = 0;
                mem_ram_oe_o   = 1;
                mem_ram_be_o   = 4'b1111;
                wdata_o        = ram_data_i;
                mem_ram_req    = 1;
            end
            `EXE_LBU_OP: begin
                mem_ram_addr_o = ram_addr_i;
                ram_we         = 0;
                mem_ram_oe_o   = 1;
                mem_ram_req    = 1;
                mem_ram_be_o   = 4'b1111;
                case (ram_addr_i[1:0])
                    2'b11: begin
                        wdata_o = {24'b0, ram_data_i[31:24]};
                    end
                    2'b10: begin
                        wdata_o = {24'b0, ram_data_i[23:16]};
                    end
                    2'b01: begin
                        wdata_o = {24'b0, ram_data_i[15:8]};
                    end
                    2'b00: begin
                        wdata_o = {24'b0, ram_data_i[7:0]};
                    end
                endcase
            end
            `EXE_LHU_OP: begin
                mem_ram_addr_o = ram_addr_i;
                ram_we         = 0;
                mem_ram_oe_o   = 1;
                mem_ram_req    = 1;
                mem_ram_be_o   = 4'b1111;
                case (ram_addr_i[1])
                    1'b1: begin
                        wdata_o = {16'b0, ram_data_i[31:16]};
                    end
                    1'b0: begin
                        wdata_o = {16'b0, ram_data_i[15:0]};
                    end
                endcase
            end
            `EXE_SB_OP:
            begin
                mem_ram_addr_o = ram_addr_i;
                ram_we         = 1;
                mem_ram_oe_o   = 0;
                data_to_write  = {wdata_i[7:0], wdata_i[7:0], wdata_i[7:0], wdata_i[7:0]};
                mem_ram_req    = 1;
                case (ram_addr_i[1:0])
                    2'b11: begin
                        mem_ram_be_o = 4'b1000;
                    end
                    2'b10: begin
                        mem_ram_be_o = 4'b0100;
                    end
                    2'b01: begin
                        mem_ram_be_o = 4'b0010;
                    end
                    2'b00: begin
                        mem_ram_be_o = 4'b0001;
                    end
                endcase
            end
            `EXE_SH_OP:
            begin
                mem_ram_addr_o = ram_addr_i;
                ram_we         = 1;
                mem_ram_oe_o   = 0;
                data_to_write  = {wdata_i[15:0], wdata_i[15:0]};
                mem_ram_req    = 1;
                case (ram_addr_i[1])
                    1'b1: begin
                        mem_ram_be_o = 4'b1100;
                    end
                    1'b0: begin
                        mem_ram_be_o = 4'b0011;
                    end
                endcase
            end
            `EXE_SW_OP:
            begin
                mem_ram_addr_o = ram_addr_i;
                ram_we         = 1;
                mem_ram_oe_o   = 0;
                mem_ram_be_o   = 4'b1111;
                data_to_write  = wdata_i;
                mem_ram_req    = 1;
            end
        endcase
    end
endmodule
