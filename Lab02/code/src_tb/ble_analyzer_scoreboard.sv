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

    // Valeur pour monitorer les paquets
    int packet_sent = 0;
    int packet_received = 0;
    int packet_matched = 0;
    int packet_error = 0;

    // Compare un paquet BLE avec un paquet USB, renvoie 1 si ils correspondent, 0 sinon
    function bit compare_packets(ble_packet ble_pkt, ble_usb_packet usb_pkt);
        bit hasErr = 0;

        // Comparer les champs importants des deux paquets
        if (ble_pkt.isAdv !== usb_pkt.isAdv) begin
            `LOG_ERROR3(svlogger::getInstance(), "Packet type mismatch: BLE isAdv = %b, USB isAdv = %b\n", ble_pkt.isAdv, usb_pkt.isAdv);
            hasErr = 1;
        end

        if (ble_pkt.addr !== usb_pkt.addr) begin
            `LOG_ERROR3(svlogger::getInstance(), "Packet address mismatch: BLE addr = %h, USB addr = %h\n", ble_pkt.addr, usb_pkt.addr);
            hasErr = 1;
        end

        if (ble_pkt.channel !== usb_pkt.channel) begin
            `LOG_ERROR3(svlogger::getInstance(), "Packet channel mismatch: BLE channel = %d, USB channel = %d\n", ble_pkt.channel, usb_pkt.channel);
            hasErr = 1;
        end

        if (ble_pkt.size !== usb_pkt.size) begin
            `LOG_ERROR3(svlogger::getInstance(), "Packet size mismatch: BLE size = %d, USB size = %d\n", ble_pkt.size, usb_pkt.size);
            hasErr = 1;
        end

        if (ble_pkt.rawData[ble_pkt.size*8-1:0] !== usb_pkt.data[usb_pkt.size*8-1:0]) begin
            `LOG_ERROR3(svlogger::getInstance(), "Packet data mismatch\n");
            hasErr = 1;
        end

        return !hasErr;
    endfunction : compare_packets

    task run;
        automatic ble_packet ble_packet = new;
        automatic ble_usb_packet usb_packet = new;

        `LOG_INFO(svlogger::getInstance(), "Scoreboard : Start");

        for(int i = 0; i < 10; i++) begin
            // Packet du driver
            ble_to_scoreboard_fifo.get(ble_packet);
            packet_sent++;
            `LOG_INFO(svlogger:: getInstance(), "Scoreboard: BLE packet received from driver\n");

            // Packet USB du monitor
            monitor_to_scoreboard_fifo.get(usb_packet);
            packet_received++;
            `LOG_INFO(svlogger:: getInstance(), "Scoreboard: USB packet received from monitor\n");

            // Check that everything is fine
            if (compare_packets(ble_packet, usb_packet)) begin
                packet_matched++;
                `LOG_INFO(svlogger::getInstance(), "Scoreboard: Packets matched\n");
            end
            else begin
                packet_error++;
                `LOG_ERROR(svlogger::getInstance(), "Scoreboard: Packet mismatch\n");
            end
        end

        `LOG_INFO5(svlogger::getInstance(), "Scoreboard : Summary\n  - Packets sent: %d\n  - Packets received: %d\n  - Packets matched: %d\n  - Packet errors: %d",
                      packet_sent, packet_received, packet_matched, packet_error);

        `LOG_INFO(svlogger::getInstance(), "Scoreboard : End");
    endtask : run

endclass : ble_analyzer_scoreboard

`endif // BLE_ANALYZER_SCOREBOARD_SV
