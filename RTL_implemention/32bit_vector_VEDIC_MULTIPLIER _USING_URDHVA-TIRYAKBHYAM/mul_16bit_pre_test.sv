module top();
  logic[31:0]A;
  logic [31:0]B;
  logic [15:0] a;
  logic [15:0] b;
  logic [31:0] out;
  logic [1:0] precision;
  logic clk=1'b1;
  logic rst=1'b1;
  int pass=0;
  int fail=0;
  multiplier_16bit dut1(.clk(clk),.rst(rst),
                     .operand_a_16bit(a),
                        .operand_b_16bit(b),
                        .output_16bit_mul(out),
                        .precision(precision));
  int i;
  always
    begin
     #5; clk=~clk;
      
      
      
    end
  initial 
    begin
      $dumpfile("file.vcd");
    $dumpvars();
      
      #1;rst=1'b0;
      #2;rst=1'b1;
      precision=2'b00;
     
      
      for(i=0;i<10000;i++)
        begin
          A= $urandom();
          
          B= $urandom();
          a=A[15:0];
          b=B[15:0];
          @(posedge clk);
           #1;
         
          if(a[7:0]*b[7:0]==out[15:0])
            pass=pass+1;
          else
            fail=fail+1;
          if(a[15:8]*b[15:8]==out[31:16])
            pass=pass+1;
          else
            fail=fail+1;
        end
        precision=2'b11;
      for(i=0;i<10000;i++)
        begin
          A= $urandom();
          
          B= $urandom();
          a=A[15:0];
          b=B[15:0];
          @(posedge clk);
           #1;
         
          if(a[15:0]*b[15:0]==out[31:0])
            pass=pass+1;
          else
            fail=fail+1;
         
        end
 ///     #1;
    //  rst=1'b0;
    
   //   rst=1'b1;
      
       
    $display("Pass=%d  Fail=%d",pass,fail);
          @(posedge clk);
     
   
        $finish;
  
    end

  
endmodule


