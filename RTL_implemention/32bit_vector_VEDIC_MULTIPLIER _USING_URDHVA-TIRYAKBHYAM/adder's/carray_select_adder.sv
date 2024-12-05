module carray_select_adder #(parameter ADDER_WIDTH=2) (input logic [ADDER_WIDTH-1:0] operand_a_csela,
                                                     input logic carry_in_csela,
                                                     output logic [ADDER_WIDTH-1:0] sum_csela );
  
  
  assign sum_csela=operand_a_csela +carry_in_csela;
    
endmodule
