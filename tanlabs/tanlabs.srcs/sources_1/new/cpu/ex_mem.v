module ex_mem(
    input wire clk,
    input wire rst,
    input wire flush,
    input wire[4:0] ex_wd,
    input wire ex_wreg,
    input wire[31:0] ex_wdata,
    input wire[7:0] ex_alu_op,
    input wire[31:0] ex_ram_addr,
    input wire[31:0] ex_excepttype,
    input wire[31:0] ex_current_inst_address,
    input wire ex_stall, 
    input wire mem_stall, 

    output reg[4:0] mem_wd,
    output reg mem_wreg,
    output reg[31:0] mem_wdata,
    output reg[7:0] mem_alu_op,
    output reg[31:0] mem_ram_addr,
    output reg[31:0] mem_excepttype,
    output reg[31:0] mem_current_inst_address
);

always @(posedge clk) 
begin
    if (rst == 1'b1) 
    begin
        mem_wd                      <=      0;
        mem_wreg                    <=      0;
        mem_wdata                   <=      0;
        mem_alu_op                  <=      0;
        mem_ram_addr                <=      0;
        mem_excepttype              <=      0;
        mem_current_inst_address    <=      0;
    end 
    else if (flush == 1'b1 || ex_stall == 1'b1 && mem_stall == 1'b0) 
    begin
        mem_wd                      <=      0;
        mem_wreg                    <=      0;
        mem_wdata                   <=      0;
        mem_alu_op                  <=      0;
        mem_ram_addr                <=      0;
        mem_excepttype              <=      0;
        mem_current_inst_address    <=      0;
    end 
    else if (ex_stall == 1'b0) 
    begin
        mem_wd                      <=      ex_wd;
        mem_wreg                    <=      ex_wreg;
        mem_wdata                   <=      ex_wdata;
        mem_alu_op                  <=      ex_alu_op;
        mem_ram_addr                <=      ex_ram_addr;
        mem_excepttype              <=      ex_excepttype;
        mem_current_inst_address    <=      ex_current_inst_address;
    end
end

endmodule