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

module multiplier_16bit (
    input logic clk,                          // Clock signal
    input logic rst,                          // Reset signal
    input logic [15:0] operand_a_16bit,      // First 16-bit operand
    input logic [15:0] operand_b_16bit,      // Second 16-bit operand
    input logic [1:0] precision,              // Precision control
    output logic [31:0] output_16bit_mul      // 32-bit multiplication output
);

    // Internal signals
    logic [3:0][15:0] in_8bit_mul_block;      // Array to hold outputs from 8-bit multipliers
    logic [31:0] output_16bit_mul_wire;       // Wire for final multiplication output
    logic [31:0] output_16bit_mul_pr8;        // Output for precision 8
    logic [31:0] output_16bit_mul_pr16;       // Output for precision 16
    logic [7:0] mux_a_8bit_pre;               // Mux input for 8-bit operand A
    logic [15:0] csa_sum;                      // Sum output from carry-save adder
    logic [15:0] csa_carry;                    // Carry output from carry-save adder
    logic carry_bka;                           // Carry output from Brent-Kung adder
    logic mux_sel;                             // Mux selection signal
    logic [3:0][15:0] in_8bit_mul_block_reg;  // Registered outputs from 8-bit multipliers
    logic mux_sel_reg;                         // Registered mux selection signal

    // Instantiate 8-bit multiplier units
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

    // Carry-save adder to combine partial products
    carry_save_adder #(.ADDER_WIDTH(16)) cs_adder (
      .operand_a_csa({in_8bit_mul_block_reg[3][7:0], in_8bit_mul_block_reg[0][15:8]}), 
        .operand_b_csa(in_8bit_mul_block_reg[1]),
        .operand_c_csa(in_8bit_mul_block_reg[2]),
        .sum_csv(csa_sum),
        .carry_csv(csa_carry)
    );

    // Brent-Kung adder to finalize the sum
    prefix_adder #(.ADDER_WIDTH(16), .NO_CARRY(0)) bk_adder (
        .operand_a({in_8bit_mul_block_reg[3][8], csa_sum[15:1]}), 
        .operand_b(csa_carry),                     
        .sum_stage(output_16bit_mul_pr16[24:9]),
        .carry_bka(carry_bka)
    );

    // Carry-select adder to finalize the output
    carray_select_adder #(.ADDER_WIDTH(7)) csela (
        .operand_a_csela(in_8bit_mul_block_reg[3][15:9]),
        .carry_in_csela(carry_bka),
        .sum_csela(output_16bit_mul_pr16[31:25])
    );

    // Assignments for output based on precision
  
    assign mux_sel = (precision == 2'b00);  // Mux selection based on precision
  assign output_16bit_mul_pr16[8:0] = {csa_sum[0], in_8bit_mul_block_reg[0][7:0]};  // Combine results for precision 16
  assign output_16bit_mul_pr8 = {in_8bit_mul_block_reg[1], in_8bit_mul_block_reg[0]};    // Combine results for precision 8
    assign mux_a_8bit_pre = mux_sel ? operand_a_16bit[15:8] : operand_a_16bit[7:0]; // Select operand A based on mux selection
    assign output_16bit_mul = mux_sel_reg ? output_16bit_mul_pr8 : output_16bit_mul_pr16; // Final output selection

    // Always block for registered mux selection and storing intermediate results
    always_ff @(posedge clk, negedge rst) begin
        if (!rst) begin
            in_8bit_mul_block_reg <= 0;  // Reset registered outputs
            mux_sel_reg <= 0;            // Reset registered mux selection
        end else begin
            mux_sel_reg <= mux_sel;      // Update registered mux selection
            in_8bit_mul_block_reg <= in_8bit_mul_block; // Store current outputs from 8-bit multipliers
        end
    end

endmodule


