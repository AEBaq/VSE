/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : ble_packet.sv
Author   : Yann Thoma
Date     : 28.11.2022

Context  : Lab for the verification of a BLE analyzer

********************************************************************************
Description : This file contains the definition of the BLE packets in terms of
              a transaction.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   28.11.2022  YTA        Initial version

*******************************************************************************/

`ifndef BLE_PACKET_SV
`define BLE_PACKET_SV


class ble_packet;

    logic[(64*8+16+32+8):0] dataToSend;
    int sizeToSend;

    logic isAdv;
    logic dataValid = 1;
    rand logic[31:0] addr;
    rand logic[15:0] header;
    rand logic[(64*8):0] rawData;
    rand logic[5:0] size; // dataLength
    rand logic[7:0] rssi;

    // Canal de transmission
    rand logic[6:0] channel; // 0 to 78

    // deviceAddr
    rand logic[31:0] deviceAddr;


    // Not sure this is totally right...
    constraint size_range {
      //size inside {[6:10]};
      if (isAdv) {
        size inside {[4:15]}; // Advertising packet : 4 to 15 bytes
      } else {
        size inside {[0:63]}; // Data packets : 0 to 63 bytes
      }
    }

    constraint channel_range {
        if (isAdv) {
            channel inside {0, 24, 78}; // Advertising channels
        } else {
            channel inside {[1:23], [25:77]}; // Data channels
            channel[0] = 0; // even channel
        }
    }

    function string psprint();
        $sformat(psprint, "BlePacket, isAdv : %b, addr= %h, time = %t\nsizeSend = %d, dataSend = %h\n",
                                                        this.isAdv, this.addr, $time,sizeToSend,dataToSend);
    endfunction : psprint

    function void post_randomize();

        logic[7:0] preamble=8'h55;

        // Initialisation des données à envoyer
        dataToSend = 0;
        sizeToSend=size*8+16+32+8;

        header = 16'h0000; // Initialisation de l'en-tête à 0 pour les bits non utilisés
        // Cas de l'envoi d'un paquet d'advertizing
        if (isAdv == 1) begin
            // On pourrait également ajouter une contrainte pour addr afin d'enlever cette ligne, afin de pas randomizer inutilement
            addr = 32'h12345678; 
            header[3:0] = size[3:0];
            sizeToSend = header[3:0] * 8 + 16 + 32 + 8; // Header[3:0] contient la taille des données pour les paquets d'advertizing
            // DeviceAddr = 0. Pour l'exemple
            // Ici, on a randomizé deviceAddr uniquement lorsqu'on envoie un paquet d'advertizing
            for(int i = 0; i < 32; i++)
                rawData[size*8-1-i] = deviceAddr[i];
        end

        // Cas de l'envoi d'un paquet de données
        else if (isAdv == 0) begin
            // Peut-être que l'adresse devra être définie d'une certaine manière.
            // TODO : Il faudrait récupérer une adresse définie dans un paquet d'advertizing déjà envoyé
            addr = 0;
            header[5:0] = size[5:0];
            sizeToSend = header[5:0] * 8 + 16 + 32 + 8;
        end


        // Affectation des données à envoyer
        // Préambule
        for(int i = 0; i < 8; i++)
            dataToSend[sizeToSend-8+i]=preamble[i];

        // Adresse
        for(int i = 0; i < 32; i++)
            dataToSend[sizeToSend-8-32+i]=addr[i];

        `LOG_INFO2(svlogger::getInstance(), "Sending packet with address %h\n",addr);

        // Header / En-tête
        for(int i = 0; i < 16; i++)
            dataToSend[sizeToSend-8-32-16+i]=header[i];

        // dataLength
        for(int i = 0; i < 6; i++)
            dataToSend[sizeToSend-8-32-16+i]=size[i];

        // Données
        for(int i = 0; i < size * 8; i++) 
            dataToSend[sizeToSend-8-32-16-1-i]=rawData[size*8-1-i];

        if (isAdv) begin
            logic[31:0] ad;
            for(int i = 0; i < 32; i++)
                ad[i] = dataToSend[sizeToSend-8-32-16-32+i];
            `LOG_INFO2(svlogger::getInstance(), "Advertising with address %h\n",ad);
        end
    endfunction : post_randomize

endclass : ble_packet


typedef mailbox #(ble_packet) ble_fifo_t;

`endif // BLE_PACKET_SV
