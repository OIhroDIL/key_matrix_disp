`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/26 17:41:53
// Design Name: 
// Module Name: key_matrix_disp
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


module key_matrix_disp(
input       rst,
input       clk,
input       key0,
input       [3:0] enc,
input       [4:0] key_in,
input       [3:0] key_out,
output      [7:0] seg_d,
output      [7:0] seg_com,
output      reg buzz    
    );

reg pls100k;
reg [5:0] pcnt;
reg pls1k;
reg [5:0] plcnt;

reg buzzs;
reg ps0,ps1;
reg [5:0] bzcnt;

wire nkpls;
wire [4:0] nkv;

wire koff;
wire [3:0] bcds;

wire clr;
wire [31:0] bcd8d;

//---------------------------100KHz PULSE GEN. --------------------------
always@(negedge rst, posedge clk)
    if(rst == 0)
        begin
            pls100k <= 0;
            pcnt <= 0;
        end 
    else
        begin
            if(pcnt < 49)
                pcnt <= pcnt +1;
            else
                begin
                    pcnt <= 0;
                    pls100k <= ~pls100k;
                end 
        end 
                  
//------------------------1KHz PULSE GNE . ------------------------
always@(negedge rst, posedge clk)
    if(rst == 0)
        begin
            pls1k <= 0;
            plcnt <= 0;
        end 
    else if((pcnt == 49) & (pls100k == 1))
        begin
            if(plcnt < 49)
                plcnt <= plcnt +1;
            else 
                begin
                    plcnt <= 0;
                    pls1k <= ~pls1k;
                end
        end 
        
//----------------------BUZZER ON CONTROL ---------------------
always@(negedge rst, posedge clk)
    if(rst == 0)
        buzzs <= 1;
    else if(clr == 1)
        buzzs <= 1;
    else if(bcds < 10 )
        buzzs <= (nkpls & ~koff);
    else 
        buzzs <= 0;
        
//------------BUZZER ON TIME EXTENSION FOR 30ms 
always@(negedge rst, posedge clk)
    if(rst == 0)
        begin   
            ps0 <= 0;
            ps1 <= 0;
            bzcnt <= 1;
        end 
    else
        begin   
            ps0 <= pls1k;
            ps1 <= ps0;
            if(ps1 & ~ps0)
                if(buzzs == 1)
                    begin
                        bzcnt <= 0;
                        buzz <= 1;
                    end 
                else if(bzcnt < 31)
                    begin
                        bzcnt <= bzcnt + 1;
                        buzz <= 1;
                    end 
                else
                    buzz <= 0;
        end 
        
//---------------KEY SCAN,V 
key_scan ukey_scan 
    (
//input 
    .rst            (rst        ),
    .clk            (clk        ),
    .pls100k        (pls100k    ),           
    .key_in         (key_in     ),
//output 
    .key_out        (key_out    ),
    .nkpls          (nkpls      ),
    .nkv            (nkv        )
    );
    
//------------KEY ASSIGN.V 
key_val_assign ukey_val_assign
    (
//input 
    .rst            (rst        ),
    .clk            (clk        ),
    .nkpls          (nkpls      ),
    .nkv            (nkv        ),
//output 
    .koff           (koff       ),
    .bcds           (bcds       )
    );
    
// -----------DISP_DATA_GEN             
disp_data_gen udisp_data_gen
    (
//input 
    .rst            (rst        ),
    .clk            (clk        ),
    .nkpls          (nkpls      ),
    .clr            (clr        ),
    .koff           (koff       ),
    .bcds           (bcds       ),
//output 
    .bcd8d          (bcd8d      )
    );
    
// ------------SEG_CTL 
seg_ctl useg_ctl
    (
//input 
    .rst            (rst        ),
    .clk            (clk        ),
    .enc            (enc        ),
    .bcd8d          (bcd8d      ),
//output 
    .seg_d          (seg_d      ),
    .seg_com        (seg_com    )
    );
    
    
endmodule 

     
                
                
                
                
                
              
 
