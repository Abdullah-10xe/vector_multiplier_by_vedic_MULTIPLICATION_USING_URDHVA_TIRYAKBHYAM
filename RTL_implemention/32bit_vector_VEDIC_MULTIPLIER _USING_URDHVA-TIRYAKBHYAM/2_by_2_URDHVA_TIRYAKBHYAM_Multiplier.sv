// Code your design here
module unit_multiplier(input logic [1:0]A,input logic [1:0] B,output logic [3:0] c);

logic [1:0] wire1;
assign c[0:0] = A[0:0] & B[0:0];

                             assign wire1 = (A[0:0] & B[1:1]  ) + (A[1:1] & B[0:0]);
assign c[1:1]=wire1[0:0];
assign c[3:2]=(A[1:1] &B[1:1])+ wire1[1:1];





endmodulels
