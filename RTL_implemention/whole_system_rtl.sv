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




/////operand tow' complement

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


module tc_sel_control_logic #(
    parameter operand_select = 0
) (
    input  logic [1:0] opcode,
    input  logic [1:0] precision,
    input  logic [31:0] operand_a,
    output logic [31:0] operand_a_from_tc,
    output logic [3:0] sign_signal
);

    // mux_select_opm is muxing on opcode and MSb considering and Precision 
    logic [3:0] mux_select_opm;
    logic [31:0] operand_a2;
    // opcode_signal is indicating for signed multiplication 
    logic opcode_signal;
    assign sign_signal=mux_select_opm;

    // Two's complemented operand stream with precision // default it is 32 bit 
    tc_bit_stream_with_precision tc_32bit_with_precision (
        .precision(precision),
        .operand_a(operand_a),
        .output_operand(operand_a2)
    );

    generate
      if (operand_select == 0) begin
          assign opcode_signal = (opcode == 2'b00 | opcode == 2'b01 | opcode == 2'b11);
        end 
        else begin
          assign opcode_signal = (opcode == 2'b00 | opcode == 2'b01);
        end
    endgenerate

    // mux_selecting 8 bits according to precision and opcode
    always_comb begin
     
        mux_select_opm[0] = (opcode_signal & (
            ((precision == 2'b00 | precision == 2'b11) & operand_a[7] == 1'b1) |
            ((precision == 2'b01) & operand_a[15] == 1'b1) |
            ((precision == 2'b10) & operand_a[31] == 1'b1)
        ));

        mux_select_opm[1] = (opcode_signal & (
            ((precision == 2'b00 | precision == 2'b11) & operand_a[15] == 1'b1) |
            ((precision == 2'b01) & operand_a[15] == 1'b1) |
            ((precision == 2'b10) & operand_a[31] == 1'b1)
        ));

        mux_select_opm[2] = (opcode_signal & (
            ((precision == 2'b00 | precision == 2'b11) & operand_a[23] == 1'b1) |
            ((precision == 2'b01) & operand_a[31] == 1'b1) |
            ((precision == 2'b10) & operand_a[31] == 1'b1)
        ));

        mux_select_opm[3] = (opcode_signal & (
            ((precision == 2'b00 | precision == 2'b11) & operand_a[31] == 1'b1) |
            ((precision == 2'b01) & operand_a[31] == 1'b1) |
            ((precision == 2'b10) & operand_a[31] == 1'b1)
        ));
         operand_a_from_tc[7:0] = (mux_select_opm[0]) ? operand_a2[7:0] : operand_a[7:0];
        operand_a_from_tc[15:8] = (mux_select_opm[1]) ? operand_a2[15:8] : operand_a[15:8];
        operand_a_from_tc[23:16] = (mux_select_opm[2]) ? operand_a2[23:16] : operand_a[23:16];
        operand_a_from_tc[31:24] = (mux_select_opm[3]) ? operand_a2[31:24] : operand_a[31:24];

    end
endmodule

module carry_save_adder #(parameter ADDER_WIDTH = 2) (
    input logic [ADDER_WIDTH-1:0] operand_a_csa,  // First operand input (CSA)
    input logic [ADDER_WIDTH-1:0] operand_b_csa,  // Second operand input (CSA)
    input logic [ADDER_WIDTH-1:0] operand_c_csa,  // Carry input (CSA)
    output logic [ADDER_WIDTH-1:0] sum_csv,        // Sum output (CSA)
    output logic [ADDER_WIDTH-1:0] carry_csv       // Carry output (CSA)
);
  
    genvar i;  // Variable for generating multiple instances of full adder

    // Generate a full adder for each bit in the operand inputs
    generate 
        for (i = 0; i < ADDER_WIDTH; i++) begin
            full_adder one_bit_adder (
                .full_adder_operand_a(operand_a_csa[i]),  // Connect operand A to full adder
                .full_adder_operand_b(operand_b_csa[i]),  // Connect operand B to full adder
                .full_adder_carry_in(operand_c_csa[i]),    // Connect carry input to full adder
                .full_adder_sum(sum_csv[i]),                // Connect sum output from full adder
                .full_adder_carry(carry_csv[i])             // Connect carry output from full adder
            ); 
        end
    endgenerate
  
endmodule




module half_adder(
    input logic half_adder_a,       // First input of the half adder
    input logic half_adder_b,       // Second input of the half adder
    output logic half_adder_sum,    // Output for the sum
    output logic half_adder_carry    // Output for the carry
);
  
  // Calculate the sum using XOR operation
  assign half_adder_sum = half_adder_a ^ half_adder_b;
  
  // Calculate the carry using AND operation
  assign half_adder_carry = half_adder_a & half_adder_b;
  
endmodule






module full_adder(
    input logic full_adder_operand_a,   // First operand of the full adder
    input logic full_adder_operand_b,   // Second operand of the full adder
    input logic full_adder_carry_in,    // Carry input from the previous stage
    output logic full_adder_sum,         // Output for the sum
    output logic full_adder_carry        // Output for the carry
);
  
    // Intermediate signals for half adder
    logic ha_sum;                        // Sum output from the half adder
    logic ha_carry;                      // Carry output from the half adder

    // Instantiate the half adder
    half_adder hf_a (
        .half_adder_a(full_adder_operand_a),   // Connect operand A to half adder
        .half_adder_b(full_adder_operand_b),   // Connect operand B to half adder
        .half_adder_sum(ha_sum),               // Connect half adder sum output
        .half_adder_carry(ha_carry)            // Connect half adder carry output
    );
  
    // Calculate the final sum using XOR operation
    assign full_adder_sum = ha_sum ^ full_adder_carry_in;
  
    // Calculate the final carry using OR and AND operations
    assign full_adder_carry = (ha_sum & full_adder_carry_in) | ha_carry;
  
endmodule










module adder_3_4 #(
    parameter ADDER_WIDTH = 3,  // Width of the adder (3 or 4 bits)
    parameter CARRY_NO = 0       // Carry input (not used in this implementation)
)(
    input logic [ADDER_WIDTH-1:0] a,  // Input operand
    input logic carry,                 // Carry input
    output logic carry_out,            // Carry output
    output logic [ADDER_WIDTH-1:0] sum // Output sum
);

generate 
    // Generate logic for 4-bit adder
    if (ADDER_WIDTH == 4) begin
        logic [ADDER_WIDTH-1:0] gate_and; // Intermediate AND gate results

        // Calculate the AND results for carry propagation
        assign gate_and[0] = a[0] & carry;
        assign gate_and[1] = a[1] & gate_and[0];
        assign gate_and[2] = a[2] & gate_and[1];
        assign gate_and[3] = a[3] & gate_and[2];

        // Assign carry out and sum outputs
        assign carry_out = gate_and[3];
        assign sum = {a[3] ^ gate_and[2], a[2] ^ gate_and[1], a[1] ^ gate_and[0], a[0] ^ carry};
    end

    // Generate logic for 3-bit adder
    if (ADDER_WIDTH == 3) begin
        logic [ADDER_WIDTH-2:0] gate_and; // Intermediate AND gate results

        // Calculate the AND results for carry propagation
        assign gate_and[0] = a[0] & carry;
        assign gate_and[1] = a[1] & gate_and[0];

        // Assign sum outputs
        assign sum[0] = a[0] ^ carry;
        assign sum[1] = a[1] ^ gate_and[0];
        assign sum[2] = a[2] ^ gate_and[1];
    end
endgenerate

endmodule

/*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                             
                                                              without intermediated select


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
// Carry Select Adder Module
module carray_select_adder #(
    parameter ADDER_WIDTH = 3  // Width of the adder (3, 7, or 15 bits)
)(
    input logic [ADDER_WIDTH-1:0] operand_a_csela, // Input operand
    input logic carry_in_csela,                     // Carry input
    output logic [ADDER_WIDTH-1:0] sum_csela       // Output sum
);

generate
    // Generate logic for 3-bit adder
    if (ADDER_WIDTH == 3) begin
        logic mux_sel; // Multiplexer select signal (not used)
        logic [ADDER_WIDTH-1:0] sum_0; // Sum when carry is 0
        logic [ADDER_WIDTH-1:0] sum_1; // Sum when carry is 1

        // Instantiate two 3-4 bit adders for carry 0 and carry 1
        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(0)) adder_0 (
            .a(operand_a_csela),
            .carry(1'b0),
            .sum(sum_0)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(0)) adder_1 (
            .a(operand_a_csela),
            .carry(1'b1),
            .sum(sum_1)
        );

        // Select the appropriate sum based on carry_in_csela
        assign sum_csela = carry_in_csela ? sum_1 : sum_0;
    end

    // Generate logic for 7-bit adder
    if (ADDER_WIDTH == 7) begin
        logic [6:0] sum_0_0; // Sum when carry is 0
        logic [6:0] sum_1_1; // Sum when carry is 1
        logic carry_sel_0;   // Carry output from first adder
        logic carry_sel_1;   // Carry output from second adder

        // Instantiate adders for the first case (carry 0)
        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_0 (
            .a(operand_a_csela[3:0]),
            .carry(1'b0),
            .sum(sum_0_0[3:0]),
            .carry_out(carry_sel_0)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_0_1 (
            .a(operand_a_csela[6:4]),
            .carry(carry_sel_0),
            .sum(sum_0_0[6:4])
        );

        // Instantiate adders for the second case (carry 1)
        adder_3_4 #(.ADDER_WIDTH(4)) adder_1_0 (
            .a(operand_a_csela[3:0]),
            .carry(1'b1),
            .sum(sum_1_1[3:0]),
            .carry_out(carry_sel_1)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_1_1 (
            .a(operand_a_csela[6:4]),
            .carry(carry_sel_1),
            .sum(sum_1_1[6:4])
        );

        // Select the appropriate sum based on carry_in_csela
        assign sum_csela = carry_in_csela ? sum_1_1 : sum_0_0;
    end

    // Generate logic for 15-bit adder
    if (ADDER_WIDTH == 15) begin
        logic [14:0] sum_0_0; // Sum when carry is 0
        logic [14:0] sum_1_1; // Sum when carry is 1
        logic carry_sel_0_0;  // Carry output from first adder
        logic carry_sel_0_1;  // Carry output from second adder
        logic carry_sel_0_2;  // Carry output from third adder
        logic carry_sel_1_0;  // Carry output from first adder (carry 1)
        logic carry_sel_1_1;  // Carry output from second adder (carry 1)
        logic carry_sel_1_2;  // Carry output from third adder (carry 1)

        // Instantiate adders for the first case (carry 0)
                // Instantiate adders for the first case (carry 0)
        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_0 (
            .a(operand_a_csela[3:0]),
            .carry(1'b0),
            .sum(sum_0_0[3:0]),
            .carry_out(carry_sel_0_0)
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_1 (
            .a(operand_a_csela[7:4]),
            .carry(carry_sel_0_0),
            .sum(sum_0_0[7:4]),
            .carry_out(carry_sel_0_1)
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_2 (
            .a(operand_a_csela[11:8]),
            .carry(carry_sel_0_1),
            .sum(sum_0_0[11:8]),
            .carry_out(carry_sel_0_2)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_0_4 (
            .a(operand_a_csela[14:12]),
            .carry(carry_sel_0_2),
            .sum(sum_0_0[14:12])
        );

        ///////////////////////////////////////////////////
        // Instantiate adders for the second case (carry 1)
        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_0_0 (
            .a(operand_a_csela[3:0]),
            .carry(1'b1),
            .sum(sum_1_1[3:0]),
            .carry_out(carry_sel_1_0)
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_0_1 (
            .a(operand_a_csela[7:4]),
            .carry(carry_sel_1_0),
            .sum(sum_1_1[7:4]),
            .carry_out(carry_sel_1_1)
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_0_2 (
            .a(operand_a_csela[11:8]),
            .carry(carry_sel_1_1),
            .sum(sum_1_1[11:8]),
            .carry_out(carry_sel_1_2)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_0_0_4 (
            .a(operand_a_csela[14:12]),
            .carry(carry_sel_1_2),
            .sum(sum_1_1[14:12])
        );

        // Select the appropriate sum based on carry_in_csela
        assign sum_csela = carry_in_csela ? sum_1_1 : sum_0_0;
    end
endgenerate

endmodule








/*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                             
                                                              with intermediated select


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/








/*





module carray_select_adder #(
    parameter ADDER_WIDTH = 3  // Width of the adder (3, 7, or 15 bits)
)(
    input logic [ADDER_WIDTH-1:0] operand_a_csela, // Input operand
    input logic carry_in_csela,                     // Carry input
    output logic [ADDER_WIDTH-1:0] sum_csela       // Output sum
);

generate 
    // Generate logic for 3-bit adder
    if (ADDER_WIDTH == 3) begin
        logic [ADDER_WIDTH-1:0] sum_0; // Sum when carry is 0
        logic [ADDER_WIDTH-1:0] sum_1; // Sum when carry is 1
        
        // Instantiate two 3-4 bit adders for carry 0 and carry 1
        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(0)) adder_0 (
            .a(operand_a_csela),
            .carry(1'b0),
            .sum(sum_0)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(0)) adder_1 (
            .a(operand_a_csela),
            .carry(1'b1),
            .sum(sum_1)
        );

        // Select the appropriate sum based on carry_in_csela
        assign sum_csela = carry_in_csela ? sum_1 : sum_0;
    end
    
    // Generate logic for 7-bit adder
    if (ADDER_WIDTH == 7) begin
        logic [3:0] sum_0_0; // Sum when carry is 0 for lower bits
        logic [3:0] sum_0_1; // Sum when carry is 1 for lower bits
        logic [2:0] sum_1_0; // Sum when carry is 0 for upper bits
        logic [2:0] sum_1_1; // Sum when carry is 1 for upper bits
        logic carry_sel_0;   // Carry output from first adder
        logic carry_sel_1;   // Carry output from second adder
        logic mux_sel;       // Multiplexer select signal
        
        // Instantiate adders for the lower 4 bits
        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_0 (
            .a(operand_a_csela[3:0]),
            .carry(1'b0),
            .sum(sum_0_0),
            .carry_out(carry_sel_0)
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_1 (
            .a(operand_a_csela[3:0]),
            .carry(1'b1),
            .sum(sum_0_1),
            .carry_out(carry_sel_1)
        );

        // Instantiate adders for the upper 3 bits
        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_1_0 (
            .a(operand_a_csela[6:4]),
            .carry(1'b0),
            .sum(sum_1_0)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_1_1 (
            .a(operand_a_csela[6:4]),
            .carry(1'b1),
            .sum(sum_1_1)
        );

        // Select the appropriate sums based on carry_in_csela
        assign sum_csela[3:0] = carry_in_csela ? sum_0_1 : sum_0_0;
        assign mux_sel = carry_in_csela ? carry_sel_1 : carry_sel_0;
        assign sum_csela[6:4] = mux_sel ? sum_1_1 : sum_1_0;
    end
    
    // Generate logic for 15-bit adder
    if (ADDER_WIDTH == 15) begin
        logic [2:0] carry_0; // Carry outputs for the case when carry is 0
        logic [2:0] carry_1; // Carry outputs for the case when carry is 1
        logic [3:0] sum_0[2:0]; // Sums for the case when carry is 0
        logic [3:0] sum_1[2:0]; // Sums for the case when carry is 1
        logic [2:0] sum_3_0; // Sum for the last 3 bits when carry is 0
        logic [2:0] sum_3_1; // Sum for the last 3 bits when carry is 1
        logic [2:0] mux_sel;  // Multiplexer select signals for carry outputs
        
        // Instantiate adders for the first 4 bits
        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_0 (
            .a(operand_a_csela[3:0]),
            .carry(1'b0),
            .sum(sum_0[0]),
            .carry_out(carry_0[0])
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_1 (
            .a(operand_a_csela[3:0]),
            .carry(1'b1),
            .sum(sum_1[0]),
            .carry_out(carry_1[0])
        );

        // Instantiate adders for the next 4 bits
        adder_3_4 #(.ADDER_WIDTH(4)) adder_1_0 (
            .a(operand_a_csela[7:4]),
            .carry(1'b0),
            .sum(sum_0[1]),
            .carry_out(carry_0[1])
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_1_1 (
            .a(operand_a_csela[7:4]),
            .carry(1'b1),
            .sum(sum_1[1]),
            .carry_out(carry_1[1])
        );

        // Instantiate adders for the next 4 bits
        adder_3_4 #(.ADDER_WIDTH(4)) adder_2_0 (
            .a(operand_a_csela[11:8]),
            .carry(1'b0),
            .sum(sum_0[2]),
            .carry_out(carry_0[2])
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_2_1 (
            .a(operand_a_csela[11:8]),
            .carry(1'b1),
            .sum(sum_1[2]),
            .carry_out(carry_1[2])
        );

        // Instantiate adders for the last 3 bits
        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_3_0 (
            .a(operand_a_csela[14:12]),
            .carry(1'b0),
            .sum(sum_3_0)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_3_1 (
            .a(operand_a_csela[14:12]),
            .carry(1'b1),
            .sum(sum_3_1)
        );

        // Select the appropriate sums based on carry_in_csela
        assign sum_csela[3:0] = carry_in_csela ? sum_1[0] : sum_0[0]; 
        assign mux_sel[0] = carry_in_csela ? carry_1[0] : carry_0[0];
        assign mux_sel[1] = mux_sel[0] ? carry_1[1] : carry_0[1];
        assign mux_sel[2] = mux_sel[1] ? carry_1[2] : carry_0[2];

        // Assign the sums for the higher bits based on the selected carry
        assign sum_csela[7:4] = mux_sel[0] ? sum_1[1] : sum_0[1];
        assign sum_csela[11:8] = mux_sel[1] ? sum_1[2] : sum_0[2];
        assign sum_csela[14:12] = mux_sel[2] ? sum_3_1 : sum_3_0;
    end
endgenerate

endmodule



*/

module prefix_adder #( 
    parameter CARRY_NO=0,
    parameter ADDER_WIDTH = 16,  // Width of the adder
    parameter STAGE = $clog2(ADDER_WIDTH) // Number of stages based on the width
)(
    input logic [ADDER_WIDTH-1:0] operand_a,  // First operand
    input logic [ADDER_WIDTH-1:0] operand_b,  // Second operand
  output logic [ADDER_WIDTH-1:0] sum_stage,      // Output sum including carry
    output logic carry_bka
);

    // Generate and propagate vectors for each stage
    logic [STAGE:0] [ADDER_WIDTH-1:0] gen_vector; // Generate vector
    logic [STAGE:0] [ADDER_WIDTH-1:0] pro_vector; // Propagate vector

    int Stage_number; // Variable to hold the stage number
    genvar i;         // Loop variable for inner loops
    genvar j;         // Loop variable for outer loops

    // Generate the pre-processing stage
    generate
        for (j = 0; j < ADDER_WIDTH; j++) begin
            pre_block pre_stage (
                .a_bit(operand_a[j]),               // Input bit A
                .b_bit(operand_b[j]),               // Input bit B
                .p_bit(pro_vector[0][j]),           // Output propagate bit
                .g_bit(gen_vector[0][j])            // Output generate bit
            );   
        end

        ////////////////////////////
        // Generate stages for the Kogge-Stone adder
        for (j = 1; j <= STAGE; j++) begin
            for (i = 0; i < ADDER_WIDTH; i++) begin
                if (i < (2**(j-1))) begin
                    // Carry forward the generate and propagate signals
                    assign gen_vector[j][i] = gen_vector[j-1][i];
                    assign pro_vector[j][i] = pro_vector[j-1][i];                                  
                end
                else if (i < 2**(j)) begin
                    // Instantiate grey cell for the current stage
                    grey_cell stage_grey_cell (
                        .generate_cur(gen_vector[j-1][i]), // Current generate signal
                        .propagate_cur(pro_vector[j-1][i]), // Current propagate signal
                        .generate_pre(gen_vector[j-1][i-(2**(j-1))]), // Previous generate signal
                        .generate_for_sum(gen_vector[j][i]) // Output generate signal for sum
                    );
                    assign pro_vector[j][i] = pro_vector[j-1][i]; // Carry forward propagate signal
                end  
                else if (i < 2**(STAGE+1)) begin
                    // Instantiate black cell for the current stage
                    black_cell stage_black_cell (
                        .propagate_pre(pro_vector[j-1][i-(2**(j-1))]), // Previous propagate signal
                        .propagate_cur(pro_vector[j-1][i]), // Current propagate signal
                        .generate_pre(gen_vector[j-1][i-(2**(j-1))]), // Previous generate signal
                        .generate_cur(gen_vector[j-1][i]), // Current generate signal
                        .propagate_sig(pro_vector[j][i]), // Output propagate signal
                        .generate_sig(gen_vector[j][i]) // Output generate signal
                    ); 
                end
            end
        end

        // Final stage to calculate the sum
        for (i = 0; i < ADDER_WIDTH; i++) begin
            if (i == 0) begin
                // Assign the first sum and carry out
                assign sum_stage[i] = pro_vector[STAGE][i];
              if(CARRY_NO==0)
                begin
                assign  carry_bka= gen_vector[STAGE][ADDER_WIDTH-1];
                end
            end
            else begin
                // Instantiate sum out cell for the remaining bits
                sum_out sum_stage_init (
                    .carry_in(gen_vector[STAGE][i-1]), // Carry input from previous stage
                    .propagate_in(pro_vector[0][i]), // Propagate input from the first stage
                    .out_sum(sum_stage[i]) // Output sum
                );
            end
        end
    endgenerate

endmodule


// Black Cell Module
module black_cell(
    input logic propagate_pre,  // Previous propagate signal
    input logic propagate_cur,   // Current propagate signal
    input logic generate_pre,    // Previous generate signal
    input logic generate_cur,     // Current generate signal
    output logic propagate_sig,   // Output propagate signal
    output logic generate_sig     // Output generate signal
);
    // Calculate the propagate signal for the current stage
    assign propagate_sig = propagate_cur & propagate_pre;

    // Calculate the generate signal for the current stage
    assign generate_sig = generate_cur | (propagate_cur & generate_pre);
endmodule

//////// Pre Processing Cell //////////
module pre_block(
    input logic a_bit,  // Input bit A
    input logic b_bit,  // Input bit B
    output logic p_bit, // Output propagate bit
    output logic g_bit  // Output generate bit
);
    // Calculate the propagate bit as the XOR of A and B
    assign p_bit = a_bit ^ b_bit;

    // Calculate the generate bit as the AND of A and B
    assign g_bit = a_bit & b_bit;
endmodule

///// Grey Cell //////
module grey_cell(
    input logic generate_cur,    // Current generate signal
    input logic propagate_cur,    // Current propagate signal
    input logic generate_pre,     // Previous generate signal
    output logic generate_for_sum // Output generate signal for sum
);
    // Calculate the generate signal for sum using current and previous signals
    assign generate_for_sum = (propagate_cur & generate_pre) | generate_cur;
endmodule

//////// Sum Out Cell //////////
module sum_out(
    input logic carry_in,        // Input carry signal
    input logic propagate_in,    // Input propagate signal
    output logic out_sum         // Output sum
);
    // Calculate the output sum as the XOR of carry_in and propagate_in
    assign out_sum = carry_in ^ propagate_in;
endmodule




   
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






module two_bit_multiplier (
    input logic [1:0] a,        // First 2-bit input
    input logic [1:0] b,        // Second 2-bit input
    output logic [3:0] c        // 4-bit output for the product
);

    logic in_wire;              // Intermediate wire for carry
    logic [2:0] and_gate_wire;  // Wires for AND gate outputs

    // Generate partial products
    assign c[0] = a[0] & b[0];  // Least significant bit (LSB)
    assign and_gate_wire[0] = a[0] & b[1]; // a[0] * b[1]
    assign and_gate_wire[1] = a[1] & b[0]; // a[1] * b[0]
    assign and_gate_wire[2] = a[1] & b[1]; // a[1] * b[1]

    // First half adder to combine the first two partial products
    half_adder h_a_0 (
        .half_adder_a(and_gate_wire[0]),
        .half_adder_b(and_gate_wire[1]),
        .half_adder_sum(c[1]),   // Sum output
        .half_adder_carry(in_wire) // Carry output
    );

    // Second half adder to combine the last partial product with the carry
    half_adder h_a_1 (
        .half_adder_a(and_gate_wire[2]),
        .half_adder_b(in_wire),
        .half_adder_sum(c[2]),    // Second sum output
        .half_adder_carry(c[3])    // Final carry output
    );

endmodule





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



  prefix_adder #(.ADDER_WIDTH(5)) bk_adder_nc (
    .operand_a({mul_block_wire[3][3:2], csa_sum[3:1]}), // First operand
    .operand_b({1'b0, csa_carry}),                      // Second operand
    .sum_stage(mul_out_4bit[7:3])                            // Sum output
);




endmodule







module  multiplier_8bit  (input  logic [7:0] operand_a_8bit,
                          input  logic [7:0] operand_b_8bit,
                          output logic [15:0] output_8bit_mul);
  logic [3:0][7:0]in_4bit_mul_block;
  logic [7:0] csa_sum;
  logic [7:0] csa_carry; 
  logic carry_bka;
  assign output_8bit_mul[3:0]=in_4bit_mul_block[0][3:0];
  assign output_8bit_mul[4]=csa_sum[0];
  multiplier_4bit unit4_0(.a_4bit(operand_a_8bit[3:0]),.b_4bit(operand_b_8bit[3:0]),.mul_out_4bit(in_4bit_mul_block[0]));
  
  multiplier_4bit unit4_1(.a_4bit(operand_a_8bit[3:0]),.b_4bit(operand_b_8bit[7:4]),.mul_out_4bit(in_4bit_mul_block[1]));
  
  multiplier_4bit unit4_2(.a_4bit(operand_a_8bit[7:4]),.b_4bit(operand_b_8bit[3:0]),.mul_out_4bit(in_4bit_mul_block[2]));
  
  multiplier_4bit unit4_3(.a_4bit(operand_a_8bit[7:4]),.b_4bit(operand_b_8bit[7:4]),.mul_out_4bit(in_4bit_mul_block[3]));
  
  carry_save_adder #(.ADDER_WIDTH(8)) cs_adder (
    .operand_a_csa({in_4bit_mul_block[3][3:0],in_4bit_mul_block [0][7:4]}), 
        .operand_b_csa(in_4bit_mul_block[1]),
        .operand_c_csa(in_4bit_mul_block[2]),
        .sum_csv(csa_sum),
        .carry_csv(csa_carry)
    );
 
  prefix_adder #(.ADDER_WIDTH(8),.NO_CARRY(0)) bk_adder  (
    .operand_a({in_4bit_mul_block[3][4], csa_sum[7:1]}), // First operand
    .operand_b(csa_carry),                      // Second operand
    .sum_stage(output_8bit_mul[12:5]) ,                           // Sum output
    .carry_bka(carry_bka)
);
 
  carray_select_adder #(.ADDER_WIDTH(3)) csela (  .operand_a_csela(in_4bit_mul_block[3][7:5]),
                                       .carry_in_csela(carry_bka),
                                       .sum_csela(output_8bit_mul[15:13]));
    
     
 
endmodule





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
        .operand_a_csa({in_8bit_mul_block[3][7:0], in_8bit_mul_block_reg[0][15:8]}), 
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
    assign output_16bit_mul_pr16[8:0] = {csa_sum[0], in_8bit_mul_block[0][7:0]};  // Combine results for precision 16
    assign output_16bit_mul_pr8 = {in_8bit_mul_block[1], in_8bit_mul_block[0]};    // Combine results for precision 8
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




