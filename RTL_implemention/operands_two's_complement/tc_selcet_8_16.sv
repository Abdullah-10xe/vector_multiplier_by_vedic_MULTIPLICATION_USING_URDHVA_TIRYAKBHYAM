
// this module is responsible for producing tc as precision and input from pervious tc block 

module tc_8_16bits #(
     parameter WIDTH = 8,parameter FIRST_CHANK=0
) (
    input logic [WIDTH-1:0] operand_a,
    output logic [WIDTH-1:0] operand_b,
    input logic mux,
    input logic [1:0] carry_in,
    output logic  carry_out
);
         integer i;
  generate
    if(FIRST_CHANK==0)
      begin
  //loop Varible
   
    // out wire of or gate 
    logic inter_or_gate;

    logic [WIDTH-2:0] or_gate;
  assign carry_out =  or_gate[WIDTH-2];
  assign inter_or_gate = carry_in[0] | carry_in[1];

    always_comb begin

        or_gate[0]  = mux ? (operand_a[0] | inter_or_gate) : operand_a[0];
        operand_b[0] = mux ? (operand_a[0] ^ inter_or_gate) : operand_a[0];
        operand_b[1] = operand_a[1] ^ or_gate[0];

      for (i = 2; i <= WIDTH-1; i = i + 1) begin
            or_gate[i-1] = operand_a[i-1] | or_gate[i-2];
            operand_b[i]  = operand_a[i] ^ or_gate[i-1];
        end
    end
      end
    else
      begin
        
        
    logic [WIDTH-3:0] or_gate;
    // carry_out signal is used for togling next bit 
    assign carry_out =  or_gate[WIDTH-3];

    always_comb begin
    
        operand_b[0] = operand_a[0];
        operand_b[1] = operand_a[1] ^ operand_a[0];
        or_gate[0]  = operand_a[1] | operand_a[0];
         for(i=2;i<=WIDTH-1;i++)
        begin
          if(i<=WIDTH-2)
            begin
          or_gate[i-1] = operand_a[i] | or_gate[i-2];
          operand_b[i]  = operand_a[i] ^ or_gate[i-2];
            end
          else
            begin
              operand_b[i]  = operand_a[i] ^ or_gate[i-2];
              
              
            end
        end

    end
        
        
        
        
        
        
      end
  endgenerate
endmodule

