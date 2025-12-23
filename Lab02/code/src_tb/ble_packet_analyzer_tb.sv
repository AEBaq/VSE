/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : ble_packet_analyzer_tb.sv
Author   : Yann Thoma
Date     : 28.11.2022

Context  : Lab for the verification of a BLE analyzer

********************************************************************************
Description : This file contains the testbench instiantiating the DUV and
              creating the simulation environment.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   28.11.2022  YTA        Initial version

*******************************************************************************/

`include "svlogger.sv"
`include "objections_pkg.sv"
`include "ble_demod_agent/ble_packet.sv"
`include "ble_demod_agent/ble_demod_itf.sv"
`include "ble_demod_agent/ble_demod_sequencer.sv"
`include "ble_demod_agent/ble_demod_driver.sv"
`include "ble_demod_agent/ble_demod_agent.sv"
`include "ble_demod_agent/ble_demod_assertions.sv"

`include "ble_usb_agent/ble_usb_itf.sv"
`include "ble_usb_agent/ble_usb_packet.sv"
`include "ble_usb_agent/ble_usb_monitor.sv"
`include "ble_usb_agent/ble_usb_agent.sv"
`include "ble_usb_agent/ble_usb_assertions.sv"

`include "ble_analyzer_scoreboard.sv"
`include "ble_analyzer_env.sv"


module packet_analyzer_tb#(int TESTCASE = 0, int ERRNO = 0);

    ble_demod_itf input_itf();
    ble_usb_itf output_itf();

    ble_demod_assertions input_assertions(
        .vif(input_itf)
    );

    ble_usb_assertions output_assertions(
        .vif(output_itf)
    );

    ble_packet_analyzer#(ERRNO,0) duv(
        .clk_i(input_itf.clk_i),
        .rst_i(input_itf.rst_i),
        .serial_i(input_itf.serial_i),
        .valid_i(input_itf.valid_i),
        .channel_i(input_itf.channel_i),
        .rssi_i(input_itf.rssi_i),
        .data_o(output_itf.data_o),
        .valid_o(output_itf.valid_o),
        .frame_o(output_itf.frame_o)
    );

    // clock generation
    always #5 input_itf.clk_i = ~input_itf.clk_i;

    assign output_itf.clk_i = input_itf.clk_i;

    initial begin
        ble_analyzer_env env;

        void'(svlogger::getInstance("logger", `SVL_VERBOSE_DEBUG, `SVL_ROUTE_TERM));

        `LOG_INFO(svlogger::getInstance(), "Starting simulation");

        objections_pkg::objection::get_inst().set_drain_time(1000ns);

        // Building the entire environment
        env = new;
        env.input_itf = input_itf;
        env.output_itf = output_itf;
        env.testcase = TESTCASE;
        env.build();
        env.connect();
        env.run();

        `LOG_INFO(svlogger::getInstance(), "Ending simulation");
        $finish;
    end

endmodule
