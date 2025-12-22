/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : ble_usb_monitor.sv
Author   : Yann Thoma
Date     : 28.11.2022

Context  : Lab for the verification of a BLE analyzer

********************************************************************************
Description : This file contains the monitor responsible for observing the
              output of the BLE analyzer and building the output transactions.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   28.11.2022  YTA        Initial version

*******************************************************************************/

`ifndef BLE_USB_MONITOR_SV
`define BLE_USB_MONITOR_SV


class ble_usb_monitor;

    int testcase;

    virtual ble_usb_itf vif;

    usb_fifo_t monitor_to_scoreboard_fifo;

    task run;
        ble_usb_packet usb_packet = new;
        `LOG_INFO(svlogger::getInstance(), "Monitor : start");


/*
        while (1) begin
            // Récupération d'un paquet USB, et transmission au scoreboard


            monitor_to_scoreboard_fifo.put(usb_packet);
        end
*/

    `LOG_INFO(svlogger::getInstance(), "Monitor : end");
    endtask : run

endclass : ble_usb_monitor

`endif // BLE_USB_MONITOR_SV
