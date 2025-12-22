/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : ble_demod_agent.sv
Author   : Yann Thoma
Date     : 28.11.2022

Context  : Lab for the verification of a BLE analyzer

********************************************************************************
Description : This file contains the input agent, that is the one generating
              the BLE packets

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   28.11.2022  YTA        Initial version

*******************************************************************************/

`ifndef BLE_DEMOD_AGENT_SV
`define BLE_DEMOD_AGENT_SV

class ble_demod_agent;


    int testcase;

    ble_demod_sequencer sequencer;
    ble_demod_driver driver;

    virtual ble_demod_itf vif;

    ble_fifo_t sequencer_to_driver_fifo;
    ble_fifo_t ble_demod_to_scoreboard_fifo;

    task build;
        sequencer_to_driver_fifo     = new(10);

        sequencer = new;
        driver = new;

        sequencer.testcase = testcase;
        driver.testcase = testcase;

    endtask : build

    task connect;

        sequencer.sequencer_to_driver_fifo = sequencer_to_driver_fifo;
        driver.sequencer_to_driver_fifo = sequencer_to_driver_fifo;
        driver.driver_to_scoreboard_fifo = ble_demod_to_scoreboard_fifo;

        driver.vif = vif;

    endtask : connect


    task run;

        fork
            sequencer.run();
            driver.run();
        join;

    endtask : run


endclass : ble_demod_agent


`endif // BLE_DEMOD_AGENT_SV