`include "define.v"
module ex(
    input wire rst,
    
    input wire [7:0] aluop_i,
    input wire [2:0] alusel_i,
    input wire [31:0] reg1_i,
    input wire [31:0] reg2_i,
    input wire [4:0] wd_i,
    input wire wreg_i,
    input wire [31:0] link_addr_i,
    input wire [31:0] ram_offset_i,
    input wire [31:0] inst_i,
    input wire [31:0] excepttype_i,
    input wire [31:0] current_inst_address_i,

    output reg [4:0] wd_o,
    output reg wreg_o,
    output reg mem_stall,
    output reg [31:0] wdata_o,
    output reg [7:0] aluop_o,
    output reg [31:0] ram_addr_o,
    output wire [31:0] excepttype_o,
    output wire [31:0] current_inst_address_o
);

reg[31:0] moveres, logicout, shiftout, arithout, ramout;

assign excepttype_o = excepttype_i;
assign current_inst_address_o = current_inst_address_i;

always @(*) begin
    case (aluop_i)
        `EXE_ADD_OP: begin
            arithout <= reg1_i + reg2_i;
        end
        `EXE_SUB_OP: begin
            arithout <= reg1_i - reg2_i;
        end
        `EXE_LUI_OP: begin
            arithout <= reg1_i;
        end
        `EXE_AUIPC_OP: begin
            arithout <= reg1_i;
        end
        default: begin
            arithout <= 0;
        end
    endcase
end

always @(*) begin
    case (aluop_i)
        `EXE_SLL_OP: begin
            shiftout <= reg1_i << reg2_i[4:0];
        end
        `EXE_SRL_OP: begin
            shiftout <= reg1_i >> reg2_i[4:0];
        end
        `EXE_SRA_OP: begin
            shiftout <= ($signed(reg1_i)) >>> reg2_i[4:0];
        end
        default: begin
            shiftout <= 0;
        end
    endcase
end

always @(*) begin
    case (aluop_i)
        `EXE_SLT_OP: begin
            case({reg1_i[31], reg2_i[31]})
                2'b01: begin
                    logicout <= 0;
                end
                2'b10: begin
                    logicout <= 1;
                end
                default: begin
                    if (reg1_i < reg2_i) begin
                        logicout <= 1;
                    end
                    else begin
                        logicout <= 0;
                    end
                end
            endcase
        end
        `EXE_SLTU_OP: begin
            if (reg1_i < reg2_i) begin
                logicout <= 1;
            end
            else begin
                logicout <= 0;
            end
        end
        `EXE_XOR_OP: begin
            logicout <= reg1_i ^ reg2_i;
        end
        `EXE_OR_OP: begin
            logicout <= reg1_i | reg2_i;
        end
        `EXE_AND_OP: begin
            logicout <= reg1_i & reg2_i;
        end
        default: begin
            logicout <= 0;
        end
    endcase
end

always @(*) begin
    ramout <= 0;
    case (aluop_i)
        `EXE_SB_OP: begin
            ramout <= reg2_i;
        end
        `EXE_SH_OP: begin
            ramout <= reg2_i;
        end
        `EXE_SW_OP: begin
            ramout <= reg2_i;
        end
        default: begin
            ramout <= 0;
        end
    endcase
end

always @ (*)
begin
    case (aluop_i)
        `EXE_LB_OP: begin
            mem_stall <= 1;
        end
        `EXE_LH_OP: begin
            mem_stall <= 1;
        end
        `EXE_LW_OP: begin
            mem_stall <= 1;
        end
        `EXE_LBU_OP: begin
            mem_stall <= 1;
        end
        `EXE_LHU_OP: begin
            mem_stall <= 1;
        end
        default: begin
            mem_stall <= 0;
        end
    endcase
end

always @(*) begin
    wd_o <= wd_i;
    wreg_o <= wreg_i;
    ram_addr_o <= alusel_i == `EXE_RES_RAM ? ram_offset_i + reg1_i : 0;
    aluop_o <= aluop_i;
    case (alusel_i)
        `EXE_RES_LOGIC: begin
            wdata_o <= logicout;
        end
        `EXE_RES_SHIFT: begin
            wdata_o <= shiftout;
        end
        `EXE_RES_ARITHMETIC: begin
            wdata_o <= arithout;
        end
        `EXE_RES_BRANCH: begin
            wdata_o <= link_addr_i;
        end
        `EXE_RES_RAM: begin
            wdata_o <= ramout;
        end
        `EXE_RES_MOVE: begin
            wdata_o <= moveres;
        end
        default: begin
            wdata_o <= 32'b0;
        end
    endcase
end

endmodule