`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2025 11:44:30
// Design Name: 
// Module Name: Tx_Mux
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


module Tx_Mux(Tx_data_out, Data_bit, Parity_bit, select);
output reg Tx_data_out;
input Data_bit,Parity_bit;
input [1:0] select;

always @(select)
begin
    case(select)
        2'b00: Tx_data_out <= 1'b0;
        2'b01: Tx_data_out <= Data_bit;
        2'b10: Tx_data_out <= Parity_bit;
        2'b11: Tx_data_out <= 1'b1;
        default: Tx_data_out <= 1;
     endcase
end

endmodule
