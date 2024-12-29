/***********************************************************************************
* Author      : Abdullah Jhatial
* Designation : Associate Hardware Design Engineer
* Company     : 10x Engineers     https://10xengineers.ai/ngineers.ai/
* Email       :  abdullah.jhatial@10xengineers.ai
*  **********************       Design        ***************************************** 
* This module design for parameterized Kogge stone adder
* Supported precision: 8-bit, 16-bit, 32-bit (00, 01, 10)
* Supported operations: MUL, MULH, MULHU, MULSU (00, 01, 10, 11)
* Design for Multiplier based on Vedic Algorithim 
***********************************************************************************/

// Kogge-Stone Adder Module   Parameterized 



module prefix_adder #( 
    parameter NO_CARRY     =  0,
    parameter ADDER_WIDTH  =  16,  // Width of the adder
    parameter STAGE        =  $clog2(ADDER_WIDTH) // Number of stages based on the width
)(
    input logic   [ADDER_WIDTH-1:0] operand_a,  // First operand
    input logic   [ADDER_WIDTH-1:0] operand_b,  // Second operand
    output logic  [ADDER_WIDTH-1:0] sum_stage,  // Output sum including carry
    output logic                    carry_bka
);

    // Generate and propagate vectors for each stage
    logic [STAGE:0] [ADDER_WIDTH-1:0] gen_vector; // Generate vector
    logic [STAGE:0] [ADDER_WIDTH-1:0] pro_vector; // Propagate vector

    int Stage_number; // Variable to hold the stage number
    genvar i;         // Loop variable for inner loops
    genvar j;         // Loop variable for outer loops

    // Generate the pre-processing stage
    generate
        for (j = 0; j < ADDER_WIDTH; j++) begin
            pre_block pre_stage (
                .a_bit(operand_a[j]),               // Input bit A
                .b_bit(operand_b[j]),               // Input bit B
                .p_bit(pro_vector[0][j]),           // Output propagate bit
                .g_bit(gen_vector[0][j])            // Output generate bit
            );   
        end

        ////////////////////////////
        // Generate stages for the Kogge-Stone adder
        for (j = 1; j <= STAGE; j++) begin
            for (i = 0; i < ADDER_WIDTH; i++) begin
                if (i < (2**(j-1))) begin
                    // Carry forward the generate and propagate signals
                    assign gen_vector[j][i] = gen_vector[j-1][i];
                    assign pro_vector[j][i] = pro_vector[j-1][i];                                  
                end
                else if (i < 2**(j)) begin
                    // Instantiate grey cell for the current stage
                    grey_cell stage_grey_cell (
                        .generate_cur(gen_vector[j-1][i]), // Current generate signal
                        .propagate_cur(pro_vector[j-1][i]), // Current propagate signal
                        .generate_pre(gen_vector[j-1][i-(2**(j-1))]), // Previous generate signal
                        .generate_for_sum(gen_vector[j][i]) // Output generate signal for sum
                    );
                    assign pro_vector[j][i] = pro_vector[j-1][i]; // Carry forward propagate signal
                end  
                else if (i < 2**(STAGE+1)) begin
                    // Instantiate black cell for the current stage
                    black_cell stage_black_cell (
                        .propagate_pre(pro_vector[j-1][i-(2**(j-1))]), // Previous propagate signal
                        .propagate_cur(pro_vector[j-1][i]), // Current propagate signal
                        .generate_pre(gen_vector[j-1][i-(2**(j-1))]), // Previous generate signal
                        .generate_cur(gen_vector[j-1][i]), // Current generate signal
                        .propagate_sig(pro_vector[j][i]), // Output propagate signal
                        .generate_sig(gen_vector[j][i]) // Output generate signal
                    ); 
                end
            end
        end

        // Final stage to calculate the sum
        for (i = 0; i < ADDER_WIDTH; i++) begin
            if (i == 0) begin
                // Assign the first sum and carry out
                assign sum_stage[i] = pro_vector[STAGE][i];
              if( NO_CARRY==0)
                begin
                assign  carry_bka= gen_vector[STAGE][ADDER_WIDTH-1];
                end
            end
            else begin
                // Instantiate sum out cell for the remaining bits
                sum_out sum_stage_init (
                    .carry_in(gen_vector[STAGE][i-1]), // Carry input from previous stage
                    .propagate_in(pro_vector[0][i]), // Propagate input from the first stage
                    .out_sum(sum_stage[i]) // Output sum
                );
            end
        end
    endgenerate

endmodule






// Black Cell Module
module black_cell(
    input logic propagate_pre,  // Previous propagate signal
    input logic propagate_cur,   // Current propagate signal
    input logic generate_pre,    // Previous generate signal
    input logic generate_cur,     // Current generate signal
    output logic propagate_sig,   // Output propagate signal
    output logic generate_sig     // Output generate signal
);
    // Calculate the propagate signal for the current stage
    assign propagate_sig = propagate_cur & propagate_pre;

    // Calculate the generate signal for the current stage
    assign generate_sig = generate_cur | (propagate_cur & generate_pre);
endmodule

//////// Pre Processing Cell //////////
module pre_block(
    input logic a_bit,  // Input bit A
    input logic b_bit,  // Input bit B
    output logic p_bit, // Output propagate bit
    output logic g_bit  // Output generate bit
);
    // Calculate the propagate bit as the XOR of A and B
    assign p_bit = a_bit ^ b_bit;

    // Calculate the generate bit as the AND of A and B
    assign g_bit = a_bit & b_bit;
endmodule

///// Grey Cell //////
module grey_cell(
    input logic generate_cur,    // Current generate signal
    input logic propagate_cur,    // Current propagate signal
    input logic generate_pre,     // Previous generate signal
    output logic generate_for_sum // Output generate signal for sum
);
    // Calculate the generate signal for sum using current and previous signals
    assign generate_for_sum = (propagate_cur & generate_pre) | generate_cur;
endmodule

//////// Sum Out Cell //////////
module sum_out(
    input logic carry_in,        // Input carry signal
    input logic propagate_in,    // Input propagate signal
    output logic out_sum         // Output sum
);
    // Calculate the output sum as the XOR of carry_in and propagate_in
    assign out_sum = carry_in ^ propagate_in;
endmodule


