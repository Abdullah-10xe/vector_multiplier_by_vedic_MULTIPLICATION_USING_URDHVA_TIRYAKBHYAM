


module carry_save_adder #(parameter ADDER_WIDTH = 2) (
    input logic [ADDER_WIDTH-1:0] operand_a_csa,  // First operand input (CSA)
    input logic [ADDER_WIDTH-1:0] operand_b_csa,  // Second operand input (CSA)
    input logic [ADDER_WIDTH-1:0] operand_c_csa,  // Carry input (CSA)
    output logic [ADDER_WIDTH-1:0] sum_csv,        // Sum output (CSA)
    output logic [ADDER_WIDTH-1:0] carry_csv       // Carry output (CSA)
);
  
    genvar i;  // Variable for generating multiple instances of full adder

    // Generate a full adder for each bit in the operand inputs
    generate 
        for (i = 0; i < ADDER_WIDTH; i++) begin
            full_adder one_bit_adder (
                .full_adder_operand_a(operand_a_csa[i]),  // Connect operand A to full adder
                .full_adder_operand_b(operand_b_csa[i]),  // Connect operand B to full adder
                .full_adder_carry_in(operand_c_csa[i]),    // Connect carry input to full adder
                .full_adder_sum(sum_csv[i]),                // Connect sum output from full adder
                .full_adder_carry(carry_csv[i])             // Connect carry output from full adder
            ); 
        end
    endgenerate
  
endmodule
