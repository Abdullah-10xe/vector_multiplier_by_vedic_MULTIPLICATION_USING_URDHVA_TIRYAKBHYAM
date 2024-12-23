/***********************************************************************************
* Author      : Abdullah Jhatial
* Designation : Associate Hardware Design Engineer
* Firm        : 10x Engineers
* Email       : abdullahjhatial92@gmail.com, abdullah.jhatial@10xengineers.ai
*  **********************       Design        ***************************************** 
* This moduel  8x8mul unit for 32bit multiplier block it multiple 8bit unsigned  numbers 
* Design for Vector Multiplier based on VEDIC MULTIPLIER USING URDHVA-TIRYAKBHYAM
***************************************************************************************/



module  multiplier_8bit  (input  logic [7:0]  operand_a_8bit,
                          input  logic [7:0]  operand_b_8bit,
                          output logic [15:0] output_8bit_mul);
  logic [3:0][7:0] in_4bit_mul_block;
  logic [7:0]      csa_sum;
  logic [7:0]      csa_carry; 
  logic carry_bka;
  assign output_8bit_mul[3:0]=in_4bit_mul_block[0][3:0];
  assign output_8bit_mul[4]=csa_sum[0];
  multiplier_4bit unit4_0(.a_4bit(operand_a_8bit[3:0]),.b_4bit(operand_b_8bit[3:0]),.mul_out_4bit(in_4bit_mul_block[0]));
  
  multiplier_4bit unit4_1(.a_4bit(operand_a_8bit[3:0]),.b_4bit(operand_b_8bit[7:4]),.mul_out_4bit(in_4bit_mul_block[1]));
  
  multiplier_4bit unit4_2(.a_4bit(operand_a_8bit[7:4]),.b_4bit(operand_b_8bit[3:0]),.mul_out_4bit(in_4bit_mul_block[2]));
  
  multiplier_4bit unit4_3(.a_4bit(operand_a_8bit[7:4]),.b_4bit(operand_b_8bit[7:4]),.mul_out_4bit(in_4bit_mul_block[3]));
  
  carry_save_adder #(.ADDER_WIDTH(8)) cs_adder (
    .operand_a_csa({in_4bit_mul_block[3][3:0],in_4bit_mul_block [0][7:4]}), 
        .operand_b_csa(in_4bit_mul_block[1]),
        .operand_c_csa(in_4bit_mul_block[2]),
        .sum_csv(csa_sum),
        .carry_csv(csa_carry)
    );
 
  prefix_adder #(.ADDER_WIDTH(8),.NO_CARRY(0)) bk_adder  (
    .operand_a({in_4bit_mul_block[3][4], csa_sum[7:1]}), // First operand
    .operand_b(csa_carry),                      // Second operand
    .sum_stage(output_8bit_mul[12:5]) ,                           // Sum output
    .carry_bka(carry_bka)
);
 
  carray_select_adder #(.ADDER_WIDTH(3)) csela (  .operand_a_csela(in_4bit_mul_block[3][7:5]),
                                       .carry_in_csela(carry_bka),
                                       .sum_csela(output_8bit_mul[15:13]));
    
     
 
endmodule



