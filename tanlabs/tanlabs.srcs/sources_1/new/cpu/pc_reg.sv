`default_nettype none
`include "define.v"
typedef struct packed {
logic valid;
logic[19:0] pc_addr;
logic[19:0] target_addr;
logic taken;
} btb_entry;
module pc_reg #(parameter CACHE_ADDR_WIDTH = 0)(
    input wire                  clk,
    input wire                  rst,
    input wire                  flush,
    input wire                  pc_stall_data,
    input wire                  pc_stall_mem,

    input wire                  branch_flag_i,
    input wire [31:0]           branch_target_addr_i,

    output reg [31:0]           pc,
    input wire [31:0]           new_pc,
    output reg                  ce,
    input wire [31:0]           inst_i,

    output reg taken
);

localparam pc_start = 32'h80000000;

wire [6:0] ins_opcode = inst_i[6:0];
wire [11:0] ins_imm_b = {inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8]};
wire [19:0] ins_imm_j = {inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21]};

wire jump_b = ins_imm_b[11];

// BTB
// wire [19:0] pc_phy_addr = pc[21:2];
reg [31:0] next_pc;
assign taken = 0;
// reg [19:0] last_pc_phy_addr; // storing last pc phy address
always_comb begin
    if (flush == 1'b1)
        begin
            next_pc = new_pc;
        end
    else if (pc_stall_data == 1'b1) begin
        if(branch_flag_i == 1'b1) begin
            next_pc = branch_target_addr_i;
        end else begin
            next_pc = pc;
        end
    end else if (pc_stall_mem == 1'b0) begin
        next_pc = pc + 32'h00000004;
        if (branch_flag_i == 1'b1) begin
            next_pc = branch_target_addr_i;
        end else if (ins_opcode == `EXE_JAL_FUNC) begin
            next_pc = {{11{ins_imm_j[19]}}, ins_imm_j, 1'b0} + pc;
        end else if (ins_opcode == `EXE_BRANCH_FUNC) begin
            // // Branch prediction
            // if (taken) next_pc = target_pc_addr;
            // else 
            if (jump_b) next_pc = {{19{ins_imm_b[11]}}, ins_imm_b, 1'b0} + pc;
        end 
    end else begin
        next_pc = pc;
    end
end

// btb_entry [(2**CACHE_ADDR_WIDTH)-1:0] cache = 0;
// logic [CACHE_ADDR_WIDTH-1:0] next         = 0;
// logic [CACHE_ADDR_WIDTH:0] ptr1           = 0;
// logic [CACHE_ADDR_WIDTH:0] ptr2           = 0;
// logic hit                                 = 0;
// logic [19:0] target_pc_phy_addr;
// wire [31:0] target_pc_addr = {10'b1000000000, target_pc_phy_addr, 2'b00};

// always_comb begin
//     target_pc_phy_addr = 0;
//     taken = 0;
//     for (ptr1 = 0; ptr1 < (2**CACHE_ADDR_WIDTH); ptr1 = ptr1 + 1) begin
//         if (cache[ptr1].valid == 1'b1 && cache[ptr1].pc_addr == pc_phy_addr) begin
//             taken = cache[ptr1].taken; // calculate from state
//             target_pc_phy_addr = cache[ptr1].target_addr;
//         end
//     end
// end

// always_ff @(posedge clk, posedge rst) begin
//     if (rst) begin
//         cache = 0;
//         next  = 0;
//         hit = 0;
//     end
//     else begin
//         hit = 0;
//         if (branch_flag_i == 1'b1) begin
//             for (ptr2 = 0; ptr2 < (2**CACHE_ADDR_WIDTH); ptr2 = ptr2 + 1) begin
//                 if (cache[ptr2].valid && cache[ptr2].pc_addr == last_pc_phy_addr) begin
//                     cache[ptr2].taken = branch_target_addr_i[21:2] == cache[ptr2].target_addr;
//                     hit = 1;
//                 end
//             end
//             if (!hit) begin
//                 cache[next].valid    = 1'b1;
//                 cache[next].pc_addr  = last_pc_phy_addr;
//                 cache[next].target_addr = branch_target_addr_i[21:2];
//                 cache[next].taken =  1'b1;
//                 next = next + 1;
//             end
//         end
//     end
// end

always @ (posedge clk)
begin
    if (rst == 1'b1)
    begin
        ce <= 1'b0;
    end
    else
    begin
        ce <= 1'b1;
    end
end

always @ (posedge clk)
begin
    if (ce == 1'b0)
    begin
        pc <= pc_start;
        // last_pc_phy_addr = pc_start[21:2];
    end
    else begin
        pc <= next_pc;
        // if (next_pc != pc) last_pc_phy_addr <= pc[21:2];
    end
end
endmodule