module half_adder(
    input logic half_adder_a,       // First input of the half adder
    input logic half_adder_b,       // Second input of the half adder
    output logic half_adder_sum,    // Output for the sum
    output logic half_adder_carry    // Output for the carry
);
  
  // Calculate the sum using XOR operation
  assign half_adder_sum = half_adder_a ^ half_adder_b;
  
  // Calculate the carry using AND operation
  assign half_adder_carry = half_adder_a & half_adder_b;
  
endmodule
