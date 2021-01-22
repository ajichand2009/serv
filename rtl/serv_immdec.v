`default_nettype none
module serv_immdec
  (
   input wire 	     i_clk,
   //State
   input wire 	     i_cnt_en,
   input wire 	     i_cnt_done,
   //Control
   input wire 	     i_csr_imm_en,
   input wire [3:0]  i_ctrl,
   output wire [4:0] o_rd_addr,
   output wire [4:0] o_rs1_addr,
   output wire [4:0] o_rs2_addr,
   //Data
   output wire 	     o_csr_imm,
   output wire 	     o_imm,
   //External
   input wire 	     i_wb_en,
   input wire [31:7] i_wb_rdt);

   reg 		     imm31;

   reg [8:0]  imm19_12_20;
   reg 	      imm7;
   reg [5:0]  imm30_25;
   reg [4:0]  imm24_20;
   reg [4:0]  imm11_7;

   reg [4:0]  rd_addr;
   reg [4:0]  rs1_addr;
   reg [4:0]  rs2_addr;

   assign o_rd_addr  = rd_addr;
   assign o_rs1_addr = rs1_addr;
   assign o_rs2_addr = rs2_addr;

   assign o_imm = i_cnt_done ? signbit : i_ctrl[0] ? imm11_7[0] : imm24_20[0];
   assign o_csr_imm = imm19_12_20[4];

   wire       signbit = imm31 & !i_csr_imm_en;

   always @(posedge i_clk) begin
      if (i_wb_en) begin
	 /* CSR immediates are always zero-extended, hence clear the signbit */
	 imm31       <= i_wb_rdt[31];
	 imm19_12_20 <= {i_wb_rdt[19:12],i_wb_rdt[20]};
	 imm7        <= i_wb_rdt[7];
	 imm30_25    <= i_wb_rdt[30:25];
	 imm24_20    <= i_wb_rdt[24:20];
	 imm11_7     <= i_wb_rdt[11:7];

         rd_addr  <= i_wb_rdt[11:7];
         rs1_addr <= i_wb_rdt[19:15];
         rs2_addr <= i_wb_rdt[24:20];
      end
      if (i_cnt_en) begin
	 imm19_12_20 <= {i_ctrl[3] ? signbit : imm24_20[0], imm19_12_20[8:1]};
	 imm7        <= signbit;
	 imm30_25    <= {i_ctrl[2] ? imm7 : i_ctrl[1] ? signbit : imm19_12_20[0], imm30_25[5:1]};
	 imm24_20    <= {imm30_25[0], imm24_20[4:1]};
	 imm11_7     <= {imm30_25[0], imm11_7[4:1]};
      end
   end
endmodule
