module brent_kung_adder #(parameter ADDER_WIDTH = 4,parameter NO_CARRY=1) (
    input logic [ADDER_WIDTH-1:0] operand_a_bka,  // First operand input
    input logic [ADDER_WIDTH-1:0] operand_b_bka,  // Second operand input
    output logic [ADDER_WIDTH-1:0] sum_bka,          // Sum output
    output logic carry_bka
);
  
    // Combinatorial logic to compute the sum
  generate 
    if(NO_CARRY==1)
      assign sum_bka = operand_a_bka + operand_b_bka;  // Perform addition
    if(NO_CARRY==0)
   assign { carry_bka,sum_bka }= operand_a_bka + operand_b_bka; 
  endgenerate
   
  
endmodule
