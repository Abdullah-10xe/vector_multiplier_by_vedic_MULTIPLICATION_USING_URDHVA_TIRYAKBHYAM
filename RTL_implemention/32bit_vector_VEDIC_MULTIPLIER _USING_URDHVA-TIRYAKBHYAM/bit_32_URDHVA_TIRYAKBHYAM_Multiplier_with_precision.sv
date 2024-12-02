/***********************************************************************************
* Author      : Abdullah Jhatial
* Designation : Associate Hardware Design Engineer
* Firm        : 10x Engineers
* Email       : abdullahjhatial92@gmail.com, abdullah.jhatial@10xengineers.ai
*  **********************       Design        ***************************************** 
* This module design for multipling32 bit data stream with supported precision 8,16,32
* Supported precision: 8-bit, 16-bit, 32-bit (00, 01, 10)
* Supported operations: MUL, MULH, MULHU, MULSU (00, 01, 10, 11)
* Design for Vector Multiplier based on VEDIC MULTIPLIER USING URDHVA-TIRYAKBHYAM
***********************************************************************************/



module two_bit_multiplier (
    input logic [1:0] a,        // First 2-bit input
    input logic [1:0] b,        // Second 2-bit input
    output logic [3:0] c        // 4-bit output for the product
);

    logic in_wire;              // Intermediate wire for carry
    logic [2:0] and_gate_wire;  // Wires for AND gate outputs

    // Generate partial products
    assign c[0] = a[0] & b[0];  // Least significant bit (LSB)
    assign and_gate_wire[0] = a[0] & b[1]; // a[0] * b[1]
    assign and_gate_wire[1] = a[1] & b[0]; // a[1] * b[0]
    assign and_gate_wire[2] = a[1] & b[1]; // a[1] * b[1]

    // First half adder to combine the first two partial products
    half_adder h_a_0 (
        .half_adder_a(and_gate_wire[0]),
        .half_adder_b(and_gate_wire[1]),
        .half_adder_sum(c[1]),   // Sum output
        .half_adder_carry(in_wire) // Carry output
    );

    // Second half adder to combine the last partial product with the carry
    half_adder h_a_1 (
        .half_adder_a(and_gate_wire[2]),
        .half_adder_b(in_wire),
        .half_adder_sum(c[2]),    // Second sum output
        .half_adder_carry(c[3])    // Final carry output
    );

endmodule



module multiplier_4bit (
    input logic [3:0] a_4bit,           // First 4-bit operand
    input logic [3:0] b_4bit,           // Second 4-bit operand
    output logic [7:0] mul_out_4bit     // 8-bit multiplication result
);
  
    logic [3:0][3:0] mul_block_wire;    // Intermediate multiplication results
    logic [3:0] csa_sum;                // Sum output from the carry-save adder
    logic [3:0] csa_carry;              // Carry output from the carry-save adder

    // Instantiate 2-bit multipliers for partial products
    two_bit_multiplier unit_0 (
        .a(a_4bit[1:0]),
        .b(b_4bit[1:0]),
        .c(mul_block_wire[0])
    );

    two_bit_multiplier unit_1 (
        .a(a_4bit[1:0]),
        .b(b_4bit[3:2]),
        .c(mul_block_wire[1])
    );

    two_bit_multiplier unit_2 (
        .a(a_4bit[3:2]),
        .b(b_4bit[1:0]),
        .c(mul_block_wire[2])
    );

    two_bit_multiplier unit_3 (
        .a(a_4bit[3:2]),
        .b(b_4bit[3:2]),
        .c(mul_block_wire[3])
    );

    // Assign the least significant bits of the multiplication result
    assign mul_out_4bit[1:0] = mul_block_wire[0][1:0]; // LSBs from the first partial product

    // Calculate the carry-save sum and carry
    carry_save_adder #(.ADDER_WIDTH(4)) cs_adder (
        .operand_a_csa({mul_block_wire[3][1:0], mul_block_wire[0][3:2]}), // Inputs for CSA
        .operand_b_csa(mul_block_wire[1]),
        .operand_c_csa(mul_block_wire[2]),
        .sum_csv(csa_sum),
        .carry_csv(csa_carry)
    );



brent_kung_adder_nc #(.ADDER_WIDTH(5)) bk_adder (
    .operand_a_bka({mul_block_wire[3][3:2], csa_sum[3:1]}), // First operand
    .operand_b_bka({1'b0, csa_carry}),                      // Second operand
    .sum_bka(mul_out_4bit[7:3])                            // Sum output
);




endmodule

