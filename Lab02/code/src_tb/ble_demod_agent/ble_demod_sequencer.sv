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

    logic[31:0] known_addr[]; // Liste des adresses connues, max 16 addresses

    function void add_addr(logic[31:0] addr);
        if (known_addr.size() >= 16) begin
            known_addr.pop_front(); // Supprimer la plus ancienne adresse
        end
        known_addr.push_back(addr);
    endfunction : add_addr

    // Testcase 0 : envoie un advertising packet suivi de 9 data packets
    task testcase0;
        automatic ble_packet packet;
        `LOG_INFO(svlogger::getInstance(), "Sequencer : start");

        // Envoie un advertising packet
        packet = new;
        packet.isAdv = 1;
        void'(packet.randomize());

        add_addr(packet.deviceAddr); // Ajouter l'adresse de l'advertising packet aux adresses connues

        sequencer_to_driver_fifo.put(packet);

        `LOG_INFO(svlogger::getInstance(), "I sent an advertising packet !");

        // Envoie plusieurs data packets
        for(int i = 0; i < 9; i++) begin

            packet = new;
            packet.isAdv = 0;
            packet.addr = known_addr[$urandom_range(0, known_addr.size() - 1)]; // Choisir une adresse connue au hasard
            void'(packet.randomize());

            sequencer_to_driver_fifo.put(packet);

            `LOG_INFO(svlogger::getInstance(), "I sent a packet !");
        end
        `LOG_INFO(svlogger::getInstance(), "Sequencer : end");
    endtask

    // Testcase 1 : envoie plusieurs advertising packet suivi de plusieurs data packets
    task testcase1;
        automatic ble_packet packet;
        `LOG_INFO(svlogger::getInstance(), "Sequencer : start");

        // Envoie plusieurs advertising packet
        for (int i = 0; i < 5; i++) begin
        packet = new;
        packet.isAdv = 1;
        void'(packet.randomize());

        add_addr(packet.deviceAddr); // Ajouter l'adresse de l'advertising packet aux adresses connues

        sequencer_to_driver_fifo.put(packet);

        `LOG_INFO(svlogger::getInstance(), "I sent an advertising packet !");
        end

        // Envoie plusieurs data packets
        for (int i = 0; i < 10; i++) begin
            packet = new;
            packet.isAdv = 0;
            packet.addr = known_addr[$urandom_range(0, known_addr.size() - 1)]; // Choisir une adresse connue au hasard
            void'(packet.randomize());
            sequencer_to_driver_fifo.put(packet);

            `LOG_INFO(svlogger::getInstance(), "I sent a packet !");
        end

        `LOG_INFO(svlogger::getInstance(), "Sequencer : end");
    endtask

    // Testcase 2 : envoie de plusieurs paquets de type aléatoires
    task testcase2;
        automatic ble_packet packet;
        `LOG_INFO(svlogger::getInstance(), "Sequencer : start");

        // Envoie un advertising packet (obligatoire)
        packet = new;
        packet.isAdv = 1;
        void'(packet.randomize());

        add_addr(packet.deviceAddr); // Ajouter l'adresse de l'advertising packet aux adresses connues

        sequencer_to_driver_fifo.put(packet);

        `LOG_INFO(svlogger::getInstance(), "I sent an advertising packet !");

        // Envoie plusieurs packet aléatoire
    
        automatic int num_packets = $urandom_range(5, 15);

        for(int i = 0; i < num_packets; i++) begin

            packet = new;
            packet.isAdv = ($urandom_range(0, 8) % 3 == 0); // Choisir aléatoirement entre advertising et data packet (1/3 de chance d'être un advertising packet)
            
            if (!packet.isAdv) begin
                packet.addr = known_addr[$urandom_range(0, known_addr.size() - 1)]; // Choisir une adresse connue au hasard
            end
            
            void'(packet.randomize());

            if (packet.isAdv) begin
                add_addr(packet.deviceAddr); // Ajouter l'adresse de l'advertising packet aux adresses connues
            end

            sequencer_to_driver_fifo.put(packet);

            `LOG_INFO(svlogger::getInstance(), "I sent a packet !");
        end
        `LOG_INFO(svlogger::getInstance(), "Sequencer : end");
    endtask

    task run;
        case (testcase)
            0: testcase0();
            1: testcase1();
            2: testcase2();
            3: testcase3();
            default: `LOG_ERROR2(svlogger::getInstance(), "Sequencer: Testcase %d not defined\n", testcase);
        endcase
    endtask : run

endclass : ble_demod_sequencer


`endif // BLE_DEMOD_SEQUENCER_SV
