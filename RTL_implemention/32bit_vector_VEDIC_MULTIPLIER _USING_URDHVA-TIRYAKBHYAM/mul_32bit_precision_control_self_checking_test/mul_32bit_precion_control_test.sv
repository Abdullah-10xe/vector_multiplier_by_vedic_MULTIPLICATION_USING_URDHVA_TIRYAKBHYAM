/***********************************************************************************
* Author      : Abdullah Jhatial
* Designation : Associate Hardware Design Engineer
* Firm        : 10x Engineers
* Email       : abdullahjhatial92@gmail.com, abdullah.jhatial@10xengineers.ai
*  **********************       Design        ***************************************** 
* This module design is for testing 32 bit vedic multipiler with precision 
* Supported precision: 8-bit, 16-bit, 32-bit (00, 01, 10)
* Supported operations: MUL, MULH, MULHU, MULSU (00, 01, 10, 11)
* Design for Vector Multiplier based on VEDIC MULTIPLIER USING URDHVA-TIRYAKBHYAM
* test with all opcode and precsions with 10000 randomize values
***********************************************************************************/
module mul_32bit_test();
  logic[31:0]A;
  logic [31:0]B;
  logic [31:0] a;
  logic [31:0] b;
  logic [63:0] out_32;
  logic [1:0] precision;
  logic clk=1'b1;
  logic rst=1'b1;
  int pass=0;
  int fail=0;
  longint al;
 
  multiplier_32bit dut1(.clk(clk),.rst(rst),
                     .operand_a_32bit(a),
                        .operand_b_32bit(b),
                        .output_32bit_mul(out_32),
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
      
      precision=2'b10;
    
      
      for(i=0;i<1000;i++)
        begin
          A= $urandom();
          
          B= $urandom();
          a=A[31:0];
          b=B[31:0];
          @(posedge clk);
           #1;
         // $display("a=%d  b=%d    out=%d",a,b,out_32);
          if(a*b==out_32)
            pass=pass+1;
          else
            begin
            fail=fail+1;
              al=a*b;
              $display("pre 10    32   a=%d  b=%d out =%d   ,actual=%d",a,b,out_32,al);
            end
         
        end
      
         precision=2'b01;
      for(i=0;i<10000;i++)
        begin
          A= $urandom();
          
          B= $urandom();
          a=A[31:0];
          b=B[31:0];
          @(posedge clk);
           #1;
         // $display("a=%d  b=%d    out=%d",a,b,out_32);
          if(a[15:0]*b[15:0]==out_32[31:0])
            pass=pass+1;
          else
            begin
            fail=fail+1;
              $display("pre 16 a[15:0]    32   a=%d  b=%d",a,b); 
              
              
            end
          if(a[31:16]*b[31:16]==out_32[63:32])
            pass=pass+1;
          else
            begin
            fail=fail+1;
              $display("pre 16 a[31]    32   a=%d  b=%d",a,b);
            end 
         
        end
      
              precision=2'b00;

      for(i=0;i<10000;i++)
        begin
          A= $urandom();
          
          B= $urandom();
          a=A[31:0];
          b=B[31:0];
          @(posedge clk);
           #1;
         // $display("a=%d  b=%d    out=%d",a,b,out_32);
          if(a[7:0]*b[7:0]==out_32[15:0])
            pass=pass+1;
          else
            begin
            fail=fail+1;
              $display("1 a=%h  b=%h",a,b,al);
            end
          if(a[15:8]*b[15:8]==out_32[31:16])
            pass=pass+1;
          else
            begin
            fail=fail+1;
              $display("2a=%d  b=%d",a,b);
            end
          if(a[23:16]*b[23:16]==out_32[47:32])
            pass=pass+1;
          else
            begin
            fail=fail+1;
              $display("3a=%h b=%h  out_text =%h \n   a[23:16]=%h      b[23:16] =%h ,   out_32[48:32]=%h",a,b,out_32,a[23:16],b[23:16],out_32[48:32]);
            end
          if(a[31:24]*b[31:24]==out_32[63:48])
            pass=pass+1;
          else
            begin
            fail=fail+1;
              $display("4 a=%d  b=%d",a,b);
              
            end
        end  
      precision=2'b10;
        
       a=32'd992600595;
      b=32'd1764109936;
      al=a*b;
      @(posedge clk);
    #1;
      $display("a=%h  b=%h out_32=%h   a*b=%h",a,b,out_32,al);
      #2;
       @(posedge clk);
      #10;
      //2673650421409543392
      
 ///     #1;
    //  rst=1'b0;
    
   //   rst=1'b1;
      
      
    $display("Pass=%d  Fail=%d",pass,fail);
          @(posedge clk);
     #2;
   
        $finish;
  
    end

  


