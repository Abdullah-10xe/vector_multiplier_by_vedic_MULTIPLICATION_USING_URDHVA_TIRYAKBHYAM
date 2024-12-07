
module test_32_bit_mul();
    // Control signals
    logic [1:0] opcode;          // Operation code for the multiplication
    logic [1:0] precision;       // Precision level for multiplication
    logic [31:0] operand_a_t;    // First operand for multiplication
    logic [31:0] operand_b_t;    // Second operand for multiplication
    logic [31:0] mul_out_32;     // Output of the multiplication
    logic rst;                   // Reset signal
    logic clk = 1;               // Clock signal initialized to 1

    // Intermediate signals
    logic [63:0] al;             // Result of multiplication (64 bits)
    int i;                       // Loop index
    logic [15:0] bit_8;          // Temporary variable for 8-bit multiplication
    logic [31:0] bit_16;         // Temporary variable for 16-bit multiplication
    int fail = 0;                // Counter for failed tests
    int pass = 0;                // Counter for passed tests

    // Instantiate the 32-bit multiplication unit
    mul_32bit_precion_control mul_dut (
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
        rst = 1'b0;
        #1;
        rst = 1'b1;

        // Test cases
        precision = 2'b01; // Set precision for multiplication
        opcode = 2'b10;    // Set opcode for unsigned multiplication
      //  mulhu();           // Call the unsigned multiplication task
$display("pass=%d   fail=%d",pass,fail);
  
        opcode = 2'b01;    // Set opcode for signed multiplication
    //    mulh();            // Call the signed multiplication task
$display("pass=%d   fail=%d",pass,fail);
  
        opcode = 2'b00;    // Set opcode for regular multiplication
        mul();             // Call the regular multiplication task
$display("pass=%d   fail=%d",pass,fail);
 
        opcode = 2'b11;    // Set opcode for signed multiplication with unsigned
        mulhsu();          // Call the signed multiplication with unsigned task
      $display("pass=%d   fail=%d",pass,fail);
  $finish;
    end
endmodule
