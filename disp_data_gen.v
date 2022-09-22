`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/26 17:04:35
// Design Name: 
// Module Name: disp_data_gen
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


module disp_data_gen(
input           rst,
input           clk,
input           nkpls,
input           clr,
input           koff,
input           [3:0] bcds,
output          [31:0] bcd8d
);

reg pl0, pl1;
reg [3:0] bcd0, bcd1, bcd2, bcd3, bcd4, bcd5, bcd6, bcd7;

//------------------SHFIT FOR NKPLS EDGE DETECT 
always@(negedge rst, posedge clk)
    if(rst == 0)
        begin 
            pl0 <= 0;
            pl1 <= 0;
        end 
    else
        begin   
            pl0 <= nkpls;
            pl1 <= pl0;
        end 
        
//-----------------BCD SHIFT REGISTER 
always@(negedge rst, posedge clk)
    if(rst == 0)
        begin   
            bcd0 <= 4'hf; bcd1 <= 4'hf; bcd2 <= 4'hf; bcd3 <= 4'hf;
            bcd4 <= 4'hf; bcd5 <= 4'hf; bcd6 <= 4'hf; bcd7 <= 4'hf;
        end 
    else
        if(clr == 1 )
            begin   
                bcd0 <= 4'hf; bcd1 <= 4'hf; bcd2 <= 4'hf; bcd3 <= 4'hf;
                bcd4 <= 4'hf; bcd5 <= 4'hf; bcd6 <= 4'hf; bcd7 <= 4'hf;
            end 
        else if((~pl0 & pl1) ==1)   //FALLING EDGE 0F NKPLS
            if((koff == 0) && (bcds < 10))
                begin 
                    bcd0 <= bcds; bcd1 <= bcd0; bcd2 <= bcd1; bcd3 <= bcd2;
                    bcd4 <= bcd3; bcd5 <= bcd4; bcd6 <= bcd5; bcd7 <= bcd6;
                end 
endmodule
