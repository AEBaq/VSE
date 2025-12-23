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
        byte unsigned received_bytes[$]; // FIFO d'octets reçus
        forever begin
            // Wait pour clk
            @(posedge vif.clk_i);

            // Detecte le début d'un paquet
            if (vif.frame_o) begin
                received_bytes = {}; // Clear la FIFO
                
                // Récupération des octets tant que frame_o est à 1
                while (vif.frame_o) begin
                    if (vif.valid_i) begin
                        received_bytes.push_back(vif.data_o);
                    end
                    @(posedge vif.clk_i);
                end

                // On a fini avec la frame, on peut construire le paquet USB
                if (received_bytes.size() >= 10) begin // Taille minimale d'un paquet USB = 10 octets
                    usb_packet = new;
                    usb_packet.from_bytes(received_bytes);

                    `LOG_INFO2(svlogger::getInstance(), "Monitor : USB packet received %s", usb_packet.psprint());

                    // Send au scoreboard
                    monitor_to_scoreboard_fifo.put(usb_packet);
                end
                else begin
                    `LOG_WARNING2(svlogger::getInstance(), "Monitor : Received USB packet too small to be valid, size = %d", received_bytes.size());
                end
            end
        end // forever


    `LOG_INFO(svlogger::getInstance(), "Monitor : end");
    endtask : run

endclass : ble_usb_monitor

`endif // BLE_USB_MONITOR_SV
