module ps2_controller #(
    // Add any necessary parameters here
) (
    input logic clk,          // System clock
    input logic rst_n,        // Reset (active-low)

    input logic ps2_clk,      // PS/2 clock input
    input logic ps2_data,     // PS/2 data input

    // Outputs
    output data[7:0] data,          // Data received from PS/2 controller
    output logic valid,             // Asserted when data is valid
    output logic err                // Asserted when error is detected
);
// Edge detector
// needs to be on ps2 clk
// have register (ps2_clk_previous)
// compare ps2_clk to ps2_clk_previous
// if ps2_clk_previous is high and current is low (( if ps2_clk_previous & !ps2_clk))

// assign ps2_clk_neg_edge = ps2_clk_previous & !ps2_clk;
    // Edge detector for PS/2 clock
    logic ps2_clk_previous;
    assign ps2_clk_neg_edge = ps2_clk_previous & !ps2_clk;

// need an always statement to assign ps2_clk_previous to ps2_clk
// have if 
    // !rst_n then ps2_clk_previous <= 1'b0;
    // else ps2_clk_previous <= ps2_clk;
// this gives neg edge to tell when to sample bit
// clk process is sensitive to core clock
// if ps2_negede do statemachine
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            ps2_clk_previous <= 1'b0;
        end
        else begin
            ps2_clk_previous <= ps2_clk;
        end
    end

    // PS/2 controller logic
    // TODO: Implement PS/2 controller functionality here


endmodule

