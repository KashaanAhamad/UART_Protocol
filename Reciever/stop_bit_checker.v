`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.11.2025 11:02:08
// Design Name: 
// Module Name: stop_bit_checker
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


module stop_bit_checker(stop_bit_receive,stop_error,check_stop);

input stop_bit_receive;
input check_stop;
output reg stop_error;

always@(check_stop,stop_bit_receive) begin
if(check_stop==1)  begin
if(stop_bit_receive==1)
stop_error=0;
else
stop_error=1;      end
end
endmodule
