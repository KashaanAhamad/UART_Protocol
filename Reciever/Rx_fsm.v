`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.11.2025 11:06:47
// Design Name: 
// Module Name: Rx_fsm
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


//module Rx_fsm(reset,clock,parity_load,check_stop,parity_error,start_detect,rx_shift );
module Rx_fsm(start_detect,parity_error,rx_shift,parity_load,check_stop,reset,clock );
input reset,clock;
output reg parity_load,check_stop,rx_shift;

parameter rx_idle=2'b00,rx_data_bit=2'b01,rx_parity_bit=2'b10,rx_stop_bit=2'b11;

input parity_error;
input start_detect;
reg[1:0]state;
reg[1:0]next_state;
integer rx_count=1;
reg start;

always@(state,start_detect,rx_count,parity_error)
begin
case(state)
rx_idle:
    next_state=(start_detect==1)?rx_data_bit:rx_idle;
rx_data_bit:  begin
    start=(rx_count==8)?0:1;
    next_state=(rx_count==8)?rx_parity_bit:rx_data_bit;    end
rx_parity_bit:
    next_state=(parity_error==1)?rx_idle:rx_stop_bit;
rx_stop_bit:
    next_state=rx_idle;
endcase
end

always@(posedge clock,negedge reset)
if(!reset)
state<=rx_idle;
else
state<=next_state;

always@(posedge clock)
if(start)	// check here start_detect
rx_count<=rx_count+1;
else
rx_count<=1;

always@(state)
begin
    if(state==rx_idle)  begin
    rx_shift=0;
    parity_load=0;
    check_stop=0;
    end
else if(state==rx_data_bit)  begin
    rx_shift=1;
    parity_load=0;
    check_stop=0;    end
else if(state==rx_parity_bit)  begin
    rx_shift=0;
    parity_load=1;
    check_stop=0;   end
else if(state==rx_stop_bit)   begin
    rx_shift=0;
    parity_load=0;
    check_stop=1;  end
else    begin
    rx_shift=0;
    parity_load=0;
    check_stop=0;  end
end


endmodule


