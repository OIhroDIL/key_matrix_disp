`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/26 17:16:54
// Design Name: 
// Module Name: seg_ctl
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


module seg_ctl(
input rst , clk,
input [3:0] enc,
input [31:0] bcd8d,
output reg[7:0] seg_d, seg_com
    );
reg [17:0] tcnt;
reg [2:0] digit_sel;

wire [3:0] d7h, d6h,d5h, d4h, d3h, d2h, d1h, d0h;
reg [3:0] sdh;

wire [6:0] segd;

//TCNT & DIGIT_SEL GENERATION 
always@(negedge rst, posedge clk)
    if(rst == 0)
        begin   
            tcnt <= 0;
            digit_sel <= 0;
        end 
    else 
        begin 
            tcnt <= tcnt +1;
            case(~enc)
            4'h0    :   digit_sel <= tcnt[02:00];    
            4'h1    :   digit_sel <= tcnt[03:01];    
            4'h2    :   digit_sel <= tcnt[04:02];    
            4'h3    :   digit_sel <= tcnt[05:03];    
            4'h4    :   digit_sel <= tcnt[06:04];    
            4'h5    :   digit_sel <= tcnt[07:05];    
            4'h6    :   digit_sel <= tcnt[08:06];    
            4'h7    :   digit_sel <= tcnt[09:07];    
            4'h8    :   digit_sel <= tcnt[10:08];    
            4'h9    :   digit_sel <= tcnt[11:09];    
            4'ha    :   digit_sel <= tcnt[12:10];    
            4'hb    :   digit_sel <= tcnt[13:11];    
            4'hc    :   digit_sel <= tcnt[14:12];    
            4'hd    :   digit_sel <= tcnt[15:13];    
            4'he    :   digit_sel <= tcnt[16:14];    
            default :   digit_sel <= tcnt[17:15];    
            endcase 
        end 

//d#h GENERATION 
assign d7h = bcd8d[31:28];
assign d7h = bcd8d[27:24];
assign d7h = bcd8d[23:20];
assign d7h = bcd8d[19:16];
assign d7h = bcd8d[15:12];
assign d7h = bcd8d[11:08];
assign d7h = bcd8d[07:04];
assign d7h = bcd8d[03:00];

// HEX TO SEGMENT DATA CONVERTING 
assign sedg =   (sdh == 4'h0) ? (7'h3f):    
                (sdh == 4'h1) ? (7'h06): 
                (sdh == 4'h2) ? (7'h5b): 
                (sdh == 4'h3) ? (7'h4f): 
                (sdh == 4'h4) ? (7'h66): 
                (sdh == 4'h5) ? (7'h6d): 
                (sdh == 4'h6) ? (7'h7d): 
                (sdh == 4'h7) ? (7'h27): 
                (sdh == 4'h8) ? (7'h7f): 
                (sdh == 4'h9) ? (7'h6f): 
                                (7'h00);
                                
// OUTPUT SELECTION
always@(negedge rst, posedge clk)
    if(rst == 0)
        begin 
            seg_d <= 8'h00;
            seg_com <= 8'h00;
        end 
    else 
        begin
            seg_d <= {1'b0, segd};
            case(digit_sel)
            3'd0        : seg_com <= 8'h01;        
            3'd1        : seg_com <= 8'h02;        
            3'd2        : seg_com <= 8'h04;        
            3'd3        : seg_com <= 8'h08;        
            3'd4        : seg_com <= 8'h10;        
            3'd5        : seg_com <= 8'h20;        
            3'd6        : seg_com <= 8'h40;        
            default     : seg_com <= 8'h80;
            endcase       
        end 
        
    
endmodule
