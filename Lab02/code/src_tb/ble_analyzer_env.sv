/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : ble_analyzer_env.sv
Author   : Yann Thoma
Date     : 28.11.2022

Context  : Lab for the verification of a BLE analyzer

********************************************************************************
Description : This file contains the environment that instantiates the input
              and output agent, as well as the scoreboard

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   28.11.2022  YTA        Initial version

*******************************************************************************/

`ifndef BLE_ANALYZER_ENV_SV
`define BLE_ANALYZER_ENV_SV

class ble_analyzer_env;

    int testcase;

    ble_demod_agent input_agent;
    ble_usb_agent output_agent;

    ble_analyzer_scoreboard scoreboard;

    virtual ble_demod_itf input_itf;
    virtual ble_usb_itf output_itf;

    ble_fifo_t ble_to_scoreboard_fifo;
    usb_fifo_t monitor_to_scoreboard_fifo;

    task build;
        ble_to_scoreboard_fifo = new(10);
        monitor_to_scoreboard_fifo   = new(100);

        input_agent = new;
        output_agent = new;
        scoreboard = new;

        input_agent.testcase = testcase;
        output_agent.testcase = testcase;
        scoreboard.testcase = testcase;

        input_agent.vif = input_itf;
        output_agent.vif = output_itf;

        input_agent.build();
        output_agent.build();
    
    endtask : build

    task connect;

        input_agent.ble_demod_to_scoreboard_fifo = ble_to_scoreboard_fifo;
        scoreboard.ble_to_scoreboard_fifo = ble_to_scoreboard_fifo;

        output_agent.monitor.monitor_to_scoreboard_fifo = monitor_to_scoreboard_fifo;
        scoreboard.monitor_to_scoreboard_fifo = monitor_to_scoreboard_fifo;

        input_agent.connect();
        output_agent.connect();

    endtask : connect

    task run;

        fork
            begin
                fork
                    input_agent.run();
                    output_agent.run();
                    scoreboard.run();
                    begin
                        while (1) begin
                            @(posedge input_itf.clk_i);
                        end
                    end
                join;
            end
            begin
                while (!objections_pkg::objection::get_inst().should_finish()) begin
                    @(posedge input_itf.clk_i);
                end
            end
        join_any;

    endtask : run

endclass : ble_analyzer_env


`endif // BLE_ANALYZER_ENV_SV
