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
   
   task two_sc_32bit_mul();
    // Convert operand_b_t to two's complement if negative
    if (operand_b_t[31] == 1'b1) begin
        sign_b[0] = 1'b1; // Set sign for operand B
        operand_b_t = (~operand_b_t) + 1'b1; // Two's complement
    end else begin
        sign_b[0] = 1'b0; // Positive sign
    end

    // Convert operand_a_t to two's complement if negative
    if (operand_a_t[31] == 1'b1) begin
        sign_a[0] = 1'b1; // Set sign for operand A
        operand_a_t = (~operand_a_t) + 1'b1; // Two's complement
    end else begin
        sign_a[0] = 1'b0; // Positive sign
    end
  endtask

task two_sc_16bit_mul();
    // Convert operand_b_t to two's complement for lower and upper halves
    if (operand_b_t[15] == 1'b1) begin
        sign_b[0] = 1'b1;
        operand_b_t[15:0] = (~operand_b_t[15:0]) + 1'b1;
    end else begin
        sign_b[0] = 1'b0;
    end

    if (operand_b_t[31] == 1'b1) begin
        sign_b[1] = 1'b1;
        operand_b_t[31:16] = (~operand_b_t[31:16]) + 1'b1;
    end else begin
        sign_b[1] = 1'b0;
    end

    // Convert operand_a_t to two's complement for lower and upper halves
    if (operand_a_t[15] == 1'b1) begin
        sign_a[0] = 1'b1;
        operand_a_t[15:0] = (~operand_a_t[15:0]) + 1'b1;
    end else begin
        sign_a[0] = 1'b0;
    end

    if (operand_a_t[31] == 1'b1) begin
        sign_a[1] = 1'b1;
        operand_a_t[31:16] = (~operand_a_t[31:16]) + 1'b1;
    end else begin
        sign_a[1] = 1'b0;
    end
  endtask

task tow_s_8_mul();
    // Convert operand_a_t to two's complement for each byte
    if (operand_a_t[7] == 1'b1) begin
        operand_a_t[7:0] = (~operand_a_t[7:0]) + 1'b1;
        sign_a[0] = 1'b1;
    end else begin
        sign_a[0] = 1'b0;
    end

    if (operand_a_t[15] == 1'b1) begin
        operand_a_t[15:8] = (~operand_a_t[15:8]) + 1'b1;
        sign_a[1] = 1'b1;
    end else begin
        sign_a[1] = 1'b0;
    end

    if (operand_a_t[23] == 1'b1) begin
        operand_a_t[23:16] = (~operand_a_t[23:16]) + 1'b1;
        sign_a[2] = 1'b1;
    end else begin
        sign_a[2] = 1'b0;
    end

    if (operand_a_t[31] == 1'b1) begin
        operand_a_t[31:24] = (~operand_a_t[31:24]) + 1'b1;
        sign_a[3] = 1'b1;
    end else begin
        sign_a[3] = 1'b0;
    end

    // Convert operand_b_t to two's complement for each byte
    if (operand_b_t[7] == 1'b1) begin
        operand_b_t[7:0] = (~operand_b_t[7:0]) + 1'b1;
        sign_b[0] = 1'b1;
    end else begin
        sign_b[0] = 1'b0;
    end

       if (operand_b_t[15] == 1'b1) begin
        operand_b_t[15:8] = (~operand_b_t[15:8]) + 1'b1;
        sign_b[1] = 1'b1;
    end else begin
        sign_b[1] = 1'b0;
    end

    if (operand_b_t[23] == 1'b1) begin
        operand_b_t[23:16] = (~operand_b_t[23:16]) + 1'b1;
        sign_b[2] = 1'b1;
    end else begin
        sign_b[2] = 1'b0;
    end

    if (operand_b_t[31] == 1'b1) begin
        operand_b_t[31:24] = (~operand_b_t[31:24]) + 1'b1;
        sign_b[3] = 1'b1;
    end else begin
        sign_b[3] = 1'b0;
    end
  endtask

task mul();
    // Loop for testing multiplication
  for (i = 0; i <= 10000; i++) begin
        operand_b_t = $urandom(); // Generate random operand B
        operand_a_t = $urandom(); // Generate random operand A
        precision = $random() / 4; // Random precision value

        @(posedge clk);
        #1;
        @(posedge clk);
        #1;
        @(posedge clk);
        #1;

        if (opcode == 2'b00) begin
            if (precision == 2'b10) begin
                two_sc_32bit_mul(); // Convert to two's complement for 32-bit
                al = operand_b_t * operand_a_t; // Perform multiplication

                // Adjust for sign
                if (sign_a[0] ^ sign_b[0]) begin
                    al = (~al) + 1'b1; // Apply two's complement if signs differ
                end

                // Check the result
                if (al[31:0] == mul_out_32) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    $display("al=%h   mul=%h", al[63:32], mul_out_32);
                end
            end

            if (precision == 2'b00) begin
                tow_s_8_mul(); // Convert to two's complement for 8-bit
                bit_8 = operand_b_t[7:0] * operand_a_t[7:0]; // Multiply lower 8 bits

                // Adjust for sign
                if (sign_a[0] ^ sign_b[0]) begin
                    bit_8 = (~bit_8) + 1'b1;
                end

                // Check the result
                if (bit_8[7:0] == mul_out_32[7:0]) begin
                    pass += 1;
                end else begin
                    fail += 1;
                    $display("First 8 bits al=%h   mul=%h", bit_8[15:8], mul_out_32[7:0]);
                end

                // Repeat for the next 8 bits
                bit_8 = operand_b_t[15:8] * operand_a_t[15:8];
                if (sign_a[1] ^ sign_b[1]) begin
                    bit_8 = (~bit_8) + 1'b1;
                end
                if (bit_8[7:0] == mul_out_32[15:8]) begin
                    pass += 1;
                end else begin
                    fail += 1;
                    $display("2nd 8 bits al=%h   mul=%h", bit_8[15:8], mul_out_32[15:8]);
                end

                // Repeat for the next 8 bits
                bit_8 = operand_b_t[23:16] * operand_a_t[23:16];
                if (sign_a[2] ^ sign_b[2]) begin
                    bit_8 = (~bit_8) + 1'b1;
                end
                if (bit_8[7:0] == mul_out_32[23:16]) begin
                    pass += 1;
                end else begin
                    fail += 1;
                    al = operand_b_t[23:16] * operand_a_t[23:16];
                                        // Check for the third 8 bits
                    $display("3rd 8 bits al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, al);
                end

                // Check for the fourth 8 bits
                bit_8 = operand_b_t[31:24] * operand_a_t[31:24];
                if (sign_a[3] ^ sign_b[3]) begin
                    bit_8 = (~bit_8) + 1'b1;
                end
                if (bit_8[7:0] == mul_out_32[31:24]) begin
                    pass += 1;
                end else begin
                    fail += 1;
                    $display("4th 8 bits al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, al);
                end
            end

            if (precision == 2'b01) begin
                two_sc_16bit_mul(); // Convert to two's complement for 16-bit

                // Multiply lower 16 bits
                bit_16 = operand_b_t[15:0] * operand_a_t[15:0];
                if (sign_a[0] ^ sign_b[0]) begin
                    bit_16 = (~bit_16) + 1'b1;
                end

                // Check the result for lower 16 bits
                if (bit_16[15:0] == mul_out_32[15:0]) begin
                    pass += 1;
                end else begin
                    fail += 1;
                    $display("Lower 16 bits al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_16[15:0], mul_out_32, operand_b_t, operand_a_t, bit_16);
                end

                // Multiply upper 16 bits
                bit_16 = operand_b_t[31:16] * operand_a_t[31:16];
                if (sign_a[1] ^ sign_b[1]) begin
                    bit_16 = (~bit_16) + 1'b1;
                end

                // Check the result for upper 16 bits
                if (bit_16[15:0] == mul_out_32[31:16]) begin
                    pass += 1;
                end else begin
                    fail += 1;
                    $display("Upper 16 bits al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_16[15:0], mul_out_32, operand_b_t, operand_a_t, bit_16);
                end
            end
        end
    end
endtask


task two_sc_32bit();
    // Convert operand_b_t to two's complement if negative
    if (operand_b_t[31] == 1'b1) begin
        sign_b[0] = 1'b1; // Set sign for operand B
        operand_b_t = (~operand_b_t) + 1'b1; // Two's complement
    end else begin
        sign_b[0] = 1'b0; // Positive sign
    end

    // Convert operand_a_t to two's complement if negative
    if (operand_a_t[31] == 1'b1) begin
        sign_a[0] = 1'b1; // Set sign for operand A
        operand_a_t = (~operand_a_t) + 1'b1; // Two's complement
    end else begin
        sign_a[0] = 1'b0; // Positive sign
    end
endtask

task two_sc_16bit();
    // Convert operand_b_t to two's complement for lower and upper halves
    if (operand_b_t[15] == 1'b1) begin
        sign_b[0] = 1'b1;
        operand_b_t[15:0] = (~operand_b_t[15:0]) + 1'b1;
    end else begin
        sign_b[0] = 1'b0;
    end

    if (operand_b_t[31] == 1'b1) begin
        sign_b[1] = 1'b1;
        operand_b_t[31:16] = (~operand_b_t[31:16]) + 1'b1;
    end else begin
        sign_b[1] = 1'b0;
    end

    // Convert operand_a_t to two's complement for lower and upper halves
    if (operand_a_t[15] == 1'b1) begin
        sign_a[0] = 1'b1;
        operand_a_t[15:0] = (~operand_a_t[15:0]) + 1'b1;
    end else begin
        sign_a[0] = 1'b0;
    end

    if (operand_a_t[31] == 1'b1) begin
        sign_a[1] = 1'b1;
        operand_a_t[31:16] = (~operand_a_t[31:16]) + 1'b1;
    end else begin
        sign_a[1] = 1'b0;
    end
  endtask

task tow_s_8();
    // Convert operand_a_t to two's complement for each byte
    if (operand_a_t[7] == 1'b1) begin
        operand_a_t[7:0] = (~operand_a_t[7:0]) + 1'b1;
        sign_a[0] = 1'b1;
    end else begin
        sign_a[0] = 1'b0;
    end

    if (operand_a_t[15] == 1'b1) begin
        operand_a_t[15:8] = (~operand_a_t[15:8]) + 1'b1;
        sign_a[1] = 1'b1;
    end else begin
        sign_a[1] = 1'b0;
    end

    if (operand_a_t[23] == 1'b1) begin
        operand_a_t[23:16] = (~operand_a_t[23:16]) + 1'b1;
        sign_a[2] = 1'b1;
    end else begin
        sign_a[2] = 1'b0;
    end

    if (operand_a_t[31] == 1'b1) begin
        operand_a_t[31:24] = (~operand_a_t[31:24]) + 1'b1;
        sign_a[3] = 1'b1;
    end else begin
        sign_a[3] = 1'b0;
    end

    // Convert operand_b_t to two's complement for each byte
    if (operand_b_t[7] == 1'b1) begin
        operand_b_t[7:0] = (~operand_b_t[7:0]) + 1'b1;
        sign_b[0] = 1'b1;
    end else begin
        sign_b[0] = 1'b0;
    end

    if (operand_b_t[15] == 1'b1) begin
        operand_b_t[15:8] = (~operand_b_t[15:8]) + 1'b1;
                sign_b[1] = 1'b1;
    end else begin
        sign_b[1] = 1'b0;
    end

    if (operand_b_t[23] == 1'b1) begin
        operand_b_t[23:16] = (~operand_b_t[23:16]) + 1'b1;
        sign_b[2] = 1'b1;
    end else begin
        sign_b[2] = 1'b0;
    end

    if (operand_b_t[31] == 1'b1) begin
        operand_b_t[31:24] = (~operand_b_t[31:24]) + 1'b1;
        sign_b[3] = 1'b1;
    end else begin
        sign_b[3] = 1'b0;
    end
  endtask

task mulh();
    // Loop for testing multiplication
  for (i = 0; i <= 10000; i++) begin
        operand_b_t = $urandom(); // Random operand B
        operand_a_t = $urandom(); // Random operand A
        precision = $random() / 4; // Random precision value

        @(posedge clk);
        #1;
        @(posedge clk);
        #1;
        @(posedge clk);
        #1;

        if (opcode == 2'b01) begin
            if (precision == 2'b10) begin
                two_sc_32bit(); // Convert to two's complement for 32-bit
                al = operand_b_t * operand_a_t; // Perform multiplication

                // Adjust for sign
                if (sign_a[0] ^ sign_b[0]) begin
                    al = (~al) + 1'b1; // Apply two's complement if signs differ
                end

                // Check the result
                if (al[63:32] == mul_out_32) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    $display("al=%h   mul=%h", al[63:32], mul_out_32);
                end
            end

            if (precision == 2'b00) begin
                tow_s_8(); // Convert to two's complement for 8-bit
                bit_8 = operand_b_t[7:0] * operand_a_t[7:0]; // Multiply lower 8 bits

                // Adjust for sign
                if (sign_a[0] ^ sign_b[0]) begin
                    bit_8 = (~bit_8) + 1'b1;
                end

                // Check the result
                if (bit_8[15:8] == mul_out_32[7:0]) begin
                    pass += 1;
                end else begin
                    fail += 1;
                    $display("First 8 bits al=%h   mul=%h", bit_8[15:8], mul_out_32[7:0]);
                end

                // Repeat for the next 8 bits
                bit_8 = operand_b_t[15:8] * operand_a_t[15:8];
                if (sign_a[1] ^ sign_b[1]) begin
                    bit_8 = (~bit_8) + 1'b1;
                end
                if (bit_8[15:8] == mul_out_32[15:8]) begin
                    pass += 1;
                end else begin
                    fail += 1;
                    $display("2nd 8 bits al=%h   mul=%h", bit_8[15:8], mul_out_32[15:8]);
                end

                // Repeat for the next 8 bits
                bit_8 = operand_b_t[23:16] * operand_a_t[23:16];
                if (sign_a[2] ^ sign_b[2]) begin
                    bit_8 = (~bit_8) + 1'b1;
                end
                if (bit_8[15:8] == mul_out_32[23:16]) begin
                    pass += 1;
                end else begin
                    fail += 1;
                    al = operand_b_t[23:16] * operand_a_t[23:16];
                    $display("3rd 8 bits al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, al);
                end

                // Repeat for the last 
                                // Repeat for the last 8 bits
                bit_8 = operand_b_t[31:24] * operand_a_t[31:24];
                if (sign_a[3] ^ sign_b[3]) begin
                    bit_8 = (~bit_8) + 1'b1;
                end
                if (bit_8[15:8] == mul_out_32[31:24]) begin
                    pass += 1;
                end else begin
                    fail += 1;
                    $display("4th 8 bits al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, al);
                end
            end

            if (precision == 2'b01) begin
                two_sc_16bit(); // Convert to two's complement for 16-bit

                // Multiply lower 16 bits
                bit_16 = operand_b_t[15:0] * operand_a_t[15:0];
                if (sign_a[0] ^ sign_b[0]) begin
                    bit_16 = (~bit_16) + 1'b1;
                end

                // Check the result
                if (bit_16[31:16] == mul_out_32[15:0]) begin
                    pass += 1;
                end else begin
                    fail += 1;
                    $display("al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_16[31:16], mul_out_32, operand_b_t, operand_a_t, al);
                end

                // Multiply upper 16 bits
                bit_16 = operand_b_t[31:16] * operand_a_t[31:16];
                if (sign_a[1] ^ sign_b[1]) begin
                    bit_16 = (~bit_16) + 1'b1;
                end

                // Check the result
                if (bit_16[31:16] == mul_out_32[31:16]) begin
                    pass += 1;
                end else begin
                    fail += 1;
                    $display("2nd al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_16[31:16], mul_out_32, operand_b_t, operand_a_t, bit_16);
                end
            end
        end
    end
endtask

// Task to perform unsigned multiplication and check results
task mulhu();
    // Loop for a large number of iterations
  for (i = 0; i <= 10000; i++) begin
        precision = $random() / 4; // Determine precision
        operand_b_t = $urandom(); // Generate random operand b
        operand_a_t = $urandom(); // Generate random operand a
        
        @(posedge clk); // Wait for clock edge
        #1; // Delay
        @(posedge clk); // Wait for clock edge
        #1; // Delay
        @(posedge clk); // Wait for clock edge
        al = operand_b_t * operand_a_t; // Perform multiplication
        #1; // Delay

        // Check opcode for unsigned multiplication operation
        if (opcode == 2'b10) begin
            // Handle 32-bit precision
            if (precision == 2'b10) begin
                if (al[63:32] == mul_out_32) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    $display("al=%h   mul=%h", al[63:32], mul_out_32); // Display mismatch
                end
            end

            // Handle 8-bit precision
            if (precision == 2'b00) begin
                // Multiply lower 8 bits
                bit_8 = operand_b_t[7:0] * operand_a_t[7:0];
                if (bit_8[15:8] == mul_out_32[7:0]) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    $display("al=%h   mul=%h", bit_8[15:8], mul_out_32[7:0]); // Display mismatch
                end

                // Multiply next 8 bits
                bit_8 = operand_b_t[15:8] * operand_a_t[15:8];
                if (bit_8[15:8] == mul_out_32[15:8]) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    $display("al=%h   mul=%h", bit_8[15:8], mul_out_32[15:8]); // Display mismatch
                end

                // Multiply third 8 bits
                bit_8 = operand_b_t[23:16] * operand_a_t[23:16];
                if (bit_8[15:8] == mul_out_32[23:16]) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    al = operand_b_t[23:16] * operand_a_t[23:16]; // Actual multiplication
                    $display("al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, al); // Display mismatch
                end

                // Multiply fourth 8 bits
                bit_8 = operand_b_t[31:24] * operand_a_t[31:24];
                if (bit_8[15:8] == mul_out_32[31:24]) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    $display("al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, al); // Display mismatch
                end 
            end

            // Handle 16-bit precision
            if (precision == 2'b01) begin
                // Multiply lower 16 bits
                bit_16 = operand_b_t[15:0] * operand_a_t[15:0];
                if (bit_16[31:16] == mul_out_32[15:0]) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    $display("al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, al); // Display mismatch
                end 

                                // Multiply upper 16 bits
                bit_16 = operand_b_t[31:16] * operand_a_t[31:16];
                if (bit_16[31:16] == mul_out_32[31:16]) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    $display("al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, al); // Display mismatch
                end        
            end
        end
    end
endtask


// Function to perform two's complement on a 32-bit unsigned operand
task two_sc_32bitsu();
    // Check if the most significant bit (sign bit) is 1
    if (operand_a_t[31] == 1'b1) begin
        sign_a[0] = 1'b1; // Set sign to 1 (negative)
        operand_a_t = (~operand_a_t) + 1'b1; // Perform two's complement
    end else begin
        sign_a[0] = 1'b0; // Set sign to 0 (positive)
    end
endtask

// Function to perform two's complement on a 16-bit unsigned operand
task two_sc_16bitsu();
    // Check the lower 16 bits
    if (operand_a_t[15] == 1'b1) begin
        sign_a[0] = 1'b1; // Set sign for lower 16 bits
        operand_a_t[15:0] = (~operand_a_t[15:0]) + 1'b1; // Perform two's complement
    end else begin
        sign_a[0] = 1'b0; // Set sign to 0
    end

    // Check the upper 16 bits
    if (operand_a_t[31] == 1'b1) begin
        sign_a[1] = 1'b1; // Set sign for upper 16 bits
        operand_a_t[31:16] = (~operand_a_t[31:16]) + 1'b1; // Perform two's complement
    end else begin
        sign_a[1] = 1'b0; // Set sign to 0
    end
endtask

// Function to perform two's complement on an 8-bit unsigned operand
task tow_s_8su();
    // Check each byte of the 32-bit operand
    if (operand_a_t[7] == 1'b1) begin
        operand_a_t[7:0] = (~operand_a_t[7:0]) + 1'b1; // Perform two's complement
        sign_a[0] = 1'b1; // Set sign for the first byte
    end else begin
        sign_a[0] = 1'b0; // Set sign to 0
    end

    if (operand_a_t[15] == 1'b1) begin
        operand_a_t[15:8] = (~operand_a_t[15:8]) + 1'b1; // Perform two's complement
        sign_a[1] = 1'b1; // Set sign for the second byte
    end else begin
        sign_a[1] = 1'b0; // Set sign to 0
    end

    if (operand_a_t[23] == 1'b1) begin
        operand_a_t[23:16] = (~operand_a_t[23:16]) + 1'b1; // Perform two's complement
        sign_a[2] = 1'b1; // Set sign for the third byte
    end else begin
        sign_a[2] = 1'b0; // Set sign to 0
    end

    if (operand_a_t[31] == 1'b1) begin
        operand_a_t[31:24] = (~operand_a_t[31:24]) + 1'b1; // Perform two's complement
        sign_a[3] = 1'b1; // Set sign for the fourth byte
    end else begin
        sign_a[3] = 1'b0; // Set sign to 0
    end
endtask

// Task to perform multiplication and check results
task mulhsu();
    // Loop for a large number of iterations
    for (i = 0; i <= 10000; i++) begin
        operand_b_t = $urandom(); // Generate random operand b
        operand_a_t = $urandom(); // Generate random operand a
        precision = $random() / 4; // Determine precision
        @(posedge clk); // Wait for clock edge
        #1; // Delay
        @(posedge clk); // Wait for clock edge
        #1; // Delay
        @(posedge clk); // Wait for clock edge
        #1; // Delay

        // Check opcode for multiplication operation
        if (opcode == 2'b11) begin
            // Handle 32-bit precision
            if (precision == 2'b10) begin
                two_sc_32bitsu(); // Call two's complement function
                al = operand_b_t * operand_a_t; // Perform multiplication
                                if (sign_a[0]) begin
                    al = (~al) + 1'b1; // Adjust result if the sign is negative
                end
                // Check if the result matches the expected output
                if (al[63:32] == mul_out_32) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    $display("al=%h   mul=%h", al[63:32], mul_out_32); // Display mismatch
                end
            end

            // Handle 8-bit precision
            if (precision == 2'b00) begin
                tow_s_8su(); // Call two's complement function for 8 bits
                bit_8 = operand_b_t[7:0] * operand_a_t[7:0]; // Multiply lower 8 bits
                if (sign_a[0]) begin
                    bit_8 = (~bit_8) + 1'b1; // Adjust result if the sign is negative
                end
                // Check if the result matches the expected output
                if (bit_8[15:8] == mul_out_32[7:0]) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    $display("first 8 bit al=%h   mul=%h", bit_8[15:8], mul_out_32[7:0]); // Display mismatch
                end

                // Multiply next 8 bits
                bit_8 = operand_b_t[15:8] * operand_a_t[15:8];
                if (sign_a[1]) begin
                    bit_8 = (~bit_8) + 1'b1; // Adjust result if the sign is negative
                end
                if (bit_8[15:8] == mul_out_32[15:8]) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    $display("2 8bits  al=%h   mul=%h", bit_8[15:8], mul_out_32[15:8]); // Display mismatch
                end

                // Multiply third 8 bits
                bit_8 = operand_b_t[23:16] * operand_a_t[23:16];
                if (sign_a[2]) begin
                    bit_8 = (~bit_8) + 1'b1; // Adjust result if the sign is negative
                end
                if (bit_8[15:8] == mul_out_32[23:16]) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    al = operand_b_t[23:16] * operand_a_t[23:16]; // Actual multiplication
                    $display("3 8 bits al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, al); // Display mismatch
                end

                // Multiply fourth 8 bits
                bit_8 = operand_b_t[31:24] * operand_a_t[31:24];
                if (sign_a[3]) begin
                    bit_8 = (~bit_8) + 1'b1; // Adjust result if the sign is negative
                end
                if (bit_8[15:8] == mul_out_32[31:24]) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    $display("4th 8 bit al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, al); // Display mismatch
                end
            end

            // Handle 16-bit precision
            if (precision == 2'b01) begin
                two_sc_16bitsu(); // Call two's complement function for 16 bits

                // Multiply lower 16 bits
                bit_16 = operand_b_t[15:0] * operand_a_t[15:0];
                if (sign_a[0]) begin
                    bit_16 = (~bit_16) + 1'b1; // Adjust result if the sign is negative
                end
                               if (bit_16[31:16] == mul_out_32[15:0]) begin
                    pass += 1; // Increment pass count for lower 16 bits
                end else begin
                    fail += 1; // Increment fail count
                    $display("al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, al); // Display mismatch
                end 

                // Multiply upper 16 bits
                bit_16 = operand_b_t[31:16] * operand_a_t[31:16];
                if (sign_a[1]) begin
                    bit_16 = (~bit_16) + 1'b1; // Adjust result if the sign is negative
                end
                if (bit_16[31:16] == mul_out_32[31:16]) begin
                    pass += 1; // Increment pass count for upper 16 bits
                end else begin
                    $display("2 al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h", bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, bit_16); // Display mismatch
                    fail += 1; // Increment fail count
                end        
            end
        end
    end
endtask
 
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
        mulhu();           // Call the unsigned multiplication task
$display("pass=%d   fail=%d",pass,fail);
  
        opcode = 2'b01;    // Set opcode for signed multiplication
        mulh();            // Call the signed multiplication task
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
