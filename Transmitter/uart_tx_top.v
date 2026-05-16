`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2025 11:40:30
// Design Name: 
// Module Name: uart_tx_top
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


module uart_tx_top(reset,Tx_start,data_in,out,clk);
input Tx_start,reset,clk;
input [7:0]data_in;

output out;
wire data_out,parity_bit;
wire [1:0] sel;
wire load,shift;

Tx_PISO(.Data_out(data_out),.Tx_data_in(data_in),.shift(shift),.Load_data(load),.clk(clk),.piso_reset(reset));
Tx_Mux Tm(.Tx_data_out(out), .Data_bit(data_out), .Parity_bit(parity_bit), .select(sel));
Parity_Gen Pg(.Tx_data(data_in),.Load_data(load),.Parity(parity_bit));
Tx_fsm FSM(.shift(shift), .Load_data(load),.select(sel), .Tx_start(Tx_start), .clk(clk),.rstn(reset));


endmodule
