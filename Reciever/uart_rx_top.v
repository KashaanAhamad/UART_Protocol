`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.11.2025 12:45:37
// Design Name: 
// Module Name: uart_rx_top
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


module uart_rx_top(clk,rstn,Rx_in,parity_bit_error,stop_bit_error,Rx_data_out );
    input clk,rstn;
    input Rx_in;
    output parity_bit_error;
    output stop_bit_error;
    output [7:0]Rx_data_out;
  
  wire start_bit_detected,shift,Parity_load,check_stop; 
  wire [7:0]SIPO_data_out; 
  
  
  assign Rx_data_out= (!stop_bit_error)?Rx_in:8'bx;

  Detect_start DS(Rx_in,start_bit_detected);
  Rx_fsm fs2(start_bit_detected,parity_bit_error,shift,Parity_load,check_stop,reset,clock);
  
  Rx_SIPO sipo(Rx_in,clk,rstn,shift,SIPO_data_out );
  
  Rx_parity_checker PC(Rx_in,SIPO_data_out,Parity_load,parity_bit_error);
  
  stop_bit_checker SC(Rx_in,stop_bit_error,check_stop); //Rx_data_out
endmodule
