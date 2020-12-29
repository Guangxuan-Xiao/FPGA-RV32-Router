module regfile(
    input wire clk,
    input wire rst,

    input wire we,
    input wire [4:0] waddr,
    input wire [31:0] wdata,

    input wire re1,
    input wire [4:0] raddr1,
    output reg [31:0] rdata1,

    input wire re2,
    input wire [4:0] raddr2,
    output reg [31:0] rdata2
);

reg[31:0] regs[31:0];

// write
always @(posedge clk) begin
    if (rst == 1'b0) begin
        if (we == 1'b1 && waddr != 5'b00000) begin
            regs[waddr] <= wdata;
        end
    end
    else
    begin
        regs [0] = 0;
        regs [1] = 0;
        regs [2] = 0;
        regs [3] = 0;
        regs [4] = 0;
        regs [5] = 0;
        regs [6] = 0;
        regs [7] = 0;
        regs [8] = 0;
        regs [9] = 0;
        regs [10] = 0;
        regs [11] = 0;
        regs [12] = 0;
        regs [13] = 0;
        regs [14] = 0;
        regs [15] = 0;
        regs [16] = 0;
        regs [17] = 0;
        regs [18] = 0;
        regs [19] = 0;
        regs [20] = 0;
        regs [21] = 0;
        regs [22] = 0;
        regs [23] = 0;
        regs [24] = 0;
        regs [25] = 0;
        regs [26] = 0;
        regs [27] = 0;
        regs [28] = 0;
        regs [29] = 0;
        regs [30] = 0;
        regs [31] = 0;

    end
end

// read1
always @(*) begin
    if (re1 ==  1'b1) begin
        if (raddr1 == 5'b00000) begin // must check first, think waddr = 0, we = 1, wdata != 0
            rdata1 <= 0;
        end else if (raddr1 == waddr && we == 1'b1) begin
            rdata1 <= wdata;
        end else begin
            rdata1 <= regs[raddr1];
        end
    end else begin
        rdata1 <= 0;
    end
end

// read2, copy from read1, change 1 to 2
always @(*) begin
    if (re2 == 1'b1) begin
        if (raddr2 == 5'b00000) begin // must check first, think waddr = 0, we = 1, wdata != 0
            rdata2 <= 0;
        end else if (raddr2 == waddr && we == 1'b1) begin
            rdata2 <= wdata;
        end else begin
            rdata2 <= regs[raddr2];
        end
    end else begin
        rdata2 <= 0;
    end
end

endmodule