`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2025 11:43:29
// Design Name: 
// Module Name: Tx_PISO
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


module Tx_PISO(Data_out,Tx_data_in,shift,Load_data,clk,piso_reset);
output  Data_out;
input [7:0]Tx_data_in;
input shift,Load_data,clk,piso_reset;

reg [7:0]shift_reg;

always @(posedge clk,negedge piso_reset)
begin
    if(!piso_reset)
        shift_reg<=8'b0000_0000;
    else if(Load_data)
        shift_reg<=Tx_data_in;
    else if(shift)
        shift_reg<={1'b0,shift_reg[7:1]};
    else 
        shift_reg<=shift_reg;    
//        Data_out<= Tx_data_in[7];
//    end else begin
//        //shift right MSB first
//        shift_reg <= {1'b0,shift_reg[7:1]};
//        Data_out <= shift_reg[0];
//    end
end
assign Data_out=shift_reg[0];

endmodule
