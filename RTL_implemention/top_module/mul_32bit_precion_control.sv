/***********************************************************************************
* Author      : Abdullah Jhatial
* Designation : Associate Hardware Design Engineer
* Firm        : 10x Engineers
* Email       : abdullahjhatial92@gmail.com, abdullah.jhatial@10xengineers.ai
*  **********************       Design        ***************************************** 
* This module design is for combine the all modules  
* Supported precision: 8-bit, 16-bit, 32-bit (00, 01, 10)
* Supported operations: MUL, MULH, MULHU, MULSU (00, 01, 10, 11)
* Design for Vector Multiplier based on VEDIC MULTIPLIER USING URDHVA-TIRYAKBHYAM
* test with all opcode and precsions with 10000 randomize values
***********************************************************************************/

module mul_32bit_precion_control (
    input logic clk,                     // Clock signal
    input logic rst,                     // Reset signal
    input logic [31:0] operand_a_reg,   // Input operand A
    input logic [31:0] operand_b_reg,   // Input operand B
    input logic [1:0] opcode_reg,        // Operation code
    input logic [1:0] precision_reg,     // Precision control
    output logic [31:0] mul_out          // Output of the multiplication
);

    // Internal signals
    logic [1:0] opcode;                  // Current opcode
    logic [1:0] precision;               // Current precision
    logic [31:0] operand_a;              // Operand A for multiplication
    logic [31:0] operand_b;              // Operand B for multiplication
    logic [31:0] operand_a_from_tc;      // Operand A from test case
    logic [31:0] operand_b_from_tc;      // Operand B from test case
    logic [3:0] sign_signal_a;           // Sign signal for operand A
    logic [3:0] sign_signal_b;           // Sign signal for operand B
    logic [63:0] mul_block_out;          // Output from the multiplication block
    logic [1:0] opcode_2reg;             // Opcode for register
    logic [1:0] precision_w;              // Write precision
    logic [3:0] sign_signal_a_w;         // Write sign signal for operand A
    logic [3:0] sign_signal_b_w;         // Write sign signal for operand B
    logic [31:0] mul_out_w;               // Intermediate multiplication output
    logic [63:0] o64;                     // 64-bit output (not used in this snippet)

    // Instantiate the 64-bit precision control module
    tc_64bit_with_precision #(.WIDTH(16)) output_select_control (
        .opcode(opcode_2reg),
        .precision(precision_w),
        .sign_signal_a(sign_signal_a),
        .sign_signal_b(sign_signal_b),
        .mul_out(mul_out_w),
        .mul_block_output(mul_block_out)
    );

    // Instantiate the control logic for operand A
    tc_sel_control_logic tc_sel_control_logic_opa (
        .opcode(opcode),
        .precision(precision),
        .operand_a(operand_a),
        .operand_a_from_tc(operand_a_from_tc),
        .sign_signal(sign_signal_a_w)
    );

    // Instantiate the control logic for operand B
    tc_sel_control_logic #( .OPERAN_B(1)) tc_sel_control_logic_opb (
        .opcode(opcode),
        .precision(precision),
        .operand_a(operand_b),
        .operand_a_from_tc(operand_b_from_tc),
        .sign_signal(sign_signal_b_w)
    );

    // Instantiate the 32-bit multiplier block
    multiplier_32bit mul_block32 (
        .clk(clk),
        .rst(rst),
        .operand_a_32bit(operand_a_from_tc),
        .operand_b_32bit(operand_b_from_tc),
        .output_32bit_mul(mul_block_out),
        .precision(precision),
        .precision_reg(precision_w)
    );

    // Sequential logic for updating registers on clock edge
    always_ff @(posedge clk, negedge rst) begin
        if (!rst) begin
            // Reset all registers
            operand_a <= 0;
            operand_b <= 0;
            opcode <= 0;
            precision <= 0;
            sign_signal_a <= 0;
            sign_signal_b <= 0;
            opcode_2reg <= 0;
            mul_out <= 0;
        end else begin
            // Update registers with input values
            operand_a <= operand_a_reg;
            operand_b <= operand_b_reg;
            opcode <= opcode_reg;
            precision <= precision_reg;
            sign_signal_a <= sign_signal_a_w;
            sign_signal_b <= sign_signal_b_w;
            opcode_2reg <= opcode;
            mul_out <= mul_out_w;
        end
    end

endmodule
