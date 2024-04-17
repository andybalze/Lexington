`timescale 1ns/1ps


module ps2_controller_TB;

    localparam MAX_CYCLES = 16*8;
    integer clk_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    integer fid;

    // DUT Ports
    // TODO put correct ports here

    logic clk;
    logic rst, rst_n;


    assign rst_n = ~rst;

    // Instantiate DUT
    // TOOD replace with my instance
    // TOOD add my ports
    ps2_controller DUT (
        .io_pins(io_pins),
        .int0(),
        .int1(),
        .axi
    );

    // Internal clock to the processor
    // 100 MHz clock
    initial clk = 1;
    initial forever #5 clk <= ~clk;

    initial begin
        fid = $fopen("ps2_controller.log");
        $dumpfile("ps2_controller.vcd");
        $dumpvars(4, ps2_controller_TB);

        // Reset
        rst <= 1;
        #20
        rst <= 0;
    end


// TODO fill in stimulus section 
// Can do initial block with delays 
// or always @ posedge clk
// if you nest them there is sequential programming?
// to test we emulate the waveform of the ps2 controller
// as the receiver we sample on the falling edge of the clock
// very similar to UART except I have to add parity bit (with XOR)
// set data signal 
// wait several clock cycles half ps2 period #40 (#80 is 1 ps2 clock period)
// do clock edge (clock will get low) (on falling edge of clock)
// alternate what changing
// data wait clk data wait clk ... ...
// data
// #40
// clk <= 0
// #40 
// clk <= 1
// #40
initial begin
    while (rst);
    #100;
    @(posedge clk);
    while (1) begin

        // Always tri-state before each test
        _en <= 'h0000;
        @(posedge clk);

        // Set mode
        _mode = $random();
        if (_mode) begin
            // Set output
            $write("clk=%4d    Testing output mode:\n", clk_count);
            $fwrite(fid,"clk=%4d    Testing output mode:\n", clk_count);
            axi_wr(ps2_controllerx_MODE, 'hFFFF, _err);
            if (_err) begin
                fail_count++;
                $write("clk=%4d    FAILED! Error writing to mode register\n", clk_count);
                $fwrite(fid,"clk=%4d    FAILED! Error writing to mode register\n", clk_count);
            end
            else begin
                // TODO implement stimulus waveform
                _data = $random();
                #40;
                clk <= 0;
                #40;
                clk <= 1;
                #40;
            end
        end
    end
end




// Parity bit is the XOR of the 8 data bits
// 1 is odd parity
// have special parity register that is a single bit
// everytime we send a databit initialize paritybit to 1
// then for each bit we send we XOR the parity bit with the data bit
// once we've gone through all bits the parity bit will be correct
// not with start or stop bit on the data bits
// [start, 8 data, parity, stop] total bits is 11 bit only 8 are data

logic _parity; // Parity bit

initial begin
    _parity = 1; // Initialize parity bit to 1

    // Send start bit
    _data = 0;
    #40;
    clk <= 0;
    #40;
    clk <= 1;
    #40;

    // Send data bits
    for (int i = 0; i < 8; i++) begin
        _data = $random();
        _parity ^= _data; // XOR parity bit with data bit
        #40;
        clk <= 0;
        #40;
        clk <= 1;
        #40;
    end

    // Send parity bit
    _data = _parity;
    #40;
    clk <= 0;
    #40;
    clk <= 1;
    #40;

    // Send stop bit
    _data = 1;
    #40;
    clk <= 0;
    #40;
    clk <= 1;
    #40;
end




logic _valid; // Valid bit

// Initialize fail and pass counters
int fail_count = 0;
int pass_count = 0;

// At the end, the valid bit should go high
always @(posedge clk) begin
    if (_valid) begin
        pass_count++;
        $write("clk=%4d    PASSED! Valid bit is high\n", clk_count);
        $fwrite(fid,"clk=%4d    PASSED! Valid bit is high\n", clk_count);
    end
    else begin
        fail_count++;
        $write("clk=%4d    FAILED! Valid bit is low\n", clk_count);
        $fwrite(fid,"clk=%4d    FAILED! Valid bit is low\n", clk_count);
    end
end








    // Stimulus
    logic [PIN_COUNT-1:0] _ps2_controller;
    initial begin
        while (rst);
        #100;
        @(posedge clk);
        while (1) begin

            // Always tri-state before each test
            _en <= 'h0000;
            @(posedge clk)

            // Set mode
            _mode = $random();
            if (_mode) begin
                // Set output
                $write("clk=%4d    Testing output mode:\n", clk_count);
                $fwrite(fid,"clk=%4d    Testing output mode:\n", clk_count);
                axi_wr(ps2_controllerx_MODE, 'hFFFF, _err);
                if (_err) begin
                    fail_count++;
                    $write("clk=%4d    FAILED! Error writing to mode register\n", clk_count);
                    $fwrite(fid,"clk=%4d    FAILED! Error writing to mode register\n", clk_count);
                end
                else begin
                    // Write output register
                    _ps2_controller = $random() & 'hFFFF;
                    $write("clk=%4d        Writing 0x%04X to ODATA register\n", clk_count, _ps2_controller);
                    $fwrite(fid,"clk=%4d        Writing  0x%04X to ODATA register\n", clk_count, _ps2_controller);
                    axi_wr(ps2_controllerx_ODATA, _ps2_controller, _err);
                    if (_err) begin
                        fail_count++;
                        $write("clk=%4d    FAILED! Error writing to output register", clk_count);
                        $fwrite(fid,"clk=%4d    FAILED! Error writing to output register", clk_count);
                    end
                    else begin
                        // Check output
                        @(posedge clk)
                        $write("clk=%4d        Measured 0x%04X from ps2_controller pins\n", clk_count, io_pins);
                        $fwrite(fid,"clk=%4d        Measured 0x%04X from ps2_controller pins\n", clk_count, io_pins);
                        if (_ps2_controller != io_pins) begin
                            fail_count++;
                            $write("clk=%4d    FAILED! Register write and pin outputs do not match\n", clk_count);
                            $fwrite(fid,"clk=%4d    FAILED! Register write and pin outputs do not match\n", clk_count);
                        end
                        else begin
                            pass_count++;
                        end
                    end
                end
            end
            else begin
                // Set input
                $write("clk=%4d    Testing input mode:\n", clk_count);
                $fwrite(fid,"clk=%4d    Testing input mode:\n", clk_count);
                axi_wr(ps2_controllerx_MODE, 0, _err);
                if (_err) begin
                    fail_count++;
                    $write("clk=%4d    FAILED! Error writing to mode register\n", clk_count);
                    $fwrite(fid,"clk=%4d    FAILED! Error writing to mode register\n", clk_count);
                end
                else begin
                    // Check tri-state
                    if (io_pins != 'hzz) begin
                        fail_count++;
                        $write("clk=%4d    FAILED! One or more pins is not high-impedance\n", clk_count);
                        $fwrite(fid,"clk=%4d    FAILED! One or more pins is not high-impedance\n", clk_count);
                    end
                    else begin
                        
                        $write("clk=%4d        All input pins are high-impedance\n", clk_count);
                        $fwrite(fid,"clk=%4d        All input pins are high-impedance\n", clk_count);
                        // Enable testbench outputs
                        // Set input and enable
                        _out <= $random();
                        _en  <= 'hFFFF;
                        @(posedge clk);
                        $write("clk=%4d        Setting 0x%04X as input\n", clk_count, _out);
                        $fwrite(fid,"clk=%4d        Setting 0x%04X as input\n", clk_count, _out);
                        // Check input
                        axi_rd(ps2_controllerx_IDATA, _ps2_controller, _err);
                        if (_err) begin
                            fail_count++;
                            $write("clk=%4d    FAILED! Error reading input register\n", clk_count);
                            $fwrite(fid,"clk=%4d    FAILED! Error reading input register\n", clk_count);
                        end
                        else begin
                            if (_ps2_controller !== _out) begin
                                fail_count++;
                                $write("clk=%4d    FAILED! IDATA register contains %04X but should be %04X\n",
                                    clk_count, _ps2_controller, _out);
                                $fwrite(fid,"clk=%4d    FAILED! IDATA register contains %04X but should be %04X\n",
                                    clk_count, _ps2_controller, _out);
                            end
                            else begin
                                pass_count++;
                                $write("clk=%4d        IDATA read 0x%04X\n", clk_count, _ps2_controller);
                                $fwrite(fid,"clk=%4d        IDATA read 0x%04X\n", clk_count, _ps2_controller);
                            end
                        end
                    end
                end
            end

            $write("\n");
            $fwrite(fid,"\n");

        end
    end


    // End Simulation
    always @(posedge clk) begin
        clk_count <= clk_count + 1;
        if (clk_count >= MAX_CYCLES) begin
            if (fail_count || (!pass_count)) begin
                $write("\n\nFAILED!    %3d/%3d\n", fail_count, fail_count+pass_count);
                $fwrite(fid,"\n\nFailed!    %3d/%3d\n", fail_count, fail_count+pass_count);
            end
            else begin
                $write("\n\nPASSED all %3d tests\n", pass_count);
                $fwrite(fid,"\n\nPASSED all %3d tests\n", pass_count);
            end
            $fclose(fid);
            $finish();
        end
    end

endmodule
