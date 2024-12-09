module carray_select_adder #(parameter ADDER_WIDTH = 2) (
    input logic [ADDER_WIDTH-1:0] operand_a_csela, // Input operand
    input logic carry_in_csela,                      // Carry input
    output logic [ADDER_WIDTH-1:0] sum_csela        // Output sum
);

    // Internal signals for the two possible sums
    logic [ADDER_WIDTH-1:0] sum_0; // Sum when carry input is 0
    logic [ADDER_WIDTH-1:0] sum_1; // Sum when carry input is 1

    // Calculate the two possible sums
    assign sum_0 = operand_a_csela + 1'b0; // No change to operand_a_csela
    assign sum_1 = operand_a_csela + 1'b1; // Increment operand_a_csela by 1

    // Select the appropriate sum based on the carry input
    assign sum_csela = carry_in_csela ? sum_1 : sum_0;

endmodule
