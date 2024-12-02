module brent_kung_adder_nc #(parameter ADDER_WIDTH = 4) (
    input logic [ADDER_WIDTH-1:0] operand_a_bka,  // First operand input
    input logic [ADDER_WIDTH-1:0] operand_b_bka,  // Second operand input
    output logic [ADDER_WIDTH-1:0] sum_bka          // Sum output
);
  
    // Combinatorial logic to compute the sum
    always_comb begin
        sum_bka = operand_a_bka + operand_b_bka;  // Perform addition
    end
  
endmodule
