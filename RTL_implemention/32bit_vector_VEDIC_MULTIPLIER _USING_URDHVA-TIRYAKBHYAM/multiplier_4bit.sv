module multiplier_4bit (
    input logic [3:0] a_4bit,           // First 4-bit operand
    input logic [3:0] b_4bit,           // Second 4-bit operand
    output logic [7:0] mul_out_4bit     // 8-bit multiplication result
);
  
    logic [3:0][3:0] mul_block_wire;    // Intermediate multiplication results
    logic [3:0] csa_sum;                // Sum output from the carry-save adder
    logic [3:0] csa_carry;              // Carry output from the carry-save adder

    // Instantiate 2-bit multipliers for partial products
    two_bit_multiplier unit2_0 (
        .a(a_4bit[1:0]),
        .b(b_4bit[1:0]),
        .c(mul_block_wire[0])
    );

    two_bit_multiplier unit2_1 (
        .a(a_4bit[1:0]),
        .b(b_4bit[3:2]),
        .c(mul_block_wire[1])
    );

    two_bit_multiplier unit2_2 (
        .a(a_4bit[3:2]),
        .b(b_4bit[1:0]),
        .c(mul_block_wire[2])
    );

    two_bit_multiplier unit2_3 (
        .a(a_4bit[3:2]),
        .b(b_4bit[3:2]),
        .c(mul_block_wire[3])
    );

    // Assign the least significant bits of the multiplication result
    assign mul_out_4bit[1:0] = mul_block_wire[0][1:0]; // LSBs from the first partial product
    assign mul_out_4bit[2]=csa_sum[0];

    // Calculate the carry-save sum and carry
    carry_save_adder #(.ADDER_WIDTH(4)) cs_adder (
        .operand_a_csa({mul_block_wire[3][1:0], mul_block_wire[0][3:2]}), // Inputs for CSA
        .operand_b_csa(mul_block_wire[1]),
        .operand_c_csa(mul_block_wire[2]),
        .sum_csv(csa_sum),
        .carry_csv(csa_carry)
    );



  brent_kung_adder #(.ADDER_WIDTH(5)) bk_adder_nc (
    .operand_a_bka({mul_block_wire[3][3:2], csa_sum[3:1]}), // First operand
    .operand_b_bka({1'b0, csa_carry}),                      // Second operand
    .sum_bka(mul_out_4bit[7:3])                            // Sum output
);




endmodule

