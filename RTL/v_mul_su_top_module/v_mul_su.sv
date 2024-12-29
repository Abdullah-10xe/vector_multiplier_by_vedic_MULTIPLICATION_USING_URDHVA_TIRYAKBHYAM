/*************************************************************************************************************************
* Author      : Abdullah Jhatial
* Designation : Associate Hardware Design Engineer
* Company     : 10x Engineers   
* Email       : abdullahjhatial92@gmail.com, abdullah.jhatial@10xengineers.ai
*  **********************       Design        *****************************************************************************
* This module design is for combining  the all modules :it is top moduel for Vedic Signed-Unsigned 32 bit Vector multiplier   
* Supported precision: 8-bit, 16-bit, 32-bit (00, 01, 10)
* Supported operations: MUL, MULH, MULHU, MULSU (00, 01, 10, 11)
* Design for Vector Multiplier based on VEDIC MULTIPLIER USING URDHVA-TIRYAKBHYAM
* test with all opcode and precsions with 50000 randomize values
***************************************************************************************************************************/
module v_mult_su (
    input logic clk,                     // Clock signal
    input logic rst,                     // Reset signal
    input logic [31:0] operand_a_reg,   // First operand input register
    input logic [31:0] operand_b_reg,   // Second operand input register
    input logic [1:0] opcode_reg,        // Opcode input register
    input logic [1:0] precision_reg,     // Precision input register
    output logic [31:0] mul_out          // Output of the multiplication
);
  
 
    // Stage 1 signals
    logic [1:0] opcode;                  // Opcode for operation
    logic [1:0] precision;               // Precision for operation
    logic [31:0] operand_a;              // First operand
    logic [31:0] operand_b;              // Second operand
    logic [31:0] operand_a_from_tc;      // Operand A after two's complement
    logic [31:0] operand_b_from_tc;      // Operand B after two's complement
    logic [3:0] sign_signal_a;           // Sign signal for operand A
    logic [3:0] sign_signal_b;           // Sign signal for operand B

    // Stage 2 signals
    logic [63:0] mul_block_out;          // Output from multiplication block
    logic [1:0] opcode_pipe1;            // Pipelined opcode

    logic [3:0] sign_signal_a_w;         // Write signal for sign of operand A
    logic [3:0] sign_signal_b_w;         // Write signal for sign of operand B
    logic [31:0] mul_out_w;              // Intermediate multiplication output
    logic [1:0] precision_pipe1;         // Pipelined precision

    // Instance of two's complement control with precision
   output_control #(.WIDTH(16)) output_select_control (
        .opcode(opcode_pipe1),
        .precision(precision_pipe1),
        .sign_signal_a(sign_signal_a),
        .sign_signal_b(sign_signal_b),
        .mul_out(mul_out_w),
      .mul_block_output(mul_block_out)
    );

    // Instance of operand A selection control logic
   operand_tc_contorl    operand_a_tc(
        .opcode(opcode),
        .precision(precision),
        .operand_a(operand_a),
        .operand_a_from_tc(operand_a_from_tc),
        .sign_signal(sign_signal_a_w)
    );

    // Instance of operand B selection control logic
  operand_tc_contorl #( .operand_select(1)) operand_b_tc (
        .opcode(opcode),
        .precision(precision),
        .operand_a(operand_b),
        .operand_a_from_tc(operand_b_from_tc),
        .sign_signal(sign_signal_b_w)
    );
 
     
    // Instance of the 32-bit multiplier block
    multiplier_32bit mul_block32 (
        .clk(clk),
        .rst(rst),
        .operand_a_32bit(operand_a_from_tc),
        .operand_b_32bit(operand_b_from_tc),
        .output_32bit_mul(mul_block_out),
        .precision(precision)
    );
      ////////////////////   Input regesters   ///////////////////////////////////////////////
    always_ff @(posedge clk, negedge rst) begin
        if (!rst) begin
            // Reset all signals
            operand_a <= '0;
            operand_b <= '0;
            opcode    <= '0;
            precision <= '0;
            
        end else begin
            // Update signals on clock edge
            operand_a <= operand_a_reg;
            operand_b <= operand_b_reg;
            opcode <= opcode_reg;
            precision <= precision_reg;
            
        end
    end
  /////////////////////  Intermidate Registers  /////////////////////////////////////
    always_ff @(posedge clk, negedge rst) 
      begin
        if (!rst) begin
            sign_signal_a    <= '0;
            sign_signal_b    <= '0;
            opcode_pipe1     <= '0;
            precision_pipe1  <= '0;
        end 
        else 
          begin
            sign_signal_a   <= sign_signal_a_w;
            sign_signal_b   <= sign_signal_b_w;
            opcode_pipe1    <= opcode;
            precision_pipe1 <= precision;
        end
      end
 ////////////////////////////  output register ////////////////////////////////////
    always_ff @(posedge clk, negedge rst) begin
        if (!rst) begin
            
            mul_out <= '0;
          
        end else 
          begin
            mul_out <= mul_out_w;
           
        end
    end

endmodule   

 
