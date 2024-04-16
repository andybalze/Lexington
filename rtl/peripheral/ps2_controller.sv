// Edge detector
// needs to be on ps2 clk
// have register (ps2_clk_previous)
// compare ps2_clk to ps2_clk_previous
// if ps2_clk_previous is high and current is low (( if ps2_clk_previous & !ps2_clk))

// assign ps2_clk_neg_edge = ps2_clk_previous & !ps2_clk;

// need an always statement to assign ps2_clk_previous to ps2_clk
// have if 
    // !rst_n then ps2_clk_previous <= 1'b0;
    // else ps2_clk_previous <= ps2_clk;
// this gives neg edge to tell when to sample bit
// clk process is sensitive to core clock
// if ps2_negede do statemachine