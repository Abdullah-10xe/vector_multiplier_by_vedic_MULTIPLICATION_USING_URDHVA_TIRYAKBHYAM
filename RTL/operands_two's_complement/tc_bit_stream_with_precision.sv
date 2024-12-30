/***********************************************************************************
* Author      : Abdullah Jhatial
* Designation : Associate Hardware Design Engineer
* Company        : 10x Engineers                 https://10xengineers.ai/
* Email       :  abdullah.jhatial@10xengineers.ai , abdullahjhatial92@gmail.com,
*  **********************       Design        ***************************************** 
* This module design is for taking 32bit two's complement depending on the opcode and precision.
* Supported precision: 8-bit, 16-bit, 32-bit (00, 01, 10)
* parameterized for  64 bit with precision of 16 ,32,64
* Supported operations: MUL, MULH, MULHU, MULSU (00, 01, 10, 11)
* Design for Vector Multiplier based on VEDIC MULTIPLIER USING URDHVA-TIRYAKBHYAM
***********************************************************************************/
///// Operand Two's Complement 
module tc_bit_stream_with_precision #(parameter WIDTH=8)
(
    input  logic [1:0] precision,                     // Precision control
    input  logic [(WIDTH*4)-1:0] operand_a,          // Input operand
    output logic [(WIDTH*4)-1:0] output_operand     // Output operand after two's complement
);
    // Mux_in signal for generating select signal for TC as precision 
    // Carry_out_from_8bit_tc 2 bit signal is propagating previous block out to next TC block
    logic [1:0]            carry_out_from_8bit_tc_0;   // Carry output from first 8-bit TC
    logic [1:0]            carry_out_from_8bit_tc_1;  // Carry output from second 8-bit TC
    logic                  carry_out_from_8bit_tc;   // General carry output
    logic [2:0]            mux_in;                  // Mux select signals
    logic [2:0][WIDTH-1:0] output_operand_0;       // Intermediate output operands
    logic [2:0][WIDTH-1:0] output_operand_1;      // Intermediate output operands
    logic [1:0]            mux_sel;              // Mux selection signals

    // Instance of the first 8-bit two's complement block
    tc_8_16bits #(
        .WIDTH(WIDTH), .FIRST_CHANK(1)
    ) from_bit0_bit7_0 (
        .operand_a(operand_a[WIDTH-1:0]),
        .operand_b(output_operand[WIDTH-1:0]),
        .carry_out(carry_out_from_8bit_tc)
    );

    /////////// 8-15 bit with 0 carry ///////////////////////////////
    tc_8_16bits #(
        .WIDTH(WIDTH)
    ) from_bit8_bit15_0 (
        .operand_a(operand_a[(WIDTH*2)-1:WIDTH]),
        .operand_b(output_operand_0[0]),
        .mux(mux_in[0]),
        .carry_in({operand_a[WIDTH-1], 1'b0}),
        .carry_out(carry_out_from_8bit_tc_0[0])
    );

    /////////// 8-15 bit with 1 carry /////////////////////////////// 
    tc_8_16bits #(
        .WIDTH(WIDTH)
    ) from_bit8_bit15_1 (
        .operand_a(operand_a[(WIDTH*2)-1:WIDTH]),
        .operand_b(output_operand_1[0]),
        .mux(mux_in[0]),
        .carry_in({operand_a[WIDTH-1], 1'b1}),
        .carry_out(carry_out_from_8bit_tc_1[0])
    );

    /////////// 16-23 bit with 0 carry ///////////////////////////////
    tc_8_16bits #(
        .WIDTH(WIDTH)
    ) from_bit16_bit23_0 (
        .operand_a(operand_a[(WIDTH*3)-1:(WIDTH*2)]),
        .operand_b(output_operand_0[1]),
        .mux(mux_in[1]),
        .carry_in({operand_a[(2*WIDTH)-1], 1'b0}),
        .carry_out(carry_out_from_8bit_tc_0[1])
    );

    /////////// 16-23 bit with 1 carry ///////////////////////////////
    tc_8_16bits #(
        .WIDTH(WIDTH)
    ) from_bit16_bit23_1 (
        .operand_a(operand_a[(WIDTH*3)-1:(WIDTH*2)]),
        .operand_b(output_operand_1[1]),
        .mux(mux_in[1]),
        .carry_in({operand_a[(2*WIDTH)-1], 1'b1}),
        .carry_out(carry_out_from_8bit_tc_1[1])
    );

    /////////// 24-31 bit with 0 carry ///////////////////////////////
    tc_8_16bits #(
        .WIDTH(WIDTH)
    ) from_bit24_bit31_0 (
        .operand_a(operand_a[(WIDTH*4)-1:(WIDTH*3)]),
        .operand_b(output_operand_0[2]),
        .mux(mux_in[2]),
        .carry_in({operand_a[(3*WIDTH)-1], 1'b0})
    );

    /////////// 24-31 bit with 1 carry ///////////////////////////////
    tc_8_16bits #(
        .WIDTH(WIDTH )
    ) from_bit24_bit31_1 (
        .operand_a(operand_a[(WIDTH*4)-1:(WIDTH*3)]),
        .operand_b(output_operand_1[2]),
        .mux(mux_in[2]),
        .carry_in({operand_a[(3*WIDTH)-1], 1'b1})
    );

    // Mux selection logic for carry outputs
    assign mux_sel[0] = carry_out_from_8bit_tc ? carry_out_from_8bit_tc_1[0] : carry_out_from_8bit_tc_0[0];
    assign mux_sel[1] = mux_sel[0] ? carry_out_from_8bit_tc_1[1] : carry_out_from_8bit_tc_0[1];
    assign output_operand[(WIDTH*2)-1:WIDTH] = carry_out_from_8bit_tc ? output_operand_1[0] : output_operand_0[0];
    assign output_operand[(WIDTH*3)-1:(WIDTH*2)] = mux_sel[0] ? output_operand_1[1] : output_operand_0[1];
    assign output_operand[(WIDTH*4)-1:(WIDTH*3)] = mux_sel[1] ? output_operand_1[2] : output_operand_0[2];

    // Generating mux select signal for concatenation of the 8-bit Two's complement blocks based on precision
    always_comb begin
        // Select signal for mux 0
        if (precision == 2'b00 || precision == 2'b11) begin
            mux_in[0] = 1'b0;
        end 
        else begin
            mux_in[0] = 1'b1;
        end

        // Select signal for mux 1
        if (precision == 2'b10) begin
            mux_in[1] = 1'b1;
        end 
        else begin
            mux_in[1] = 1'b0;
        end

        // Select signal for mux 2
        if (precision == 2'b00 || precision == 2'b11) begin
            mux_in[2] = 1'b0;
        end 
        else begin
            mux_in[2] = 1'b1;
        end
    end
endmodule


