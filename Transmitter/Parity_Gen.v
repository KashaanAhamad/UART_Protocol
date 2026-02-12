`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2025 11:43:56
// Design Name: 
// Module Name: Parity_Gen
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


module Parity_Gen(Tx_data,Load_data,Parity );
input [7:0] Tx_data;
input Load_data;
output  Parity;

reg [7:0]parity_mem;

always @(Load_data,Tx_data)
begin
    if(Load_data)  
            parity_mem <= Tx_data;
    else 
             parity_mem <= parity_mem;
end
assign Parity= ^(parity_mem);
endmodule
