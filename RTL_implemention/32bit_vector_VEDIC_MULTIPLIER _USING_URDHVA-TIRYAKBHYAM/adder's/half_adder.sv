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
module half_adder(
    input logic half_adder_a,       // First input of the half adder
    input logic half_adder_b,       // Second input of the half adder
    output logic half_adder_sum,    // Output for the sum
    output logic half_adder_carry    // Output for the carry
);
  
  // Calculate the sum using XOR operation
  assign half_adder_sum = half_adder_a ^ half_adder_b;
  
  // Calculate the carry using AND operation
  assign half_adder_carry = half_adder_a & half_adder_b;
  
endmodule
