module multiplier_16bit (
    input  logic clk,                     // Clock input
    input  logic rst,                     // Reset input
    input  logic [15:0] operand_a_16bit, // First 16-bit operand
    input  logic [15:0] operand_b_16bit, // Second 16-bit operand
    input  logic [1:0] precision,         // Precision control
    output logic [31:0] output_16bit_mul   // 32-bit multiplication result
);

    // Internal signals
    logic [3:0][15:0] in_8bit_mul_block; // Array to hold 8-bit multiplication results
    logic [31:0] output_16bit_mul_wire;  // Wire for final output
    logic [31:0] output_16bit_mul_pr8;   // Intermediate result for 8-bit precision
    logic [31:0] output_16bit_mul_pr16;  // Intermediate result for 16-bit precision
    logic [7:0] mux_a_8bit_pre;          // MUX input for 8-bit operand A
    logic [15:0] csa_sum;                 // Sum output from carry-save adder
    logic [15:0] csa_carry;               // Carry output from carry-save adder
    logic carry_bka;                      // Carry output from Brent-Kung adder
    logic mux_sel;                       // MUX selection signal

    // Instantiating four 8-bit multipliers
    multiplier_8bit unit8_0 (
        .operand_a_8bit(operand_a_16bit[7:0]),
        .operand_b_8bit(operand_b_16bit[7:0]),
        .output_8bit_mul(in_8bit_mul_block[0])
    );

    multiplier_8bit unit8_1 (
        .operand_a_8bit(mux_a_8bit_pre),
        .operand_b_8bit(operand_b_16bit[15:8]),
        .output_8bit_mul(in_8bit_mul_block[1])
    );

    multiplier_8bit unit8_2 (
        .operand_a_8bit(operand_a_16bit[15:8]),
        .operand_b_8bit(operand_b_16bit[7:0]),
        .output_8bit_mul(in_8bit_mul_block[2])
    );

    multiplier_8bit unit8_3 (
        .operand_a_8bit(operand_a_16bit[15:8]),
        .operand_b_8bit(operand_b_16bit[15:8]),
        .output_8bit_mul(in_8bit_mul_block[3])
    );

    // Carry-save adder instantiation
    carry_save_adder #(.ADDER_WIDTH(16)) cs_adder (
        .operand_a_csa({in_8bit_mul_block[3][7:0], in_8bit_mul_block[0][15:8]}), 
        .operand_b_csa(in_8bit_mul_block[1]),
        .operand_c_csa(in_8bit_mul_block[2]),
        .sum_csv(csa_sum),
        .carry_csv(csa_carry)
    );

    // Brent-Kung adder instantiation
    brent_kung_adder #(.ADDER_WIDTH(16), .NO_CARRY(0)) bk_adder (
        .operand_a_bka({in_8bit_mul_block[3][8], csa_sum[15:1]}), 
        .operand_b_bka(csa_carry),                     
        .sum_bka(output_16bit_mul_pr16[24:9]),
        .carry_bka(carry_bka)
    );

    // Carry-select adder instantiation
    carray_select_adder #(.ADDER_WIDTH(7)) csela (
        .operand_a_csela(in_8bit_mul_block[3][15:9]),
        .carry_in_csela(carry_bka),
        .sum_csela(output_16bit_mul_pr16[31:25])
    );

    // Assigning outputs based on precision
    assign mux_sel = (precision == 2'b00); // MUX selection based on precision
    assign output_16bit_mul_pr16[8:0] = {csa_sum[0], in_8bit_mul_block[0][7:0]}; // 16-bit output for precision 16
    assign output_16bit_mul_pr8 = {in_8bit_mul_block[1], in_8bit_mul_block[0]}; // 16-bit output for precision 8
    assign mux_a_8bit_pre = mux_sel ? operand_a_16bit[15:8] : operand_a_16bit[7:0]; // MUX for operand A
    assign output_16bit_mul_wire = mux_sel ? output_16bit_mul_pr8 : output_16bit_mul_pr16; // Final output selection

    // Always block for updating output on clock edge
    always_ff @(posedge clk, negedge rst) begin
        if (!rst) begin
            output_16bit_mul <= 0; // Reset output to 0
        end else begin
            output_16bit_mul = output_16bit_mul_wire; // Update output with the selected wire
        end
    end

endmodule
