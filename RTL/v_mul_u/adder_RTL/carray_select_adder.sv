/**************************************************************************************************************
* Author      : Abdullah Jhatial
* Designation : Associate Hardware Design Engineer
* Company        : 10x Engineers    contact@10xengineers.ai ,   https://10xengineers.ai/
* Email       : abdullah.jhatial@10xengineers.ai , abdullahjhatial92@gmail.com
*  **********************       Design        *****************************************************************
* This module design for adding single operand (5,7,15) bit number with carry in with carry select Architecture 
* Supported precision: 8-bit, 16-bit, 32-bit (00, 01, 10)
* Supported operations: MUL, MULH, MULHU, MULSU (00, 01, 10, 11)
* Design for Vector Multiplier based on VEDIC MULTIPLIER USING URDHVA-TIRYAKBHYAM
****************************************************************************************************************/

/////////////////////  BEC circuit   ///////////////////////////////////////////////////////////////////////////


module adder_3_4 #(
    parameter ADDER_WIDTH = 3,          // Width of the adder (3 or 4 bits)
    parameter CARRY_SIG   = 0,             // Carry signal parameter
    parameter WIDTH_C     = ADDER_WIDTH - 1'b1, // Width for carry case
    parameter WIDTH_NC    = ADDER_WIDTH - 2'b10 // Width for no carry case
)(
    input  logic [ADDER_WIDTH-1:0] a,    // Input operand
    output logic carry_out,              // Carry output
    output logic [ADDER_WIDTH-1:0] sum   // Output sum
);

genvar i; // Declare a generate variable

generate 

    // Generate logic for 3-bit adder
    if (ADDER_WIDTH == 3) begin
        logic gate_and; // Intermediate AND gate results

        // Calculate the AND results for carry propagation
        assign gate_and = a[1] & a[0];

        // Assign sum outputs
        assign sum[0] = ~a[0];
        assign sum[1] = a[1] ^ a[0];
        assign sum[2] = a[2] ^ gate_and;
    end

    //////////////////////  else block /////////////////
    else
    begin
        ////////////////////  Sum with carry out start/////////////////////////
        if (CARRY_SIG == 1) begin
            logic [WIDTH_C-1:0] gate_and; // Intermediate AND gate results

            ////////// propagation signals (gate_and) start//////////////////////////
            for (i = 0; i < WIDTH_C; i++) begin
                if (i == 0) begin
                    assign gate_and[i] = a[i+1] & a[i];
                end
                else begin
                    assign gate_and[i] = a[i+1] & gate_and[i-1];  
                end
            end
            ////////////////////  end propagation signals  ///////////////
            
            ////////////////////// Start sum signals///////////////////////////////////
            assign sum[0] = ~a[0];
            assign sum[1] = a[1] ^ a[0];
            assign carry_out = gate_and[WIDTH_C-1];
            
            for (i = 2; i <= WIDTH_C; i++) begin
                assign sum[i] = a[i] ^ gate_and[i-2];
            end
            ///////////////////// end sum ///////////////////////
        end // end of CARRY_SIG == 1
        
        //////////// sum with carry completed ///////////////////////
        
        ////////////////////// Sum without carry_out start ///////////////////   
        else
        begin
            logic [WIDTH_NC-1:0] gate_and; // Intermediate AND gate results

            for (i = 0; i < WIDTH_NC; i++) begin
                if (i == 0) begin
                    assign gate_and[i] = a[i+1] & a[i];
                end
                else begin
                    assign gate_and[i] = a[i+1] & gate_and[i-1];  
                end
            end
            
            ///////// sum starts ///////
            assign sum[0] = ~a[0];
            assign sum[1] = a[1] ^ a[0];
            for (i = 2; i < ADDER_WIDTH; i++) begin
                assign sum[i] = a[i] ^ gate_and[i-2];
            end
        end // end of else for no carry_out
    end // end of else for CARRY_SIG

endgenerate

endmodule



////////////////////////////////////   Adding N bit number with single bit , by using  BEC Binary to Excess-1 Circuit /////////////////////////////////////////////////////


module carray_select_adder #(
    parameter ADDER_WIDTH = 3  // Width of the adder (3, 7, or 15 bits)
)(
    input logic  [ADDER_WIDTH-1:0] operand_a_csela, // Input operand
    input logic  carry_in_csela,                     // Carry input
    output logic [ADDER_WIDTH-1:0] sum_csela       // Output sum
);

generate 
    // Generate logic for 3-bit adder
    if (ADDER_WIDTH == 3) begin
        logic [ADDER_WIDTH-1:0] sum_1; // Sum when carry is 1
        
        // Instantiate the 3-bit adder
        adder_3_4 #(.ADDER_WIDTH(3)) adder_1 (
            .a(operand_a_csela),
            .sum(sum_1)
        );

        // Select the appropriate sum based on carry_in_csela
        assign sum_csela = carry_in_csela ? sum_1 : operand_a_csela;
    end
    
    // Generate logic for 7-bit adder
    if (ADDER_WIDTH == 7) begin
       
        logic [6:0] sum_1; // Sum when carry is 1 for upper bits
        
        // Instantiate the 4-bit adder for lower bits
      adder_3_4 #(.ADDER_WIDTH(7)) adder_1_0 (
            .a(operand_a_csela),
            .sum(sum_1)
           
        );

        // Select the appropriate sums based on carry_in_csela
      assign sum_csela= carry_in_csela ? sum_1 : operand_a_csela;
       
    end
    
    // Generate logic for 15-bit adder
    if (ADDER_WIDTH == 15) begin
        logic carry_1; // Carry outputs for the case when carry is 1
        logic [6:0]  sum_1; // Sums for the case when carry is 1
        logic [7:0] sum_2; // Sum for the last 3 bits when carry is 1
        logic  mux_sel;  // Multiplexer select signals for carry outputs
      
        // Instantiate adders for the first 4 bits
      adder_3_4 #(.ADDER_WIDTH(7),.CARRY_SIG(1)) adder_1_1 (
        .a(operand_a_csela[6:0]),
            .sum(sum_1),
            .carry_out(carry_1)
        );
       
      adder_3_4 #(.ADDER_WIDTH(8)) adder_1_2 (
        .a(operand_a_csela[14:7]),
        .sum(sum_2));
      
       
      // Select the appropriate sums based on carry_in_csela
      assign sum_csela[6:0] = carry_in_csela ? sum_1   : operand_a_csela[6:0]; 
      assign mux_sel        = carry_in_csela ? carry_1 : 1'b0;
      
     // Assign the sums for the higher bits based on the selected carry
      assign sum_csela[14:7]   = mux_sel ? sum_2  : operand_a_csela[14:7];
        
    end
endgenerate

endmodule



























