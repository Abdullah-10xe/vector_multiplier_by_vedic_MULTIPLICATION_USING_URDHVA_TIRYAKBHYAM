 
module test_32_bit_mul();
    // Control signals
    logic [1:0] opcode;          // Operation code for the multiplication
    logic [1:0] precision;       // Precision level for multiplication
    logic [31:0] operand_a_t;    // First operand for multiplication
    logic [31:0] operand_b_t;    // Second operand for multiplication
    logic [31:0] mul_out_32;     // Output of the multiplication
    logic rst;                   // Reset signal
    logic clk = 1;               // Clock signal initialized to 1
    int  actual_a;
    int actual_b;
    // Intermediate signals
    logic [63:0] al;             // Result of multiplication (64 bits)
    int i;                       // Loop index
    logic [15:0] bit_8;          // Temporary variable for 8-bit multiplication
    logic [31:0] bit_16;         // Temporary variable for 16-bit multiplication
    int fail = 0;                // Counter for failed tests
    int pass = 0;                // Counter for passed tests
    logic [63:0] x;
    int mulpass;
    int mulfail;
    int mulhpass;
    int mulhfail;
    int mulhsupass; 
    int mulhsufail;
    int mulhupass;
    int mulhufail;
   ///////// corner case list//////////////
  int itrator;
  int c;
  logic [5:0] [31:0] cc_8bita = {32'h00000000,32'hFFFFFFFF,32'h01010101,
                        32'hF0F0F0F0,32'hd2e4f0af,32'h7f456010};
  
  logic [5:0] [31:0] cc_8bitb ={32'h00000000,32'hFFFFFFFF,32'h01010101,
                        32'hF0F0F0F0,32'hd2e4f0af,32'h7f456010};
  
  
  logic [5:0] [31:0] cc_16bita =  {32'h00000000,32'hFFFFFFFF,32'h01010101,
                               32'hF0F0F0F0,32'hedf0af01,32'h70ff6014};
  
  logic [5:0] [31:0] cc_16bitb =  {32'h00000000,32'hFFFFFFFF,32'h01010101,
                               32'hF0F0F0F0,32'hedf0af01,32'h70ff6014};
  
  logic [5:0] [31:0]cc_32bita = {32'h00000000,32'hFFFFFFFF,32'h01010101,
                        32'hF0F0F0F0,32'hd2e4f0af,32'h7f456010};
  
  logic [5:0] [31:0] cc_32bitb ={32'h00000000,32'hFFFFFFFF,32'h01010101,
                        32'hF0F0F0F0,32'hd2e4f0af,32'h7f456010};
  /*
  cc_8bita  [5:0] [31:0]  = {32'h00000000,32'hFFFFFFFF,32'h01010101
                        32'hF0F0F0F0,32'hd2e4f0af,32'h7f456010};
  
  cc_8bitb  [5:0] [31:0]  =  {32'h00000000,32'hFFFFFFFF,32'h01010101
                        32'hF0F0F0F0,32'hd2e4f0af,32'h7f456010};
  
  cc_16bita [5:0] [31:0]  =  {32'h00000000,32'hFFFFFFFF,32'h01010101
                        32'hF0F0F0F0,32'hedf0af01,32'h70ff6014};
  
  cc_16bitb [5:0] [31:0]  =  {32'h00000000,32'hFFFFFFFF,32'h01010101
                        32'hF0F0F0F0,32'hedf0af01,32'h70ff6014};
  cc_32bita [5:0] [31:0]  ={32'h00000000,32'hFFFFFFFF,32'h01010101
                        32'hF0F0F0F0,32'hd2e4f0af,32'h7f456010};
  cc_32bitb [5:0] [31:0]  ={32'h00000000,32'hFFFFFFFF,32'h01010101
                        32'hF0F0F0F0,32'hd2e4f0af,32'h7f456010};*/
  
    // Instantiate the 32-bit multiplication unit
    v_mult mul_dut (
        .clk(clk),
        .rst(rst),
        .operand_a_reg(operand_a_t),
        .operand_b_reg(operand_b_t),
        .opcode_reg(opcode),
        .precision_reg(precision),
        .mul_out(mul_out_32)
    );

    // Clock generation
    always begin
        #5; clk = ~clk; // Toggle clock every 5 time units
    end

    // Sign variables (not used in this snippet)
    logic [3:0] sign_a;
    logic [3:0] sign_b;

    // Include multiplication tasks
    `include "mulh.sv"
    `include "mul.sv"
    `include "mulhu.sv"
    `include "mulsu.sv"

    initial begin
        // Initialize waveform dump
        $dumpfile("file.vcd");
        $dumpvars();
  
        // Reset the system
        rst = 1'b1;
        #1;
        rst = 1'b0;
      #1;
      rst = 1'b1; 
      
     // precision=2'b01;
   //  operand_a_t=32'h0f05561f;  
     // operand_b_t=32'h04b58300;
      /// c == 1 checking corner casses////////
     c=1;
    opcode=2'b00;
     mul();
     mulpass=pass;
     mulfail=fail;
     pass=0;
     fail=0;
     opcode=2'b01;
     mulh();
     mulhpass=pass;
     mulhfail=fail; 
     pass=0;
     fail=0;
     opcode=2'b10;
     mulhu();
     mulhupass=pass;
     mulhufail=fail;
     pass=0;
     fail=0;
     opcode = 2'b11;    
     mulhsu();             
     mulhsupass=pass;
     mulhsufail=fail;
     
      $display(" mulpass=%d   mulhpass=%d    mulhupass=%d     mulhsupass=%d \n mulfail=%d   mulhfail=%d  mulsufail=%d    mulhsufail=%d  ",mulpass,mulhpass,mulhupass, mulhsupass,mulfail,mulhfail,  mulhsufail, mulhsufail);
  $finish;
    end
endmodule


