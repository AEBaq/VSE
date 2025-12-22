/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : ble_usb_agent.sv
Author   : Yann Thoma
Date     : 28.11.2022

Context  : Lab for the verification of a BLE analyzer

********************************************************************************
Description : This file contains the output agent, getting information from the
              USB packets.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   28.11.2022  YTA        Initial version

*******************************************************************************/

`ifndef BLE_USB_AGENT_SV
`define BLE_USB_AGENT_SV

class ble_usb_agent;


    int testcase;

    ble_usb_monitor monitor;

    virtual ble_usb_itf vif;

    task build;

        monitor = new;

        monitor.testcase = testcase;
    
    endtask : build

    task connect;

        monitor.vif = vif;

    endtask : connect

    task run;

        fork
            monitor.run();
        join;

    endtask : run


endclass : ble_usb_agent


`endif // BLE_USB_AGENT_SV