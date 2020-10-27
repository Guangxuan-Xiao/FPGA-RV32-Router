`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2020 08:25:21 AM
// Design Name: 
// Module Name: tb_blk_mem_gen_0
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_blk_mem_gen_0(

    );

    reg reset;
    initial begin
        reset = 1;
        #15
        reset = 0;
    end

    wire clka;
    wire clkb;

    clock clock_a(
        .clk_50M(clka)
    );

    clock clock_b(
        .clk_50M(clkb)
    );

    wire ena;
    reg enablea;
    assign ena = enablea;
    wire wea;
    reg wenablea;
    assign wea = wenablea;
    wire [3 : 0] addra;
    reg [3 : 0] addressa;
    assign addra = addressa;
    wire [15 : 0] dina;
    reg [15 : 0] dataina;
    assign dina = dataina;
    wire [15 : 0] douta;

    wire enb;
    reg enableb;
    assign enb = enableb;
    wire web;
    reg wenableb;
    assign web = wenableb;
    wire [3 : 0] addrb;
    reg [3 : 0] addressb;
    assign addrb = addressb;
    wire [15 : 0] dinb;
    reg [15 : 0] datainb;
    assign dinb = datainb;
    wire [15 : 0] doutb;

    blk_mem_gen_0 blk_mem_gen (
    .clka(clka),    // input wire clka
    .ena(ena),      // input wire ena
    .wea(wea),      // input wire [0 : 0] wea
    .addra(addra),  // input wire [3 : 0] addra
    .dina(dina),    // input wire [15 : 0] dina
    .douta(douta),  // output wire [15 : 0] douta
    .clkb(clkb),    // input wire clkb
    .enb(enb),      // input wire enb
    .web(web),      // input wire [0 : 0] web
    .addrb(addrb),  // input wire [3 : 0] addrb
    .dinb(dinb),    // input wire [15 : 0] dinb
    .doutb(doutb)  // output wire [15 : 0] doutb
    );

    always @ (posedge clka) begin
        if (reset) begin
            enablea <= 0;
            enableb <= 0;
            wenablea <= 0;
            wenableb <= 0;
            addressa <= 0;
            addressb <= 1;
            dataina <= 0;
            datainb <= 0;
        end
        else if (!enablea) begin
            enablea <= 1;
            enableb <= 1;
            wenablea <= 1;
        end
        else begin
            addressa <= addressa + 1;
            addressb <= addressb + 1;
            dataina <= dataina + 1;
        end
    end
endmodule
