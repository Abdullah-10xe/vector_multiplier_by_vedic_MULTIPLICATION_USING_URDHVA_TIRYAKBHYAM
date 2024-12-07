





module test_32_bit_mul();
  logic [1:0] opcode;
  logic [1:0]precision;
  logic [31:0]operand_a_t;
  logic [31:0]operand_b_t;
  logic [31:0]mul_out_32;
  logic rst;
  logic clk=1;

  logic [63:0] al;
  int i;
  int fail=0;
  int pass=0;
  mul_32bit_precion_control  mul_dut(.clk(clk),.rst(rst),
                                     .operand_a_reg(operand_a_t),
                                     .operand_b_reg(operand_b_t),
                                     .opcode_reg(opcode),
                                     .precision_reg(precision),
                                     .mul_out(mul_out_32));
 
  
  always
    begin
    #5; clk=~clk;
  
    end
  
  initial 
   begin
       $dumpfile("file.vcd");
    $dumpvars();
     rst=1'b0;
     
     #1;
     rst=1'b1;
     precision=2'b10;
     opcode=2'b10;
     for (i=0;i<=100;i++)
       begin
     operand_b_t=32'hfffffffe;
      operand_a_t=32'h00000002;
     @(posedge clk);
     #1;
      @(posedge clk);
     #1;
           @(posedge clk);
         al=operand_b_t* operand_a_t;
     #1;
         
         if(opcode==2'10 )
         begin
         if(precision==2'b10)
           begin
         if(al[63:32]==mul_out_32 )
           begin
             pass+=1;
             
           end
         else
           
           begin
             fail+=1;
             
           end
           end
         end
         #100;
       end
     $display("fail=%d",fail);
     $finish;
     
     
   end
  
  
  
  

  
  
  
endmodule


