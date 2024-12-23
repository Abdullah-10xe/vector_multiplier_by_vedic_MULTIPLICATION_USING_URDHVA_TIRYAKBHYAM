module mul_32_test_top();
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
  
    // Instantiate the 32-bit multiplication unit
    v_mult_su mul_dut (
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
    `include "/home/abdullah/vmult_signed_unsigned_by_Vedic_MULTIPLIER/verif/self_checking_v_mul_su/mulh_test.sv"
    `include "/home/abdullah/vmult_signed_unsigned_by_Vedic_MULTIPLIER/verif/self_checking_v_mul_su/mulhu_test.sv"
    `include "/home/abdullah/vmult_signed_unsigned_by_Vedic_MULTIPLIER/verif/self_checking_v_mul_su/mulsu_test.sv"
    `include "/home/abdullah/vmult_signed_unsigned_by_Vedic_MULTIPLIER/verif/self_checking_v_mul_su/mul_test.sv"

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
      
     precision=2'b01;
     operand_a_t=32'h0f05561f;  
     operand_b_t=32'h04b58300;
     
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



