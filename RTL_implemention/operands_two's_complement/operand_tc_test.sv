module top ();
 
  logic [31:0] A;
  logic [31:0] B;
  logic [1:0] Perison;
  logic [1:0] op;
  logic [3:0] ct;

  int pass = 0;
  int fail = 0;
 
  //operand_select ==0 for operand A
  tc_sel_control_logic #(.operand_select(1))dut (
      .precision(Perison),
      .opcode(op),
      .operand_a(A),
      .operand_a_from_tc(B),
      .sign_signal(ct)
  );  
  
  
 
  
  tc_64bit_with_precision dut16(.mul_block_output(a64),.opcode(op),.precision(Perison),.sign_signal_a(sign_a),.sign_signal_b(sign_b),.mul_out(out));
`include "test_b.sv"  // test_a.sv for operand A
  initial begin
    $dumpfile("file.vcd");
    $dumpvars();
   
   op = 2'b11;
    Perison = 2'b00;
    bit_8();
    Perison = 2'b01;
    bit_16();
    Perison = 2'b10;
    bit_32();
    
   #5;
     op = 2'b00;
    Perison = 2'b00;
    bit_8();
    Perison = 2'b01;
    bit_16();
    Perison = 2'b10;
    bit_32();
    #5;
     op = 2'b01;
    Perison = 2'b00;
    bit_8();
    Perison = 2'b01;
    bit_16();
    Perison = 2'b10;
    bit_32(); 
    #5
    op = 2'b10;
    Perison = 2'b00;
    bit_8();
    Perison = 2'b01;
    bit_16();
    Perison = 2'b10;
    bit_32();
    #5;
    $display("pass==%d   fail==%d", pass, fail);
    $finish;
  end
endmodule

