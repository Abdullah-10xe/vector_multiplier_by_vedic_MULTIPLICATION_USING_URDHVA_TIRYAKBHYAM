/***********************************************************************************
* Author      : Abdullah Jhatial
* Designation : Associate Hardware Design Engineer
* Firm        : 10x Engineers
* Email       : abdullahjhatial92@gmail.com, abdullah.jhatial@10xengineers.ai
*  **********************       Design        ***************************************** 
* This module design is for taking two's complement depending on the opcode and precision.
* Supported precision: 8-bit, 16-bit, 32-bit (00, 01, 10)
* Supported operations: MUL, MULH, MULHU, MULSU (00, 01, 10, 11)
* Design for Vector Multiplier based on VEDIC MULTIPLIER USING URDHVA-TIRYAKBHYAM
***********************************************************************************/
// 3-4 Bit Adder Module



module adder_3_4 #(
    parameter ADDER_WIDTH = 3,  // Width of the adder (3 or 4 bits)
    parameter CARRY_NO = 0       // Carry input (not used in this implementation)
)(
    input logic [ADDER_WIDTH-1:0] a,  // Input operand
    input logic carry,                 // Carry input
    output logic carry_out,            // Carry output
    output logic [ADDER_WIDTH-1:0] sum // Output sum
);

generate 
    // Generate logic for 4-bit adder
    if (ADDER_WIDTH == 4) begin
        logic [ADDER_WIDTH-1:0] gate_and; // Intermediate AND gate results

        // Calculate the AND results for carry propagation
        assign gate_and[0] = a[0] & carry;
        assign gate_and[1] = a[1] & gate_and[0];
        assign gate_and[2] = a[2] & gate_and[1];
        assign gate_and[3] = a[3] & gate_and[2];

        // Assign carry out and sum outputs
        assign carry_out = gate_and[3];
        assign sum = {a[3] ^ gate_and[2], a[2] ^ gate_and[1], a[1] ^ gate_and[0], a[0] ^ carry};
    end

    // Generate logic for 3-bit adder
    if (ADDER_WIDTH == 3) begin
        logic [ADDER_WIDTH-2:0] gate_and; // Intermediate AND gate results

        // Calculate the AND results for carry propagation
        assign gate_and[0] = a[0] & carry;
        assign gate_and[1] = a[1] & gate_and[0];

        // Assign sum outputs
        assign sum[0] = a[0] ^ carry;
        assign sum[1] = a[1] ^ gate_and[0];
        assign sum[2] = a[2] ^ gate_and[1];
    end
endgenerate

endmodule





/*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                             
                                                              with intermediated select


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/



module carray_select_adder #(
    parameter ADDER_WIDTH = 3  // Width of the adder (3, 7, or 15 bits)
)(
    input logic [ADDER_WIDTH-1:0] operand_a_csela, // Input operand
    input logic carry_in_csela,                     // Carry input
    output logic [ADDER_WIDTH-1:0] sum_csela       // Output sum
);

generate 
    // Generate logic for 3-bit adder
    if (ADDER_WIDTH == 3) begin
        logic [ADDER_WIDTH-1:0] sum_0; // Sum when carry is 0
        logic [ADDER_WIDTH-1:0] sum_1; // Sum when carry is 1
        
        // Instantiate two 3-4 bit adders for carry 0 and carry 1
        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(0)) adder_0 (
            .a(operand_a_csela),
            .carry(1'b0),
            .sum(sum_0)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(0)) adder_1 (
            .a(operand_a_csela),
            .carry(1'b1),
            .sum(sum_1)
        );

        // Select the appropriate sum based on carry_in_csela
        assign sum_csela = carry_in_csela ? sum_1 : sum_0;
    end
    
    // Generate logic for 7-bit adder
    if (ADDER_WIDTH == 7) begin
        logic [3:0] sum_0_0; // Sum when carry is 0 for lower bits
        logic [3:0] sum_0_1; // Sum when carry is 1 for lower bits
        logic [2:0] sum_1_0; // Sum when carry is 0 for upper bits
        logic [2:0] sum_1_1; // Sum when carry is 1 for upper bits
        logic carry_sel_0;   // Carry output from first adder
        logic carry_sel_1;   // Carry output from second adder
        logic mux_sel;       // Multiplexer select signal
        
        // Instantiate adders for the lower 4 bits
        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_0 (
            .a(operand_a_csela[3:0]),
            .carry(1'b0),
            .sum(sum_0_0),
            .carry_out(carry_sel_0)
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_1 (
            .a(operand_a_csela[3:0]),
            .carry(1'b1),
            .sum(sum_0_1),
            .carry_out(carry_sel_1)
        );

        // Instantiate adders for the upper 3 bits
        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_1_0 (
            .a(operand_a_csela[6:4]),
            .carry(1'b0),
            .sum(sum_1_0)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_1_1 (
            .a(operand_a_csela[6:4]),
            .carry(1'b1),
            .sum(sum_1_1)
        );

        // Select the appropriate sums based on carry_in_csela
        assign sum_csela[3:0] = carry_in_csela ? sum_0_1 : sum_0_0;
        assign mux_sel = carry_in_csela ? carry_sel_1 : carry_sel_0;
        assign sum_csela[6:4] = mux_sel ? sum_1_1 : sum_1_0;
    end
    
    // Generate logic for 15-bit adder
    if (ADDER_WIDTH == 15) begin
        logic [2:0] carry_0; // Carry outputs for the case when carry is 0
        logic [2:0] carry_1; // Carry outputs for the case when carry is 1
        logic [3:0] sum_0[2:0]; // Sums for the case when carry is 0
        logic [3:0] sum_1[2:0]; // Sums for the case when carry is 1
        logic [2:0] sum_3_0; // Sum for the last 3 bits when carry is 0
        logic [2:0] sum_3_1; // Sum for the last 3 bits when carry is 1
        logic [2:0] mux_sel;  // Multiplexer select signals for carry outputs
        
        // Instantiate adders for the first 4 bits
        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_0 (
            .a(operand_a_csela[3:0]),
            .carry(1'b0),
            .sum(sum_0[0]),
            .carry_out(carry_0[0])
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_1 (
            .a(operand_a_csela[3:0]),
            .carry(1'b1),
            .sum(sum_1[0]),
            .carry_out(carry_1[0])
        );

        // Instantiate adders for the next 4 bits
        adder_3_4 #(.ADDER_WIDTH(4)) adder_1_0 (
            .a(operand_a_csela[7:4]),
            .carry(1'b0),
            .sum(sum_0[1]),
            .carry_out(carry_0[1])
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_1_1 (
            .a(operand_a_csela[7:4]),
            .carry(1'b1),
            .sum(sum_1[1]),
            .carry_out(carry_1[1])
        );

        // Instantiate adders for the next 4 bits
        adder_3_4 #(.ADDER_WIDTH(4)) adder_2_0 (
            .a(operand_a_csela[11:8]),
            .carry(1'b0),
            .sum(sum_0[2]),
            .carry_out(carry_0[2])
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_2_1 (
            .a(operand_a_csela[11:8]),
            .carry(1'b1),
            .sum(sum_1[2]),
            .carry_out(carry_1[2])
        );

        // Instantiate adders for the last 3 bits
        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_3_0 (
            .a(operand_a_csela[14:12]),
            .carry(1'b0),
            .sum(sum_3_0)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_3_1 (
            .a(operand_a_csela[14:12]),
            .carry(1'b1),
            .sum(sum_3_1)
        );

        // Select the appropriate sums based on carry_in_csela
        assign sum_csela[3:0] = carry_in_csela ? sum_1[0] : sum_0[0]; 
        assign mux_sel[0] = carry_in_csela ? carry_1[0] : carry_0[0];
        assign mux_sel[1] = mux_sel[0] ? carry_1[1] : carry_0[1];
        assign mux_sel[2] = mux_sel[1] ? carry_1[2] : carry_0[2];

        // Assign the sums for the higher bits based on the selected carry
        assign sum_csela[7:4] = mux_sel[0] ? sum_1[1] : sum_0[1];
        assign sum_csela[11:8] = mux_sel[1] ? sum_1[2] : sum_0[2];
        assign sum_csela[14:12] = mux_sel[2] ? sum_3_1 : sum_3_0;
    end
endgenerate

endmodule





/*


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                             
                                                              without intermediated select


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Carry Select Adder Module
module carray_select_adder #(
    parameter ADDER_WIDTH = 3  // Width of the adder (3, 7, or 15 bits)
)(
    input logic [ADDER_WIDTH-1:0] operand_a_csela, // Input operand
    input logic carry_in_csela,                     // Carry input
    output logic [ADDER_WIDTH-1:0] sum_csela       // Output sum
);

generate
    // Generate logic for 3-bit adder
    if (ADDER_WIDTH == 3) begin
        logic mux_sel; // Multiplexer select signal (not used)
        logic [ADDER_WIDTH-1:0] sum_0; // Sum when carry is 0
        logic [ADDER_WIDTH-1:0] sum_1; // Sum when carry is 1

        // Instantiate two 3-4 bit adders for carry 0 and carry 1
        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(0)) adder_0 (
            .a(operand_a_csela),
            .carry(1'b0),
            .sum(sum_0)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(0)) adder_1 (
            .a(operand_a_csela),
            .carry(1'b1),
            .sum(sum_1)
        );

        // Select the appropriate sum based on carry_in_csela
        assign sum_csela = carry_in_csela ? sum_1 : sum_0;
    end

    // Generate logic for 7-bit adder
    if (ADDER_WIDTH == 7) begin
        logic [6:0] sum_0_0; // Sum when carry is 0
        logic [6:0] sum_1_1; // Sum when carry is 1
        logic carry_sel_0;   // Carry output from first adder
        logic carry_sel_1;   // Carry output from second adder

        // Instantiate adders for the first case (carry 0)
        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_0 (
            .a(operand_a_csela[3:0]),
            .carry(1'b0),
            .sum(sum_0_0[3:0]),
            .carry_out(carry_sel_0)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_0_1 (
            .a(operand_a_csela[6:4]),
            .carry(carry_sel_0),
            .sum(sum_0_0[6:4])
        );

        // Instantiate adders for the second case (carry 1)
        adder_3_4 #(.ADDER_WIDTH(4)) adder_1_0 (
            .a(operand_a_csela[3:0]),
            .carry(1'b1),
            .sum(sum_1_1[3:0]),
            .carry_out(carry_sel_1)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_1_1 (
            .a(operand_a_csela[6:4]),
            .carry(carry_sel_1),
            .sum(sum_1_1[6:4])
        );

        // Select the appropriate sum based on carry_in_csela
        assign sum_csela = carry_in_csela ? sum_1_1 : sum_0_0;
    end

    // Generate logic for 15-bit adder
    if (ADDER_WIDTH == 15) begin
        logic [14:0] sum_0_0; // Sum when carry is 0
        logic [14:0] sum_1_1; // Sum when carry is 1
        logic carry_sel_0_0;  // Carry output from first adder
        logic carry_sel_0_1;  // Carry output from second adder
        logic carry_sel_0_2;  // Carry output from third adder
        logic carry_sel_1_0;  // Carry output from first adder (carry 1)
        logic carry_sel_1_1;  // Carry output from second adder (carry 1)
        logic carry_sel_1_2;  // Carry output from third adder (carry 1)

        // Instantiate adders for the first case (carry 0)
                // Instantiate adders for the first case (carry 0)
        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_0 (
            .a(operand_a_csela[3:0]),
            .carry(1'b0),
            .sum(sum_0_0[3:0]),
            .carry_out(carry_sel_0_0)
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_1 (
            .a(operand_a_csela[7:4]),
            .carry(carry_sel_0_0),
            .sum(sum_0_0[7:4]),
            .carry_out(carry_sel_0_1)
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_2 (
            .a(operand_a_csela[11:8]),
            .carry(carry_sel_0_1),
            .sum(sum_0_0[11:8]),
            .carry_out(carry_sel_0_2)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_0_4 (
            .a(operand_a_csela[14:12]),
            .carry(carry_sel_0_2),
            .sum(sum_0_0[14:12])
        );

        ///////////////////////////////////////////////////
        // Instantiate adders for the second case (carry 1)
        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_0_0 (
            .a(operand_a_csela[3:0]),
            .carry(1'b1),
            .sum(sum_1_1[3:0]),
            .carry_out(carry_sel_1_0)
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_0_1 (
            .a(operand_a_csela[7:4]),
            .carry(carry_sel_1_0),
            .sum(sum_1_1[7:4]),
            .carry_out(carry_sel_1_1)
        );

        adder_3_4 #(.ADDER_WIDTH(4)) adder_0_0_2 (
            .a(operand_a_csela[11:8]),
            .carry(carry_sel_1_1),
            .sum(sum_1_1[11:8]),
            .carry_out(carry_sel_1_2)
        );

        adder_3_4 #(.ADDER_WIDTH(3), .CARRY_NO(1)) adder_0_0_4 (
            .a(operand_a_csela[14:12]),
            .carry(carry_sel_1_2),
            .sum(sum_1_1[14:12])
        );

        // Select the appropriate sum based on carry_in_csela
        assign sum_csela = carry_in_csela ? sum_1_1 : sum_0_0;
    end
endgenerate

endmodule







*/


