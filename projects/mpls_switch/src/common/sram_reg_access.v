///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// 
// MPLS Switch Sram Reg Access Module Enhancements,
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
//   $Id: sram_reg_access.v 3616 2008-04-16 19:53:33Z grg $
//   Distributed through the NetBSD License
//-----------------------------------------------------------

// Module: sram_reg_access.v with MPLS Enhancements
// Project: NF2.1 reference design
// Description: SRAM register access module
//
// Provides register access to SRAM
//
// The main component of complexity is that the SRAM data width is
// generally different than the register data width. Each SRAM word is
// currently mapped into the register address space as follows:
//
//   # CPCI words per SRAM word = log2(SRAM_DATA_WIDTH/CPCI_NF2_DATA_WIDTH)
//
//   SRAM data right-aligned in CPCI words
//
///////////////////////////////////////////////////////////////////////////////

`timescale  1ns /  10ps
module sram_reg_access #(
      parameter SRAM_ADDR_WIDTH = 19,
      parameter SRAM_DATA_WIDTH = 36,
      parameter SRAM_REG_ADDR_WIDTH = 21
   )
   (
      // register interface
      input                            sram_reg_req,
      input                            sram_reg_rd_wr_L,    // 1 = read, 0 = write
      input [`SRAM_REG_ADDR_WIDTH-1:0] sram_reg_addr,
      input [`CPCI_NF2_DATA_WIDTH-1:0] sram_reg_wr_data,

      output reg                       sram_reg_ack,
      output reg [`CPCI_NF2_DATA_WIDTH -1:0] sram_reg_rd_data,

      // --- Requesters (read and/or write)
      output reg                       wr_req,
      output reg [SRAM_ADDR_WIDTH-1:0] wr_addr,
      output reg [SRAM_DATA_WIDTH-1:0] wr_data,
      input                            wr_ack,

      output reg                       rd_req,
      output reg [SRAM_ADDR_WIDTH-1:0] rd_addr,
      input      [SRAM_DATA_WIDTH-1:0] rd_data,
      input                            rd_ack,
      input                            rd_vld,

      // --- Misc

      input reset,
      input clk

   );

`LOG2_FUNC

// Calculate the number of CPCI words per SRAM word
localparam CPCI_DATA_WORDS =
   SRAM_DATA_WIDTH / `CPCI_NF2_DATA_WIDTH +
   ((SRAM_DATA_WIDTH % `CPCI_NF2_DATA_WIDTH != 0) ? 1 : 0);
localparam CPCI_WORDS_WIDTH = log2(CPCI_DATA_WORDS);
localparam CPCI_WORDS = 2 ** CPCI_WORDS_WIDTH;
localparam CPCI_NON_DATA_WORDS = CPCI_WORDS - CPCI_DATA_WORDS;
localparam SRAM_WORD_WIDTH = (CPCI_WORDS_WIDTH == 0) ? 1 : CPCI_WORDS_WIDTH;
localparam BLOCK_WIDTH = CPCI_WORDS * `CPCI_NF2_DATA_WIDTH;

// Local signals
reg sram_reg_acked;

wire [`SRAM_REG_ADDR_WIDTH - CPCI_WORDS_WIDTH - 1:0] sram_addr;
wire [SRAM_WORD_WIDTH - 1:0] sram_word;
wire [`CPCI_NF2_DATA_WIDTH - 1:0] sram_data_word;
wire [SRAM_DATA_WIDTH - 1:0] sram_wr_data;
wire [BLOCK_WIDTH - 1:0] sram_data;

reg rd_acked;
reg rd_vld_latched;
reg [SRAM_DATA_WIDTH - 1:0] sram_wr_data1;
reg wr_reg_ack_next,wr_reg_ack;

// ====================================
// Process register requests
// ====================================

always @(posedge clk)
begin
   if (reset || !sram_reg_req) begin
      sram_reg_ack <= 1'b0;
      sram_reg_rd_data <= 'h0;

      sram_reg_acked <= 1'b0;

      rd_acked <= 1'b0;
      rd_vld_latched <= 1'b0;
      wr_reg_ack_next <= 1'b0;
      wr_reg_ack <= 1'b0;
      wr_data <= sram_wr_data1;
   end
   else begin
      if (!sram_reg_acked) begin
         // The read/write address is identical
         wr_addr <= sram_addr;
         rd_addr <= sram_addr;
         wr_reg_ack <= wr_reg_ack_next;
         wr_data <= sram_wr_data1;

         // Generate a read request if the request hasn't yet been acked
         // Note: the real signal is combinatorial based upon the
         // current value of rd_ack
         if (sram_reg_rd_wr_L) begin
             rd_req <= !rd_ack && !rd_acked;
             rd_acked <= rd_ack || rd_acked;
         end

         // Update the read result or change the write data when the read
         // data from the SRAM is valid
         if (sram_reg_rd_wr_L && rd_vld) begin
           // if (sram_reg_rd_wr_L)
               sram_reg_rd_data <= sram_data_word;
           /* else if (!sram_reg_rd_wr_L && rd_vld)
               wr_data <= sram_wr_data;*/
         end

         if (!sram_reg_rd_wr_L)begin
               if (sram_reg_addr[CPCI_WORDS_WIDTH-1:0]==2'b11) begin
                   sram_wr_data1[31:0] <= sram_reg_wr_data;
                   wr_reg_ack_next <= 1'b1;
               end

               else if (sram_reg_addr[CPCI_WORDS_WIDTH-1:0]==2'b10) begin
                   sram_wr_data1[63:32] <= sram_reg_wr_data;
                   wr_reg_ack_next <= 1'b1;
               end

               else if (sram_reg_addr[CPCI_WORDS_WIDTH-1:0]==2'b01) begin
                   sram_wr_data1[71:64] <= sram_reg_wr_data[7:0];
                   wr_reg_ack_next <= 1'b1;
               end
   
               else if (sram_reg_addr[CPCI_WORDS_WIDTH-1:0]==2'b00 && sram_reg_wr_data == 32'hffffffff) begin
                   wr_req <= !wr_ack;
               end
                
         end

         rd_vld_latched <= rd_vld || rd_vld_latched;

         // Generate a write request if the request hasn't yet been acked
         // Note: the real signal is combinatorial based upon the
         // current value of wr_ack and whether the read has been acked
       /*  if (!sram_reg_rd_wr_L && rd_vld || rd_vld_latched)
            wr_req <= !wr_ack;*/

         // Generate the ack signal when the read or write is complete
         if ((sram_reg_rd_wr_L && rd_vld) ||
             (!sram_reg_rd_wr_L && wr_ack) || (!sram_reg_rd_wr_L && wr_reg_ack)) begin
            sram_reg_ack <= 1'b1;
            sram_reg_acked <= 1'b1;
         end
      end
      else begin
         sram_reg_ack <= 1'b0;
      end
   end
end

assign sram_data = {{(BLOCK_WIDTH-SRAM_DATA_WIDTH){1'b0}}, rd_data};
assign sram_data_word = sram_data[sram_word * `CPCI_NF2_DATA_WIDTH +: `CPCI_NF2_DATA_WIDTH];
assign sram_addr = sram_reg_addr[`SRAM_REG_ADDR_WIDTH-1:CPCI_WORDS_WIDTH];

generate
   if (CPCI_DATA_WORDS > 1) begin
      genvar i;
      wire [SRAM_DATA_WIDTH-1:0] sram_words_all [CPCI_WORDS-1:0];

      assign sram_word = (CPCI_WORDS - 1) - sram_reg_addr[CPCI_WORDS_WIDTH-1:0];
      assign sram_wr_data = sram_words_all[sram_word];

      // The following if statement is required because ModelSim seems to
      // evaluate the rd_data select for correctness even if the
      // top-level if statement is false
      if (SRAM_DATA_WIDTH - 1 >= `CPCI_NF2_DATA_WIDTH)
         assign sram_words_all[0] =
            {
               rd_data[SRAM_DATA_WIDTH - 1 : `CPCI_NF2_DATA_WIDTH],
               sram_reg_wr_data
            };

      for (i = 1; i < CPCI_DATA_WORDS - 1; i = i + 1) begin : sram_words_with_data
         assign sram_words_all[i] =
            {
               rd_data[SRAM_DATA_WIDTH - 1 : (i + 1) * `CPCI_NF2_DATA_WIDTH],
               sram_reg_wr_data,
               rd_data[i * `CPCI_NF2_DATA_WIDTH - 1 : 0]
            };
      end
      assign sram_words_all[CPCI_DATA_WORDS - 1] =
         {
            sram_reg_wr_data,
            rd_data[(CPCI_DATA_WORDS - 1) * `CPCI_NF2_DATA_WIDTH - 1:0]
         };
      for (i = CPCI_DATA_WORDS; i < CPCI_WORDS; i = i + 1) begin : sram_words_empty
         assign sram_words_all[i] = rd_data;
      end
   end
   else begin
      assign sram_word = 0;
      assign sram_wr_data = sram_reg_wr_data;
   end
endgenerate

endmodule // sram_reg_access

