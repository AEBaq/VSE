
`include "ble_demod_itf.sv"

module ble_demod_assertions(ble_demod_itf vif);

    // Maybe not the best assertion ever
    assert_failing: assert property ( @(posedge vif.clk_i) (!vif.valid_i));

endmodule
