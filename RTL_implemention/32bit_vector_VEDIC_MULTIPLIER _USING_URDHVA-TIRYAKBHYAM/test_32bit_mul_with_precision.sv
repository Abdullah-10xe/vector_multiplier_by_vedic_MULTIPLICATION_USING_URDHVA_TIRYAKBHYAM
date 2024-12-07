module mul_32bit_test();
  logic [31:0] A;                // 32-bit input A
  logic [31:0] B;                // 32-bit input B
  logic [31:0] a;                // Local variable for operand A
  logic [31:0] b;                // Local variable for operand B
  logic [63:0] out_32;           // 64-bit output for multiplication result
  logic [1:0] precision;         // Precision control for multiplication
  logic clk = 1'b1;              // Clock signal initialized to high
  logic rst = 1'b1;              // Reset signal initialized to high
  int pass = 0;                  // Counter for passed tests
  int fail = 0;                  // Counter for failed tests
  longint al;                    // Variable to hold actual multiplication result

  // Instantiate the 32-bit multiplier
  multiplier_32bit dut1(
    .clk(clk),
    .rst(rst),
    .operand_a_32bit(a),
    .operand_b_32bit(b),
    .output_32bit_mul(out_32),
    .precision(precision)
  );

  int i;

  // Clock generation
  always begin
    #5; clk = ~clk;               // Toggle clock every 5 time units
  end

  initial begin
    $dumpfile("file.vcd");       // Specify the VCD file for waveform output
    $dumpvars();                 // Dump all variables for simulation

    #1; rst = 1'b0;              // Assert reset
    #2; rst = 1'b1;              // Deassert reset

    precision = 2'b10;           // Set precision to 32-bit

    // Test case for 32-bit multiplication
    for (i = 0; i < 1000; i++) begin
      A = $urandom();             // Generate random 32-bit value for A
      B = $urandom();             // Generate random 32-bit value for B
      a = A[31:0];                // Assign lower 32 bits of A
      b = B[31:0];                // Assign lower 32 bits of B
      @(posedge clk);             // Wait for the positive edge of the clock
      #1;

      // Check if the multiplication result is correct
      if (a * b == out_32) begin
        pass = pass + 1;          // Increment pass counter
      end else begin
        fail = fail + 1;          // Increment fail counter
        al = a * b;               // Calculate actual multiplication
        $display("pre 10    32   a=%d  b=%d out =%d   ,actual=%d", a, b, out_32, al);
      end
    end

    // Test case for 16-bit multiplication
    precision = 2'b01;           // Set precision to 16-bit
    for (i = 0; i < 10000; i++) begin
      A = $urandom();             // Generate random 32-bit value for A
      B = $urandom();             // Generate random 32-bit value for B
      a = A[31:0];                // Assign lower 32 bits of A
      b = B[31:0];                // Assign lower 32 bits of B
      @(posedge clk);             // Wait for the positive edge of the clock
      #1;

      // Check lower 16 bits multiplication
      if (a[15:0] * b[15:0] == out_32[31:0]) begin
        pass = pass + 1;          // Increment pass counter
      end else begin
        fail = fail + 1;          // Increment fail counter
        $display("pre 16 a[15:0]    32   a=%d  b=%d", a, b);
      end

      // Check upper 16 bits multiplication
      if (a[31:16] * b[31:16] == out_32[63:32]) begin
        pass = pass + 1;          // Increment pass counter
      end else begin
        fail = fail + 1;          // Increment fail counter
        $display("pre 16 a[31]    32   a=%d  b=%d", a, b);
      end
    end

    // Test case for 8-bit multiplication
    precision = 2'b00;           // Set precision to 8-bit
      for (i = 0; i < 10000; i++) begin
      A = $urandom();             // Generate random 32-bit value for A
      B = $urandom();             // Generate random 32-bit value for B
      a = A[31:0];                // Assign lower 32 bits of A
      b = B[31:0];                // Assign lower 32 bits of B
      @(posedge clk);             // Wait for the positive edge of the clock
      #1;

      // Check lower 8 bits multiplication
      if (a[7:0] * b[7:0] == out_32[15:0]) begin
        pass = pass + 1;          // Increment pass counter
      end else begin
        fail = fail + 1;          // Increment fail counter
        $display("1 a=%h  b=%h", a, b);
      end

      // Check next 8 bits multiplication
      if (a[15:8] * b[15:8] == out_32[31:16]) begin
        pass = pass + 1;          // Increment pass counter
      end else begin
        fail = fail + 1;          // Increment fail counter
        $display("2 a=%d  b=%d", a, b);
      end

      // Check next 8 bits multiplication
      if (a[23:16] * b[23:16] == out_32[47:32]) begin
        pass = pass + 1;          // Increment pass counter
      end else begin
        fail = fail + 1;          // Increment fail counter
        $display("3 a=%h b=%h  out_text =%h \n   a[23:16]=%h      b[23:16] =%h ,   out_32[48:32]=%h", a, b, out_32, a[23:16], b[23:16], out_32[48:32]);
      end

      // Check upper 8 bits multiplication
      if (a[31:24] * b[31:24] == out_32[63:48]) begin
        pass = pass + 1;          // Increment pass counter
      end else begin
        fail = fail + 1;          // Increment fail counter
        $display("4 a=%d  b=%d", a, b);
      end
    end  

    // Final test case with specific values
    precision = 2'b10;           // Set precision back to 32-bit
    a = 32'd992600595;           // Specific test value for a
    b = 32'd1764109936;          // Specific test value for b
    al = a * b;                  // Calculate actual multiplication
    @(posedge clk);              // Wait for the positive edge of the clock
    #1;
    $display("a=%h  b=%h out_32=%h   a*b=%h", a, b, out_32, al);
    #2;
    @(posedge clk);
    #10;

    // Display the final results
    $display("Pass=%d  Fail=%d", pass, fail); // Show the number of passed and failed tests
    @(posedge clk);
    #2;

    $finish;                     // End the simulation
  end
endmodule
