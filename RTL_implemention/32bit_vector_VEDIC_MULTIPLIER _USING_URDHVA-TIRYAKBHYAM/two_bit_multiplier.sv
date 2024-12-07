module two_bit_multiplier (
    input logic [1:0] a,        // First 2-bit input
    input logic [1:0] b,        // Second 2-bit input
    output logic [3:0] c        // 4-bit output for the product
);

    logic in_wire;              // Intermediate wire for carry
    logic [2:0] and_gate_wire;  // Wires for AND gate outputs

    // Generate partial products
    assign c[0] = a[0] & b[0];  // Least significant bit (LSB)
    assign and_gate_wire[0] = a[0] & b[1]; // a[0] * b[1]
    assign and_gate_wire[1] = a[1] & b[0]; // a[1] * b[0]
    assign and_gate_wire[2] = a[1] & b[1]; // a[1] * b[1]

    // First half adder to combine the first two partial products
    half_adder h_a_0 (
        .half_adder_a(and_gate_wire[0]),
        .half_adder_b(and_gate_wire[1]),
        .half_adder_sum(c[1]),   // Sum output
        .half_adder_carry(in_wire) // Carry output
    );

    // Second half adder to combine the last partial product with the carry
    half_adder h_a_1 (
        .half_adder_a(and_gate_wire[2]),
        .half_adder_b(in_wire),
        .half_adder_sum(c[2]),    // Second sum output
        .half_adder_carry(c[3])    // Final carry output
    );

endmodule
