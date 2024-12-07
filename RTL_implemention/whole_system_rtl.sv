module mul_32bit_precion_control(input logic clk,input logic rst,
           input logic [31:0]operand_a_reg,
           input logic [31:0] operand_b_reg ,
           input logic [1:0]opcode_reg, 
           input logic [1:0]precision_reg,
           output logic [31:0]mul_out);
  
  logic [1:0] opcode;
  logic [1:0] precision;
  logic [31:0] operand_a;
  logic [31:0] operand_b;
  logic [31:0] operand_a_from_tc;
  logic [31:0] operand_b_from_tc;
  logic [3:0] sign_signal_a;
  logic [3:0] sign_signal_b;
  logic [63:0] mul_block_out;
  logic [1:0] opcode_2reg;
  logic [1:0] precision_w;
  logic [3:0] sign_signal_a_w;
  logic [3:0] sign_signal_b_w;
  logic [31:0] mul_out_w;
  logic [63:0]o64;
   
  tc_64bit_with_precision #(.WIDTH(16)) output_select_control(.opcode(opcode_2reg),.precision(precision_w),
                                                              .sign_signal_a(sign_signal_a),.sign_signal_b(sign_signal_b),
                                                              .mul_out (mul_out_w),.mul_block_output(mul_block_out));
    
  
  
 tc_sel_control_logic   tc_sel_control_logic_opa (.opcode(opcode),.precision(precision),
                                                  .operand_a( operand_a),.operand_a_from_tc( operand_a_from_tc),
                                                  .sign_signal( sign_signal_a_w));
  
  
 
  tc_sel_control_logic  #( .operand_select(1)) tc_sel_control_logic_opb (.opcode(opcode),.precision(precision),.operand_a(operand_b),
                                                                         .operand_a_from_tc( operand_b_from_tc),.sign_signal(sign_signal_b_w));
  
  
  
  
  
  
  multiplier_32bit mul_block32(.clk(clk),.rst(rst),
                               .operand_a_32bit(operand_a_from_tc),
                               .operand_b_32bit(operand_b_from_tc),
                               .output_32bit_mul(mul_block_out),
                               .precision(precision),
                               .precision_reg(precision_w));
  
  
 
  
  
  
 
  
  always_ff @(posedge clk , negedge rst)
    begin
      if(!rst)
        begin
operand_a<=0;
operand_b<=0;
opcode<=0;
precision<=0;
sign_signal_a<=0;
sign_signal_b<=0;
opcode_2reg<=0;
mul_out<=0;

end
      else
        begin
          
           
          operand_a<=operand_a_reg;
          operand_b<=operand_b_reg;
          opcode<= opcode_reg;
          precision<=precision_reg;
          sign_signal_a<= sign_signal_a_w;
          sign_signal_b<= sign_signal_b_w;
          opcode_2reg<=opcode;
          mul_out<=mul_out_w;
          
        
          
        end
      
      
    end



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

module carray_select_adder #(parameter ADDER_WIDTH=2) (input logic [ADDER_WIDTH-1:0] operand_a_csela,
                                                     input logic carry_in_csela,
                                                     output logic [ADDER_WIDTH-1:0] sum_csela );
  
  
  assign sum_csela=operand_a_csela +carry_in_csela;
    
endmodule



module brent_kung_adder #(parameter ADDER_WIDTH = 4,parameter NO_CARRY=1) (
    input logic [ADDER_WIDTH-1:0] operand_a_bka,  // First operand input
    input logic [ADDER_WIDTH-1:0] operand_b_bka,  // Second operand input
    output logic [ADDER_WIDTH-1:0] sum_bka,          // Sum output
    output logic carry_bka
);
  
    // Combinatorial logic to compute the sum
  generate 
    if(NO_CARRY==1)
      assign sum_bka = operand_a_bka + operand_b_bka;  // Perform addition
    if(NO_CARRY==0)
   assign { carry_bka,sum_bka }= operand_a_bka + operand_b_bka; 
  endgenerate
   
  
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



  brent_kung_adder #(.ADDER_WIDTH(5)) bk_adder_nc (
    .operand_a_bka({mul_block_wire[3][3:2], csa_sum[3:1]}), // First operand
    .operand_b_bka({1'b0, csa_carry}),                      // Second operand
    .sum_bka(mul_out_4bit[7:3])                            // Sum output
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
  multiplier_4bit unit2_0(.a_4bit(operand_a_8bit[3:0]),.b_4bit(operand_b_8bit[3:0]),.mul_out_4bit(in_4bit_mul_block[0]));
  multiplier_4bit unit2_1(.a_4bit(operand_a_8bit[3:0]),.b_4bit(operand_b_8bit[7:4]),.mul_out_4bit(in_4bit_mul_block[1]));
  multiplier_4bit unit2_2(.a_4bit(operand_a_8bit[7:4]),.b_4bit(operand_b_8bit[3:0]),.mul_out_4bit(in_4bit_mul_block[2]));
  multiplier_4bit unit2_3(.a_4bit(operand_a_8bit[7:4]),.b_4bit(operand_b_8bit[7:4]),.mul_out_4bit(in_4bit_mul_block[3]));
  
  carry_save_adder #(.ADDER_WIDTH(8)) cs_adder (
    .operand_a_csa({in_4bit_mul_block[3][3:0],in_4bit_mul_block [0][7:4]}), 
        .operand_b_csa(in_4bit_mul_block[1]),
        .operand_c_csa(in_4bit_mul_block[2]),
        .sum_csv(csa_sum),
        .carry_csv(csa_carry)
    );
 
  brent_kung_adder #(.ADDER_WIDTH(8),.NO_CARRY(0)) bk_adder  (
    .operand_a_bka({in_4bit_mul_block[3][4], csa_sum[7:1]}), // First operand
    .operand_b_bka(csa_carry),                      // Second operand
    .sum_bka(output_8bit_mul[12:5]) ,                           // Sum output
    .carry_bka(carry_bka)
);
 
  carray_select_adder #(.ADDER_WIDTH(3)) csela (  .operand_a_csela(in_4bit_mul_block[3][7:5]),
                                       .carry_in_csela(carry_bka),
                                       .sum_csela(output_8bit_mul[15:13]));
    
    
    
    
    
    
 
endmodule















module  multiplier_16bit  (input  logic clk, input logic rst,
                           input  logic [15:0] operand_a_16bit,
                           input  logic [15:0] operand_b_16bit,
                           input  logic [1:0] precision,
                           output logic [31:0] output_16bit_mul);
  logic [3:0][15:0]in_8bit_mul_block;
  logic [31:0]     output_16bit_mul_wire; 
  logic [31:0] output_16bit_mul_pr8;
  logic [31:0] output_16bit_mul_pr16;
  logic [7:0]  mux_a_8bit_pre;
  logic [15:0] csa_sum;
  logic [15:0] csa_carry;
  logic        carry_bka;
  logic        mux_sel;
 
  
  multiplier_8bit unit2_0 (.operand_a_8bit(operand_a_16bit[7:0]),.operand_b_8bit(operand_b_16bit[7:0]),.output_8bit_mul(in_8bit_mul_block[0]));
  multiplier_8bit unit2_1 (.operand_a_8bit(mux_a_8bit_pre),.operand_b_8bit( operand_b_16bit[15:8]),.output_8bit_mul(in_8bit_mul_block[1]));
  multiplier_8bit unit2_2 (.operand_a_8bit(operand_a_16bit[15:8]),.operand_b_8bit(operand_b_16bit[7:0]),.output_8bit_mul(in_8bit_mul_block[2]));
  multiplier_8bit unit2_3 (.operand_a_8bit(operand_a_16bit[15:8]),.operand_b_8bit(operand_b_16bit[15:8]),.output_8bit_mul(in_8bit_mul_block[3]));
  
  
  
  carry_save_adder #(.ADDER_WIDTH(16)) cs_adder (
    .operand_a_csa({in_8bit_mul_block [3][7:0],in_8bit_mul_block [0][15:8]}), 
    .operand_b_csa(in_8bit_mul_block[1]),
    .operand_c_csa(in_8bit_mul_block[2]),
    .sum_csv(csa_sum),
    .carry_csv(csa_carry)
    );
  
  
  
  brent_kung_adder #(.ADDER_WIDTH(16),.NO_CARRY(0)) bk_adder  (
    .operand_a_bka({in_8bit_mul_block[3][8], csa_sum[15:1]}), 
    .operand_b_bka(csa_carry),                     
    .sum_bka(output_16bit_mul_pr16[24:9]),
     .carry_bka(carry_bka)
);
  
  carray_select_adder #(.ADDER_WIDTH(7)) csela (  
                                        .operand_a_csela(in_8bit_mul_block[3][15:9]),
                                       .carry_in_csela(carry_bka),
                                       .sum_csela(output_16bit_mul_pr16[31:25]));
     
  
  
  
  assign mux_sel=(precision==2'b00);
  assign output_16bit_mul_pr16 [8:0]={csa_sum[0],in_8bit_mul_block[0][7:0]};
  assign output_16bit_mul_pr8 ={in_8bit_mul_block[1],in_8bit_mul_block[0]};
  assign mux_a_8bit_pre=mux_sel?operand_a_16bit[15:8]:operand_a_16bit[7:0];
  assign output_16bit_mul_wire=mux_sel?output_16bit_mul_pr8 :output_16bit_mul_pr16  ;

  
  
  always_ff @(posedge clk,negedge rst)
    begin
      if(!rst)
        begin
         output_16bit_mul<=0;
        
        end
        else
          begin
          
      output_16bit_mul=output_16bit_mul_wire;
     
          end
      end
    
    
      
      
    
    
    
    
    
 
endmodule


module  multiplier_32bit  (input  logic clk, input logic rst,
                           input  logic [31:0] operand_a_32bit,
                           input  logic [31:0] operand_b_32bit,
                           input  logic [1:0] precision,
                           output logic [63:0] output_32bit_mul,
                           output logic [1:0] precision_reg);
  logic [3:0][31:0]in_16bit_mul_block;
  logic [63:0] output_32bit_mul_wire; 
  logic [63:0] output_32bit_mul_pr8_16;
  logic [63:0] output_32bit_mul_pr32;
  logic [15:0]  mux_a_16bit_pre;
  logic [31:0] csa_sum;
  logic [31:0] csa_carry;
  logic        carry_bka;
  logic          mux_sel;
  logic     [31:0] b_16_0;
  logic     [31:0] b_16_1;
  logic     [31:0] b_16_2;
  logic     [31:0] b_16_3;
  logic       mux_sel_reg;
  assign b_16_0=in_16bit_mul_block[0];
  assign b_16_1=in_16bit_mul_block[1];
  assign b_16_2=in_16bit_mul_block[2];
  assign b_16_3=in_16bit_mul_block[3];
       
  multiplier_16bit unit16_0 (.clk(clk),.rst(rst),.operand_a_16bit(operand_a_32bit[15:0]),.operand_b_16bit(operand_b_32bit[15:0]),
                            .output_16bit_mul(in_16bit_mul_block[0]),.precision(precision));
  multiplier_16bit unit16_1 (.clk(clk),.rst(rst),.operand_a_16bit(mux_a_16bit_pre),.operand_b_16bit( operand_b_32bit[31:16]),
                            .output_16bit_mul(in_16bit_mul_block[1]),.precision(precision));
  multiplier_16bit unit16_2 (.clk(clk),.rst(rst),.operand_a_16bit(operand_a_32bit[31:16]),.operand_b_16bit(operand_b_32bit[15:0]),
                            .output_16bit_mul(in_16bit_mul_block[2]),.precision(precision));
  multiplier_16bit unit16_3 (.clk(clk),.rst(rst),.operand_a_16bit(operand_a_32bit[31:16]),.operand_b_16bit(operand_b_32bit[31:16]),
                            .output_16bit_mul(in_16bit_mul_block[3]),.precision(precision));
  
  
  
  carry_save_adder #(.ADDER_WIDTH(32)) cs_adder (
    .operand_a_csa({in_16bit_mul_block [3][15:0],in_16bit_mul_block [0][31:16]}), 
    .operand_b_csa(in_16bit_mul_block[1]),
    .operand_c_csa(in_16bit_mul_block[2]),
    .sum_csv(csa_sum),
    .carry_csv(csa_carry)
    );
  
  
  
  brent_kung_adder #(.ADDER_WIDTH(32),.NO_CARRY(0)) bk_adder  (
    .operand_a_bka({in_16bit_mul_block[3][16], csa_sum[31:1]}), 
    .operand_b_bka(csa_carry),                     
    .sum_bka(output_32bit_mul_pr32[48:17]),
     .carry_bka(carry_bka)
);
  
  carray_select_adder #(.ADDER_WIDTH(15)) csela (  
    .operand_a_csela(in_16bit_mul_block[3][31:17]),
                                       .carry_in_csela(carry_bka),
    .sum_csela(output_32bit_mul_pr32[63:49]));
     
  
  
  
  
  assign sum_bit0=csa_sum[0];
  assign mux_sel=(precision==2'b10|precision==2'b11);
  assign mux_sel_reg=(precision_reg==2'b10|precision_reg==2'b11);
  assign output_32bit_mul_pr32 [16:0]={csa_sum[0],in_16bit_mul_block[0][15:0]};
  assign output_32bit_mul_pr8_16 ={in_16bit_mul_block[1],in_16bit_mul_block[0]};
  assign mux_a_16bit_pre=mux_sel?operand_a_32bit[15:0]:operand_a_32bit[31:16];
  assign output_32bit_mul_wire=mux_sel_reg? output_32bit_mul_pr32:output_32bit_mul_pr8_16  ;
  assign output_32bit_mul=output_32bit_mul_wire;

  always_ff @(posedge clk,negedge rst)
    begin
      
      if(!rst)
        begin
        
        precision_reg<=2'b00;
        end
      else
        begin
         
          precision_reg<=precision;
          
          
          
        end
      
      
    end
 
endmodule



/***********************************************************************************
* Author      : Abdullah Jhatial
* Designation : Associate Hardware Design Engineer
* Firm        : 10x Engineers
* Email       : abdullahjhatial92@gmail.com, abdullah.jhatial@10xengineers.ai
*  **********************       Design        ***************************************** 
* This module design is for taking two's complement depending on the opcode and precision.
* Supported precision: 8-bit, 16-bit, 32-bit (00, 01, 10)
* Supported operations: MUL, MULH, MULHU, MULSU (00, 01, 10, 11)
* Design for Multiplier based on Vedic Algorithim 
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

/*

module tc_64bit_with_precision #(parameter WIDTH=16)  (input logic [63:0]mul_block_output,
                                                       input  logic  [1:0] opcode,
                                                       input logic   [1:0]   precision  ,
                                                       input logic [3:0]sign_signal_a,
                                                       input logic [3:0] sign_signal_b ,
                                                       output logic [31:0] mul_out  );
  logic [63:0] mul_out_tc;
  logic [63:0] mul_out_mux_sel;
  logic [3:0] sign_mux_sel ;
  
  tc_bit_stream_with_precision #(.WIDTH(WIDTH)) tc_64bit_with_precision (.operand_a(mul_block_output),.output_operand(mul_out_tc),.precision(precision));
  genvar i;
  generate 
    for(i=0;i<=3;i++)
      begin
      assign  sign_mux_sel[i]=sign_signal_a[i] ^ sign_signal_b[i] ;
       assign mul_out_mux_sel[(WIDTH*(i+1))-1:WIDTH*i]=sign_mux_sel[i]?mul_out_tc[(WIDTH*(i+1))-1:WIDTH*i]:mul_block_output[(WIDTH*(i+1))-1:WIDTH*i]; 
      end
      endgenerate
  
      always_comb
        begin
        //  mul_out={ mul_out_mux_sel[56:48], mul_out_mux_sel[39:32], mul_out_mux_sel[23:16], mul_out_mux_sel[7:0]};
          if(opcode==2'b00 & precision==2'b00)  begin
           
            mul_out={ mul_out_mux_sel[56:48], mul_out_mux_sel[39:32], mul_out_mux_sel[23:16], mul_out_mux_sel[7:0]};
            end
          else if  (opcode==2'b00 &precision==2'b01) begin
              mul_out={mul_out_mux_sel[47:32],mul_out_mux_sel[15:0]};
          end
          else if  (opcode==2'b00 &precision==2'b10) begin
                mul_out=mul_out_mux_sel[31:0];
            end
          else if (opcode==2'b00 &precision==2'b11) begin
                mul_out={ mul_out_mux_sel[56:48], mul_out_mux_sel[39:32], mul_out_mux_sel[23:16], mul_out_mux_sel[7:0]};
              end
          else if (opcode!=2'b00 &precision==2'b00) begin
                    mul_out={mul_out_mux_sel[63:57],mul_out_mux_sel[47:32],mul_out_mux_sel[31:24],mul_out_mux_sel[15:8]};
                end
          else if (opcode!=2'b00 &precision==2'b01)begin 
                    mul_out={mul_out_mux_sel[63:48],mul_out_mux_sel[31:16]};
                  end
          else if (opcode!=2'b00 &precision==2'b10) begin
                                mul_out= mul_out_mux_sel[63:32];
              
                    end
         
          
        end
endmodule

*/





