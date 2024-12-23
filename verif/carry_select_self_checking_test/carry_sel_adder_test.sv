module tb_carray_select_adder;
    // Parameters
    parameter ADDER_WIDTH = 15; // Updated to 15
 logic [ADDER_WIDTH-1:0] expected_sum;
    // Inputs to the DUT
    logic [ADDER_WIDTH-1:0] operand_a_csela;
    logic carry_in_csela;

    // Output from the DUT
    logic [ADDER_WIDTH-1:0] sum_csela;

    // Instantiate the carray_select_adder module (DUT)
    carray_select_adder #(ADDER_WIDTH) dut (
        .operand_a_csela(operand_a_csela),
        .carry_in_csela(carry_in_csela),
        .sum_csela(sum_csela)
    );
  int j;
  int okk;

    // Clock signal for simulation
    logic clk;
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz clock

    // Random generation of test vectors and self-checking
    initial begin
        // Initialize the random seed
      
$dumpfile("file.vcd");
        $dumpvars();
        // Run for 1000 cycles
      okk=0;
        repeat (100) begin
            // Generate random inputs
            operand_a_csela = $random % (1 << ADDER_WIDTH);  // Random operand_a_csela (0 to 32767 for ADDER_WIDTH = 15)
            carry_in_csela = $random % 2;                     // Random carry_in_csela (0 or 1)

            // Wait for the next clock cycle
            #10;

            // Perform self-checking
           
            expected_sum = operand_a_csela + carry_in_csela; // Calculate expected sum
          for(j=0;j<15;j++)
            begin
              if(sum_csela[j]===1'bx)
                begin
                  $display("x   bit=%d  sum==%b",j,sum_csela[j]);
                  okk=okk+1;
                end
              
              
            end

            // Check if the output is correct
            if (sum_csela !== expected_sum) begin
                $display("ERROR at time %0t: operand_a_csela = %b, carry_in_csela = %b, sum_csela = %b, expected = %b",
                         $time, operand_a_csela, carry_in_csela, sum_csela, expected_sum);
                $stop; // Stop the simulation on error
            end
        //  $display("sum_csela=%d  expected = %d ",sum_csela,expected_sum);
        end

        // If we pass all checks, print success message
        $display("Test completed successfully! All outputs are correct.");
        $finish; // End the simulation
    end

endmodule

