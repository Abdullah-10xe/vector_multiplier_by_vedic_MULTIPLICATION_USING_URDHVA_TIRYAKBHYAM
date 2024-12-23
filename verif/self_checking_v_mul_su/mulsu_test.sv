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
