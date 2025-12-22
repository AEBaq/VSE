/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : ble_analyzer_scoreboard.sv
Author   : Yann Thoma
Date     : 28.11.2022

Context  : Lab for the verification of a BLE analyzer

********************************************************************************
Description : This file contains the scoreboard responsible for comparing the
              input/output transactions

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   28.11.2022  YTA        Initial version

*******************************************************************************/

`ifndef BLE_ANALYZER_SCOREBOARD_SV
`define BLE_ANALYZER_SCOREBOARD_SV


class ble_analyzer_scoreboard;

    int testcase;
    
    ble_fifo_t ble_to_scoreboard_fifo;
    usb_fifo_t monitor_to_scoreboard_fifo;

    task run;
        automatic ble_packet ble_packet = new;
        automatic ble_usb_packet usb_packet = new;

        `LOG_INFO(svlogger::getInstance(), "Scoreboard : Start");


        for(int i=0; i< 10; i++) begin
            ble_to_scoreboard_fifo.get(ble_packet);
//            monitor_to_scoreboard_fifo.get(usb_packet);
            // Check that everything is fine

        end

        `LOG_INFO(svlogger::getInstance(), "Scoreboard : End");
    endtask : run

endclass : ble_analyzer_scoreboard

`endif // BLE_ANALYZER_SCOREBOARD_SV
