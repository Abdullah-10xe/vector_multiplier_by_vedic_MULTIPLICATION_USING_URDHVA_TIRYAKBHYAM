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
module carray_select_adder #(parameter ADDER_WIDTH = 2) (
    input logic [ADDER_WIDTH-1:0] operand_a_csela, // Input operand
    input logic carry_in_csela,                      // Carry input
    output logic [ADDER_WIDTH-1:0] sum_csela        // Output sum
);

    // Internal signals for the two possible sums
    logic [ADDER_WIDTH-1:0] sum_0; // Sum when carry input is 0
    logic [ADDER_WIDTH-1:0] sum_1; // Sum when carry input is 1

    // Calculate the two possible sums
    assign sum_0 = operand_a_csela + 1'b0; // No change to operand_a_csela
    assign sum_1 = operand_a_csela + 1'b1; // Increment operand_a_csela by 1

    // Select the appropriate sum based on the carry input
    assign sum_csela = carry_in_csela ? sum_1 : sum_0;

endmodule
