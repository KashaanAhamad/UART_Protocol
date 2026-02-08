`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.11.2025 13:13:24
// Design Name: 
// Module Name: Rx_SIPO
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


module Rx_SIPO(Data_in,clk,clear,shift,Data_out);
input clk,clear;
input Data_in,shift;
output  [7:0]Data_out;

reg [7:0] mem_data;

always @(posedge clk,negedge clear)
begin
    if(!clear)
        mem_data<=8'd0;
    else if(shift==1) 
        mem_data<= {Data_in,mem_data[7:1]};
     else 
        mem_data<= mem_data;
end
//mem_data[7] <= Data_in;
  assign Data_out= mem_data;
endmodule
