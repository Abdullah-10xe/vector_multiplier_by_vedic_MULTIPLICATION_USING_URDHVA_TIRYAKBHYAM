
// this module is responsible for producing Tow's compliment  as precision 
// this module desing on prefix calculation techniques which reduces logic levels
// this module parameterized unit it take base unit bits and produce the tow's complement 
/// for precions same logic with little modifications  for detail check diagram
module tc_8_16bits #(
    parameter WIDTH = 8,                // Width of the operands
    parameter FIRST_CHANK = 0,          // Indicates the first chunk
    parameter STAGE = $clog2(WIDTH)     // Number of stages based on the width
) (
    input logic  [WIDTH-1:0]  operand_a,  // Input operand A
    output logic [WIDTH-1:0]  operand_b,  // Output operand B
    input logic               mux,                     // Multiplexer control signal
    input logic  [1:0]        carry_in,          // Carry input signals
    output logic              carry_out               // Carry output signal
);

    genvar i; // Loop variable for width
    genvar j; // Loop variable for stages

    generate
        if (FIRST_CHANK == 0) begin
            // Declare a generate vector for stages
            logic [STAGE:0] [WIDTH-1:0] gen_vector;
            logic inter_or_gate; // Intermediate OR gate signal
            logic sig_a_0; // Signal for operand_a[0]

            // Compute the intermediate OR gate signal
            assign inter_or_gate = carry_in[0] | carry_in[1];
            assign sig_a_0 = mux ? inter_or_gate : operand_a[0];
            assign gen_vector[0][0] = mux ? (operand_a[0] | inter_or_gate) : operand_a[0];
            assign gen_vector[0][WIDTH-1:1] = operand_a[WIDTH-1:1];

            // Generate the stages
            for (j = 1; j <= STAGE; j++) begin
                for (i = 0; i < WIDTH; i++) begin
                    if (i < (2**(j-1))) begin
                        assign gen_vector[j][i] = gen_vector[j-1][i];
                    end else begin
                        // Instantiate the OR cell for the current stage
                        or_cell stage_or_cell (
                            .a_bit(gen_vector[j-1][i]),
                            .or_pre(gen_vector[j-1][i - (2**(j-1))]),
                            .carry(gen_vector[j][i])
                        );
                    end
                end
            end

            // Compute the output operand_b and carry_out
            for (i = 0; i < WIDTH ; i++) begin
                if (i == 0) begin
                    assign operand_b[i] = mux ? (inter_or_gate ^ operand_a[0]) : operand_a[0];
                    assign carry_out = gen_vector[STAGE][WIDTH-1];
                end else begin
                    // Instantiate the XOR cell for the last stage
                    xor_cell xor_last_stage (
                        .gen_a(gen_vector[STAGE][i-1]),
                        .op_a(operand_a[i]),
                        .xor_out(operand_b[i])
                    );
                end
            end

        end else begin
            // First 8 bits as prefix
            logic [STAGE:0] [WIDTH-1:0] gen_vector; // Generate vector
            assign gen_vector[0] = operand_a; // Initialize the first stage with operand_a

            // Generate the stages
            for (j = 1; j <= STAGE; j++) begin
                for (i = 0; i < WIDTH; i++) begin
                    if (i < (2**(j-1))) begin
                        assign gen_vector[j][i] = gen_vector[j-1][i];
                    end else begin
                        // Instantiate the OR cell for the current stage
                        or_cell stage_or_cell (
                            .a_bit(gen_vector[j-1][i]),
                            .or_pre(gen_vector[j-1][i - (2**(j-1))]),
                            .carry(gen_vector[j][i])
                        );
                    end
                end
            end

            // Compute the output operand_b and carry_out
            for (i = 0; i < WIDTH; i++) begin
                if (i == 0) begin
                    assign operand_b[i] = gen_vector[STAGE][i];
                    assign carry_out = gen_vector[STAGE][WIDTH-1];
                end else begin
                    // Instantiate the XOR cell for the last stage
                    xor_cell xor_last_stage (
                        .gen_a(gen_vector[STAGE][i-1]),
                        .op_a(operand_a[i]),
                        .xor_out(operand_b[i])
                    );
                end
            end
        end
    endgenerate

endmodule

//////////////////// OR Cell ///////////////////////////////
module or_cell (
    input logic  a_bit, 
    input logic  or_pre,
    output logic carry
);
    // Compute the OR operation
    assign carry = a_bit | or_pre; // Assign the result of the OR operation
endmodule

//////////////////////// XOR Cell ///////////////////////////
module xor_cell (
    input logic  gen_a, 
    input logic  op_a,
    output logic xor_out
);
    // Compute the XOR operation
    assign xor_out = gen_a ^ op_a; // Assign the result of the XOR operation
endmodule

