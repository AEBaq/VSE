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

    // Testcase 3 : Taille min des données
    task run_testcase_3;
        automatic ble_packet packet;
        
        // Advertising avec taille min : 4 octets
        packet = new;
        packet.isAdv = 1;
        void'(packet.randomize() with { size == 4; });
        add_addr(packet.deviceAddr);
        sequencer_to_driver_fifo.put(packet);
        `LOG_INFO2(svlogger:: getInstance(), "Testcase3: Adv size min = %d", packet.size);
        
        // Data avec taille min : 0 octet
        packet = new;
        packet. isAdv = 0;
        packet.addr = known_addr[$urandom_range(0, known_addr.size() - 1)];
        void'(packet. randomize() with { size == 0; });
        sequencer_to_driver_fifo.put(packet);
        `LOG_INFO2(svlogger::getInstance(), "Testcase3: Data size min = %d", packet.size);
    endtask

    // Testcase 4 :  Taille max des données
    task run_testcase_4;
        automatic ble_packet packet;
        
        // Advertising avec taille max : 15 octets
        packet = new;
        packet.isAdv = 1;
        void'(packet.randomize() with { size == 15; });
        add_addr(packet.deviceAddr);
        sequencer_to_driver_fifo.put(packet);
        `LOG_INFO2(svlogger:: getInstance(), "Testcase4: Adv size max = %d", packet.size);
        
        // Data avec taille max : 63 octets
        packet = new;
        packet.isAdv = 0;
        packet.addr = known_addr[$urandom_range(0, known_addr.size() - 1)];
        void'(packet.randomize() with { size == 63; });
        sequencer_to_driver_fifo. put(packet);
        `LOG_INFO2(svlogger::getInstance(), "Testcase4: Data size max = %d", packet.size);
    endtask

    // Testcase 5 : Test limite FIFO 16 adresses
    task run_testcase_5;
        automatic ble_packet packet;
        logic [31:0] first_addr;
        
        // Envoyer 17 advertising (le 18e remplace le 1er)
        for (int i = 0; i < 17; i++) begin
            packet = new;
            packet.isAdv = 1;
            void'(packet.randomize());
            
            if (i == 0) first_addr = packet.deviceAddr;
            
            add_addr(packet.deviceAddr);
            sequencer_to_driver_fifo.put(packet);
            `LOG_INFO3(svlogger:: getInstance(), "Testcase5: Adv %d, deviceAddr = %h", i, packet.deviceAddr);
        end
        
        // Envoyer un data avec la 2ème adresse
        packet = new;
        packet.isAdv = 0;
        packet.addr = known_addr[1];  // Mtn c'est la 2ème adresse
        void'(packet. randomize());
        sequencer_to_driver_fifo.put(packet);
        `LOG_INFO2(svlogger::getInstance(), "Testcase5: Data with addr = %h", packet.addr);
        
        // Tenter d'utiliser la première adresse (devrait échouer si DUV correct)
        packet = new;
        packet.isAdv = 0;
        packet.addr = first_addr;  // Cette adresse a été supprimée
        void'(packet.randomize());
        sequencer_to_driver_fifo. put(packet);
        `LOG_INFO2(svlogger::getInstance(), "Testcase5: Data with addr = %h (delete addr)", packet.addr);
    endtask

    // Testcase 6 :  Canaux advertising uniquement (0, 24, 78)
    task run_testcase_6;
        automatic ble_packet packet;
        int adv_channels[] = '{0, 24, 78};
        
        for (int i = 0; i < 3; i++) begin
            packet = new;
            packet.isAdv = 1;
            void'(packet.randomize() with { channel == adv_channels[i]; });
            add_addr(packet.deviceAddr);
            sequencer_to_driver_fifo.put(packet);
            `LOG_INFO2(svlogger::getInstance(), "Testcase6: Adv on channel %d", packet.channel);
        end
    endtask

    // Testcase 7 : Canaux data uniquement (pairs sauf 0, 24, 78)
    task run_testcase_7;
        automatic ble_packet packet;
        
        // D'abord un advertising
        packet = new;
        packet.isAdv = 1;
        void'(packet.randomize());
        add_addr(packet. deviceAddr);
        sequencer_to_driver_fifo.put(packet);
        
        // Paquets data sur différents canaux
        for (int ch = 2; ch <= 76; ch += 10) begin
            if (ch != 24) begin  // 24 est advertising
                packet = new;
                packet.isAdv = 0;
                packet.addr = known_addr[$urandom_range(0, known_addr.size() - 1)];
                void'(packet.randomize() with { channel == ch; });
                sequencer_to_driver_fifo.put(packet);
                `LOG_INFO2(svlogger::getInstance(), "Testcase7: Data on channel %d", packet.channel);
            end
        end
    endtask

    // Testcase 8 : Valeurs extrêmes de RSSI
    task run_testcase_8;
        automatic ble_packet packet;
        
        // Advertising
        packet = new;
        packet.isAdv = 1;
        void'(packet.randomize() with { rssi == 8'h00; });  // RSSI min
        add_addr(packet. deviceAddr);
        sequencer_to_driver_fifo.put(packet);
        `LOG_INFO2(svlogger::getInstance(), "Testcase8: Adv RSSI = %d", packet. rssi);
        
        // Data avec différents RSSI
        packet = new;
        packet.isAdv = 0;
        packet.addr = known_addr[$urandom_range(0, known_addr.size() - 1)];
        void'(packet. randomize() with { rssi == 8'hFF; });  // RSSI max
        sequencer_to_driver_fifo.put(packet);
        `LOG_INFO2(svlogger::getInstance(), "Testcase8: Data RSSI max = %d", packet.rssi);
        
        packet = new;
        packet.isAdv = 0;
        packet.addr = known_addr[$urandom_range(0, known_addr.size() - 1)];
        void'(packet.randomize() with { rssi == 8'h80; });  // RSSI moyen
        sequencer_to_driver_fifo.put(packet);
        `LOG_INFO2(svlogger::getInstance(), "Testcase8: Data RSSI moyen = %d", packet.rssi);
    endtask

    // Testcase 9 : Data sans advertising préalable (Pour tester si le DUV rejette correctement)=
    task run_testcase_9;
        automatic ble_packet packet;
        
        // Utiliser une adresse "inventée"
        packet = new;
        packet.isAdv = 0;
        packet.addr = 32'hDEADBEEF;  // Adresse invalide
        void'(packet. randomize());
        sequencer_to_driver_fifo.put(packet);
        `LOG_INFO2(svlogger::getInstance(), "Testcase9: Data with invalid addr %h", packet.addr);
        
        // Maintenant envoyer un advertising
        packet = new;
        packet.isAdv = 1;
        void'(packet. randomize());
        add_addr(packet.deviceAddr);
        sequencer_to_driver_fifo.put(packet);
        
        // Puis un data valide
        packet = new;
        packet.isAdv = 0;
        packet.addr = known_addr[$urandom_range(0, known_addr.size() - 1)];
        void'(packet.randomize());
        sequencer_to_driver_fifo.put(packet);
        `LOG_INFO2(svlogger::getInstance(), "Testcase9: Data with valid addr %h", packet.addr);
    endtask

    // Testcase 10 : Tous les canaux advertising
    task run_testcase_10;
        automatic ble_packet packet;
        
        // Canal 0 (2402 MHz)
        packet = new;
        packet.isAdv = 1;
        void'(packet.randomize() with { channel == 0; });
        add_addr(packet. deviceAddr);
        sequencer_to_driver_fifo.put(packet);
        `LOG_INFO(svlogger::getInstance(), "Testcase10: Adv canal 0");
        
        // Canal 24 (2426 MHz)
        packet = new;
        packet.isAdv = 1;
        void'(packet. randomize() with { channel == 24; });
        add_addr(packet.deviceAddr);
        sequencer_to_driver_fifo.put(packet);
        `LOG_INFO(svlogger::getInstance(), "Testcase10: Adv canal 24");
        
        // Canal 78 (2480 MHz)
        packet = new;
        packet.isAdv = 1;
        void'(packet.randomize() with { channel == 78; });
        add_addr(packet.deviceAddr);
        sequencer_to_driver_fifo.put(packet);
        `LOG_INFO(svlogger::getInstance(), "Testcase10: Adv canal 78");
        
        // Data pour chaque adresse
        for (int i = 0; i < 3; i++) begin
            packet = new;
            packet.isAdv = 0;
            packet.addr = known_addr[i];
            void'(packet.randomize());
            sequencer_to_driver_fifo.put(packet);
        end
    endtask

    task run;
        case (testcase)
            0: testcase0();
            1: testcase1();
            2: testcase2();
            3: testcase3();
            4: testcase4();
            5: testcase5();
            6: testcase6();
            7: testcase7();
            8: testcase8();
            9: testcase9();
            10: testcase10();
            default: begin
                `LOG_ERROR2(svlogger::getInstance(), "Sequencer: Testcase %d not defined\n", testcase);
            end
        endcase
    endtask : run

endclass : ble_demod_sequencer


`endif // BLE_DEMOD_SEQUENCER_SV
