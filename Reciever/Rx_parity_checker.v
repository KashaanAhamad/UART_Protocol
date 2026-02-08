`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.11.2025 13:29:31
// Design Name: 
// Module Name: Rx_parity_checker
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


module Rx_parity_checker(data_received,
                            
                            parity_error,
                            parity_bit_rx,
                            parity_load );
//input Rx_in,Parity_Load;
//input [7:0] sipo_Data_in;

//output Parity_bit_Error;

//reg [7:0]parity_mem;

//always@(*)
//begin
//    if(Parity_Load)
//        parity_mem<=sipo_Data_in;
//end

input[7:0]data_received;
input parity_bit_rx,parity_load;     //clock
output reg parity_error;

//always@(parity_bit_rx,parity_load)
always@(*)
if(parity_load)  begin
if(parity_bit_rx==^data_received)
parity_error=0;
else
parity_error=1;   end


endmodule
