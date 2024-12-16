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

module mul_32bit_precision_control(
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
    tc_64bit_with_precision #(.WIDTH(16)) output_select_control (
        .opcode(opcode_pipe1),
        .precision(precision_pipe1),
        .sign_signal_a(sign_signal_a),
        .sign_signal_b(sign_signal_b),
        .mul_out(mul_out_w),
      .mul_block_output(mul_block_out)
    );

    // Instance of operand A selection control logic
    tc_sel_control_logic tc_sel_control_logic_opa (
        .opcode(opcode),
        .precision(precision),
        .operand_a(operand_a),
        .operand_a_from_tc(operand_a_from_tc),
        .sign_signal(sign_signal_a_w)
    );

    // Instance of operand B selection control logic
    tc_sel_control_logic #( .operand_select(1)) tc_sel_control_logic_opb (
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
    // Always block for sequential logic
    always_ff @(posedge clk, negedge rst) begin
        if (!rst) begin
            // Reset all signals
            operand_a <= 0;
            operand_b <= 0;
            opcode <= 0;
            precision <= 0;
            sign_signal_a <= 0;
            sign_signal_b <= 0;
            opcode_pipe1 <= 0;
            mul_out <= 0;
            precision_pipe1 <= 0;
        end else begin
            // Update signals on clock edge
            operand_a <= operand_a_reg;
            operand_b <= operand_b_reg;
            opcode <= opcode_reg;
            precision <= precision_reg;
            sign_signal_a <= sign_signal_a_w;
            sign_signal_b <= sign_signal_b_w;
            opcode_pipe1 <= opcode;
            mul_out <= mul_out_w;
            precision_pipe1 <= precision;
        end
    end
    

endmodule   

module tc_bit_stream_with_precision #(parameter WIDTH=8)
               (
    input  logic [1:0] precision,
    input  logic [(WIDTH*4)-1:0] operand_a,
                 output logic [(WIDTH*4)-1:0] output_operand
);
   //  mux_in signal for genrating select signal for tc as precsion 
   // carray_out_from_8bit_tc 2 bit signal is propagating perviosus block out to next tc block
    logic [2:0] carry_out_from_8bit_tc;
    logic [2:0] mux_in;

    tc_8_16bits #(
      .WIDTH(WIDTH),.FIRST_CHANK(1)
    ) from_bit0_bit7 (
        .operand_a (operand_a[WIDTH-1:0]),
      .operand_b (output_operand[WIDTH-1:0]),
      .carry_out(carry_out_from_8bit_tc[0])
    );

    tc_8_16bits#(
      .WIDTH(WIDTH)
    ) from_bit8_bit15 (
      .operand_a(operand_a[(WIDTH*2)-1:WIDTH]),
      .operand_b(output_operand[(WIDTH*2)-1:WIDTH]),
        .mux(mux_in[0]),
      .carry_in({operand_a[WIDTH-1],carry_out_from_8bit_tc[0]}),
        .carry_out(carry_out_from_8bit_tc[1])
    );

    tc_8_16bits#(
      .WIDTH(WIDTH)
    ) from_bit16_bit23 (
      .operand_a(operand_a[(WIDTH*3)-1:(WIDTH*2)]),
      .operand_b(output_operand[(WIDTH*3)-1:(WIDTH*2)]),
        .mux(mux_in[1]),
      .carry_in({operand_a[(2*WIDTH)-1],carry_out_from_8bit_tc[1]}),
        .carry_out(carry_out_from_8bit_tc[2])
    );

  tc_8_16bits #(
      .WIDTH(WIDTH)
    ) from_bit24_bit31 (
      .operand_a(operand_a[(WIDTH*4)-1:(WIDTH*3)]),
      .operand_b(output_operand[(WIDTH*4)-1:(WIDTH*3)]),
        .mux(mux_in[2]),
    .carry_in({operand_a[(3*WIDTH)-1],carry_out_from_8bit_tc[2]})
    );
    // genrating mux select signal for concatenatoin the 8 bit Tow's complemt blocks based on precision
    always_comb begin
        // select signal for  mux 0
        if (precision == 2'b00 | precision == 2'b11) begin
            mux_in[0] = 1'b0;
        end 
        else begin
            mux_in[0] = 1'b1;
        end

        // select signal for mux 1
        if (precision == 2'b10) begin
            mux_in[1] = 1'b1;
        end 
        else begin
            mux_in[1] = 1'b0;
        end
        // select signal for mux 2
        if (precision == 2'b00 | precision == 2'b11) begin
            mux_in[2] = 1'b0;
        end 
        else begin
            mux_in[2] = 1'b1;
        end
    end

endmodule

// this module is responsible for producing tc as precision and input from pervious tc block 

module tc_8_16bits #(
     parameter WIDTH = 8,parameter FIRST_CHANK=0
) (
    input logic [WIDTH-1:0] operand_a,
    output logic [WIDTH-1:0] operand_b,
    input logic mux,
    input logic [1:0] carry_in,
    output logic  carry_out
);
         integer i;
  generate
    if(FIRST_CHANK==0)
      begin
  //loop Varible
   
    // out wire of or gate 
    logic inter_or_gate;

    logic [WIDTH-2:0] or_gate;
  assign carry_out =  or_gate[WIDTH-2];
  assign inter_or_gate = carry_in[0] | carry_in[1];

    always_comb begin

        or_gate[0]  = mux ? (operand_a[0] | inter_or_gate) : operand_a[0];
        operand_b[0] = mux ? (operand_a[0] ^ inter_or_gate) : operand_a[0];
        operand_b[1] = operand_a[1] ^ or_gate[0];

      for (i = 2; i <= WIDTH-1; i = i + 1) begin
            or_gate[i-1] = operand_a[i-1] | or_gate[i-2];
            operand_b[i]  = operand_a[i] ^ or_gate[i-1];
        end
    end
      end
    else
      begin
        
        
    logic [WIDTH-3:0] or_gate;
    // carry_out signal is used for togling next bit 
    assign carry_out =  or_gate[WIDTH-3];

    always_comb begin
    
        operand_b[0] = operand_a[0];
        operand_b[1] = operand_a[1] ^ operand_a[0];
        or_gate[0]  = operand_a[1] | operand_a[0];
         for(i=2;i<=WIDTH-1;i++)
        begin
          if(i<=WIDTH-2)
            begin
          or_gate[i-1] = operand_a[i] | or_gate[i-2];
          operand_b[i]  = operand_a[i] ^ or_gate[i-2];
            end
          else
            begin
              operand_b[i]  = operand_a[i] ^ or_gate[i-2];
              
              
            end
        end

    end
        
        
        
        
        
        
      end
  endgenerate
endmodule






