module full_adder(
    input logic full_adder_operand_a,   // First operand of the full adder
    input logic full_adder_operand_b,   // Second operand of the full adder
    input logic full_adder_carry_in,    // Carry input from the previous stage
    output logic full_adder_sum,         // Output for the sum
    output logic full_adder_carry        // Output for the carry
);
  
    // Intermediate signals for half adder
    logic ha_sum;                        // Sum output from the half adder
    logic ha_carry;                      // Carry output from the half adder

    // Instantiate the half adder
    half_adder hf_a (
        .half_adder_a(full_adder_operand_a),   // Connect operand A to half adder
        .half_adder_b(full_adder_operand_b),   // Connect operand B to half adder
        .half_adder_sum(ha_sum),               // Connect half adder sum output
        .half_adder_carry(ha_carry)            // Connect half adder carry output
    );
  
    // Calculate the final sum using XOR operation
    assign full_adder_sum = ha_sum ^ full_adder_carry_in;
  
    // Calculate the final carry using OR and AND operations
    assign full_adder_carry = (ha_sum & full_adder_carry_in) | ha_carry;
  
endmodule

