`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2026 13:40:16
// Design Name: 
// Module Name: uart_top
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


module uart_top(
			clock, 
			reset, 
			tx_start, 
			data_in, 
			parity_error, 
			stop_bit_error, 
			data_output
    );
    
input reset, clock, tx_start;
input [7:0]data_in;
output parity_error, stop_bit_error;
output [7:0]data_output;

wire tx_rx_wire;

uart_rx_top ur1(reset,clock,tx_rx_wire,parity_error,stop_bit_error,data_output);
uart_tx_top ut1(reset,tx_start,data_in,tx_rx_wire,clock);

endmodule
