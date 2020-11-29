module ctrl(
            input wire clk,
            input wire rst,
            input wire all_req,
            input wire id_req,
            input wire if_req,
            input wire mem_req,
            input wire ex_req,
            input wire[31:0] syscall_bias,
            output reg pc_stall_data,
            output reg pc_stall_mem,
            output reg if_stall,
            output reg id_stall,
            output reg ex_stall,
            output reg mem_stall,
            output reg wb_stall,
            input wire[31:0] excepttype_i,
            output reg[31:0] new_pc,
            output reg flush);

    always @(*) begin
        new_pc = 0;
        if (all_req == 1'b1) begin
            pc_stall_data = 1;
            pc_stall_mem  = 1;
            if_stall      = 1;
            id_stall      = 1;
            ex_stall      = 1;
            mem_stall     = 1;
            wb_stall      = 1;
            flush         = 0;
        end
        else if (mem_req == 1'b1) begin
            pc_stall_data = 1;
            pc_stall_mem  = 1;
            if_stall      = 1;
            id_stall      = 1;
            ex_stall      = 1;
            mem_stall     = 1;
            wb_stall      = 0;
            flush         = 0;
        end
        else if (id_req == 1'b1 && if_req == 1'b1) begin
            pc_stall_data = 1;
            pc_stall_mem  = 1;
            if_stall      = 1;
            id_stall      = 0;
            ex_stall      = 0;
            mem_stall     = 0;
            wb_stall      = 0;
            flush         = 0;
        end
        else if (id_req == 1'b1 && if_req == 1'b0) begin
            pc_stall_data = 1;
            pc_stall_mem  = 0;
            if_stall      = 1;
            id_stall      = 0;
            ex_stall      = 0;
            mem_stall     = 0;
            wb_stall      = 0;
            flush         = 0;
        end
        else if (if_req == 1'b1 && id_req == 1'b0) begin
            pc_stall_data = 0;
            pc_stall_mem  = 1;
            if_stall      = 1;
            id_stall      = 0;
            ex_stall      = 0;
            mem_stall     = 0;
            wb_stall      = 0;
            flush         = 0;
        end
        else begin
            pc_stall_data = 0;
            pc_stall_mem  = 0;
            if_stall      = 0;
            id_stall      = 0;
            ex_stall      = 0;
            mem_stall     = 0;
            wb_stall      = 0;
            flush         = 0;
        end
    end
endmodule
