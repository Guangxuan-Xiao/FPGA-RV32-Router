`include "define.v"

module id(input wire rst,
          input wire [31:0] pc_i,
          input wire [31:0] inst_i,
          input wire [31:0] reg1_data_i,
          input wire [31:0] reg2_data_i,
          input wire ex_wreg_i,
          input wire [4:0] ex_wd_i,
          input wire [31:0] ex_wdata_i,
          input wire mem_wreg_i,
          input wire [4:0] mem_wd_i,
          input wire [31:0] mem_wdata_i,
          input wire [7:0] pre_aluop,
          input wire pre_reg1_read,
          input wire pre_reg2_read,
          input wire pre_wreg,
          input wire [4:0] pre_reg1_addr,
          input wire [4:0] pre_reg2_addr,
          input wire [4:0] pre_wd,
          output reg reg1_read_o,
          output reg reg2_read_o,
          output reg [4:0] reg1_addr_o,
          output reg [4:0] reg2_addr_o,
          output reg [7:0] aluop_o,
          output reg [2:0] alusel_o,
          output reg [31:0] reg1_o,
          output reg [31:0] reg2_o,
          output reg [4:0] wd_o,
          output reg wreg_o,
          output reg branch_flag_o,
          output reg [31:0] branch_target_addr_o,
          output reg [31:0] link_addr_o,
          output reg [31:0] ram_offset_o,
          output wire stall_req_o,
          output wire [31:0] inst_o,
          output wire [31:0] excepttype_o,
          output wire [31:0] current_inst_address_o,
          input wire taken);
    
    // Instruction Decode result
    wire [6:0] ins_opcode = inst_i[6:0];
    wire [4:0] ins_rs1    = inst_i[19:15];
    wire [4:0] ins_rs2    = inst_i[24:20];
    wire [4:0] ins_rd     = inst_i[11:7];
    wire [4:0] ins_shamt  = inst_i[24:20];
    wire [6:0] ins_funct7 = inst_i[31:25];
    wire [2:0] ins_funct3 = inst_i[14:12];
    wire [11:0] ins_imm_i = inst_i[31:20];
    wire [11:0] ins_imm_s = {inst_i[31:25], inst_i[11:7]};
    wire [11:0] ins_imm_b = {inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8]};
    wire [19:0] ins_imm_u = inst_i[31:12];
    wire [19:0] ins_imm_j = {inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21]};
    wire jump_b           = inst_i[31];

    // Instruction Decode process result
    wire [31:0] imm_i_signed = {{20{ins_imm_i[11]}}, ins_imm_i};
    wire [31:0] imm_i_shamt  = {27'b0, ins_shamt};
    wire [31:0] imm_s_signed = {{20{ins_imm_s[11]}}, ins_imm_s};
    wire [31:0] pc_next      = pc_i + 32'h00000004;
    wire [31:0] pc_next_b    = pc_i + {{19{ins_imm_b[11]}}, ins_imm_b, 1'b0};
    wire [31:0] pc_next_j    = pc_i + {{11{ins_imm_j[19]}}, ins_imm_j, 1'b0};
    wire [31:0] imm_b_signed = {{19{ins_imm_b[11]}}, ins_imm_b, 1'b0};
    wire [31:0] imm_lui      = {ins_imm_u, 12'b0};
    wire [31:0] imm_auipc    = pc_i + {ins_imm_u, 12'b0};
    
    reg [31:0] imm_reg;
    reg instvalid;
    parameter INSTVALID   = 0;
    parameter INSTINVALID = 1;
    reg branch;
    
    reg stall_data     = 0;
    reg stall_branch   = 0;
    reg stall_load     = 0;
    assign stall_req_o = stall_load | stall_branch | stall_data;
    assign inst_o      = inst_i;
    
    reg is_syscall;
    reg is_eret;
    assign excepttype_o           = {19'b0, is_eret, 3'b0, is_syscall, 8'b0};
    assign current_inst_address_o = pc_i;
    
    always @ (*)
    begin
        aluop_o     = 0;
        alusel_o    = 0;
        wd_o        = 0;
        wreg_o      = 0;
        reg1_read_o = 0;
        reg2_read_o = 0;
        reg1_addr_o = ins_rs1;
        reg2_addr_o = ins_rs2;
        imm_reg     = 0;
        
        branch_flag_o        = 0;
        branch_target_addr_o = 0;
        link_addr_o          = 0;
        
        ram_offset_o = 0;
        is_syscall   = 0;
        is_eret      = 0;
        instvalid    = INSTINVALID;
        
        stall_load = 0;
        stall_branch = 0;
        case(ins_opcode)
            `EXE_CAL_FUNC: begin
                case (ins_funct3)
                    `EXE_ADD_FUNC: begin
                        case (ins_funct7)
                            `EXE_SUB_FUNC: begin
                                wreg_o      = 1;
                                aluop_o     = `EXE_SUB_OP;
                                alusel_o    = `EXE_RES_ARITHMETIC;
                                reg1_read_o = 1;
                                reg2_read_o = 1;
                                imm_reg     = 0;
                                wd_o        = ins_rd;
                                instvalid   = INSTVALID;
                            end
                            default: begin
                                wreg_o      = 1;
                                aluop_o     = `EXE_ADD_OP;
                                alusel_o    = `EXE_RES_ARITHMETIC;
                                reg1_read_o = 1;
                                reg2_read_o = 1;
                                imm_reg     = 0;
                                wd_o        = ins_rd;
                                instvalid   = INSTVALID;
                            end
                        endcase
                    end
                    `EXE_SLL_FUNC: begin
                        wreg_o      = 1;
                        aluop_o     = `EXE_SLL_OP;
                        alusel_o    = `EXE_RES_SHIFT;
                        reg1_read_o = 1;
                        reg2_read_o = 1;
                        imm_reg     = 0;
                        wd_o        = ins_rd;
                        instvalid   = INSTVALID;
                    end
                    `EXE_SLT_FUNC: begin
                        wreg_o      = 1;
                        aluop_o     = `EXE_SLT_OP;
                        alusel_o    = `EXE_RES_LOGIC;
                        reg1_read_o = 1;
                        reg2_read_o = 1;
                        imm_reg     = 0;
                        wd_o        = ins_rd;
                        instvalid   = INSTVALID;
                    end
                    `EXE_SLTU_FUNC: begin
                        wreg_o      = 1;
                        aluop_o     = `EXE_SLTU_OP;
                        alusel_o    = `EXE_RES_LOGIC;
                        reg1_read_o = 1;
                        reg2_read_o = 1;
                        imm_reg     = 0;
                        wd_o        = ins_rd;
                        instvalid   = INSTVALID;
                    end
                    `EXE_XOR_FUNC: begin
                        wreg_o      = 1;
                        aluop_o     = `EXE_XOR_OP;
                        alusel_o    = `EXE_RES_LOGIC;
                        reg1_read_o = 1;
                        reg2_read_o = 1;
                        imm_reg     = 0;
                        wd_o        = ins_rd;
                        instvalid   = INSTVALID;
                    end
                    `EXE_SRL_FUNC: begin
                        case (ins_funct7)
                            `EXE_SRA_FUNC: begin
                                wreg_o      = 1;
                                aluop_o     = `EXE_SRA_OP;
                                alusel_o    = `EXE_RES_SHIFT;
                                reg1_read_o = 1;
                                reg2_read_o = 1;
                                imm_reg     = 0;
                                wd_o        = ins_rd;
                                instvalid   = INSTVALID;
                            end
                            default: begin
                                wreg_o      = 1;
                                aluop_o     = `EXE_SRL_OP;
                                alusel_o    = `EXE_RES_SHIFT;
                                reg1_read_o = 1;
                                reg2_read_o = 1;
                                imm_reg     = 0;
                                wd_o        = ins_rd;
                                instvalid   = INSTVALID;
                            end
                        endcase
                    end
                    `EXE_OR_FUNC: begin
                        wreg_o      = 1;
                        aluop_o     = `EXE_OR_OP;
                        alusel_o    = `EXE_RES_LOGIC;
                        reg1_read_o = 1;
                        reg2_read_o = 1;
                        imm_reg     = 0;
                        wd_o        = ins_rd;
                        instvalid   = INSTVALID;
                    end
                    `EXE_AND_FUNC: begin
                        wreg_o      = 1;
                        aluop_o     = `EXE_AND_OP;
                        alusel_o    = `EXE_RES_LOGIC;
                        reg1_read_o = 1;
                        reg2_read_o = 1;
                        imm_reg     = 0;
                        wd_o        = ins_rd;
                        instvalid   = INSTVALID;
                    end
                    default: begin
                        wreg_o      = 0;
                        aluop_o     = `EXE_NOP_OP;
                        alusel_o    = `EXE_RES_NOP;
                        reg1_read_o = 0;
                        reg2_read_o = 0;
                        imm_reg     = 0;
                        wd_o        = 0;
                        instvalid   = INSTVALID;
                    end
                endcase
            end
            `EXE_CALI_FUNC: begin
                case(ins_funct3)
                    `EXE_ADDI_FUNC: begin
                        wreg_o      = 1;
                        aluop_o     = `EXE_ADD_OP;
                        alusel_o    = `EXE_RES_ARITHMETIC;
                        reg1_read_o = 1;
                        reg2_read_o = 0;
                        imm_reg     = imm_i_signed;
                        wd_o        = ins_rd;
                        instvalid   = INSTVALID;
                    end
                    `EXE_SLLI_FUNC: begin
                        wreg_o      = 1;
                        aluop_o     = `EXE_SLL_OP;
                        alusel_o    = `EXE_RES_SHIFT;
                        reg1_read_o = 1;
                        reg2_read_o = 0;
                        imm_reg     = imm_i_shamt;
                        wd_o        = ins_rd;
                        instvalid   = INSTVALID;
                    end
                    `EXE_SLTI_FUNC: begin
                        wreg_o      = 1;
                        aluop_o     = `EXE_SLT_OP;
                        alusel_o    = `EXE_RES_LOGIC;
                        reg1_read_o = 1;
                        reg2_read_o = 0;
                        imm_reg     = imm_i_signed;
                        wd_o        = ins_rd;
                        instvalid   = INSTVALID;
                    end
                    `EXE_SLTIU_FUNC: begin
                        wreg_o      = 1;
                        aluop_o     = `EXE_SLTU_OP;
                        alusel_o    = `EXE_RES_LOGIC;
                        reg1_read_o = 1;
                        reg2_read_o = 0;
                        imm_reg     = imm_i_signed;
                        wd_o        = ins_rd;
                        instvalid   = INSTVALID;
                    end
                    `EXE_XORI_FUNC: begin
                        wreg_o      = 1;
                        aluop_o     = `EXE_XOR_OP;
                        alusel_o    = `EXE_RES_LOGIC;
                        reg1_read_o = 1;
                        reg2_read_o = 0;
                        imm_reg     = imm_i_signed;
                        wd_o        = ins_rd;
                        instvalid   = INSTVALID;
                    end
                    `EXE_SRLI_FUNC: begin
                        case (ins_funct7)
                            `EXE_SRAI_FUNC: begin
                                wreg_o      = 1;
                                aluop_o     = `EXE_SRA_OP;
                                alusel_o    = `EXE_RES_SHIFT;
                                reg1_read_o = 1;
                                reg2_read_o = 0;
                                imm_reg     = imm_i_shamt;
                                wd_o        = ins_rd;
                                instvalid   = INSTVALID;
                            end
                            default: begin
                                wreg_o      = 1;
                                aluop_o     = `EXE_SRL_OP;
                                alusel_o    = `EXE_RES_SHIFT;
                                reg1_read_o = 1;
                                reg2_read_o = 0;
                                imm_reg     = imm_i_shamt;
                                wd_o        = ins_rd;
                                instvalid   = INSTVALID;
                            end
                        endcase
                    end
                    `EXE_ORI_FUNC: begin
                        wreg_o      = 1;
                        aluop_o     = `EXE_OR_OP;
                        alusel_o    = `EXE_RES_LOGIC;
                        reg1_read_o = 1;
                        reg2_read_o = 0;
                        imm_reg     = imm_i_signed;
                        wd_o        = ins_rd;
                        instvalid   = INSTVALID;
                    end
                    `EXE_ANDI_FUNC: begin
                        wreg_o      = 1;
                        aluop_o     = `EXE_AND_OP;
                        alusel_o    = `EXE_RES_LOGIC;
                        reg1_read_o = 1;
                        reg2_read_o = 0;
                        imm_reg     = imm_i_signed;
                        wd_o        = ins_rd;
                        instvalid   = INSTVALID;
                    end
                    default:
                    begin
                        wreg_o      = 0;
                        aluop_o     = `EXE_NOP_OP;
                        alusel_o    = `EXE_RES_NOP;
                        reg1_read_o = 0;
                        reg2_read_o = 0;
                        imm_reg     = 0;
                        wd_o        = 0;
                        instvalid   = INSTVALID;
                    end
                endcase
            end
            `EXE_LOAD_FUNC: begin
                case(ins_funct3)
                    `EXE_LB_FUNC: begin
                        wreg_o       = 1;
                        aluop_o      = `EXE_LB_OP;
                        alusel_o     = `EXE_RES_RAM;
                        reg1_read_o  = 1;
                        reg2_read_o  = 0;
                        imm_reg      = imm_i_signed;
                        wd_o         = ins_rd;
                        instvalid    = INSTVALID;
                        stall_load   = 1;
                        ram_offset_o = imm_i_signed;
                    end
                    `EXE_LH_FUNC: begin
                        wreg_o       = 1;
                        aluop_o      = `EXE_LH_OP;
                        alusel_o     = `EXE_RES_RAM;
                        reg1_read_o  = 1;
                        reg2_read_o  = 0;
                        imm_reg      = imm_i_signed;
                        wd_o         = ins_rd;
                        instvalid    = INSTVALID;
                        stall_load   = 1;
                        ram_offset_o = imm_i_signed;
                    end
                    `EXE_LW_FUNC: begin
                        wreg_o       = 1;
                        aluop_o      = `EXE_LW_OP;
                        alusel_o     = `EXE_RES_RAM;
                        reg1_read_o  = 1;
                        reg2_read_o  = 0;
                        imm_reg      = imm_i_signed;
                        wd_o         = ins_rd;
                        instvalid    = INSTVALID;
                        stall_load   = 1;
                        ram_offset_o = imm_i_signed;
                    end
                    `EXE_LBU_FUNC: begin
                        wreg_o       = 1;
                        aluop_o      = `EXE_LBU_OP;
                        alusel_o     = `EXE_RES_RAM;
                        reg1_read_o  = 1;
                        reg2_read_o  = 0;
                        imm_reg      = imm_i_signed;
                        wd_o         = ins_rd;
                        instvalid    = INSTVALID;
                        stall_load   = 1;
                        ram_offset_o = imm_i_signed;
                    end
                    `EXE_LHU_FUNC: begin
                        wreg_o       = 1;
                        aluop_o      = `EXE_LHU_OP;
                        alusel_o     = `EXE_RES_RAM;
                        reg1_read_o  = 1;
                        reg2_read_o  = 0;
                        imm_reg      = imm_i_signed;
                        wd_o         = ins_rd;
                        instvalid    = INSTVALID;
                        stall_load   = 1;
                        ram_offset_o = imm_i_signed;
                    end
                    default: begin
                        wreg_o      = 0;
                        aluop_o     = `EXE_NOP_OP;
                        alusel_o    = `EXE_RES_NOP;
                        reg1_read_o = 0;
                        reg2_read_o = 0;
                        imm_reg     = 0;
                        wd_o        = 0;
                        instvalid   = INSTVALID;
                    end
                endcase
            end
            `EXE_STORE_FUNC: begin
                case (ins_funct3)
                    `EXE_SB_FUNC: begin
                        wreg_o       = 0;
                        aluop_o      = `EXE_SB_OP;
                        alusel_o     = `EXE_RES_RAM;
                        reg1_read_o  = 1;
                        reg2_read_o  = 1;
                        imm_reg      = imm_s_signed;
                        wd_o         = 0;
                        instvalid    = INSTVALID;
                        ram_offset_o = imm_s_signed;
                    end
                    `EXE_SH_FUNC: begin
                        wreg_o       = 0;
                        aluop_o      = `EXE_SH_OP;
                        alusel_o     = `EXE_RES_RAM;
                        reg1_read_o  = 1;
                        reg2_read_o  = 1;
                        imm_reg      = imm_s_signed;
                        wd_o         = 0;
                        instvalid    = INSTVALID;
                        ram_offset_o = imm_s_signed;
                    end
                    `EXE_SW_FUNC: begin
                        wreg_o       = 0;
                        aluop_o      = `EXE_SW_OP;
                        alusel_o     = `EXE_RES_RAM;
                        reg1_read_o  = 1;
                        reg2_read_o  = 1;
                        imm_reg      = imm_s_signed;
                        wd_o         = 0;
                        instvalid    = INSTVALID;
                        ram_offset_o = imm_s_signed;
                    end
                    default: begin
                        wreg_o      = 0;
                        aluop_o     = `EXE_NOP_OP;
                        alusel_o    = `EXE_RES_NOP;
                        reg1_read_o = 0;
                        reg2_read_o = 0;
                        imm_reg     = 0;
                        wd_o        = 0;
                        instvalid   = INSTVALID;
                    end
                endcase
            end
            `EXE_BRANCH_FUNC: begin
                case (ins_funct3)
                    `EXE_BEQ_FUNC: begin
                        wreg_o      = 0;
                        aluop_o     = `EXE_BRANCH_OP;
                        alusel_o    = `EXE_RES_BRANCH;
                        reg1_read_o = 1;
                        reg2_read_o = 1;
                        imm_reg     = 0;
                        wd_o        = 0;
                        instvalid   = INSTINVALID;
                        link_addr_o = 0;
                        if (reg1_o == reg2_o)
                        begin
                            branch_flag_o        = 1;
                            branch_target_addr_o = pc_next_b;
                            stall_branch         = 1; // ~taken -> 1
                        end
                        else if (reg1_o != reg2_o)
                        begin
                            branch_flag_o        = 1;
                            branch_target_addr_o = pc_next;
                            stall_branch         = 1; // taken -> 1
                        end
                    end
                    `EXE_BNE_FUNC: begin
                        wreg_o      = 0;
                        aluop_o     = `EXE_BRANCH_OP;
                        alusel_o    = `EXE_RES_BRANCH;
                        reg1_read_o = 1;
                        reg2_read_o = 1;
                        imm_reg     = 0;
                        wd_o        = 0;
                        instvalid   = INSTINVALID;
                        link_addr_o = 0;
                        if (reg1_o != reg2_o)
                        begin
                            branch_flag_o        = 1;
                            branch_target_addr_o = pc_next_b;
                            stall_branch         = 1; // ~taken -> 1
                        end
                        else if (reg1_o == reg2_o)
                        begin
                            branch_flag_o        = 1;
                            branch_target_addr_o = pc_next;
                            stall_branch         = 1; // taken -> 1
                        end
                    end
                    `EXE_BLT_FUNC: begin
                        wreg_o      = 0;
                        aluop_o     = `EXE_BRANCH_OP;
                        alusel_o    = `EXE_RES_BRANCH;
                        reg1_read_o = 1;
                        reg2_read_o = 1;
                        imm_reg     = 0;
                        wd_o        = 0;
                        instvalid   = INSTINVALID;
                        link_addr_o = 0;
                        case({reg1_o[31], reg2_o[31]})
                            2'b01: begin
                                branch = 0;
                            end
                            2'b10: begin
                                branch = 1;
                            end
                            default: begin
                                if (reg1_o < reg2_o) begin
                                    branch = 1;
                                end
                                else begin
                                    branch = 0;
                                end
                            end
                        endcase
                        if (branch == 1'b1)
                        begin
                            branch_flag_o        = 1;
                            branch_target_addr_o = pc_next_b;
                            stall_branch         = 1; // ~taken -> 1
                        end
                        else if (branch == 1'b0)
                        begin
                            branch_flag_o        = 1;
                            branch_target_addr_o = pc_next;
                            stall_branch         = 1; // taken -> 1
                        end
                    end
                    `EXE_BGE_FUNC: begin
                        wreg_o      = 0;
                        aluop_o     = `EXE_BRANCH_OP;
                        alusel_o    = `EXE_RES_BRANCH;
                        reg1_read_o = 1;
                        reg2_read_o = 1;
                        imm_reg     = 0;
                        wd_o        = 0;
                        instvalid   = INSTINVALID;
                        link_addr_o = 0;
                        case({reg1_o[31], reg2_o[31]})
                            2'b01: begin
                                branch = 1;
                            end
                            2'b10: begin
                                branch = 0;
                            end
                            default: begin
                                if (reg1_o >= reg2_o) begin
                                    branch = 1;
                                end
                                else begin
                                    branch = 0;
                                end
                            end
                        endcase
                        if (branch == 1'b1)
                        begin
                            branch_flag_o        = 1;
                            branch_target_addr_o = pc_next_b;
                            stall_branch         = 1; // ~taken -> 1
                        end
                        else if (branch == 1'b0)
                        begin
                            branch_flag_o        = 1;
                            branch_target_addr_o = pc_next;
                            stall_branch         = 1; // taken -> 1
                        end
                    end
                    `EXE_BLTU_FUNC: begin
                        wreg_o      = 0;
                        aluop_o     = `EXE_BRANCH_OP;
                        alusel_o    = `EXE_RES_BRANCH;
                        reg1_read_o = 1;
                        reg2_read_o = 1;
                        imm_reg     = 0;
                        wd_o        = 0;
                        instvalid   = INSTINVALID;
                        link_addr_o = 0;
                        if (reg1_o < reg2_o)
                        begin
                            branch_flag_o        = 1;
                            branch_target_addr_o = pc_next_b;
                            stall_branch         = 1; // ~taken -> 1
                        end
                        else if (reg1_o >= reg2_o)
                        begin
                            branch_flag_o        = 1;
                            branch_target_addr_o = pc_next;
                            stall_branch         = 1; // taken -> 1
                        end
                    end
                    `EXE_BGEU_FUNC: begin
                        wreg_o      = 0;
                        aluop_o     = `EXE_BRANCH_OP;
                        alusel_o    = `EXE_RES_BRANCH;
                        reg1_read_o = 1;
                        reg2_read_o = 1;
                        imm_reg     = 0;
                        wd_o        = 0;
                        instvalid   = INSTINVALID;
                        link_addr_o = 0;
                        if (reg1_o >= reg2_o)
                        begin
                            branch_flag_o        = 1;
                            branch_target_addr_o = pc_next_b;
                            stall_branch         = 1; // ~taken -> 1
                        end
                        else if (reg1_o < reg2_o)
                        begin
                            branch_flag_o        = 1;
                            branch_target_addr_o = pc_next;
                            stall_branch         = 1; // taken -> 1
                        end
                    end
                    default: begin
                        wreg_o      = 0;
                        aluop_o     = `EXE_NOP_OP;
                        alusel_o    = `EXE_RES_NOP;
                        reg1_read_o = 0;
                        reg2_read_o = 0;
                        imm_reg     = 0;
                        wd_o        = 0;
                        instvalid   = INSTVALID;
                    end
                endcase
            end
            `EXE_JAL_FUNC: begin
                wreg_o               = 1;
                aluop_o              = `EXE_BRANCH_OP;
                alusel_o             = `EXE_RES_BRANCH;
                reg1_read_o          = 0;
                reg2_read_o          = 0;
                imm_reg              = 0;
                wd_o                 = ins_rd;
                link_addr_o          = pc_next;
                branch_flag_o        = 0;
                branch_target_addr_o = pc_next_j;
                stall_branch         = 0;
                instvalid            = INSTINVALID;
            end
            `EXE_JALR_FUNC: begin
                wreg_o               = 1;
                aluop_o              = `EXE_BRANCH_OP;
                alusel_o             = `EXE_RES_BRANCH;
                reg1_read_o          = 1;
                reg2_read_o          = 0;
                imm_reg              = 0;
                wd_o                 = ins_rd;
                link_addr_o          = pc_next;
                branch_flag_o        = 1;
                branch_target_addr_o = (reg1_o + imm_i_signed) & (~1);
                stall_branch         = 1;
                instvalid            = INSTINVALID;
            end
            `EXE_LUI_FUNC: begin
                wreg_o      = 1;
                aluop_o     = `EXE_LUI_OP;
                alusel_o    = `EXE_RES_ARITHMETIC;
                reg1_read_o = 0;
                reg2_read_o = 0;
                imm_reg     = imm_lui;
                wd_o        = ins_rd;
                instvalid   = INSTVALID;
            end
            `EXE_AUIPC_FUNC: begin
                wreg_o      = 1;
                aluop_o     = `EXE_AUIPC_OP;
                alusel_o    = `EXE_RES_ARITHMETIC;
                reg1_read_o = 0;
                reg2_read_o = 0;
                imm_reg     = imm_auipc;
                wd_o        = ins_rd;
                instvalid   = INSTVALID;
            end
            default:
            begin
                wreg_o      = 0;
                aluop_o     = `EXE_NOP_OP;
                alusel_o    = `EXE_RES_NOP;
                reg1_read_o = 0;
                reg2_read_o = 0;
                imm_reg     = 0;
                wd_o        = 0;
                instvalid   = INSTVALID;
            end
        endcase
    end
    
    always @ (*)
    begin
        if (reg1_read_o == 1'b1 && reg1_addr_o == 5'b00000)
        begin
            reg1_o = 0;
        end
        else if (reg1_read_o == 1'b1)
        begin
            if (ex_wreg_i == 1'b1 && ex_wd_i == reg1_addr_o)
            begin
                reg1_o = ex_wdata_i;
            end
            else if (mem_wreg_i == 1'b1 && mem_wd_i == reg1_addr_o)
            begin
                reg1_o = mem_wdata_i;
            end
            else
            begin
                reg1_o = reg1_data_i;
            end
        end
        else
        begin
            reg1_o = imm_reg;
        end
    end
    
    always @(*)
    begin
        if (reg2_read_o == 1'b1 && reg2_addr_o == 5'b00000)
        begin
            reg2_o = 0;
        end
        else if (reg2_read_o == 1'b1)
        begin
            if (ex_wreg_i == 1'b1 && ex_wd_i == reg2_addr_o)
            begin
                reg2_o = ex_wdata_i;
            end
            else if (mem_wreg_i == 1'b1 && mem_wd_i == reg2_addr_o)
            begin
                reg2_o = mem_wdata_i;
            end
            else begin
                reg2_o = reg2_data_i;
            end
        end
        else
        begin
            reg2_o = imm_reg;
        end
    end
    
    
    wire stall_req_reg1, stall_req_reg2, pre_is_load;
    assign pre_is_load    = (pre_aluop == `EXE_LB_OP ||  pre_aluop == `EXE_LW_OP);
    assign stall_req_reg1 = reg1_read_o == 1'b1 && pre_wd == reg1_addr_o;
    assign stall_req_reg2 = reg2_read_o == 1'b1 && pre_wd == reg2_addr_o;
    always @(*) begin
        stall_data = (pre_is_load == 1'b1) && (pre_wreg == 1'b1) && (pre_wd != 5'b00000) && (stall_req_reg1 || stall_req_reg2);
    end
    
endmodule
