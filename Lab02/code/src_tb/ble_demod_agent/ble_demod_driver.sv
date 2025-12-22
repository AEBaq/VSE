/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : ble_demod_driver.sv
Author   : Yann Thoma
Date     : 28.11.2022

Context  : Lab for the verification of a BLE analyzer

********************************************************************************
Description : This file contains the driver representing the demodulator
              behavior

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   28.11.2022  YTA        Initial version

*******************************************************************************/

`ifndef BLE_DEMOD_DRIVER_SV
`define BLE_DEMOD_DRIVER_SV


class ble_demod_driver;

    int testcase;

    ble_fifo_t sequencer_to_driver_fifo;
    ble_fifo_t driver_to_scoreboard_fifo;

    virtual ble_demod_itf vif;

    task drive_packet(ble_packet packet);
        objections_pkg::objection::get_inst().raise();
//        packet.isAdv = 1;
//        void'(packet.randomize());
        vif.valid_i <= 1;
        for(int i = packet.sizeToSend - 1;i>=0; i--) begin
            vif.serial_i <= packet.dataToSend[i];
            vif.channel_i <= 0;
            if (!packet.isAdv)
                vif.channel_i <= 2;
            vif.rssi_i <= 4;
            @(posedge vif.clk_i);
        end
        // Send the packet to the scoreboard
        driver_to_scoreboard_fifo.put(packet);
        vif.serial_i <= 0;
        vif.valid_i <= 0;
        vif.channel_i <= 0;
        vif.rssi_i <= 0;
        for(int i=0; i<9; i++)
            @(posedge vif.clk_i);
        objections_pkg::objection::get_inst().drop();
    endtask

    task run;
        automatic ble_packet packet;
        packet = new;
        `LOG_INFO(svlogger::getInstance(), "Driver : start");

        vif.serial_i <= 0;
        vif.valid_i <= 0;
        vif.channel_i <= 0;
        vif.rssi_i <= 0;
        vif.rst_i <= 1;
        @(posedge vif.clk_i);
        vif.rst_i <= 0;
        @(posedge vif.clk_i);
        @(posedge vif.clk_i);

        // Cette fonction mérite d'être mieux écrite

        for(int i=0;i<10;i++) begin
            sequencer_to_driver_fifo.get(packet);
            drive_packet(packet);
            `LOG_INFO(svlogger::getInstance(), "I got a packet!!!!");
        end

        for(int i=0;i<99;i++)
            @(posedge vif.clk_i);

        `LOG_INFO(svlogger::getInstance(), "Driver : end");
    endtask : run

endclass : ble_demod_driver



`endif // BLE_DEMOD_DRIVER_SV
