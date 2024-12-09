module multiplier_32bit (
    input  logic clk,                     // Clock input
    input  logic rst,                     // Reset input
    input  logic [31:0] operand_a_32bit, // First 32-bit operand
    input  logic [31:0] operand_b_32bit, // Second 32-bit operand
    input  logic [1:0] precision,         // Precision control
    output logic [63:0] output_32bit_mul, // 64-bit multiplication result
    output logic [1:0] precision_reg       // Registered precision
);

    // Internal signals
    logic [3:0][31:0] in_16bit_mul_block; // Array to hold 16-bit multiplication results
    logic [63:0] output_32bit_mul_wire;   // Wire for final output
    logic [63:0] output_32bit_mul_pr8_16; // Intermediate result for 8-16 precision
    logic [63:0] output_32bit_mul_pr32;   // Intermediate result for 32 precision
    logic [15:0] mux_a_16bit_pre;         // MUX input for 16-bit operand A
    logic [31:0] csa_sum;                  // Sum output from carry-save adder
    logic [31:0] csa_carry;                // Carry output from carry-save adder
    logic carry_bka;                       // Carry output from Brent-Kung adder
    logic mux_sel;                        // MUX selection signal
    logic [31:0] b_16_0;                  // 16-bit operand B part 0
    logic [31:0] b_16_1;                  // 16-bit operand B part 1
    logic [31:0] b_16_2;                  // 16-bit operand B part 2
    logic [31:0] b_16_3;                  // 16-bit operand B part 3
    logic mux_sel_reg;                    // Registered MUX selection signal

    // Assigning 16-bit parts of operand B
    assign b_16_0 = in_16bit_mul_block[0];
    assign b_16_1 = in_16bit_mul_block[1];
    assign b_16_2 = in_16bit_mul_block[2];
    assign b_16_3 = in_16bit_mul_block[3];

    // Instantiating four 16-bit multipliers partial muls
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

    // Assigning outputs based on precision
    assign sum_bit0 = csa_sum[0]; // LSB of the sum
    assign mux_sel = (precision == 2'b10 | precision == 2'b11); // MUX selection based on precision
    assign mux_sel_reg = (precision_reg == 2'b10 | precision_reg == 2'b11); // Registered MUX selection

    // Output assignments based on precision
    assign output_32bit_mul_pr32[16:0] = {csa_sum[0], in_16bit_mul_block[0][15:0]}; // 32-bit output for precision 32
    assign output_32bit_mul_pr8_16 = {in_16bit_mul_block[1], in_16bit_mul_block[0]}; // 32-bit output for precision 8-16
    assign mux_a_16bit_pre = mux_sel ? operand_a_32bit[15:0] : operand_a_32bit[31:16]; // MUX for operand A
    assign output_32bit_mul_wire = mux_sel_reg ? output_32bit_mul_pr32 : output_32bit_mul_pr8_16; // Final output selection
    assign output_32bit_mul = output_32bit_mul_wire; // Assign final output

    // Always block for updating precision register
    always_ff @(posedge clk, negedge rst) begin
        if (!rst) begin
            precision_reg <= 2'b00; // Reset precision register
        end else begin
            precision_reg <= precision; // Update precision register
        end
    end

endmodule
