module multiplier_8bit (
    input  logic [7:0] operand_a_8bit, // First 8-bit operand
    input  logic [7:0] operand_b_8bit, // Second 8-bit operand
    output logic [15:0] output_8bit_mul  // 16-bit multiplication result
);

    // Internal signals
    logic [3:0][7:0] in_4bit_mul_block; // Array to hold 4-bit multiplication results
    logic [7:0] csa_sum;                // Sum output from carry-save adder
    logic [7:0] csa_carry;              // Carry output from carry-save adder
    logic carry_bka;                    // Carry output from Brent-Kung adder

    // Assigning the lower bits of the output
    assign output_8bit_mul[3:0] = in_4bit_mul_block[0][3:0]; // LSBs from the first 4-bit multiplication
    assign output_8bit_mul[4] = csa_sum[0];                   // Next bit from the carry-save adder

    // Instantiating four 4-bit multipliers
    multiplier_4bit unit4_0 (
        .a_4bit(operand_a_8bit[3:0]),
        .b_4bit(operand_b_8bit[3:0]),
        .mul_out_4bit(in_4bit_mul_block[0])
    );

    multiplier_4bit unit4_1 (
        .a_4bit(operand_a_8bit[3:0]),
        .b_4bit(operand_b_8bit[7:4]),
        .mul_out_4bit(in_4bit_mul_block[1])
    );

    multiplier_4bit unit4_2 (
        .a_4bit(operand_a_8bit[7:4]),
        .b_4bit(operand_b_8bit[3:0]),
        .mul_out_4bit(in_4bit_mul_block[2])
    );

    multiplier_4bit unit4_3 (
        .a_4bit(operand_a_8bit[7:4]),
        .b_4bit(operand_b_8bit[7:4]),
        .mul_out_4bit(in_4bit_mul_block[3])
    );

    // Carry-save adder instantiation
    carry_save_adder #(.ADDER_WIDTH(8)) cs_adder (
        .operand_a_csa({in_4bit_mul_block[3][3:0], in_4bit_mul_block[0][7:4]}), 
        .operand_b_csa(in_4bit_mul_block[1]),
        .operand_c_csa(in_4bit_mul_block[2]),
        .sum_csv(csa_sum),
        .carry_csv(csa_carry)
    );

    // Brent-Kung adder instantiation
    brent_kung_adder #(.ADDER_WIDTH(8), .NO_CARRY(0)) bk_adder (
        .operand_a_bka({in_4bit_mul_block[3][4], csa_sum[7:1]}), // First operand
        .operand_b_bka(csa_carry),                               // Second operand
        .sum_bka(output_8bit_mul[12:5]),                        // Sum output
        .carry_bka(carry_bka)
    );

    // Carry-select adder instantiation
    carray_select_adder #(.ADDER_WIDTH(3)) csela (
        .operand_a_csela(in_4bit_mul_block[3][7:5]),
        .carry_in_csela(carry_bka),
        .sum_csela(output_8bit_mul[15:13]) // MSBs of the output
    );

endmodule
