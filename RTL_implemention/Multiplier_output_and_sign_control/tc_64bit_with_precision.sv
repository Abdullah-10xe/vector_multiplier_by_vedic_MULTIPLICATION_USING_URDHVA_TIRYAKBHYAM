/***********************************************************************************
* Author      : Abdullah Jhatial
* Designation : Associate Hardware Design Engineer
* Firm        : 10x Engineers
* Email       : abdullahjhatial92@gmail.com, abdullah.jhatial@10xengineers.ai
*  **********************       Design        ***************************************** 
* This module design is for taking two's complement of output from Multiplier block
* Depending on oprands signs_signals and precision
* Supported precision: 8-bit, 16-bit, 32-bit (00, 01, 10)
* Supported operations: MUL, MULH, MULHU, MULSU (00, 01, 10, 11)
* Design for Vector Multiplier based on VEDIC MULTIPLIER USING URDHVA-TIRYAKBHYAM
***********************************************************************************/
   
module tc_64bit_with_precision #(parameter WIDTH = 16) (
    input logic [63:0] mul_block_output,  // 64-bit output from the multiplication block
    input logic [1:0] opcode,              // Operation code to determine the operation
    input logic [1:0] precision,           // Precision control for the output
    input logic [3:0] sign_signal_a,       // Sign signals for operand A
    input logic [3:0] sign_signal_b,       // Sign signals for operand B
    output logic [31:0] mul_out            // 32-bit output of the multiplication
);

    logic [63:0] mul_out_tc;              // Temporary output from the test case
    logic [63:0] mul_out_mux_sel;          // Mux selection for output
    logic [3:0] sign_mux_sel;              // Mux selection for sign signals

    // Instantiate the test case bit stream with precision
    tc_bit_stream_with_precision #(.WIDTH(WIDTH)) tc_64bit_with_precision (
        .operand_a(mul_block_output),
        .output_operand(mul_out_tc),
        .precision(precision)
    );

    genvar i;
    generate 
        for (i = 0; i <= 3; i++) begin
            // Calculate the sign based on XOR of sign signals
            assign sign_mux_sel[i] = sign_signal_a[i] ^ sign_signal_b[i];
            // Select the output based on the sign
            assign mul_out_mux_sel[(WIDTH * (i + 1)) - 1 : WIDTH * i] = 
                sign_mux_sel[i] ? mul_out_tc[(WIDTH * (i + 1)) - 1 : WIDTH * i] : 
                mul_block_output[(WIDTH * (i + 1)) - 1 : WIDTH * i]; 
        end
    endgenerate

    always_comb begin
        // Determine the output based on opcode and precision
      mul_out={ mul_out_mux_sel[56:48], mul_out_mux_sel[39:32], mul_out_mux_sel[23:16], mul_out_mux_sel[7:0]};
        if (opcode == 2'b00 && precision == 2'b00) begin
            mul_out = {mul_out_mux_sel[56:48], mul_out_mux_sel[39:32], 
                       mul_out_mux_sel[23:16], mul_out_mux_sel[7:0]};
        end else if (opcode == 2'b00 && precision == 2'b01) begin
            mul_out = {mul_out_mux_sel[47:32], mul_out_mux_sel[15:0]};
        end else if (opcode == 2'b00 && precision == 2'b10) begin
            mul_out = mul_out_mux_sel[31:0];
        end else if (opcode == 2'b00 && precision == 2'b11) begin
            mul_out = {mul_out_mux_sel[56:48], mul_out_mux_sel[39:32], 
                       mul_out_mux_sel[23:16], mul_out_mux_sel[7:0]};
        end else if (opcode != 2'b00 && precision == 2'b00) begin
          mul_out = {mul_out_mux_sel[63:56], mul_out_mux_sel[47:40], 
                       mul_out_mux_sel[31:24], mul_out_mux_sel[15:8]};
        end else if (opcode != 2'b00 && precision == 2'b01) begin 
            mul_out = {mul_out_mux_sel[63:48], mul_out_mux_sel[31:16]};
        end else if (opcode != 2'b00 && precision == 2'b10) begin
            mul_out = mul_out_mux_sel[63:32];
        end
    end
endmodule
