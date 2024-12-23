module tb_kogge_stone();
 
  // Parameters for the testbench
  parameter ADDER_WIDTH = 32
  ; // Set the width of the adder
  int pass;
  int fail;
  int count;
  // Testbench signals
  logic [ADDER_WIDTH-1:0] operand_a;
  logic [ADDER_WIDTH-1:0] operand_b;
  logic [ADDER_WIDTH:0] sum_ks;
  logic [ADDER_WIDTH:0] expected_sum;

  // Instantiate the Kogge-Stone adder
  prefix_adder #(.ADDER_WIDTH(32)) uut (
      .operand_a(operand_a),
      .operand_b(operand_b),
    .sum_stage (sum_ks[ADDER_WIDTH-1:0]),
    .carry_bka(sum_ks[ADDER_WIDTH])
  );

  // Initialize the random seed
  initial begin
    // Initialize waveform dump
        $dumpfile("file.vcd");
        $dumpvars();
    count=0;
    // Initialize signals
    operand_a = '0;
    operand_b = '0;
    pass=0;
    fail=0;
    // Test 100 random cases
    for (int i = 0; i < 10000; i++) begin
      // Randomize the operands
      operand_a=$random()/33;
      operand_b=$random()/33;
      ///00100111111110001, Got: 00101011111110001
      
      // Wait for the adder to compute the result
      #5;
      
      // Compute the expected sum (ignoring carry-out)
      
      expected_sum = operand_a + operand_b;

      // Check if the Kogge-Stone adder produces the expected result
      if (sum_ks !== expected_sum) begin
   //  $display("Error: Test failed at iteration %0d", i);
       $display("Operand A: %b, Operand B: %b, Expected Sum: %b, Got: %b", 
               operand_a, operand_b, expected_sum, sum_ks);
        fail+=1;
      end else begin
        pass=1+pass;
       // $display("Test passed at iteration %0d", i);
      //   $display("Operand A: %b, Operand B: %b, Expected Sum: %b, Got: %b", 
         //        operand_a, operand_b, expected_sum, sum_ks);
      end
     
    end
    $display("pass_test %0d   fail_test =%d  count=%d", pass,fail,count);
    $stop; // Stop the simulation after all tests
  end

endmodule

