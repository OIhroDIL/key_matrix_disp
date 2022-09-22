`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/26 16:27:20
// Design Name: 
// Module Name: key_val_assign
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


module key_val_assign(
//input 
input           rst, 
input           clk,
input           nkpls,
input           [4:0] nkv,
//output 
output          reg koff,
output          reg [3:0] bcds
);

reg             pl0,pl1;

//--------------SHIFT REGISTER FOR DETECT EDGE OF NKPLS--------------------
always@(negedge rst, posedge clk)
    if(rst == 0)
        begin   
            pl0 <= 0;
            pl1 <= 1;
        end 
    else
        begin
            pl0 <= nkpls;
            pl1 <= pl0;
        end 

//-----------------NO KEY & KEY OFF CHECK--------------
always@(negedge rst, posedge clk)
    if(rst == 0)
        begin
            koff <= 1;
            bcds <= 4'hf;
        end 
    else if((pl0 & ~pl1) == 1)
        if(nkv == 0)
            koff <= 1;
        else
            begin
                koff <= 0;
                if      (nkv == 03) bcds <= 4'h0;  
                else if (nkv == 07) bcds <= 4'h1;
                else if (nkv == 08) bcds <= 4'h2;
                else if (nkv == 09) bcds <= 4'h3;
                else if (nkv == 12) bcds <= 4'h4;
                else if (nkv == 13) bcds <= 4'h5;
                else if (nkv == 14) bcds <= 4'h6;
                else if (nkv == 17) bcds <= 4'h7;
                else if (nkv == 18) bcds <= 4'h8;
                else if (nkv == 19) bcds <= 4'h9;
                else                bcds <= 4'hf;
             end     
    else
        begin
        end 
          
endmodule 
   