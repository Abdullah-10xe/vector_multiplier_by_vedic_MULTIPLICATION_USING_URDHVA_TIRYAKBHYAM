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

// tc ==two's complement  
// Parameter operand_select is used for creating hardwere for operand B
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
        operand_a_from_tc[7:0] = (mux_select_opm[0]) ? operand_a2[7:0] : operand_a[7:0];
        operand_a_from_tc[15:8] = (mux_select_opm[1]) ? operand_a2[15:8] : operand_a[15:8];
        operand_a_from_tc[23:16] = (mux_select_opm[2]) ? operand_a2[23:16] : operand_a[23:16];
        operand_a_from_tc[31:24] = (mux_select_opm[3]) ? operand_a2[31:24] : operand_a[31:24];

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
    end
endmodule



// tc ==two's complement

module tc_bit_stream_with_precision #(parameter WIDTH=8)
               (
    input  logic [1:0] precision,
    input  logic [(WIDTH*4)-1:0] operand_a,
                 output logic [(WIDTH*4)-1:0] output_operand
);
   //  mux_in signal for genrating select signal for tc as precsion 
   // carray_out_from_8bit_tc 2 bit signal is propagating perviosus block out to next tc block
    logic [2:0][1:0] carry_out_from_8bit_tc;
    logic [2:0] mux_in;

    tc_first_8bits #(
      .WIDTH(WIDTH)
    ) from_bit0_bit7 (
        .operand_a (operand_a[WIDTH-1:0]),
      .operand_b (output_operand[WIDTH-1:0]),
        .carry_out(carry_out_from_8bit_tc[0])
    );

    tc_remaning_8bits#(
      .WIDTH(WIDTH)
    ) from_bit8_bit15 (
      .operand_a(operand_a[(WIDTH*2)-1:WIDTH]),
      .operand_b(output_operand[(WIDTH*2)-1:WIDTH]),
        .mux(mux_in[0]),
        .carry_in(carry_out_from_8bit_tc[0]),
        .carry_out(carry_out_from_8bit_tc[1])
    );

    tc_remaning_8bits#(
      .WIDTH(WIDTH)
    ) from_bit16_bit23 (
      .operand_a(operand_a[(WIDTH*3)-1:(WIDTH*2)]),
      .operand_b(output_operand[(WIDTH*3)-1:(WIDTH*2)]),
        .mux(mux_in[1]),
        .carry_in(carry_out_from_8bit_tc[1]),
        .carry_out(carry_out_from_8bit_tc[2])
    );

    tc_remaning_8bits #(
      .WIDTH(WIDTH)
    ) from_bit24_bit31 (
      .operand_a(operand_a[(WIDTH*4)-1:(WIDTH*3)]),
      .operand_b(output_operand[(WIDTH*4)-1:(WIDTH*3)]),
        .mux(mux_in[2]),
        .carry_in(carry_out_from_8bit_tc[2])
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

module tc_remaning_8bits #(
     parameter WIDTH = 8
) (
    input logic [WIDTH-1:0] operand_a,
    output logic [WIDTH-1:0] operand_b,
    input logic mux,
    input logic [1:0] carry_in,
    output logic [1:0] carry_out
);
  //loop Varible
    integer i;
    // out wire of or gate 
    logic inter_or_gate;

    logic [WIDTH-2:0] or_gate;
  assign carry_out = {operand_a[WIDTH-1], or_gate[WIDTH-2]};
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
endmodule

// Produce two's complement of first 8 bits of input_stream A
module tc_first_8bits #(
    parameter WIDTH = 8
) (
    input  logic [WIDTH-1:0] operand_a,
    output logic [WIDTH-1:0] operand_b,
    output logic [1:0] carry_out
);
    integer i;
    logic [WIDTH-3:0] or_gate;
    // carry_out signal is used for togling next bit 
    assign carry_out = {operand_a[WIDTH-1], or_gate[WIDTH-3]};

    always_comb begin
        operand_b[0] = operand_a[0];
        operand_b[1] = operand_a[1] ^ operand_a[0];
        or_gate[0]  = operand_a[1] | operand_a[0];

      for (i = 2; i <= WIDTH-1; i = i + 1) begin
        if (i < WIDTH) begin
                or_gate[i-1] = operand_a[i] | or_gate[i-2];
                operand_b[i]  = operand_a[i] ^ or_gate[i-2];
        end 
        else begin
                operand_b[i] = operand_a[i] ^ or_gate[i-2];
        end
      end
    end
endmodule


