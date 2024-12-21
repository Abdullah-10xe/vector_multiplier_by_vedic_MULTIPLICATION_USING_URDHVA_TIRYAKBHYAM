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

module multiplier_32bit (
    input logic clk,                          // Clock signal
    input logic rst,                          // Reset signal
    input logic [31:0] operand_a_32bit,      // First 32-bit operand
    input logic [31:0] operand_b_32bit,      // Second 32-bit operand
    input logic [1:0] precision,              // Precision control
    output logic [63:0] output_32bit_mul      // 64-bit multiplication output
);

    // Internal signals
    logic [3:0][31:0] in_16bit_mul_block;     // Array to hold outputs from 16-bit multipliers
    logic [63:0] output_32bit_mul_wire;       // Wire for final multiplication output
    logic [63:0] output_32bit_mul_pr8_16;     // Output for precision 8 and 16
    logic [63:0] output_32bit_mul_pr32;       // Output for precision 32
    logic [15:0] mux_a_16bit_pre;             // Mux input for 16-bit operand A
    logic [31:0] csa_sum;                      // Sum output from carry-save adder
    logic [31:0] csa_carry;                    // Carry output from carry-save adder
    logic carry_bka;                           // Carry output from Brent-Kung adder
    logic mux_sel;                             // Mux selection signal
    logic [31:0] b_16_0;                       // 16-bit operand B part 0
    logic [31:0] b_16_1;                       // 16-bit operand B part 1
    logic [31:0] b_16_2;                       // 16-bit operand B part 2
    logic [31:0] b_16_3;                       // 16-bit operand B part 3
    logic mux_sel_reg;                         // Registered mux selection signal

    // Instantiate 16-bit multiplier units
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

    // Carry-save adder to combine partial products
    carry_save_adder #(.ADDER_WIDTH(32)) cs_adder (
        .operand_a_csa({in_16bit_mul_block[3][15:0], in_16bit_mul_block[0][31:16]}), 
        .operand_b_csa(in_16bit_mul_block[1]),
        .operand_c_csa(in_16bit_mul_block[2]),
        .sum_csv(csa_sum),
        .carry_csv(csa_carry)
    );

    // Brent-Kung adder to finalize the sum
    prefix_adder #(.ADDER_WIDTH(32), .NO_CARRY(0)) bk_adder (
        .operand_a({in_16bit_mul_block[3][16], csa_sum[31:1]}), 
        .operand_b(csa_carry),                     
        .sum_stage(output_32bit_mul_pr32[48:17]),
        .carry_bka(carry_bka)
    );

    // Carry-select adder to finalize the output
    carray_select_adder #(.ADDER_WIDTH(15)) csela (
        .operand_a_csela(in_16bit_mul_block[3][31:17]),
        .carry_in_csela(carry_bka),
        .sum_csela(output_32bit_mul_pr32[63:49])
    );

    // Assignments for output based on precision
    assign sum_bit0 = csa_sum[0];  // Capture the least significant bit of the sum
    assign mux_sel = (precision == 2'b10 || precision == 2'b11);  // Mux selection based on precision

    // Output assignments based on precision
    assign output_32bit_mul_pr32[16:0] = {csa_sum[0], in_16bit_mul_block[0][15:0]};  // Combine results for precision 32
    assign output_32bit_mul_pr8_16 = {in_16bit_mul_block[1], in_16bit_mul_block[0]};  // Combine results for precision 8 and 16
    assign mux_a_16bit_pre = mux_sel ? operand_a_32bit[15:0] : operand_a_32bit[31:16];  // Select operand A based on mux selection
    assign output_32bit_mul_wire = mux_sel_reg ? output_32bit_mul_pr32 : output_32bit_mul_pr8_16;  // Final output selection
    assign output_32bit_mul = output_32bit_mul_wire;  // Assign final output

    // Always block for registered mux selection
    always_ff @(posedge clk, negedge rst) begin
        if (!rst) begin
            mux_sel_reg <= 0;  // Reset registered mux selection
        end else begin
            mux_sel_reg <= mux_sel;  // Update registered mux selection
        end
    end

endmodule





