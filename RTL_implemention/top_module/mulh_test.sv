function two_sc_32bit();
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
endfunction

function two_sc_16bit();
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
endfunction

function tow_s_8();
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
endfunction

task mulh();
    // Loop for testing multiplication
    for (i = 0; i <= 1000; i++) begin
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
