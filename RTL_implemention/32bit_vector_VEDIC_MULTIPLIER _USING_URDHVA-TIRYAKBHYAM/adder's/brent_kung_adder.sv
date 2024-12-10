/***********************************************************************************
* Author      : Abdullah Jhatial
* Designation : Associate Hardware Design Engineer
* Firm        : 10x Engineers
* Email       : abdullahjhatial92@gmail.com, abdullah.jhatial@10xengineers.ai
*  **********************       Design        ***************************************** 
* This module design is for taking two's complement depending on the opcode and precision.
* Supported precision: 8-bit, 16-bit, 32-bit (00, 01, 10)
* Supported operations: MUL, MULH, MULHU, MULSU (00, 01, 10, 11)
* Design for Vector Multiplier based on VEDIC MULTIPLIER USING URDHVA-TIRYAKBHYAM
***********************************************************************************/
module brent_kung_adder #(parameter ADDER_WIDTH = 4,parameter NO_CARRY=1) (
    input logic [ADDER_WIDTH-1:0] operand_a_bka,  // First operand input
    input logic [ADDER_WIDTH-1:0] operand_b_bka,  // Second operand input
    output logic [ADDER_WIDTH-1:0] sum_bka,          // Sum output
    output logic carry_bka
);
  
    // Combinatorial logic to compute the sum
  generate 
    if(NO_CARRY==1)
      assign sum_bka = operand_a_bka + operand_b_bka;  // Perform addition
    if(NO_CARRY==0)
   assign { carry_bka,sum_bka }= operand_a_bka + operand_b_bka; 
  endgenerate
   
  
endmodule
