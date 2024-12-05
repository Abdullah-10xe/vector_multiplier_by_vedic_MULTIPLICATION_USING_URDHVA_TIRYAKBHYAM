module multiplier_32bit (
    input  logic clk,                     // Clock input
    input  logic rst,                     // Reset input
    input  logic [31:0] operand_a_32bit, // 32-bit input operand A
    input  logic [31:0] operand_b_32bit, // 32-bit input operand B
    input  logic [1:0] precision,         // Precision control (00: 8-bit, 01: 16-bit, 10: 32-bit, etc.)
    output logic [63:0] output_32bit_mul  // 64-bit output for the multiplication result
);

    // Internal signals for 16-bit multiplication blocks
    logic [3:0][31:0] in_16bit_mul_block; // Array to hold results of 16-bit multiplications
    logic [63:0] output_32bit_mul_wire;   // Wire for the final output
    logic [63:0] output_32bit_mul_pr8_16; // Output for 8-bit and 16-bit precision
    logic [63:0] output_32bit_mul_pr32;   // Output for 32-bit precision
    logic [15:0] mux_a_16bit_pre;         // Mux input for selecting 16-bit operand
    logic [31:0] csa_sum;                  // Sum output from the carry-save adder
    logic [31:0] csa_carry;                // Carry output from the carry-save adder
    logic carry_bka;                       // Carry output from the Brent-Kung adder
    logic mux_sel;                        // Mux selection signal
   

    // Instantiating 16-bit multiplier units
    multiplier_16bit unit16_0 (
        .clk(clk),
        .rst(rst),
        .operand_a_16bit(operand_a_32bit[15:0]),
        .operand_b_16bit(operand_b_32bit[15:0]),
        .output_16bit_mul(in_16bit_mul_block[0]),
        .precision(precision)
    );

    multiplier_16bit unit16_1 (
        .clk(clk),
        .rst(rst),
        .operand_a_16bit(mux_a_16bit_pre),
        .operand_b_16bit(operand_b_32bit[31:16]),
        .output_16bit_mul(in_16bit_mul_block[1]),
        .precision(precision)
    );

    multiplier_16bit unit16_2 (
        .clk(clk),
        .rst(rst),
        .operand_a_16bit(operand_a_32bit[31:16]),
        .operand_b_16bit(operand_b_32bit[15:0]),
        .output_16bit_mul(in_16bit_mul_block[2]),
        .precision(precision)
    );

    multiplier_16bit unit16_3 (
        .clk(clk),
        .rst(rst),
        .operand_a_16bit(operand_a_32bit[31:16]),
        .operand_b_16bit(operand_b_32bit[31:16]),
        .output_16bit_mul(in_16bit_mul_block[3]),
        .precision(precision)
    );

    // Carry-save adder instantiation
    carry_save_adder #(.ADDER_WIDTH(32)) cs_adder (
        .operand_a_csa({in_16bit_mul_block[3][15:0], in_16bit_mul_block[0][31:16]}), 
        .operand_b_csa(in_16bit_mul_block[1]),
        .operand_c_csa(in_16bit_mul_block[2]),
        .sum_csv(csa_sum),
        .carry_csv(csa_carry)
    );

    // Brent-Kung adder instantiation
    brent_kung_adder #(.ADDER_WIDTH(32), .NO_CARRY(0)) bk_adder (
        .operand_a_bka({in_16bit_mul_block[3][16], csa_sum[31:1]}), 
        .operand_b_bka(csa_carry),                     
        .sum_bka(output_32bit_mul_pr32[48:17]),
        .carry_bka(carry_bka)
    );

    // Carry-select adder instantiation
    carray_select_adder #(.ADDER_WIDTH(15)) csela (
        .operand_a_csela(in_16bit_mul_block[3][31:17]),
                .carry_in_csela(carry_bka),
        .sum_csela(output_32bit_mul_pr32[63:49])
    );

    // Assigning the first bit of the sum for output
    
    // Mux selection based on precision
    assign mux_sel = (precision == 2'b10 | precision == 2'b11); // Select for 16-bit or 32-bit precision
    assign output_32bit_mul_pr32[16:0] = {csa_sum[0], in_16bit_mul_block[0][15:0]}; // Combine results for 32-bit precision
    assign output_32bit_mul_pr8_16 = {in_16bit_mul_block[1], in_16bit_mul_block[0]}; // Combine results for 8-bit and 16-bit precision

    // Select the appropriate 16-bit operand based on precision
    assign mux_a_16bit_pre = mux_sel ? operand_a_32bit[15:0] : operand_a_32bit[31:16];

    // Select the final output based on precision
    assign output_32bit_mul_wire = mux_sel ? output_32bit_mul_pr32 : output_32bit_mul_pr8_16;

    // Assign the final output
    assign output_32bit_mul = output_32bit_mul_wire;

endmodule