`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2025 11:42:34
// Design Name: 
// Module Name: Tx_fsm
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


module Tx_fsm(shift, Load_data,select, Tx_start, clk,rstn );
input clk,rstn;
output reg shift, Load_data;
output reg [1:0] select;
input Tx_start;

reg [2:0]state;
reg [2:0]next_state;

integer count=1;
reg count_start=0;
//reg [2:0]count=0;

parameter Idle=3'b000, start_bit=3'b001, data_bit=3'b010, parity_bit=3'b011, stop_bit=3'b100;


always @(Tx_start,state,count)
begin
    case(state)
        Idle: next_state=Tx_start?start_bit:Idle;
              
        start_bit: next_state=data_bit;
        
        data_bit: begin 
                count_start=(count==8)?0:1;
                next_state=(count==8)?parity_bit:data_bit;
             end
             
        parity_bit: next_state=stop_bit;
        stop_bit: next_state=Idle;
        default: next_state=Idle;
    endcase
end


always @(posedge clk,negedge rstn)
begin
    if(!rstn)
        state<= Idle;
    else 
        state<= next_state;
end

always@(posedge clk)
begin
    if(!count_start)
        count<=count+1;
     else
            count<=1;
end

//Output Logic
always @(state)
begin       
    if(state==Idle)begin
        select=2'b11;
        Load_data=1'b0;
        shift=0;
     end
     else if(state==start_bit)begin
        select=2'b00;
        Load_data=1'b1;
        shift=0;
     end
     else if(state==data_bit)begin
        select=2'b01;
        Load_data=1'b0;
        shift=1;
     end
     else if(state==parity_bit)begin
        select=2'b10;
        Load_data=1'b1;
        shift=0;
     end
     else if(state==stop_bit)begin
        select=2'b11;
        Load_data=1'b0;
        shift=0;
     end
     else begin
        select=2'b11;
        Load_data=0;
        shift=0;
      end
  end
  
endmodule
