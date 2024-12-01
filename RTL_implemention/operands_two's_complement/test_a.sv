task bit_8();
    for (int i = 0; i <= 5000; i++) begin
        A = $urandom(); // Generate a random value for A
        #5; // Wait for 5 time units

        if (op != 2'b10) begin
            // First 8-bit chunk
            if (A[7] == 1'b1) begin
                if (((~A[7:0]) + 1'b1) == B[7:0]) begin
                    pass = pass + 1; // Increment pass count
                end 
                else begin
                    $display(" full A =%b   ,fail A= %b   B=%b", A, A[7:0], B[7:0]);
                    fail += 1; // Increment fail count
                end
            end 
            else if (A[7:0] == B[7:0]) begin
                pass = pass + 1; // Increment pass count
            end

            // Second 8-bit chunk
            if (A[15] == 1'b1) begin
                if (((~A[15:8]) + 1'b1) == B[15:8]) begin
                    pass = pass + 1; // Increment pass count
                end 
                else begin
                    $display("full A fail A= %b   B=%b", A, A[15:8], B[15:8]);
                    fail += 1; // Increment fail count
                end
            end 
            else if (A[15:8] == B[15:8]) begin
                pass = pass + 1; // Increment pass count
            end

            // Third 8-bit chunk
            if (A[23] == 1'b1) begin
                if (((~A[23:16]) + 1'b1) == B[23:16]) begin
                    pass = pass + 1; // Increment pass count
                end 
                else begin
                    $display("full A =%b fail A= %b   B=%b", A, A[23:16], B[23:16]);
                    fail += 1; // Increment fail count
                end
            end 
            else if (A[23:16] == B[23:16]) begin
                pass = pass + 1; // Increment pass count
            end

            // Fourth 8-bit chunk
            if (A[31] == 1'b1) begin
                if (((~A[31:24]) + 1'b1) == B[31:24]) begin
                    pass = pass + 1; // Increment pass count
                end 
                else begin
                    $display("full A=%b fail A= %b   B=%b", A, A[31:24], B[31:24]);
                    fail += 1; // Increment fail count
                end
            end 
            else if (A[31:24] == B[31:24]) begin
                pass = pass + 1; // Increment pass count
            end
        end
        else begin
            if (A != B) 
                fail = 1 + fail; // Increment fail count if A is not equal to B
        end
    end
endtask

task bit_32();
    for (int i = 0; i <= 5000; i++) begin
        A = $urandom(); // Generate a random value for A
        #5; // Wait for 5 time units

        if (op != 2'b10) begin
            if (A[31] == 1'b1) begin
                if ((~A) + 1'b1 == B) begin
                    pass = pass + 1; // Increment pass count
                end 
                else begin
                    $display("fail 32 precision A= %b", A);
                    fail += 1; // Increment fail count
                end
            end 
            else if (A == B) begin
                pass = pass + 1; // Increment pass count
            end
        end
        else begin
            if (A == B)
                pass += 1; // Increment pass count
            else
                fail += 1; // Increment fail count
        end
    end
endtask

task bit_16();
    for (int i = 0; i <= 5000; i++) begin
        A = $urandom(); // Generate a random value for A
        #5; // Wait for 5 time units

        if (op != 2'b10) begin
            // Check the upper 16 bits
            if (A[31] == 1'b1) begin
                if ((~A[31:16]) + 1'b1 == B[31:16]) begin
                    pass = pass + 1; // Increment pass count
                end 
                else begin
                    $display("fail 16 A= %b", A);
                    fail += 1; // Increment fail count
                end
            end 
            else if (A[31:16] == B[31:16]) begin
                pass = pass + 1; // Increment pass count
            end

            // Check the lower 16 bits
            if (A[15] == 1'b1) begin
                if ((~A[15:0]) + 1'b1 == B[15:0]) begin
                    pass = pass + 1; // Increment pass count
                end 
                else begin
                    $display("fail 16 A= %b", A);
                    fail += 1; // Increment fail count
                end
            end 
            else if (A[15:0] == B[15:0]) begin
                pass = pass + 1; // Increment pass count
            end
        end
        else begin
            if (A != B) 
                fail += 1; // Increment fail count if A is not equal to B
            else
                pass += 1; // Increment pass count if A is equal to B
        end
    end
endtask




