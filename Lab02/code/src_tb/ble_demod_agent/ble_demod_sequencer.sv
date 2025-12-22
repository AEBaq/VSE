/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : ble_demod_sequencer.sv
Author   : Yann Thoma
Date     : 28.11.2022

Context  : Lab for the verification of a BLE analyzer

********************************************************************************
Description : This file contains the sequencer responsible for generating the
              BLE packets that have to be played.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   28.11.2022  YTA        Initial version

*******************************************************************************/

`ifndef BLE_DEMOD_SEQUENCER_SV
`define BLE_DEMOD_SEQUENCER_SV

class ble_demod_sequencer;

    int testcase;
    
    ble_fifo_t sequencer_to_driver_fifo;

    task run;
        automatic ble_packet packet;
        `LOG_INFO(svlogger::getInstance(), "Sequencer : start");

        packet = new;
        packet.isAdv = 1;
        void'(packet.randomize());

        sequencer_to_driver_fifo.put(packet);

        `LOG_INFO(svlogger::getInstance(), "I sent an advertising packet!!!!");


        for(int i=0;i<9;i++) begin

            packet = new;
            packet.isAdv = 0;
            void'(packet.randomize());

            sequencer_to_driver_fifo.put(packet);

            `LOG_INFO(svlogger::getInstance(), "I sent a packet!!!!");
        end
        `LOG_INFO(svlogger::getInstance(), "Sequencer : end");
    endtask : run

endclass : ble_demod_sequencer


`endif // BLE_DEMOD_SEQUENCER_SV
