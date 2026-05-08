`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.01.2026 00:22:07
// Design Name: 
// Module Name: baud_gen
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


//module baud_gen();

module baud_generate_tx(clock,tx_sel,baud_tx_out);
input clock;
input[1:0]tx_sel;
output reg baud_tx_out;

wire baud_tick_115200bps,baud_tick_38400bps,baud_tick_19200bps,baud_tick_9600bps;

integer count1=0;
integer count2=0;
integer count3=0;
integer count4=0;

always@(posedge clock)
if(count1<86)
	count1<=count1+1;
else
	count1=1;

assign baud_tick_115200bps=(count1<44)?1:0;

always@(posedge clock)
if(count2<260)
	count2<=count2+1;
else
	count2=1;

assign baud_tick_38400bps=(count2<131)?1:0;

always@(posedge clock)
if(count3<520)
	count3<=count3+1;
else
	count3=1;

assign baud_tick_19200bps=(count3<261)?1:0;

always@(posedge clock)
if(count4<1042)
	count4<=count4+1;
else
	count4=1;

assign baud_tick_9600bps=(count4<522)?1:0;

always@(tx_sel,baud_tick_115200bps,baud_tick_38400bps,baud_tick_19200bps,baud_tick_9600bps)
begin
	case(tx_sel)
		2'b00:baud_tx_out=baud_tick_115200bps;
		2'b01:baud_tx_out=baud_tick_38400bps;
		2'b10:baud_tx_out=baud_tick_19200bps;
		2'b11:baud_tx_out=baud_tick_9600bps;
	endcase
end
endmodule

