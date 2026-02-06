`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.11.2025 12:54:43
// Design Name: 
// Module Name: Detect_start
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

//No TB yet
module Detect_start(rx_in,start_bit_detected );
input rx_in;
output reg start_bit_detected;

always @(*)
begin
    if(rx_in)
        start_bit_detected<=0;
    else
        start_bit_detected<=1;
end
endmodule
