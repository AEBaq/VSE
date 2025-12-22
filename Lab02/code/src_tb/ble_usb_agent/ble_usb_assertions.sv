

`include "ble_usb_itf.sv"

module ble_usb_assertions(ble_usb_itf vif);

    // Maybe not the best assertion ever
    assert_failing: assert property ( @(posedge vif.clk_i) (!vif.frame_o));

endmodule
