`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Singapore University of Technology and Design
// Engineer: Xiang Maoyang
// Create Date: 08.01.2024 12:47:59
// Design Name: Basys3 Demo - Stop Watch 
// Module Name: top_module
// Breif: This is a simple demo stop-watch project on Basys 3 FPGA Development Board;
// The stop watch will display time (MMSS) on 4 digs 7Segment; (M-Minute S-Second)
// The stop watch can be reset by btnR on board; 
// Target Devices: Basys 3 Board 
//////////////////////////////////////////////////////////////////////////////////

module top_module(
    input clk,      //100MHz Clock Source;
    input btnR,     //BTNR - RESET System;
    input btnStart, //BTNSTART - Start counting;
    output [6:0] seg,// 7-Segment - Segment[6:0];
    output dp,      // 7-Segment - Segment-DP;
    output [3:0] an, // 7-Segment - Common Anode;
    output runLED,  // led, running state
    output startLED // led, start button    these leds were added for debugging purpurses, and to show state of some registers
);

//Set BTNR Button as Reset Function;
//Normally, the digital systems prefer logic low as reset rather than logic high;
//Therefore, we declare a reset wire (rstn) which is connected to btnR with NOT gate;   
//Added startstop button to start, pause and resume counting 
wire rstn;
assign rstn=~btnR;
wire start;
assign start=~btnStart;
assign startLED=start;
//In this application, we need 2 clock, 1Hz and 500Hz;
//500Hz - Drive 7Segment Display;
//1Hz   - Drive Stop Watch;
//Create 500Hz and 1Hz Clock Signal from input 100Mhz Clk Signal;
reg clk_500hz_r;
reg clk_1hz_r;
reg [16:0]cnter_500hz_r;    // 100Mhz/(500Hz*2) =  100_000(17 bits);
reg [7:0] cnter_1hz_r;      // 500Hz/(1Hz*2) = 250 (8 bits)

reg running;  //running flag to keep trakc of paused/unpaused state
assign runLED=running;
reg start_r; // value to read button press into a register value during clock
reg dp_r; //decimal place memory register



always@(posedge clk)begin // things must always follow the clock, thus this function reads the start button state when clock ticks
    start_r <= start ;
end

always@(negedge start_r, negedge rstn)begin  //function to change the "running" state, resetting it upon reset button and start/stopping on the start button
        if(!rstn) begin
        running <= 0;
        end
        else 
        running<=~running;
        end
//Create 500Hz Clock from 100MHz Clock Source;
//We iterate the 100MHz clock signal 100,000 times and perform a toggle operation on the clk_500hz_r register;
always@(posedge clk, negedge rstn)begin
    if(!rstn)begin              //Non-Sync Reset
        clk_500hz_r <= 1'b0;    //Set 500hz clock as '0' to avoid any uncertain status;        
        cnter_500hz_r <= 17'd0; //Clear counter
    end
    else begin

        if(cnter_500hz_r == 17'd100_000-1'b1)begin   //When counter reach 100_000
            clk_500hz_r <= ~clk_500hz_r;        //Toggle 500Hz CLk reg;
            cnter_500hz_r <= 17'd0;             //Clear counter
        end
        else
            cnter_500hz_r <= cnter_500hz_r +1'b1; //Counter
        end
    end


//Create 1Hz Clock from 500Hz Clock Source;
always@(posedge clk_500hz_r, negedge rstn)begin
    if(!rstn)begin
        clk_1hz_r <= 1'b0;
        cnter_1hz_r <= 8'd0;
    end
    else begin
        if(running)begin                        //Interrupt of the counter tick up if running is not true, disables counting up unless running is true
        if(cnter_1hz_r == 8'd250-1'b1)begin
            clk_1hz_r <= ~clk_1hz_r;
            cnter_1hz_r <= 8'd0;
        end
        else
            cnter_1hz_r <= cnter_1hz_r +1'b1;
    end
end
end

//Drive 7Segment Display;
//There are 4 7Segment LED on the Basys 3 Board, which share segment driver;
//Hence, we have to turn on 4 7Segment LED in sequence;
reg [7:0] segment_r;        //Register - Drive 7 Segment
assign dp =  segment_r[7];  //Connnect Register(7-Segment) to Segment Pin-DP
assign seg[6:0] = segment_r[6:0];   //Connnect Register(7-Segment) to Segment Pin (seg[6:0])
reg [3:0] cur_num_r;        //Register - BCD Number Display at this moment; 
wire [15:0] bcd_num;        //Wire - 4 BCD Number;
reg [3:0] an_r;             //Register - Drive Common Anode;
assign an = ~an_r;  //Connnect Register(Anode) to Anode Pins with NOT Gate;      
                            //If 7Segment is Common Cathod, connect Pins without NOT Gate
                            
//Drive 7Segment Anode;
//When an_r == 0001, DIG4 will turn on;
//When an_r == 0001, at posedge clk_500hz_r, an_r will be set to 0010(DIG3 ON);
//When an_r == 0010, at posedge clk_500hz_r, an_r will be set to 0100(DIG2 ON);
//....
//DIG4 -> DIG3 -> DIG2 -> DIG1 -> DIG4 -> DIG3 -> DIG2 -> ...;
always @(negedge rstn,posedge clk_500hz_r)begin
    if(!rstn)begin
        an_r <= 4'b0000;    //When system reset, empty all display;
    end
    else begin
        case(an_r)                  
        4'b0001: an_r <= 4'b0010;   //DISPLAY ON DIG3
        4'b0010: an_r <= 4'b0100;   //DISPLAY ON DIG2
        4'b0100: an_r <= 4'b1000;   //DISPLAY ON DIG1
        default: an_r <= 4'b0001;   //DISPLAY ON DIG4
        endcase
    end
end

//When DIG4 on, BCD Number Display at this moment is bcd_num[3:0];  (i.e Stop Watch - Second Unit)
//When DIG3 on, BCD Number Display at this moment is bcd_num[7:4];  (i.e Stop Watch - Second Decade)
//When DIG2 on, BCD Number Display at this moment is bcd_num[11:8]; (i.e Stop Watch - Minute Unit)
//When DIG1 on, BCD Number Display at this moment is bcd_num[15:12];(i.e Stop Watch - Minute Decade)
always @(an_r,bcd_num)begin
    case(an_r)
        4'b0001: cur_num_r <= bcd_num[3:0];
        4'b0010: cur_num_r <= bcd_num[7:4];
        4'b0100: cur_num_r <= bcd_num[11:8];
        4'b1000: cur_num_r <= bcd_num[15:12];
        default: cur_num_r <= 4'b0;
    endcase    
end

//Decode BCD NUM into corrosponding 7Segment Code;
always @(cur_num_r) begin
if (dp_r && (an_r==4'b0100)) begin  //if writing to the minute unit count (digit 2) and decimal register is true
    case(cur_num_r)
        4'h0:segment_r <= 7'h40;    //NUM "0."
        4'h1:segment_r <= 7'h4f;    //NUM "1."
        4'h2:segment_r <= 7'h24;    //NUM "2."
        4'h3:segment_r <= 7'h30;    //NUM "3."
        4'h4:segment_r <= 7'h19;    //NUM "4."
        4'h5:segment_r <= 7'h12;    //NUM "5."
        4'h6:segment_r <= 7'h02;    //NUM "6."
        4'h7:segment_r <= 7'h78;    //NUM "7."
        4'h8:segment_r <= 7'h00;    //NUM "8."
        4'h9:segment_r <= 7'h10;    //NUM "9."
        default: segment_r <= 7'h7f;
    endcase
    end
    else begin
        case(cur_num_r)
        4'h0:segment_r <= 8'hc0;    //NUM "0"
        4'h1:segment_r <= 8'hf9;    //NUM "1"
        4'h2:segment_r <= 8'ha4;    //NUM "2"
        4'h3:segment_r <= 8'hb0;    //NUM "3"
        4'h4:segment_r <= 8'h99;    //NUM "4"
        4'h5:segment_r <= 8'h92;    //NUM "5"
        4'h6:segment_r <= 8'h82;    //NUM "6"
        4'h7:segment_r <= 8'hF8;    //NUM "7"
        4'h8:segment_r <= 8'h80;    //NUM "8"
        4'h9:segment_r <= 8'h90;    //NUM "9"
        default: segment_r <= 8'hff;
        // 4'ha:segment_r <= 8'h88;    //NUM "A" - HEX NUMBER DISPLAY
        // 4'hb:segment_r <= 8'h83;    //NUM "b"
        // 4'hc:segment_r <= 8'hc6;    //NUM "C"
        // 4'hd:segment_r <= 8'ha1;    //NUM "D"
        // 4'he:segment_r <= 8'h86;    //NUM "E"
        // 4'hf:segment_r <= 8'h8e;    //NUM "F"
    endcase
    end
end

// Timer Section is composed with 4 BCD Number counter(Minute Decade,Minute Unit, Second Decade, Minute Unit);
reg [3:0] sec_unit_bcd_r,sec_deca_bcd_r,min_unit_bcd_r,min_deca_bcd_r; //Register - (Minute Decade,Minute Unit, Second Decade, Second Unit);
reg sec_unit_cout,sec_deca_cout,min_unit_cout; //Carry Out Signal, When 4 BCD Number counter reach upper limit, it will generate a cout signal;

//Counter           Upper Limit
//Minute Decade     5
//Minute Unit       9
//Second Decade     5
//Second Unit       9

always @(posedge clk_1hz_r or negedge rstn)begin
    if(!rstn)begin
        sec_unit_bcd_r <= 4'd0; //Clear BCD Number Counter;
        sec_unit_cout <= 1'b0;  //Clear Cout Signal;
    end
    else begin
        if(sec_unit_bcd_r == 4'h9)begin
            sec_unit_cout <= 1'b1;  //Cout generate a posedge;
            sec_unit_bcd_r <= 4'd0; //Clear BCD Number Counter;
        end
        else begin
            sec_unit_cout <= 1'b0;                      //Clear Cout Signal;
            sec_unit_bcd_r <= sec_unit_bcd_r + 1'b1; // BCD Number Counter increase by '1';
        end
    end
end

always @(posedge sec_unit_cout or negedge rstn)begin
    if(!rstn)begin
        sec_deca_bcd_r <= 4'd0;
        sec_deca_cout <= 1'b0;
        dp_r<=0; //disable decimal place memory
    end
    else begin
        if(sec_deca_bcd_r == 4'h5)begin
            sec_deca_cout <= 1'b1;
            sec_deca_bcd_r <= 4'd0;
            dp_r <= 1; //enable decimal place memory
        end
        else begin
            sec_deca_cout <= 1'b0;
            sec_deca_bcd_r <= sec_deca_bcd_r + 1'b1;
        end
    end
end

always @(posedge sec_deca_cout or negedge rstn)begin
    if(!rstn)begin
        min_unit_bcd_r <= 4'd0;
        min_unit_cout <= 1'b0;
    end
    else begin
        if(min_unit_bcd_r == 4'h9)begin
            min_unit_cout <= 1'b1;
            min_unit_bcd_r <= 4'd0;
        end
        else begin
            min_unit_cout <= 1'b0;
            min_unit_bcd_r <= min_unit_bcd_r + 1'b1;
        end
    end
end

always @(posedge min_unit_cout or negedge rstn)begin
    if(!rstn)begin
        min_deca_bcd_r <= 4'd0;
    end
    else begin
        if(min_deca_bcd_r == 4'h5)begin
            min_deca_bcd_r <= 4'd0;
        end
        else begin
            min_deca_bcd_r <= min_deca_bcd_r + 1'b1;
        end
    end
end

//When DIG4 on, BCD Number Display at this moment is bcd_num[3:0];  (i.e Stop Watch - Second Unit)
//When DIG3 on, BCD Number Display at this moment is bcd_num[7:4];  (i.e Stop Watch - Second Decade)
//When DIG2 on, BCD Number Display at this moment is bcd_num[11:8]; (i.e Stop Watch - Minute Unit)
//When DIG1 on, BCD Number Display at this moment is bcd_num[15:12];(i.e Stop Watch - Minute Decade)
assign  bcd_num[15:12]  = min_deca_bcd_r;
assign  bcd_num[11:8]   = min_unit_bcd_r;
assign  bcd_num[7:4]    = sec_deca_bcd_r;
assign  bcd_num[3:0]    = sec_unit_bcd_r;

endmodule