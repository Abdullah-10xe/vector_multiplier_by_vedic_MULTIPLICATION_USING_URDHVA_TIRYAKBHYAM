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


