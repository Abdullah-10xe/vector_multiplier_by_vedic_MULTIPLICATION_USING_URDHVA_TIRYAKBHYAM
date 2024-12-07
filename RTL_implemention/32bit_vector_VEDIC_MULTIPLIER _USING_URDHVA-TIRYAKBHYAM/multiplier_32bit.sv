module  multiplier_32bit  (input  logic clk, input logic rst,
                           input  logic [31:0] operand_a_32bit,
                           input  logic [31:0] operand_b_32bit,
                           input  logic [1:0] precision,
                           output logic [63:0] output_32bit_mul,
                           output logic [1:0] precision_reg);
  logic [3:0][31:0]in_16bit_mul_block;
  logic [63:0] output_32bit_mul_wire; 
  logic [63:0] output_32bit_mul_pr8_16;
  logic [63:0] output_32bit_mul_pr32;
  logic [15:0]  mux_a_16bit_pre;
  logic [31:0] csa_sum;
  logic [31:0] csa_carry;
  logic        carry_bka;
  logic          mux_sel;
  logic     [31:0] b_16_0;
  logic     [31:0] b_16_1;
  logic     [31:0] b_16_2;
  logic     [31:0] b_16_3;
  logic       mux_sel_reg;
  assign b_16_0=in_16bit_mul_block[0];
  assign b_16_1=in_16bit_mul_block[1];
  assign b_16_2=in_16bit_mul_block[2];
  assign b_16_3=in_16bit_mul_block[3];
       
  multiplier_16bit unit16_0 (.clk(clk),.rst(rst),.operand_a_16bit(operand_a_32bit[15:0]),.operand_b_16bit(operand_b_32bit[15:0]),
                            .output_16bit_mul(in_16bit_mul_block[0]),.precision(precision));
  multiplier_16bit unit16_1 (.clk(clk),.rst(rst),.operand_a_16bit(mux_a_16bit_pre),.operand_b_16bit( operand_b_32bit[31:16]),
                            .output_16bit_mul(in_16bit_mul_block[1]),.precision(precision));
  multiplier_16bit unit16_2 (.clk(clk),.rst(rst),.operand_a_16bit(operand_a_32bit[31:16]),.operand_b_16bit(operand_b_32bit[15:0]),
                            .output_16bit_mul(in_16bit_mul_block[2]),.precision(precision));
  multiplier_16bit unit16_3 (.clk(clk),.rst(rst),.operand_a_16bit(operand_a_32bit[31:16]),.operand_b_16bit(operand_b_32bit[31:16]),
                            .output_16bit_mul(in_16bit_mul_block[3]),.precision(precision));
  
  
  
  carry_save_adder #(.ADDER_WIDTH(32)) cs_adder (
    .operand_a_csa({in_16bit_mul_block [3][15:0],in_16bit_mul_block [0][31:16]}), 
    .operand_b_csa(in_16bit_mul_block[1]),
    .operand_c_csa(in_16bit_mul_block[2]),
    .sum_csv(csa_sum),
    .carry_csv(csa_carry)
    );
  
  
  
  brent_kung_adder #(.ADDER_WIDTH(32),.NO_CARRY(0)) bk_adder  (
    .operand_a_bka({in_16bit_mul_block[3][16], csa_sum[31:1]}), 
    .operand_b_bka(csa_carry),                     
    .sum_bka(output_32bit_mul_pr32[48:17]),
     .carry_bka(carry_bka)
);
  
  carray_select_adder #(.ADDER_WIDTH(15)) csela (  
    .operand_a_csela(in_16bit_mul_block[3][31:17]),
                                       .carry_in_csela(carry_bka),
    .sum_csela(output_32bit_mul_pr32[63:49]));
     
  
  
  
  
  assign sum_bit0=csa_sum[0];
  assign mux_sel=(precision==2'b10|precision==2'b11);
  assign mux_sel_reg=(precision_reg==2'b10|precision_reg==2'b11);
  assign output_32bit_mul_pr32 [16:0]={csa_sum[0],in_16bit_mul_block[0][15:0]};
  assign output_32bit_mul_pr8_16 ={in_16bit_mul_block[1],in_16bit_mul_block[0]};
  assign mux_a_16bit_pre=mux_sel?operand_a_32bit[15:0]:operand_a_32bit[31:16];
  assign output_32bit_mul_wire=mux_sel_reg? output_32bit_mul_pr32:output_32bit_mul_pr8_16  ;
  assign output_32bit_mul=output_32bit_mul_wire;

  always_ff @(posedge clk,negedge rst)
    begin
      
      if(!rst)
        begin
        
        precision_reg<=2'b00;
        end
      else
        begin
         
          precision_reg<=precision;
          
          
          
        end
      
      
    end
 
endmodule


