`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2026 14:02:35
// Design Name: 
// Module Name: baud_generator_rx
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


module baud_generator_rx(
					clock,
					rx_sel,
					baud_rx_out
    );	
    
input clock;
input[1:0]rx_sel;
output reg baud_rx_out;

wire baud_tick_115200bps,baud_tick_38400bps,baud_tick_19200bps,baud_tick_9600bps;

integer count1=0;
integer count2=0;
integer count3=0;
integer count4=0;


always@(posedge clock)
if(count1<68)
	count1<=count1+1;
else
	count1=1;

assign baud_tick_115200bps=(count1<35)?1:0;

always@(posedge clock)
if(count2<208)
	count2<=count2+1;
else
	count2=1;

assign baud_tick_38400bps=(count2<105)?1:0;

always@(posedge clock)
if(count3<416)
	count3<=count3+1;
else
	count3=1;

assign baud_tick_19200bps=(count3<209)?1:0;

always@(posedge clock)
if(count4<832)
	count4<=count4+1;
else
	count4=1;

assign baud_tick_9600bps=(count4<417)?1:0;

always@(rx_sel,baud_tick_115200bps,baud_tick_38400bps,baud_tick_19200bps,baud_tick_9600bps)
begin
	case(rx_sel)
		2'b00:baud_rx_out=baud_tick_115200bps;
		2'b01:baud_rx_out=baud_tick_38400bps;
		2'b10:baud_rx_out=baud_tick_19200bps;
		2'b11:baud_rx_out=baud_tick_9600bps;
	endcase
end
endmodule
