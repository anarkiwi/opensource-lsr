//
// MPLS Switch Divider Module Enhancements,
//   Developed by Algo-Logic Systems
//   Copyright 2011 Google Inc. All Rights Reserved.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//       Unless required by applicable law or agreed to in writing, software
//       distributed under the License is distributed on an "AS IS" BASIS,
//       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
//       implied.
//       See the License for the specific language governing permissions and
//       limitations under the License.
//   Based on code from NetFPGA Project
//   Distributed through the NetBSD License
//-----------------------------------------------------------
// Module: divider.v
// Project: NF2.1
// Description: Divider unit used for load distribution.
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

  module divider
    
   (// --- Interface to the previous stage
         input [3:0]dividend,
	 input [3:0] divisor,
	 output reg [3:0]    remainder,
	// --- Misc

    input                              reset,
    input                              clk
   );


 wire [1:0] dh1;
 wire[3:0] mod_8;
 reg [3:0]    remainder_next;

 assign dh1 = dividend[3:2]^dividend[1:0];
 assign mod_8 = dividend%8;

parameter INIT = 0;
reg          div_state, div_state_next;

always @(*) begin
  div_state_next = div_state;
  remainder_next = remainder;

case(div_state)
			
   INIT: begin

           
            if(divisor==4'h1) begin
                remainder_next=0;
            end
            if(divisor==4'h2) begin
                remainder_next=dividend%2;
            end
            if(divisor==4'h3) begin
                   if (dh1==2'b11)begin
                      remainder_next=0;
                   end
                   else begin
                      remainder_next={2'b0,dh1};
                   end
            end
            if(divisor==4'h4) begin
                remainder_next=dividend%4;
            end 
            if(divisor==4'h5) begin
                   if (mod_8==4'h7)begin
                      remainder_next=0;
                   end
                   else if (mod_8==4'h6)begin
                      remainder_next=4'h2;
                   end
                   else if (mod_8==4'h5)begin
                      remainder_next=4'h4;
                   end
                   else begin
                      remainder_next=mod_8;
                   end
            end 
            if(divisor==4'h6) begin
                   if (mod_8==4'h7)begin
                      remainder_next=0;
                   end
                   else if (mod_8==4'h6)begin
                      remainder_next=4'h5;
                   end
                   else begin
                      remainder_next=mod_8;
                   end
            end  
            if(divisor==4'h7) begin
                   if (mod_8==4'h7)begin
                      remainder_next=0;
                   end
                   else begin
                      remainder_next=mod_8;
                   end
            end
            if(divisor==4'h8) begin
                  remainder_next=mod_8;
            end 
            if(divisor==4'h9) begin
                   if (dividend==4'hf)begin
                      remainder_next=4'h0;
                   end
                   else if (dividend==4'he)begin
                      remainder_next=4'h1;
                   end
                   else if (dividend==4'hd)begin
                      remainder_next=4'h2;
                   end
                   else if (dividend==4'hc)begin
                      remainder_next=4'h3;
                   end
                   else if (dividend==4'hb)begin
                      remainder_next=4'h4;
                   end
                   else if (dividend==4'ha)begin
                      remainder_next=4'h5;
                   end
                   else if (dividend==4'h9)begin
                      remainder_next=4'h6;
                   end
                   else begin
                      remainder_next=dividend;
                   end
            end
            if(divisor==4'ha) begin
                   if (dividend==4'hf)begin
                      remainder_next=4'h0;
                   end
                   else if (dividend==4'he)begin
                      remainder_next=4'h1;
                   end
                   else if (dividend==4'hd)begin
                      remainder_next=4'h2;
                   end
                   else if (dividend==4'hc)begin
                      remainder_next=4'h3;
                   end
                   else if (dividend==4'hb)begin
                      remainder_next=4'h4;
                   end
                   else if (dividend==4'ha)begin
                      remainder_next=4'h5;
                   end
                   else begin
                      remainder_next=dividend;
                   end
            end
            if(divisor==4'hb) begin
                   if (dividend==4'hf)begin
                      remainder_next=4'h0;
                   end
                   else if (dividend==4'he)begin
                      remainder_next=4'h2;
                   end
                   else if (dividend==4'hd)begin
                      remainder_next=4'h4;
                   end
                   else if (dividend==4'hc)begin
                      remainder_next=4'h6;
                   end
                   else if (dividend==4'hb)begin
                      remainder_next=4'h8;
                   end
                   else begin
                      remainder_next=dividend;
                   end
            end  
             if(divisor==4'hc) begin
                   if (dividend==4'hf)begin
                      remainder_next=4'h0;
                   end
                   else if (dividend==4'he)begin
                      remainder_next=4'hf;
                   end
                   else if (dividend==4'hd)begin
                      remainder_next=4'h5;
                   end
                   else if (dividend==4'hc)begin
                      remainder_next=4'ha;
                   end
                   else begin
                      remainder_next=dividend;
                   end
            end 
             if(divisor==4'hd) begin
                   if (dividend==4'hf)begin
                      remainder_next=4'h0;
                   end
                   else if (dividend==4'he)begin
                      remainder_next=4'hf;
                   end
                   else if (dividend==4'hd)begin
                      remainder_next=4'h8;
                   end
                   else begin
                      remainder_next=dividend;
                   end
            end 
            if(divisor==4'he) begin
                   if (dividend==4'hf)begin
                      remainder_next=4'h0;
                   end
                   else if (dividend==4'he)begin
                      remainder_next=4'hf;
                   end
                   else begin
                      remainder_next=dividend;
                   end
            end 
            if(divisor==4'hf) begin
                   if (dividend==4'hf)begin
                      remainder_next=4'h0;
                   end
                   else begin
                      remainder_next=dividend;
                   end
            end 
            if(divisor==4'h0) begin
                   remainder_next=4'h0;
            end 
      end //INIT          
    endcase // case(state)  
 end //always
 always @(posedge clk) begin
      if(reset) begin
         div_state <= INIT;
	 remainder <= 0;
      end
      else begin
         div_state <= div_state_next;
	 remainder <= remainder_next;
      end
 end  //always 
endmodule // divider 
