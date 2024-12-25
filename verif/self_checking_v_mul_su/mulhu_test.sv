// Task to perform unsigned multiplication and check results
task mulhu();
  if(c==0)
    begin
      itrator=100;
      
  precision=2'b00;
  mulhu_ref();
  precision=2'b01;
  mulhu_ref();
  precision=2'b10;
  mulhu_ref();
      
    end
  
  else
   begin
     itrator=0;
         for(int j=0;j<=5;j++)
           begin
             for (int k=0;k<=5;k++)
               begin
                 $display("in");
                 precision=2'b00;
                 operand_b_t=cc_8bita[k];
                 operand_a_t=cc_8bita[j];
                 mulhu_ref();
                 precision=2'b01;
                 operand_b_t=cc_16bita[k];
                 operand_a_t=cc_16bita[j];
                 mulhu_ref();
                 precision=2'b10;
                 operand_b_t=cc_32bita[k];
                 operand_a_t=cc_32bita[j];
                 mulhu_ref();
               end
     
     
     
     
   end
   end
endtask



task mulhu_ref();
  
  
     // Loop for a large number of iterations
  for (i = 0; i <= itrator; i++) begin
    if(c==0)
      begin
        operand_b_t = $urandom(); // Generate random operand b
        operand_a_t = $urandom(); // Generate random operand a
      end
        
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
                  $display("pre=%h  a=%h b=%h  pre=%h   al=%h   mul=%h",precision, operand_a_t, operand_b_t,precision ,al[63:32], mul_out_32); // Display mismatch
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
                  $display(" pre=%h al=%h   mul=%h",precision, bit_8[15:8], mul_out_32[7:0]); // Display mismatch
                end

                // Multiply next 8 bits
                bit_8 = operand_b_t[15:8] * operand_a_t[15:8];
                if (bit_8[15:8] == mul_out_32[15:8]) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                  $display("pre=%h al=%h   mul=%h",precision, bit_8[15:8], mul_out_32[15:8]); // Display mismatch
                end

                // Multiply third 8 bits
                bit_8 = operand_b_t[23:16] * operand_a_t[23:16];
                if (bit_8[15:8] == mul_out_32[23:16]) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    al = operand_b_t[23:16] * operand_a_t[23:16]; // Actual multiplication
                    $display("al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h",precision, bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, al); // Display mismatch
                end

                // Multiply fourth 8 bits
                bit_8 = operand_b_t[31:24] * operand_a_t[31:24];
                if (bit_8[15:8] == mul_out_32[31:24]) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                    $display("al_test=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h",precision
                             , bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, al); // Display mismatch
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
                  $display("pre=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h",precision,
                             bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, al); // Display mismatch
                end 

                                // Multiply upper 16 bits
                bit_16 = operand_b_t[31:16] * operand_a_t[31:16];
                if (bit_16[31:16] == mul_out_32[31:16]) begin
                    pass += 1; // Increment pass count
                end else begin
                    fail += 1; // Increment fail count
                  $display("pre=%h   mul_out=%h    a=%h    b=%h  a*b_actual=%h",precision
                             , bit_8[15:8], mul_out_32, operand_b_t, operand_a_t, al); // Display mismatch
                end        
            end
        end
    end
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
endtask





