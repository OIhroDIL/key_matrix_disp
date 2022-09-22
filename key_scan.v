`timescale 1ns / 1ps

module key_scan(
//input
input   rst,                //
input   clk,                // 10MHz SYSTEM CLK
input   pls100k,            // 100kHz PULSE , SCAN TIMING CONTROL
input   pls1k,              // 1KHz PULSE , SCAN START AT RISING EDGE       
input   [4:0] key_in,       // 4BIT KEY PAD ROW INPUT
//output
output  reg[3:0] key_out,   // 3BIT KEY PAD COLUMN OUTPUT
output  reg nkpls,          // ONE SHOT PULSE WHEN NEW KEY HAS DETECTED
output  reg[4:0] nkv        // 4BIT NEW KEY VALUE OUTPUT
);

reg     pl0,pl1;            // FOR EDGE DETECT OF PLS1K
reg     pk0,pk1;            // FOR EDGE DETECT OF PLS100K    
reg     [4:0] pkcnt;        // PLS100K COUINTER FOR SCAN TIMING CONTROL    

wire    [1:0]cnt;
wire    [2:0]kscnt;         // COUNTER FOR KEY SCAN CONTROL

reg     [4:0] kv0,kv1,kvp; 
reg     [4:0] kcnt;

reg     nokey,multkey;

//-------1 cycle scan timing signal generation 
always@(negedge rst, posedge clk)
    if(rst==0)
        begin
            pl0 <= 0; pl1 <= 0; pk0 <= 0; pk1 <= 0;
            pkcnt <= 31;
        end
    else
        begin 
            pk0 <= pls100k;     pk1 <= pk0;
            if(pk0 & ~pk1)                          // RISING EDGE OF PLS100K
                begin
                    pl0 <= pls1k;
                    pl1 <= pl0;
                    if((pl0 & ~pl1) == 1)           // RISING EDGE OF PLS1K
                        pkcnt <= 0 ;
                    else if(pkcnt < 31)
                        pkcnt <= pkcnt+1;
                end 
        end 
assign cnt = pkcnt[1:0];                            // 1 LINE SCAN TIMING COUNTER
assign kscnt = pkcnt[4:2];                          // 1 CYCLE SCAN TIMING COUNTER

//------------------key out generation 
always@(negedge rst, posedge clk)
    if(rst == 0)
        key_out <= 4'hf;
    else if(pk0 & ~pk1)                             // RIGING EDGE OF PLS100K
        if      (kscnt == 1)    key_out <= (4'b1110);
        else if (kscnt == 2)    key_out <= (4'b1101);
        else if (kscnt == 3)    key_out <= (4'b1011);         
        else if (kscnt == 4)    key_out <= (4'b0111);
        else                    key_out <= (4'b1111);

//------------------------key scan ROUTING for 1 cycle 
always@(negedge rst , posedge clk)
    if(rst == 0)
        begin 
            nokey <=1;      multkey <=0;
            kv0 <= 5'h0;    kv1 <= 5'h0;    kvp <= 5'h0;
        end 
    else if((pk0 & ~pk1) & (cnt ==1))                       // RISING EDGE OF PLS100K AND CNT == 1
        if(kscnt == 0)
            begin
                nokey <= 1;  multkey <= 0;
                kv0 <= 5'h0;    kvp <= 5'h0;
            end 
        else if(kscnt == 5)
            kv1 <= kv0;
        else if(kscnt < 5)                                  // SCAN LOGIC FOR EDGE LINE SCANNING
            begin
                if(multkey == 1)
                    begin
                        nokey <= 0; kv0 <= 31;
                    end
                else if(nokey == 1)
                    if(key_in ==31)
                        kvp <= kvp + 5;                     // FOR NEXT COLUM SCAN
                    else
                        begin
                            nokey <= 0;
                            if      (key_in == 5'b11110)    kv0 <= kvp +1;
                            else if (key_in == 5'b11101)    kv0 <= kvp +2;
                            else if (key_in == 5'b11011)    kv0 <= kvp +3;
                            else if (key_in == 5'b10111)    kv0 <= kvp +4;
                            else if (key_in == 5'b01111)    kv0 <= kvp +5;
                            else
                                begin
                                    multkey <= 1;           // MULTI KEY HAS PUSHED
                                    kv0 <= 31;
                                end 
                        end
                else                                        // KEY HAS BEEN PUSHED IN PREVIOUS LINE SCAN
                    if(key_in != 31)
                        begin
                            multkey <= 1;                   // MULTI KEY HAS PUSHED
                            kv0 <= 31;
                        end 
            end 

//------------------counter for debounce module key_scan
always@(negedge rst, posedge clk)
    if(rst == 0)
        kcnt = 5'h0;
    else if(pk0 & ~pk1)                                     // RISING EDGE OF PLS100K
        if((kscnt == 5) & (cnt == 1))
            if(kv0 != kv1)
                kcnt <= 5'h0;
            else if(kcnt <20)
                kcnt <= kcnt + 1;

//-----------------ney key value catch and NKPLS Generation
always@(negedge rst , posedge clk)
    if(rst == 0)
        begin 
            nkpls <= 0;     nkv <= 4'h0;
        end            
    else if(pk0 & ~pk1)                                     // RISING EDGE OF PLS100K
        if((kscnt == 5) && (cnt == 2))
            begin
                nkpls <= 0;
                if(kcnt == 18)
                    if(kv1 <= 20)    nkv <= kv1;
                    else            nkv <= 31;
                else if(kcnt == 19)
                    nkpls <= 1;
            end

endmodule
